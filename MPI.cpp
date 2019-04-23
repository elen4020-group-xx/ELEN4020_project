#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
    // Initialize the MPI environment
    MPI_Init(NULL, NULL);
    MPI_File fh;

    // Get the number of processes
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    char buf[2];
    short chunk[2][2];

    // Get the rank of the process
    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

    MPI_File_open(MPI_COMM_WORLD, "myfile",MPI_MODE_RDONLY,
    MPI_INFO_NULL, &fh);
    MPI_Offset offset;

    offset=0; 

   
        MPI_File_read(fh, buf, sizeof(buf)*sizeof(char), MPI_CHAR, MPI_STATUS_IGNORE);

 
        //chunk[i][j]=buf[i*2+j]-'0';
        printf("%x\n",buf);
    
      

    

    MPI_File_close(&fh); 

    // Finalize the MPI environment.
    MPI_Finalize();
}