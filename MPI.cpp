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

    srand(time(NULL)+rank);//use rank as part of seed



    int noBlocks=world_size;
    int matElems=matSize*matSize;

    if((matElems/world_size)<4)//enfore min submatrix size of 4(2x2)
        noBlocks=matElems/4; //limit number of processes

    int blockSize=matElems/noBlocks;//buffer size


    while(!(sqrt(blockSize)-floor(sqrt(blockSize)) )==0){//reduce number of processes to obtain square submatrices
        noBlocks--;
        if(matElems%noBlocks==0){//make sure even division can still occur
            blockSize=matElems/noBlocks;
        }
    }
    int blockDim=sqrt(blockSize);

    int blocksPerRow=matSize/blockDim;
    int blockNum=rank;

    int row = (blockNum/blocksPerRow)*blockDim;

	int startCol = (blockNum)%blocksPerRow*blockDim;

    int offset_per_mat_row=matSize;

    int bufLoc=0;


    short* thisBuf=NULL;
    
    if(rank<noBlocks){
        thisBuf=(short*)malloc(sizeof(short)*blockSize);
        for(int i=0;i<blockSize; i++)//random init of submatrix
        {
            thisBuf[i]=rand()%100;
        }
        transposeBlock(thisBuf,blockDim);

    }


//send and recv

    short* rcvBuf=NULL;

    if(rank<noBlocks)
    MPI_Send(thisBuf,blockSize,MPI_SHORT,0,0,MPI_COMM_WORLD);

    if(rank==0)
    {
        rcvBuf=(short*)malloc(sizeof(short)*matElems);
        for(int i=0;i<noBlocks;i++)
        {
            MPI_Recv(rcvBuf+(i*blockSize),blockSize,MPI_SHORT,i,0,MPI_COMM_WORLD,0);
        }
    }

 

//Comms complete
    MPI_Barrier(MPI_COMM_WORLD);



    if(rank==0)//let rank 0 write the mat size
    {
        MPI_File outFile;

        MPI_File_open(MPI_COMM_SELF, outFile_n,MPI_MODE_CREATE | MPI_MODE_WRONLY,MPI_INFO_NULL, &outFile);

        int bufLoc=0;
        MPI_File_write_at(outFile,0,&matSize,1,MPI_SHORT, MPI_STATUS_IGNORE);

        for (int i=0;i<noBlocks;i++)
        {
            int row,col=0;
            if(i%(blocksPerRow+1)==0)//determine where the current block must be written to
            {//loopback
                row = (i/blocksPerRow);
                col = (i)%blocksPerRow;
            }
            else
            {
                col=i/blocksPerRow;
                row=i%blocksPerRow;
            }

            int offset=row*matSize*sizeof(short)*blockDim + col*sizeof(short)*blockDim;//convert block number to an offset
            for(int j=0;j<blockDim;j++)
            {
                //write submatrices row-by-row
                MPI_File_write_at(outFile,offset+2,rcvBuf+bufLoc, blockDim, MPI_SHORT, MPI_STATUS_IGNORE);
                offset+=matSize*sizeof(short);
                bufLoc+=blockDim;
            }
        }
        
        MPI_File_close(&outFile); //close file on r0

    }
    
    MPI_Barrier(MPI_COMM_WORLD);

    // Finalize the MPI environment.
    free(thisBuf);
    free(rcvBuf);
    t2 = MPI_Wtime(); 
    if(rank==0)
    printf( "Elapsed time is %f\n", t2 - t1 ); 

    MPI_Finalize();
    return 0;
}