#include <mpi.h>
#include <stdio.h>
#include <math.h>
#include <upc_relaxed.h>

int main(int argc, char** argv) {

    shared [] int* z;
    z=upc_global_alloc(4,sizeof(int));
   
    int* init_z = malloc(sizeof(int)*4);
    
   init_z[0]=1;
   init_z[1]=2;
   init_z[2]=3;
   init_z[3]=4;

 //   int init_z[2]={1,2};
    
    if (MYTHREAD == 0) {
    upc_memput(z+2, init_z+2,2*sizeof(int));
    }
    upc_fence;

    upc_barrier;
    if(MYTHREAD==0)
    {
        printf("%d %d %d %d \n",z[0],z[1],z[2],z[3]);
    }


    upc_free(z);
    //upc_memput( globalBuf, asd, sizeof(short)*4);


}