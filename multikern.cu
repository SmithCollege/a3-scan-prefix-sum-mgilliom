#include <iostream>
#include <math.h>
#include <sys/time.h>
// Kernel function to add the elements of two arrays

#define N 100000
#define BLOCKSIZE 256
#define ITEMS_PER_THREAD 100
__global__ void k1(int *in, int *k1out) {

	int gindex = threadIdx.x + blockIdx.x*blockDim.x;

	k1out[gindex*100]=in[gindex*100];
	for (int i = gindex*100+1; i <= (gindex*100 + 99); i++){ //ea thread deals w 100 items
		k1out[i]=k1out[i-1]+in[i];
	}	
}

__global__ void k3(int *k1out, int *k2out, int *k3out) {

	int gindex = threadIdx.x + blockIdx.x*blockDim.x;
	if (threadIdx.x > 0){
		for (int i = gindex*100; i <= (gindex*100 + 99); i++){ //ea thread deals w 100 items
			k3out[i]=k1out[i]+k2out[gindex-1];
		}	
	}
	else{
		for (int i = 0; i <= 99; i++){
			k1out[i]=k3out[i];
		}
	}
}



__global__ void k2(int *k1out, int *k2out) {
	k2out[0] = k1out[99];
	for (int i = 1; i < N / 100+1; i++){
		k2out[i] = k2out[i-1] + k1out[i*100+99];
	}
}




  
double get_clock(){
	struct timeval tv; int ok;
	ok = gettimeofday(&tv, (void *) 0);
	if (ok<0) { printf("gettimeofday error"); }
	return (tv.tv_sec * 1.0 + tv.tv_usec * 1.0E-6);
}

int main(void)
{
	int *in, *k1out, *k2out, *k3out;
//	int size_of_k2out = (N+1);
	
	
  // Allocate Unified Memory – accessible from CPU or GPU
	cudaMallocManaged(&in, N*sizeof(int));
  	cudaMallocManaged(&k1out, N*sizeof(int));
  	cudaMallocManaged(&k2out, N/ITEMS_PER_THREAD+1);
  	cudaMallocManaged(&k3out, N*sizeof(int));

  // initialize x and y arrays on the host
    for (int i = 0; i < N; i++) {
    	in[i] = 1;
   		k1out[i] = -1;
  	}

  // Run kernel on the GPU
	//int numBlocks = (N + BLOCKSIZE - 1) / BLOCKSIZE;
	int numThreads = N / ITEMS_PER_THREAD;
	int numBlocks = ceil(1.0 * numThreads / BLOCKSIZE);
	printf("num threads %d, numBlocks %d", numThreads, numBlocks);
	
	double t0 = get_clock();
	k1<<<numBlocks, BLOCKSIZE>>>(in, k1out);
	printf("%s\n", cudaGetErrorString(cudaGetLastError()));
	k2<<<1, 1>>>(k1out, k2out);
	printf("%s\n", cudaGetErrorString(cudaGetLastError()));
	k3<<<numBlocks, BLOCKSIZE>>>(k1out, k2out, k3out);
	printf("%s\n", cudaGetErrorString(cudaGetLastError()));
  
	  // Wait for GPU to finish before accessing on host
	cudaDeviceSynchronize();
	double t1 = get_clock();
	printf("time: %f s\n", (t1-t0));


	for (int i = 99; i < N; i+=1000){
	  printf("%d. %d\n",i, k1out[i]);
  	}
  	#if 0
  	for (int i = 0; i < numThreads; i++){
	  printf("%d. %d\n",i, k2out[i]);
  	}

  	for (int i = 0; i < N; i+=1000){
	  printf("%d. %d\n",i, k3out[i]);
  	}
  	#endif
  	

  // Free memory
  cudaFree(in);
  cudaFree(k1out);
  cudaFree(k2out);
  cudaFree(k3out);
  
  return 0;
}
