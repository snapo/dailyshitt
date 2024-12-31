
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo apt-get install nvidia-headless-550-server
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-4


# Noise reduction of the fans, if you are happy apply it in the bashrc every time
Set powerlimit on GPU to have a little silence from the stupid fans (sudo nvidia-smi -i 0 -pl 200)
Set powerlimit on GPU to have a little silence from the stupid fans (sudo nvidia-smi -i 1 -pl 200)



# Add to the .bashrc
export PATH=$PATH:/usr/local/cuda-12.4/bin
export CUDA_VERSION=12.4
export CUDA_HOME="/usr/local/cuda-${CUDA_VERSION}"
export CUDA_PATH="${CUDA_HOME}"
export PATH="${CUDA_PATH}/bin:${PATH}"
export LIBRARY_PATH="${CUDA_PATH}/lib64:${LIBRARY_PATH}"
export LD_LIBRARY_PATH="${CUDA_PATH}/lib64:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH="${CUDA_PATH}/extras/CUPTI/lib64:${LD_LIBRARY_PATH}"
export NVCC="${CUDA_PATH}/bin/nvcc"
export CFLAGS="-I${CUDA_PATH}/include ${CFLAGS}"
Set powerlimit on GPU to have a little silence from the stupid fans (sudo nvidia-smi -i 0 -pl 200)
Set powerlimit on GPU to have a little silence from the stupid fans (sudo nvidia-smi -i 1 -pl 200)


