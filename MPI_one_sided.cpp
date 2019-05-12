#include <mpi.h>
#include <stdio.h>
#include <math.h>
#include <stdlib.h>     
#include <time.h>       



void swap(short &s1, short &s2)
{
    short temp=s1;
    s1=s2;
    s2=temp;
}

void transposeBlock(short* mat,int dim)
{
    //this will still be in row major
    #pragma omp parallel for
    for (int i = 0; i < dim; ++i )
    {
       for (int j = 0; j < i; ++j )
       {
          // Index in the original matrix.
          int index1 = i*dim+j;

          // Index in the transpose matrix.
          int index2 = j*dim+i;

         swap(mat[index1],mat[index2]);
       }
    }

}


int main(int argc, char** argv) {


    double t1, t2; 
    t1 = MPI_Wtime(); 
    int matSize=atoi(argv[1]);
    char* outFile_n=argv[2];
   


    // Initialize the MPI environment
    MPI_Init(NULL, NULL);
    // Get the number of processes
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);


    // Get the rank of the process
    int rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    srand(time(NULL)+rank);
    int matElems=matSize*matSize;



    int noBlocks=world_size;

    if( (matElems/world_size) < 4)
        noBlocks=matElems/4; //limit number of processes



    int blockSize=matElems/noBlocks;//buffer size
    while(!(sqrt(blockSize)-floor(sqrt(blockSize)) )==0){
        noBlocks--;
        if(matElems%noBlocks==0){
            blockSize=matElems/noBlocks;
        }
    }
    int blockDim=sqrt(blockSize);

    int blocksPerRow=matSize/blockDim;
    int blockNum=rank;

    int row = (blockNum/blocksPerRow)*blockDim;

	int startCol = (blockNum)%blocksPerRow*blockDim;


   short* thisBuf=NULL;
    
    if(rank<noBlocks){
        thisBuf=(short*)malloc(sizeof(short)*blockSize);
        for(int i=0;i<blockSize; i++)//random init
        {
            thisBuf[i]=rand()%100;
        }
        transposeBlock(thisBuf,blockDim);

    }
    MPI_Barrier(MPI_COMM_WORLD);

//Window and one-sided
    MPI_Win window;


    MPI_Win_create(thisBuf,blockSize*sizeof(short),sizeof(short),MPI_INFO_NULL, MPI_COMM_WORLD,&window);    // do put and get calls
    MPI_Win_fence(MPI_MODE_NOPRECEDE, window); 

    short* rcvBuf=NULL;
    if(rank==0)
    {
        rcvBuf=(short*)malloc(sizeof(short)*matElems);
        for(int i=0;i<noBlocks;i++)
        {
            MPI_Get(rcvBuf+(i*blockSize),blockSize,MPI_SHORT,i,0,blockSize, MPI_SHORT,window);
        }
    }
    MPI_Win_fence((MPI_MODE_NOSTORE | MPI_MODE_NOSUCCEED), window); 

    MPI_Barrier(MPI_COMM_WORLD);
    MPI_Win_free( &window );


    MPI_File outFile;


    MPI_File_open(MPI_COMM_WORLD, outFile_n,MPI_MODE_CREATE | MPI_MODE_WRONLY,MPI_INFO_NULL, &outFile);

//rank0 write to file
    MPI_Datatype subMatrix;

    MPI_Type_vector(matSize*blockDim,blockDim,matSize,MPI_SHORT, &subMatrix );//derived data type
    MPI_Type_commit( &subMatrix );

    if(rank==0)
    {
        MPI_File_write_at(outFile,0,&matSize,1,MPI_SHORT, MPI_STATUS_IGNORE);
    }

    for (int i=0;i<noBlocks;i++)
    {
        

        int row,col=0;
        if(i%(blockDim+1)==0)
        {//loopback
             row = (i/blocksPerRow)*blockDim;
             col = (i)%blocksPerRow*blockDim;
        }
        else
        {
             col=i/blocksPerRow;
             row=i%blocksPerRow;

        }

        int offset=row*matSize*sizeof(short)*blockDim + col*sizeof(short)*blockDim;
        //printf("I %d off %d \n",i,offset);
        MPI_File_set_view(outFile, offset+2, MPI_SHORT, subMatrix, "native",MPI_INFO_NULL);     ///+2 for the mat size
        if(rank==0)
            MPI_File_write(outFile,rcvBuf+(i*blockSize), blockSize, MPI_SHORT, MPI_STATUS_IGNORE);
    }

    
    MPI_Barrier(MPI_COMM_WORLD);
    MPI_Type_free( &subMatrix );


    MPI_File_close(&outFile); 



    free(thisBuf);
    free(rcvBuf);

    t2 = MPI_Wtime(); 
    if(rank==0)
    printf( "Elapsed time is %f\n", t2 - t1 ); 
    MPI_Finalize();
    return 0;
}