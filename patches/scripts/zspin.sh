#!/bin/bash 

#################################################################################
# Install zsping
#################################################################################


#Be sure that base_img.sh is installed before running this script
/usr/share/zpkgs/zeos-tools/zexecprior.sh base_img.sh
#Be sure that hsf_instlr.sh is installed before running this script
/usr/share/zpkgs/zeos-tools/zexecprior.sh hfs_instlr.sh
# Download and install last zspin version

CURRENTVERSION="0.3.2"

echo "==========================================================================="
echo "Downloading and installing ZSPIN v$CURRENTVERSION"
echo "==========================================================================="

cd /usr/games/hfsbox
wget -nc https://github.com/HFScode/zspin/releases/download/v"$CURRENTVERSION"/zspin-"$CURRENTVERSION"-linux64.zip
unzip zspin-"$CURRENTVERSION"-linux64.zip -d zspin/

