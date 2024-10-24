#include <iostream>
#include <math.h>
#include <sys/time.h>
// Kernel function to add the elements of two arrays

#define N 100000
#define BLOCKSIZE 256
__global__ void scan(int *in, int *out) {

	int gindex = threadIdx.x + blockIdx.x*blockDim.x;

	if (gindex == 0){
		out[0] = in[0];
	}
	else {	
		int sum = 0;
		for (int j = 0; j <= gindex; j++){
			sum+=in[j];
		}
		out[gindex] = sum;		
	}
//	__syncthreads();
	
}
  
double get_clock(){
	struct timeval tv; int ok;
	ok = gettimeofday(&tv, (void *) 0);
	if (ok<0) { printf("gettimeofday error"); }
	return (tv.tv_sec * 1.0 + tv.tv_usec * 1.0E-6);
}

int main(void)
{
	int *in, *out;
	

  // Allocate Unified Memory – accessible from CPU or GPU
	cudaMallocManaged(&in, N*sizeof(int));
  	cudaMallocManaged(&out, N*sizeof(int));

  // initialize x and y arrays on the host
    for (int i = 0; i < N; i++) {
    	in[i] = 1;
   		out[i] = -1;
  	}

  // Run kernel on the GPU
	int numBlocks = (N + BLOCKSIZE - 1) / BLOCKSIZE;

	double t0 = get_clock();
	scan<<<numBlocks, BLOCKSIZE>>>(in, out);
  
	  // Wait for GPU to finish before accessing on host
	cudaDeviceSynchronize();
	double t1 = get_clock();
	printf("time: %f s\n", (t1-t0));
	  
	//for (int i = 0; i < N; i++){
	  //printf("%d. %d\n",i, out[i]);
  	//}

  // Free memory
  cudaFree(in);
  cudaFree(out);
  
  return 0;
}
