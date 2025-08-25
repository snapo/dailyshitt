#!/bin/bash
# Script to install NVIDIA drivers, CUDA 12.8, and configure Docker for GPU support on headless systems

echo "Starting NVIDIA driver, CUDA 12.8, and Docker GPU setup..."

# Update system packages
sudo apt-get update
sudo apt-get upgrade -y

# Install necessary dependencies
sudo apt-get install -y build-essential dkms linux-headers-$(uname -r)

# Download and install the latest CUDA keyring
echo "📥 Installing CUDA repository keyring..."
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb

# Update package list
sudo apt-get update

# Install the latest NVIDIA driver that supports RTX 2080 Ti (headless mode)
echo "🎮 Installing NVIDIA headless driver..."
sudo apt-get install -y nvidia-headless-570-server nvidia-utils-570-server

# Install CUDA 12.8 toolkit
echo "📦 Installing CUDA Toolkit 12.8..."
sudo apt-get install -y cuda-toolkit-12-8

# Set power limits for both GPUs
echo "⚡ Setting GPU power limits..."
sudo nvidia-smi -i 0 -pl 150
sudo nvidia-smi -i 1 -pl 150

# Install NVIDIA Container Toolkit for Docker
echo "🐳 Installing NVIDIA Container Toolkit..."
sudo apt-get install -y nvidia-container-toolkit

# Configure Docker to use NVIDIA as default runtime
echo "🔧 Configuring Docker for GPU support..."
sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  },
  "default-runtime": "nvidia"
}
EOF

# Restart Docker to apply changes
echo "🔄 Restarting Docker service..."
sudo systemctl restart docker

# Add environment variables to .bashrc if not already present
echo "📝 Setting up CUDA environment variables..."

CUDA_ENV_ADDED=$(grep -c "CUDA_VERSION=12.8" ~/.bashrc)

if [ $CUDA_ENV_ADDED -eq 0 ]; then
  cat >> ~/.bashrc << 'EOF'

# CUDA 12.8 Environment Variables
export CUDA_VERSION=12.8
export CUDA_HOME="/usr/local/cuda-${CUDA_VERSION}"
export CUDA_PATH="${CUDA_HOME}"
export PATH="${CUDA_PATH}/bin:${PATH}"
export LIBRARY_PATH="${CUDA_PATH}/lib64:${LIBRARY_PATH}"
export LD_LIBRARY_PATH="${CUDA_PATH}/lib64:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH="${CUDA_PATH}/extras/CUPTI/lib64:${LD_LIBRARY_PATH}"
export NVCC="${CUDA_PATH}/bin/nvcc"
export CFLAGS="-I${CUDA_PATH}/include ${CFLAGS}"
EOF
else
  echo "⚠️ CUDA environment already configured in ~/.bashrc"
fi

# Reload environment
source ~/.bashrc

# Add power limit settings to crontab (ensure they survive reboots and thermal resets)
echo "⏰ Adding power limit persistence via crontab..."
{
  sudo crontab -l 2>/dev/null | grep -v "nvidia-smi -i [01] -pl 150"
  echo "@reboot /usr/bin/nvidia-smi -i 0 -pl 150 # GPU 0 power limit"
  echo "@reboot /usr/bin/nvidia-smi -i 1 -pl 150 # GPU 1 power limit"
  echo "*/2 * * * * /usr/bin/nvidia-smi -i 0 -pl 150 # Refresh every 2 mins"
  echo "*/2 * * * * /usr/bin/nvidia-smi -i 1 -pl 150 # Refresh every 2 mins"
} | sudo crontab -

# Final message
echo ""
echo "✅ Installation complete! Please reboot your system:"
echo "   sudo reboot"
echo ""
echo "💡 After reboot, verify with:"
echo "   nvidia-smi"
echo "   nvcc --version"
echo "   docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu22.04 nvidia-smi"

