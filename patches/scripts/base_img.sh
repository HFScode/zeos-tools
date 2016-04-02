#!/bin/bash 

#################################################################################
# Install base image
#################################################################################
#
# Add Ubuntu PPAs
# Install prerequistes and dependencies
# Install LXDE and remove unwanted softwares

echo "Installing prequisites for base image"
echo

echo "========================================"
echo "Adding APT Repos"
echo "========================================"
apt-get install -y software-properties-common
add-apt-repository -y ppa:libretro/stable
add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu/ wily main restricted universe multiverse" 
add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu/ wily-security main restricted universe multiverse"
add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu/ wily-updates main restricted universe multiverse"
add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu/ wily-backports main restricted universe multiverse"
add-apt-repository -y "deb http://archive.canonical.com/ubuntu wily partner"
echo



echo "========================================"
echo "Upgrading"
echo "========================================"
apt-get update
apt-get -y upgrade
echo



echo "========================================"
echo "Installing requirements"
echo "========================================"
apt-get -y install testdisk reiserfsprogs ntfs-3g dosfstools
apt-get -y install casper ubiquity ubiquity-frontend-gtk ubiquity-slideshow-lubuntu
apt-get -y install lxde
apt-get -y install zip rar unzip unrar ssh gedit retroarch retroarch-* libretro-* alsa-base alsa-utils pulseaudio xfce4-mixer terminator adobe-flashplugin  gdebi
echo



echo "========================================"
echo "Cleaning."
echo "========================================"
apt-get clean
echo "Base image installed"
