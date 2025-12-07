#include <cstdio>
#include <cuda_runtime.h>
#include <stdint.h>

__global__ void sumBlock(int8_t *outputData, int width, int height,
                         cudaTextureObject_t texture) {
  unsigned int x = blockIdx.x * blockDim.x + threadIdx.x;
  unsigned int y = blockIdx.y * blockDim.y + threadIdx.y;

  float xf = (float)x + 0.5f;
  float yf = (float)y + 0.5f;

  if (!tex2D<int8_t>(texture, xf, yf))
    return;

  int8_t sum = 0;

  for (int8_t x_offset = -1; x_offset <= 1; x_offset++) {
    for (int8_t y_offset = -1; y_offset <= 1; y_offset++) {
      sum += tex2D<int8_t>(texture, xf + (float)x_offset, yf + (float)y_offset);
    }
  }

  outputData[y * width + x] = sum < 5 ? 1 : 0;
}

extern "C" void sumNeighbours(int8_t *outputData, int8_t *inputData,
                              int32_t dataWidth, int32_t dataHeight) {
  int32_t dataSize = dataWidth * dataHeight * sizeof(int8_t);

  cudaError_t err = cudaSuccess;
  int8_t *result = NULL;
  err = cudaMalloc((void **)&result, dataSize);
  cudaMemset((void *)result, 0, dataSize);

  if (err) {
    puts("WeeWoo1");
    return;
  }

  cudaChannelFormatDesc channelDesc =
      cudaCreateChannelDesc(8, 0, 0, 0, cudaChannelFormatKindSigned);
  cudaArray *cuArray;

  err = cudaMallocArray(&cuArray, &channelDesc, dataWidth, dataHeight);
  if (err) {
    puts("WeeWoo2");
    return;
  }
  err = cudaMemcpy2DToArray(
      cuArray, 0, 0, inputData, dataWidth * sizeof(int8_t),
      dataWidth * sizeof(int8_t), dataHeight, cudaMemcpyHostToDevice);
  if (err) {
    puts("WeeWoo3");
    return;
  }

  cudaTextureObject_t texture;
  cudaResourceDesc textureResourceDesc;
  memset(&textureResourceDesc, 0, sizeof(cudaResourceDesc));

  textureResourceDesc.resType = cudaResourceTypeArray;
  textureResourceDesc.res.array.array = cuArray;

  cudaTextureDesc textureDesc;
  memset(&textureDesc, 0, sizeof(cudaTextureDesc));

  textureDesc.normalizedCoords = false;
  textureDesc.filterMode = cudaFilterModePoint;
  textureDesc.addressMode[0] = cudaAddressModeBorder;
  textureDesc.addressMode[1] = cudaAddressModeBorder;
  textureDesc.readMode = cudaReadModeElementType;

  err = cudaCreateTextureObject(&texture, &textureResourceDesc, &textureDesc,
                                NULL);

  if (err) {
    printf("%d", err);
    puts("WeeWoo4");
    return;
  }

  dim3 dimBlock(8, 8);
  dim3 dimGrid(dataWidth / dimBlock.x + 1, dataHeight / dimBlock.y + 1);

  sumBlock<<<dimGrid, dimBlock>>>(result, dataWidth, dataHeight, texture);

  err = cudaDeviceSynchronize();
  if (err) {
    puts("WeeWoo5");
    return;
  }

  err = cudaMemcpy(outputData, result, dataSize, cudaMemcpyDeviceToHost);
  if (err) {
    puts("WeeWoo6");
    return;
  }

  cudaDestroyTextureObject(texture);
  cudaFree(result);
  cudaFree(cuArray);
}
