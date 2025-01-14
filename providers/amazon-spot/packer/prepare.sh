#!/usr/bin/env bash
set -x
# print disk info
sudo lsblk
sudo df -Th
# Allow notty sudo
sudo sed -n -e '/Defaults.*requiretty/s/^/#/p' /etc/sudoers
if grep -q 'Amazon Linux 2' /etc/os-release; then
  # install python 3.8
  sudo yum install -y amazon-linux-extras
  sudo amazon-linux-extras enable python3.8
fi
# Upgrade the base image fully
# TODO: discuss potentially disabling this after building base to prevent blindly sliding package versions from build to build
sudo yum -y update
# Install dev tools and python
sudo yum install -y wget libffi libffi-devel openssl-devel python3.8
sudo yum groupinstall -y 'Development Tools'
# Upgrade pip
if [[ ! -f get-pip.py ]]; then
    wget https://bootstrap.pypa.io/get-pip.py && python3.8 get-pip.py
fi
# Install ansible
sudo python3.8 -m pip install --upgrade --trusted-host pypi.python.org ansible==6.0.0
if ! grep -q '^5.15' <(uname -r) && grep -q 'Amazon Linux 2' /etc/os-release; then
  # Update to kernel 5.15 if not on 5.15 already
  sudo amazon-linux-extras install -y kernel-5.15
  sudo reboot now
fi
