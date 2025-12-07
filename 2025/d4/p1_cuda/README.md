This is a fancy solution to Part 2 using CUDA. To compile the cuda stuff:

```bash
nvcc -arch=sm_86 -O3 -std=c++20 -c cudaTexture.cu -o cudaTexture.o

ar crv libCudaTexture.a cudaTexture.o
```
