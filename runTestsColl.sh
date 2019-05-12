./genfiles.sh

rm -f mc.o
rm -f mc1.o
mpiCC MPI_coll.cpp -o mc.o
mpiCC MPI_one_sided_coll.cpp -o mc1.o

echo "Collective two sided"

echo "16 8"
mpiexec -n 16 mc.o matrixFile_8 matrixFile_8_16_m
echo "16 16"
mpiexec -n 16 mc.o matrixFile_16 matrixFile_16_16_m
echo "16 32"
mpiexec -n 16 mc.o matrixFile_32 matrixFile_32_16_m
echo "16 64"
mpiexec -n 16 mc.o matrixFile_64 matrixFile_64_16_m
echo "16 128"
mpiexec -n 16 mc.o matrixFile_128 matrixFile_128_16_m


echo "32 16"
mpiexec -n 32 mc.o matrixFile_16 matrixFile_16_32_m
echo "32 32"
mpiexec -n 32 mc.o matrixFile_32 matrixFile_32_32_m
echo "32 64"
mpiexec -n 32 mc.o matrixFile_64 matrixFile_64_32_m
echo "32 128"
mpiexec -n 32 mc.o matrixFile_128 matrixFile_128_32_m


echo "64 32"
mpiexec -n 64 mc.o matrixFile_32 matrixFile_32_64_m
echo "64 64"
mpiexec -n 64 mc.o matrixFile_64 matrixFile_64_64_m
echo "64 128"
mpiexec -n 64 mc.o matrixFile_128 matrixFile_128_64_m


echo "Collective one sided"

echo "16 8"
mpiexec -n 16 mc1.o matrixFile_8 matrixFile_8_16_m1
echo "16 16"
mpiexec -n 16 mc1.o matrixFile_16 matrixFile_16_16_m1
echo "16 32"
mpiexec -n 16 mc1.o matrixFile_32 matrixFile_32_16_m1
echo "16 64"
mpiexec -n 16 mc1.o matrixFile_64 matrixFile_64_16_m1
echo "16 128"
mpiexec -n 16 m1.o matrixFile_128 matrixFile_128_16_m1


echo "32 16"
mpiexec -n 32 mc1.o matrixFile_16 matrixFile_16_32_m
echo "32 32"
mpiexec -n 32 mc1.o matrixFile_32 matrixFile_32_32_m
echo "32 64"
mpiexec -n 32 mc1.o matrixFile_64 matrixFile_64_32_m
echo "32 128"
mpiexec -n 32 mc1.o matrixFile_128 matrixFile_128_32_m



echo "64 32"
mpiexec -n 64 mc1.o matrixFile_32 matrixFile_32_64_m
echo "64 64"
mpiexec -n 64 mc1.o matrixFile_64 matrixFile_64_64_m
echo "64 128"
mpiexec -n 64 mc1.o matrixFile_128 matrixFile_128_64_m


