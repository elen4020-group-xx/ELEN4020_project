#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
    // Initialize the MPI environment
    MPI_Init(NULL, NULL);
    MPI_File fh;

    // Get the number of processes
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    char buf[100];

    // Get the rank of the process
    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

    MPI_File_open(MPI_COMM_WORLD, "file.txt",MPI_MODE_RDONLY,
    MPI_INFO_NULL, &fh);

    if (world_rank == 0)
    {
        MPI_Offset x ;
        MPI_File_get_size(fh,&x);
        printf("ddd %lld\n",x);
        MPI_File_read(fh, buf, 100, MPI_CHAR, MPI_STATUS_IGNORE);
        printf("ddd %s",buf);

    }

    MPI_File_close(&fh); 

    // Finalize the MPI environment.
    MPI_Finalize();
}