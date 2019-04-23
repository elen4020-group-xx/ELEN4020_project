#include <stdio.h>
#include <fstream>
#include "rank2Tensor.h"

int main(int argc, char* argv[])
{
    short N=atoi(argv[1]);
    char* fileName=argv[2];

    
    rank2Tensor r2;
    r2.cols=N;
    r2.rows=N;
    initRank2Tensor(&r2);
   

    displayRank2Tensor(&r2);

    std::fstream myfile;
    myfile = std::fstream(fileName, std::ios::out | std::ios::binary);
    //Here would be some error handling
    
    myfile.write((char*)&N,sizeof(short));
    for(int i = 0; i < N; ++i){
        for(int j=0;j<N;j++)
        {
            myfile.write((char*)&r2.matrix[i][j],sizeof(short));
        }
    }
    myfile.close();

    std::ifstream inBinFile(fileName,std::ios::in | std::ios::binary);
    for(int i = 0; i < N; ++i){
        for(int j=0;j<N;j++)
        {
            char buffer[2];
            inBinFile.read((char*)&buffer,sizeof(char)*sizeof(buffer));
            short num = (int)buffer[0] | (int)buffer[1]<<8;
          //  printf("%d\n",num);
        }
    }
    inBinFile.close();


    disposeRank2Tensor(&r2);

    return 0;

}