#!/bin/bash
##################################################################################################
# This script is used to generate a fresh ISO with the last patches applied
# The new ISO will generated by applying all the patches on the Mini Ubuntu Remix ISO
# run with curl: 
# sudo bash -c "$(curl -s https://raw.githubusercontent.com/HFScode/zeos-tools/master/makeiso.sh)"
##################################################################################################


###Check if script is run as root.
if [ "$EUID" -ne 0 ]
  then
      clear
      echo 
      echo "================================="
      echo "Please rerun this script as root."
      echo "================================="
      echo
  exit
fi

##########################################################
# Vars and const
##########################################################
GITPULL="true" #By default a git pull is done
PKGLIST=""
ALLPKG="true" #Install all packages by default
INSTSUCCESS="true" #true of false depends on install success or not
DEFAULZEOSGITPATH="zeos-tools" #Default path for the git repo clone
DEFAULTISORIPPATH="ISO" #Default path for extracting the ISO
readonly DEFAULTPATH="/usr/share/zpkgs" #The default path where to search for the scripts
readonly DEFAULTSCRIPTDIR="$DEFAULZEOSGITPATH/patches/scripts"
readonly INSTPKGLIST="installed.txt" #Default name for the list of already installed pkg
readonly CURRINSTPKGLST="curinstall.txt" #Default name for the list of currently 
                                         #running scripts
readonly ERRORLOG="error.log" #Default name for the error log file"
readonly INSTALLLOG="install.log" #Default name for the install log file
readonly ISONAME="ubuntu-mini-remix-15.10-amd64.iso"
SELF=`basename $0`




usage() {
        echo "Usage: $SELF"
        exit 1
}

failure() {
        echo "$SELF: $@" >&2
        exit 1
}

###Check if UCK is installed
UCKINSTALLED=$(dpkg-query -W --showformat='${Status}\n' uck|grep "install ok installed")
echo "Verifing if UCK is installed"
if [ "" == "$UCKINSTALLED" ]; then
  echo "UCK not installed. Installing..."
  sudo apt-get --force-yes --yes install uck
else
  echo "UCK already installed."
fi



###Download ISO if not already present
echo "Trying to download ISO file"
wget -nc -P $DEFAULTPATH http://ubuntu-mini-remix.mirror.garr.it/mirrors/ubuntu-mini-remix/15.10/$ISONAME

###Search for an existing working-dir if found ask for bakup
if [ -d "$DEFAULTPATH/$DEFAULTISORIPPATH" ]; then
    echo "A previous ISO extract dir was found"
    echo "I need to remove it".
    echo "Do you want me to backup it ?[Y/N]"
    read ANSWER
    if [ $ANSWER == "Y" ] || [ $ANSWER == "y" ]; then
        echo "Please enter a name for your backup :"
        read ANSWER
        mv $DEFAULTPATH/$DEFAULTISORIPPATH $DEFAULTPATH/$ANSWER
    else 
        uck-remaster-clean-all $DEFAULTPATH/$DEFAULTISORIPPATH
    fi
fi

###Unpack ISO
uck-remaster-unpack-iso $DEFAULTPATH/$ISONAME $DEFAULTPATH/$DEFAULTISORIPPATH

###Unpack squashfs
uck-remaster-unpack-rootfs $DEFAULTPATH/$DEFAULTISORIPPATH

###Unpack initrd
#uck-remaster-unpack-initrd $DEFAULTPATH/$DEFAULTISORIPPATH

###Prepare alternate
uck-remaster-prepare-alternate $DEFAULTPATH/$DEFAULTISORIPPATH

###Copy repo files to squashf
mkdir $DEFAULTPATH/$DEFAULTISORIPPATH/remaster-root$DEFAULTPATH/
cd $DEFAULTPATH/$DEFAULTISORIPPATH/remaster-root$DEFAULTPATH/
git clone --depth=1 https://github.com/HFScode/zeos-tools 
chmod +x -R $DEFAULTPATH/$DEFAULTISORIPPATH/remaster-root$DEFAULTPATH/ 
echo "Your environment is ready"
echo "You can manually copy some files to root file system before I chroot it"
echo "Press Enter you're ready to continue...."
read ANSWER
###chroot and run main install script
uck-remaster-chroot-rootfs $DEFAULTPATH/$DEFAULTISORIPPATH $DEFAULTPATH/$DEFAULZEOSGITPATH/install.sh

###Clean squashfs (but keep the installed.txt for further update from the iso)
rm -R $DEFAULTPATH/$DEFAULTISORIPPATH/remaster-root$DEFAULTPATH/$DEFAULZEOSGITPATH
###Repack initrd
#uck-remaster-pack-initrd $DEFAULTPATH/$DEFAULTISORIPPATH
###Repack squashfs
uck-remaster-pack-rootfs $DEFAULTPATH/$DEFAULTISORIPPATH
###Rebuil ISO
uck-remaster-pack-iso hfsbox.iso $DEFAULTPATH/$DEFAULTISORIPPATH -h -d "HFSBOX"

