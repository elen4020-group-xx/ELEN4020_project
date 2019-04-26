#include <mpi.h>
#include <stdio.h>
#include <math.h>


void swap(short &s1, short &s2)
{
    short temp=s1;
    s1=s2;
    s2=temp;
}

void transposeBlock(short* mat,int dim)
{
    //this will still be in row major
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


    char* inFile=argv[1];
    char* outFile_n=argv[2];



    // Initialize the MPI environment
    MPI_Init(NULL, NULL);
    // Get the number of processes
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);


    // Get the rank of the process
    int rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    MPI_File fh;

    MPI_File_open(MPI_COMM_WORLD,inFile,MPI_MODE_RDONLY,
    MPI_INFO_NULL, &fh);


    short matSize;


    MPI_File_read_all(fh,&matSize,1, MPI_SHORT, MPI_STATUS_IGNORE);//let all procs read the size of the matrix
   // printf(" matrix size is %d\n",matSize);

    int noBlocks=world_size;
    int matElems=matSize*matSize;
    int blockSize=matElems/noBlocks;//buffer size

    int blockDim=sqrt(blockSize);

    int blocksPerRow=matSize/blockDim;
    int blockNum=rank;

    int row = (blockNum/blocksPerRow)*blockDim;

	int startCol = (blockNum)%blocksPerRow*blockDim;

    int offset_per_mat_row=matSize;

    int bufLoc=0;

    MPI_Datatype subMatrix;

    MPI_Type_vector(matSize*blockDim,blockDim,offset_per_mat_row,MPI_SHORT, &subMatrix );
    MPI_Type_commit( &subMatrix );


    short* thisBuf=(short*)malloc(sizeof(short)*blockSize);
    long int offset=row*matSize*sizeof(short) + startCol*sizeof(short);

    MPI_File_set_view(fh, offset+2, MPI_SHORT, subMatrix, "native",MPI_INFO_NULL); 


    MPI_File_read_all(fh,thisBuf, blockSize, MPI_SHORT, MPI_STATUS_IGNORE);
     

    MPI_File_close(&fh); 

   transposeBlock(thisBuf,blockDim);
   int correspondingBlock=0;

   if(rank%(blockDim+1)==0)
    {
        correspondingBlock=rank;//loopback
    }
    else
    {
        int row=rank/blocksPerRow;
        int col=rank%blocksPerRow;
        correspondingBlock=col*blocksPerRow+row;
    }
    
//Window and one-sided
    MPI_Win window;

    short* rcvBuf=(short*)malloc(sizeof(short)*blockSize);

    MPI_Win_create(thisBuf,blockSize*sizeof(short),sizeof(short),MPI_INFO_NULL, MPI_COMM_WORLD,&window);    // do put and get calls
    MPI_Win_fence(MPI_MODE_NOPRECEDE, window); 


    MPI_Get(rcvBuf,blockSize,MPI_SHORT,correspondingBlock,0,blockSize, MPI_SHORT,window);

    MPI_Win_fence((MPI_MODE_NOSTORE | MPI_MODE_NOSUCCEED), window); 
    MPI_Win_free( &window );
//Comms complete
    MPI_File outFile;

    MPI_File_open(MPI_COMM_WORLD, outFile_n,MPI_MODE_CREATE | MPI_MODE_WRONLY,MPI_INFO_NULL, &outFile);

    if(rank==0)//let rank 0 write the mat size
    {
        MPI_File_write_at(outFile,0,&matSize,1,MPI_SHORT, MPI_STATUS_IGNORE);
    }


    //reset these numbers
    offset=row*matSize*sizeof(short) + startCol*sizeof(short);
    MPI_File_set_view(outFile, offset+2, MPI_SHORT, subMatrix, "native",MPI_INFO_NULL);     ///+2 for the mat size

    MPI_File_write_all(outFile,rcvBuf, blockSize, MPI_SHORT, MPI_STATUS_IGNORE);
    MPI_File_close(&outFile); 



    // Finalize the MPI environment.
    MPI_Type_free( &subMatrix );
    free(thisBuf);
    free(rcvBuf);
    MPI_Finalize();
    return 0;
}