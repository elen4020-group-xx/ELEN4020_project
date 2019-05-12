rm -f m.o
rm -f m1.o
mpiCC MPI.cpp -o m.o -fopenmp
mpiCC MPI_one_sided.cpp -o m1.o -fopenmp

echo "OMP enabled"

echo "Using Typical Approach Omp enabled"

echo "16 256"
mpiexec -n 16  m.o 256 matrixFile_8_16_m 
echo "16 512"
mpiexec -n 16  m.o 512 matrixFile_16_16_m 
echo "16 1024"
mpiexec -n 16  m.o 1024 matrixFile_32_16_m 


echo "64 256"
mpiexec -n 64  m.o 256 matrixFile_8_16_m 
echo "64 512"
mpiexec -n 64  m.o 512 matrixFile_16_16_m 
echo "64 1024"
mpiexec -n 64  m.o 1024 matrixFile_32_16_m 

echo "Using One SIDED with vector dType Approach"


echo "16 256"
mpiexec -n 16  m1.o 256 matrixFile_8_16_m 
echo "16 512"
mpiexec -n 16  m1.o 512 matrixFile_16_16_m 
echo "16 1024"
mpiexec -n 16  m.o 1024 matrixFile_32_16_m 


echo "64 256"
mpiexec -n 64  m1.o 256 matrixFile_8_16_m 
echo "64 512"
mpiexec -n 64  m1.o 512 matrixFile_16_16_m 
echo "64 1024"
mpiexec -n 64  m1.o 1024 matrixFile_32_16_m 

rm -f m.o
rm -f m1.o
mpiCC MPI.cpp -o m.o 
mpiCC MPI_one_sided.cpp -o m1.o 

echo "OMP disabled"

echo "Using Typical Approach Omp enabled"

echo "16 256"
mpiexec -n 16  m.o 256 matrixFile_8_16_m 
echo "16 512"
mpiexec -n 16  m.o 512 matrixFile_16_16_m 
echo "16 1024"
mpiexec -n 16  m.o 1024 matrixFile_32_16_m 


echo "64 256"
mpiexec -n 64  m.o 256 matrixFile_8_16_m 
echo "64 512"
mpiexec -n 64  m.o 512 matrixFile_16_16_m 
echo "64 1024"
mpiexec -n 64  m.o 1024 matrixFile_32_16_m 

echo "Using One SIDED with vector dType Approach"


echo "16 256"
mpiexec -n 16  m1.o 256 matrixFile_8_16_m 
echo "16 512"
mpiexec -n 16  m1.o 512 matrixFile_16_16_m 
echo "16 1024"
mpiexec -n 16  m.o 1024 matrixFile_32_16_m 


echo "64 256"
mpiexec -n 64  m1.o 256 matrixFile_8_16_m 
echo "64 512"
mpiexec -n 64  m1.o 512 matrixFile_16_16_m 
echo "64 1024"
mpiexec -n 64  m1.o 1024 matrixFile_32_16_m 
