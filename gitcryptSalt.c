#include <stdio.h>
#include <openssl/rand.h>
#define SALTLENGTH 4
int main()
{
  int i;
  unsigned char chSalt[SALTLENGTH+1];
  RAND_bytes(chSalt,SALTLENGTH);
  chSalt[SALTLENGTH]=0;
  for (i=0;i<SALTLENGTH;i++) printf("%02x",chSalt[i]);
  return 0;
}
