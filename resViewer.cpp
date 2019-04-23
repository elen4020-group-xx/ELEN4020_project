#include <stdio.h>
#include <fstream>



int main(int argc, char* argv[])
{
    short N=argv[1][0]-'0';
    char* fileName=argv[2];
  std::ifstream inBinFile(fileName,std::ios::in | std::ios::binary);
   char buffer[2];
    inBinFile.read((char*)&buffer,sizeof(char)*sizeof(buffer));
    printf("mat size %d",buffer);

    for(int i = 0; i < N; ++i){
        for(int j=0;j<N;j++)
        {
            char buffer[2];
            inBinFile.read((char*)&buffer,sizeof(char)*sizeof(buffer));
            short num = (int)buffer[0] | (int)buffer[1]<<8;
            printf("%d,",num);
        }
        printf("\n");
    }
    inBinFile.close();
    

}