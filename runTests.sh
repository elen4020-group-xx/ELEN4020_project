rm -f m.o
rm -f m1.o
mpiCC MPI.cpp -o m.o
mpiCC MPI_one_sided.cpp -o m1.o

echo "Using Typical Approach"

echo "16 8"
mpiexec -n 16 m.o 8 matrixFile_8_16_m 
echo "16 16"
mpiexec -n 16 m.o 16 matrixFile_16_16_m 
echo "16 32"
mpiexec -n 16 m.o 32 matrixFile_32_16_m 
echo "16 64"
mpiexec -n 16 m.o 64 matrixFile_64_16_m 
echo "16 128"
mpiexec -n 16 m.o 128 matrixFile_128_16_m 

echo "32 8"
mpiexec -n 32 m.o 8 matrixFile_8_32_m
echo "32 16"
mpiexec -n 32 m.o 16 matrixFile_16_32_m
echo "32 32"
mpiexec -n 32 m.o 32 matrixFile_32_32_m
echo "32 64"
mpiexec -n 32 m.o 64 matrixFile_64_32_m
echo "32 128"
mpiexec -n 32 m.o 128 matrixFile_128_32_m


echo "64 8"
mpiexec -n 64 m.o 8 matrixFile_8_64_m
echo "64 16"
mpiexec -n 64 m.o 16 matrixFile_16_64_m
echo "64 32"
mpiexec -n 64 m.o 32 matrixFile_32_64_m
echo "64 64"
mpiexec -n 64 m.o 64 matrixFile_64_64_m
echo "64 128"
mpiexec -n 64 m.o 128 matrixFile_128_64_m


echo "Using One SIDED with vector dType Approach"

echo "16 8"
mpiexec -n 16 m1.o 8 matrixFile_8_16_m1
echo "16 16"
mpiexec -n 16 m1.o 16 matrixFile_16_16_m1
echo "16 32"
mpiexec -n 16 m1.o 32 matrixFile_32_16_m1
echo "16 64"
mpiexec -n 16 m1.o 64 matrixFile_64_16_m1
echo "16 128"
mpiexec -n 16 m1.o 128 matrixFile_128_16_m1

echo "32 8"
mpiexec -n 32 m1.o 8 matrixFile_8_32_m
echo "32 16"
mpiexec -n 32 m1.o 16 matrixFile_16_32_m
echo "32 32"
mpiexec -n 32 m1.o 32 matrixFile_32_32_m
echo "32 64"
mpiexec -n 32 m1.o 64 matrixFile_64_32_m
echo "32 128"
mpiexec -n 32 m1.o 128 matrixFile_128_32_m


echo "64 8"
mpiexec -n 64 m1.o 8 matrixFile_8_64_m
echo "64 16"
mpiexec -n 64 m1.o 16 matrixFile_16_64_m
echo "64 32"
mpiexec -n 64 m1.o 32 matrixFile_32_64_m
echo "64 64"
mpiexec -n 64 m1.o 64 matrixFile_64_64_m
echo "64 128"
mpiexec -n 64 m1.o 128 matrixFile_128_64_m


