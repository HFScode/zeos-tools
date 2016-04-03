#!/bin/bash 

#################################################################################
# Configure HFSBox and post install script
#################################################################################
# Install the emulators and ZSpin directory structure
# Install a post install script that is run at the first boot to configure
# the HFSBox (SP or 15K)

echo "======================================================="
echo "Installing HFSBox"
echo "======================================================="

echo "Checking for base installation"
/usr/share/zpkgs/zeos-tools/zexecprior.sh base_img.sh

echo "Configuring zsnes"
apt-get -y install zsnes
echo "Configuring HFSBOX and other emulators"
cd /usr/share/zpgks/zeos-tools/patches/deb/
dpkg-split --join hfsbox_1.0.1*
dpkg -i /usr/share/zpgks/zeos-tools/patches/deb/hfsbox-1.0.1_1.0.1_all.deb
