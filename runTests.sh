./genfiles.sh

rm -f m.o
rm -f m1.o
mpiCC MPI.cpp -o m.o
mpiCC MPI_one_sided.cpp -o m1.o

mpiexec -n 16 m.o matrixFile_32 matrixFile_32_16_m
mpiexec -n 16 m.o matrixFile_64 matrixFile_64_16_m
mpiexec -n 16 m.o matrixFile_128 matrixFile_128_16_m

mpiexec -n 32 m.o matrixFile_64 matrixFile_64_32_m

mpiexec -n 64 m.o matrixFile_128 matrixFile_128_64_m

mpiexec -n 16 m1.o matrixFile_32 matrixFile_32_16_m1
mpiexec -n 16 m1.o matrixFile_64 matrixFile_64_16_m1
mpiexec -n 16 m1.o matrixFile_128 matrixFile_128_16_m1

mpiexec -n 32 m1.o  matrixFile_64 matrixFile_64_32_m1

mpiexec -n 64 m1.o matrixFile_128 matrixFile_128_64_m1
