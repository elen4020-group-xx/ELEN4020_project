g++ inputCreator.cpp -o inp.o
rm -f matrixFile*
./inp.o 8 matrixFile_8
./inp.o 16 matrixFile_16
./inp.o 32 matrixFile_32
./inp.o 64 matrixFile_64
./inp.o 128 matrixFile_128