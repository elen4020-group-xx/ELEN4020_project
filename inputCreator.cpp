#include <stdio.h>
#include "rank2Tensor.h"

int main(int argc, char* argv[])
{
    int N=argv[1][0]-'0';
    char* fileName=argv[2];

    
    rank2Tensor r2;
    r2.cols=N;
    r2.rows=N;
    initRank2Tensor(&r2);
    FILE * fp;
    displayRank2Tensor(&r2);
    fp = fopen (fileName,"w");
    
    fprintf(fp,"%d",N);
    for(int i = 0; i < N;i++){
        for (int j=0;j<N;j++)
        {
            fprintf (fp, ",%d",r2.matrix[i][j]);
        }
    }
    
    /* close the file*/  
    fclose (fp);

    disposeRank2Tensor(&r2);

    return 0;

}