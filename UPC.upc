#include <mpi.h>
#include <stdio.h>
#include <math.h>
#include <upc.h>
#include <upc_io.h>


void swap(short* s1, short *s2)
{
    short temp=*s1;
    *s1=*s2;
    *s2=temp;
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

         swap(&mat[index1],&mat[index2]);
       }
    }

}


int main(int argc, char** argv) {

    char* inFile=argv[1];
    char* outFile=argv[2];


    //printf("Hello from thread %d of %d\n", MYTHREAD, THREADS);


    upc_file_t* inpFilePt;
    inpFilePt = upc_all_fopen(inFile, UPC_RDONLY|UPC_INDIVIDUAL_FP,0, 0);

    //not using common fp
    short matSize;
    upc_all_fread_local(inpFilePt,&matSize, 1, sizeof(short),UPC_IN_NOSYNC|UPC_OUT_NOSYNC);


    int noBlocks=THREADS;
    int matElems=matSize*matSize;
    int blockSize=matElems/noBlocks;//buffer size

    int blockDim=sqrt(blockSize);


 //   printf("blocksize : %d\n",blockDim);


//////
    int blocksPerRow=matSize/blockDim;
    int blockNum=MYTHREAD;

    int row = (blockNum/blocksPerRow)*blockDim;

	int startCol = (blockNum)%blocksPerRow*blockDim;

    //


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
    }
    upc_barrier;

    upc_all_fclose (inpFilePt);


    transposeBlock(thisBuf,blockDim);

    
   int correspondingBlock=0;

   if(MYTHREAD%(blockDim+1)==0)
    {
        correspondingBlock=MYTHREAD;//loopback
    }
    else
    {
        int row=MYTHREAD/blocksPerRow;
        int col=MYTHREAD%blocksPerRow;

        correspondingBlock=col*blocksPerRow+row;
    }

    int writeRow = (correspondingBlock/blocksPerRow)*blockDim;

	int writeCol = (correspondingBlock)%blocksPerRow*blockDim;



    upc_barrier;

    shared [] short* globalBuf;
    globalBuf=upc_all_alloc(THREADS,blockSize*sizeof(short));

//    ///all write to global buf
    upc_barrier;
    
   

    offset=writeRow*matSize + writeCol;
    bufLoc=0;

    for(int i=0; i< blockDim;i++)
    {   
        upc_memput(globalBuf+offset,thisBuf+bufLoc, blockDim*sizeof(short));
        offset+=matSize;
        bufLoc+=blockDim;
        upc_fence;
    }
    upc_barrier;

    printf("blocksize : %d\n",blockDim);

    if(MYTHREAD==0)
    for (int i = 0; i < matSize; ++i )
    {
       for (int j = 0; j < matSize; ++j )
       {
          printf("%d,",globalBuf[i*matSize+j]);
       }
       printf("\n");
    }
   
    
    upc_file_t* outFilePt;
    outFilePt= upc_all_fopen(outFile, UPC_CREATE|UPC_WRONLY|UPC_INDIVIDUAL_FP, 0,0);


    if(MYTHREAD==0)
    {
        //(upc_file_t *fd, void *buffer,size_t size, size_t nmemb, upc_flag_t flags);

        upc_all_fwrite_local(outFilePt,&matSize,1,sizeof(short), UPC_IN_NOSYNC|UPC_OUT_NOSYNC);
    }

    offset=row*matSize + startCol;

    for(int i=0; i< blockDim;i++)
    {   
        //upc_all_fwrite_shared(upc_file_t *fd,shared void *buffer, size_t blocksize, size_t size,size_t nmemb, upc_flag_t flags);
   
        upc_all_fseek(outFilePt,offset*sizeof(short)+2,UPC_SEEK_SET);
        upc_all_fwrite_shared(outFilePt,globalBuf+offset,sizeof(short),blockDim,sizeof(short), 0);
        offset+=matSize;
    }

    
    
   
    while(upc_all_fclose (outFilePt)!=0)
    {
        printf("ye\n");
    }
    upc_barrier;
   free(thisBuf);
   


    return 0;
}