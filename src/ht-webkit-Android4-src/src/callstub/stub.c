#include <stdio.h>
#include <string.h>

int main(void)
{
  FILE *fp;
  long fsize;

  fp = fopen("shellcode.raw", "rb");

  fprintf(stdout,"Length: %d\n",strlen(SC));
  (*(void(*)()) SC)();
  return 0;
}
