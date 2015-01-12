#include <stdio.h>
int main (int argc,char *argv[])
{
  FILE *tempFile;
  if (argc > 1){
    if((tempFile = fopen (argv[1],"wb")) == NULL){
      printf("打开缓存文件失败！\n");
      return 1;
    }
    else{
      char chInstream[1];
      while (1){
	fread(chInstream,sizeof(char),1,stdin);
	if (!feof(stdin)){
	  fwrite(chInstream,sizeof(char),1,tempFile);
	}
	else{
	  break;
	}
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
