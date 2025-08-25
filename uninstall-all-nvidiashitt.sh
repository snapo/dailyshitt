#!/bin/bash
# Script to completely remove all NVIDIA components

echo "Starting complete NVIDIA uninstallation..."

# Remove all NVIDIA packages :cite[1]:cite[3]
sudo apt-get remove --purge '^nvidia-.*' -y
sudo apt-get remove --purge '^cuda-.*' -y
sudo apt-get remove --purge '^libnvidia-.*' -y

# Remove any remaining NVIDIA packages
sudo apt-get remove --purge 'nvidia*' -y
sudo apt-get remove --purge 'cuda*' -y

# Remove NVIDIA repository sources
sudo rm -f /etc/apt/sources.list.d/cuda*
sudo rm -f /etc/apt/sources.list.d/nvidia*
sudo rm -f /etc/apt/sources.list.d/graphics-drivers*

# Remove any leftover NVIDIA files :cite[10]
sudo find /usr/lib -iname "*nvidia*" -exec rm -rf {} +
sudo find /usr/local -iname "*cuda*" -exec rm -rf {} +

# Remove NVIDIA configuration files
sudo rm -f /etc/modprobe.d/nvidia*
sudo rm -f /etc/modprobe.d/blacklist-nvidia*
sudo rm -f /etc/X11/xorg.conf

# Restore original xorg configuration if available
if [ -f /etc/X11/xorg.conf.backup ]; then
    sudo mv /etc/X11/xorg.conf.backup /etc/X11/xorg.conf
fi

# Clean up package system
sudo apt-get autoremove -y
sudo apt-get autoclean -y

# Reinstall ubuntu-desktop to restore any removed dependencies :cite[1]
sudo apt-get install --reinstall ubuntu-desktop -y

echo "NVIDIA uninstallation complete. Please reboot your system."
