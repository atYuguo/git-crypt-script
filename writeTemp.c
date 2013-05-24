#include <stdio.h>
int main (int argc,char *argv[])
{
  FILE *tempFile;
  if (argc > 1){
    if((tempFile = fopen (argv[1],"w")) == NULL){
      printf("打开缓存文件失败！\n");
      return 1;
    }
    else{
      char chInstream;
      while ((chInstream = getchar() ) != EOF){
	putc(chInstream,tempFile);
      }
    }
    fclose(tempFile);
  }
  else{
    printf("请给出缓存文件路径！\n");
    return 1;
  }
  return 0;
}
