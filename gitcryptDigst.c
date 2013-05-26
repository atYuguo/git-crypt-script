#include <stdio.h>
#include <openssl/evp.h>
#define READLENGTH 128
main (int argc, char *argv[])
{
  EVP_MD_CTX *mdctx;
  const EVP_MD *md=EVP_sha1();
  char mess[READLENGTH+1];
  unsigned char md_value[EVP_MAX_MD_SIZE];
  int md_len,i,nowLength;
  FILE *theFile;

  if (argc < 2){
    printf("无文件名！\n");
    return 1;
  }
  else{
    if ((theFile = fopen (argv[1],"r")) == NULL){
      printf("打开文件错误！\n");
      return 1;
    }
    else{
      OpenSSL_add_all_digests();
      mdctx=EVP_MD_CTX_create();
      EVP_DigestInit_ex(mdctx,md,NULL);
      while (! feof(theFile) ){
	nowLength=fread(mess,sizeof(char),READLENGTH,theFile);
	mess[nowLength]=0;
	EVP_DigestUpdate(mdctx,mess,nowLength);
      }
      EVP_DigestFinal_ex(mdctx,md_value,&md_len);
      EVP_MD_CTX_destroy(mdctx);
      for(i=0;i<md_len;i++) printf("%02x",md_value[i]);
    }
  }
  return 0;
}
