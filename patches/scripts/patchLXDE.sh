#!/bin/bash 

#################################################################################
# Correct some stuff in LXED
#################################################################################
#
# Add the logout menu
# Remove xscreensave

#Be sure that base_img.sh is installed before running this script
/usr/share/zpkgs/zeos-tools/zexecprior.sh base_img.sh

apt-get -y install  --reinstall lxsession-logout
apt-get -y remove xscreensaver 

