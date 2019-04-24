#include <mpi.h>
#include <stdio.h>
#include <math.h>
#include <upc.h>
#include <upc_io.h>

using namespace upc;

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
    char* outFile=argv[2];


    printf("Hello from thread %d of %d\n", MYTHREAD, THREADS);


    upc_file_t* inpFilePt;
    inpFilePt = upc_all_fopen(inFile, UPC RDONLY|UPC_INDIVIDUAL_FP, size_t numhints, 0);

    //not using common fp
    short matSize;
    upc_all_fread_local(inpFilePt,&matSize, 1, sizeof(short),UPC_IN_NOSYNC|UPC_OUT_NOSYNC);

    int noBlocks=THREADS;
    int matElems=matSize*matSize;
    int blockSize=matElems/noBlocks;//buffer size

    int blockDim=sqrt(blockSize);


  //////
    int blocksPerRow=matSize/blockDim;
    int blockNum=MYTHREAD;

    int row = (blockNum/blocksPerRow)*blockDim;

	int startCol = (blockNum)%blocksPerRow*blockDim;

    int offset_per_mat_row=matSize*sizeof(short);

    int bufLoc=0;

    short* thisBuf=(short*)malloc(sizeof(short)*blockSize);
    long int offset=row*matSize*sizeof(short) + startCol*sizeof(short);


///COULD BE DONE WITH NON CONTIGUOUS FILE VIEW
    for(int i=0; i< blockDim;i++)
    {   
        ///+2 for the mat size
      //  MPI_File_read_at_all(fh,offset+2,thisBuf+bufLoc, blockDim, MPI_SHORT, MPI_STATUS_IGNORE);
        upc_all_fseek(inpFilePt,offset+2,UPC_SEEK_SET);
        upc_all_fread_local(inpFilePt,thisBuf+bufLoc,blockDim,sizeof(short), UPC_IN_NOSYNC|UPC_OUT_NOSYNC);

        offset+=offset_per_mat_row;
        bufLoc+=blockDim;
        row=row+1;
    }

    upc_all_fclose (inpFilePt);

    barrier();

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

    int writeRow = (correspondingBlock/blocksPerRow)*blockDim;

	int writeCol = (correspondingBlock)%blocksPerRow*blockDim;


    shared_array<short> globalBuf;
    globalBuf.init(blockSize);
   ///all write to global buf

    offset=writeRow*matSize + writeCol;
    bufLoc=0;
    for(int i=0; i< blockDim;i++)
    {   
        ///+2 for the mat size
        memcpy(globalBuf+offset,thisBuf+bufLoc,blockDim*sizeof(short))
        offset+=offset_per_mat_row;
        bufLoc+=blockDim;
        row=row+1;
    }


    barrier();
    upc_file_t* outFilePt;
    outFilePt= upc_all_fopen(outFile, UPC_CREATE | UPC_WRONLY|UPC_INDIVIDUAL_FP, 0,0);

    
    upc_all_fclose (outFilePt);

    barrier();


    //all read from global buf and output


    return 0;
}