#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
void MatrixMulOnHost(int* in, int* out, int size){
	out[0] = in[0];
	for (int i = 0; i < size; i++){
		out[i] = in[i]+out[i-1];
	}
}

double get_clock(){
        struct timeval tv; int ok;
        ok = gettimeofday(&tv, (void *) 0);
        if (ok<0) { printf("gettimeofday error"); }
        return (tv.tv_sec * 1.0 + tv.tv_usec * 1.0E-6);
}

int main() {
  int size = 100000;

  int* in = malloc(sizeof(int) * size);
  int* out = malloc(sizeof(int) * size);


  for (int i = 0; i < size; i++) {
      in[i] = 1; 
  }

  double t0 = get_clock();
  MatrixMulOnHost(in, out, size);
  double t1 = get_clock();
  printf("time: %f s\n", (t1-t0));

  #if 0
  for (int i = 0; i < size; i ++){
  	printf("%d, ",out[i]);
  }
  #endif


  return 0;
}
