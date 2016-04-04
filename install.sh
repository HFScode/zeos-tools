#!/bin/bash

###################################################################################################
# This script is used to setup the environment in your vitual machine
# Install the base or last available ISO then run with curl :
# sudo bash -c "$(curl -s https://raw.githubusercontent.com/HFScode/zeos-tools/master/install.sh)"
# This will apply the last patches and fix that are not available yet in the last ISO
# To buil a fresh ISO use :
# # sudo bash -c "$(curl -s https://raw.githubusercontent.com/HFScode/zeos-tools/master/makeiso.sh)"
####################################################################################################



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
###We need to be sure that git is installed

GITINSTALLED=$(dpkg-query -W --showformat='${Status}\n' git|grep "install ok installed")
echo "Verifing if git is installed"
if [ "" == "$GITINSTALLED" ]; then
  echo "git not installed. Installing..."
  sudo apt-get --force-yes --yes install git
else
  echo "git already installed."
fi
#########################################################################################
# Arguments
#########################################################################################
# --gitpull or -p :
#   true/false, default true
#    - If true, the script will make a git pull of the repo
#    - If false, the script will try to install without pulling
#      the repo. Be sure to have copied the files manually before.
#
# --pkglist or -l:
#   path to package list file
#   if not specified the script will install all packages
#   if specified, the script will install only the package in the list



#########################################################################################
# Variables and constants
#########################################################################################
GITPULL="true" #By default a git pull is done
PKGLIST=""
ALLPKG="true" #Install all packages by default
INSTSUCCESS="true" #true of false depends on install success or not
DEFAULZEOSGITPATH="zeos-tools" #Default path for the git repo clone
readonly DEFAULTPATH="/usr/share/zpkgs" #The default path where to search for the scripts
readonly DEFAULTSCRIPTDIR="$DEFAULZEOSGITPATH/patches/scripts"
readonly INSTPKGLIST="installed.txt" #Default name for the list of already installed pkg
readonly CURRINSTPKGLST="curinstall.txt" #Default name for the list of currently 
                                         #running scripts
readonly ERRORLOG="error.log" #Default name for the error log file"
readonly INSTALLLOG="install.log" #Default name for the install log file

#########################################################################################
# Function def
#########################################################################################

### Install a package
function installpkg {
    checklock $1
    CHECKRESULT=$?
    if  [ $CHECKRESULT == 1 ]; then
       INSTSUCCESS="false"
    fi
    echo ">>>Installing package $1"
    #Put a lock on this script to avoid recursive calls
    echo $1 >> $DEFAULTPATH/$CURRINSTPKGLST
    echo "Chekching if package $1 is already installed"
    grep -Fxq "$1" $DEFAULTPATH/$INSTPKGLIST
    if [ $? != "0" ]; then
        echo "Script $1 is not installed"
        echo "Running $1 script"
        echo
        echo $DEFAULTPATH/$DEFAULTSCRIPTDIR/$1
        if [ -f $DEFAULTPATH/$DEFAULTSCRIPTDIR/$1 ]; then
            echo "*****    $1 script output   *****"

            $DEFAULTPATH/$DEFAULTSCRIPTDIR/$1
            if [ $? == "0" ]; then
                echo "$1 successfully installed"
	        echo $1 >> $DEFAULTPATH/$INSTPKGLIST
            else
                echo "!!! ERROR WHILE INSTALLING $1 !!!"
                INSTSUCCESS="false"
            fi
        else
                echo "!!! ERROR : SCRIPT NOT FOUND !!!"
                INSTSUCCESS="false"                   
        fi
       echo "*****End of $1 script output*****"
    else
        echo "Package $1 already installed. Ignoring"
    fi
    #remove lock for this file
    echo "Removing lock for $1"
    sed -i "/$1/d" $DEFAULTPATH/$CURRINSTPKGLST
}


### Install a package
function checklock {
    echo "Checking for a file lock on $1 on main script"
    INFLOOPWARNING="false"
    grep -Fxq "$1" $DEFAULTPATH/$CURRINSTPKGLST
    if [ $? == "0" ]; then
        echo "true"
	INFLOOPWARNING="true"
    fi
    grep -Fxq "bypass" $DEFAULTPATH/$CURRINSTPKGLST
      if [ $? == "0" ]; then
	INFLOOPWARNING="false"
    fi  
    echo $INFLOOPWARNING
    if [ $INFLOOPWARNING == "true" ]; then
        echo 
        echo
        echo "**************************************************************************"
        echo "                               WARNING"
        echo "**************************************************************************"
        echo "You are trying to run a script that is already running"
        echo "This is probably due to a recursive call (ie script1 calls script2 and "
        echo "script2 calls script1) and can potentially result to an infinite loop."
        echo "Unless the script you're tring to run again is able to manage infinite"
        echo "loops, this is something that is DISCOURAGED"
        echo "If you are certain that your script will not produce recusive calls of "
        echo "another script then I can remove all locks and let your script run."
        echo "Be warned that **ALL** recursive calls checks will be disabled and I won't"
        echo "be able anymore to prevent **ANY** recursive call"
        echo "**************************************************************************"
        echo "Do you want me to remove **ALL** locks ? [N/y]"
        
        read REMOVELOCK
        if [ $REMOVELOCK == "N" ] || [ $REMOVELOCK == "n" ]; then
            INSTSUCCESS="false"

        elif [ $REMOVELOCK == "Y" ] || [ $REMOVELOCK == "y" ]; then
	      echo "bypass" >> $DEFAULTPATH/$CURRINSTPKGLST
              echo "BYPASS MODE ENABLED"
        else
            INSTSUCCESS="false"
        fi
    fi
}


#########################################################################################
# Main script
#########################################################################################

clear
for i in "$@"
do

case $i in
    -p=*|--gitpull=*)
    GITPULL="${i#*=}"
    if [ $GITPULL != "true" -a $GITPULL != "false" ]; then
        GITPULL="true";
        echo "WARNING : WRONG PARAMETER. >>> -p or --gitpull must be equal to true or false, forcing to true"
    fi
    shift
    ;;
    -l=*|--pkglist=*)
    PKGLIST="${i#*=}"
    ALLPKG="false"
    if [ ! -f $PKGLIST ]; then
        echo "WARNING : WRONG PARAMAETER >>> Package list file not found, installing all the package instead"
        PKGLIST=""
        ALLPKG="true"
     fi
     shift 
     ;;
     *)
            # unknown option, quickly and dirtly ignored
     ;;
esac
done

###Clone/pull the git repo
echo "========================================================"
echo "Entering Git repo update"
echo "========================================================"
echo 
echo "Git Pull required : $GITPULL"
if [ $GITPULL == "true" ]; then
    echo "Updating git repo"
    if [ -d "$DEFAULTPATH/$DEFAULZEOSGITPATH" ]; then
        echo "$DEFAULZEOSGITPATH exists checking if it is git repo"
	cd $DEFAULTPATH/$DEFAULZEOSGITPATH
        ISGITREPO=$(git rev-parse --is-inside-work-tree)
        if [ $ISGITREPO == "true" ]; then
            echo "$DEFAULZEOSGITPATH is a git repo. Pulling..."
            git pull
            cd ..
        else
            echo "$DEFAULZEOSGITPATH is not a git repo. Script will now exit"
            exit 1
        fi
    else
        echo "Git repo does not exists. Script will now clone the last revision..."
	cd $DEFAULTPATH/
        git clone --depth=1 https://github.com/HFScode/zeos-tools        
    fi
    echo "Git repo up to date"
    echo
    echo
else
    echo "Do not update repo."
    echo 
    echo
fi


###Install packages
>$DEFAULTPATH/$INSTPKGLIST
>$DEFAULTPATH/$CURRINSTPKGLST

echo "========================================================"
echo "Entering Install loop"
echo "========================================================"
echo 
if [ $ALLPKG != "false" ]; then
   echo "Info: Installing all packages"
   echo "-----------------------------"
   for PKG in $DEFAULTPATH/$DEFAULTSCRIPTDIR/*.sh
   do
       if [[ -f $PKG ]]; then
          installpkg $(basename $PKG) #Install the package
       fi
   done


else
    echo "Info: Installing selected packages only"
    echo "---------------------------------------"
    echo 
    #Had to use this f***ng for loop to 
    #avoid weird bug with read...
    for PKG in $(cat $PKGLIST); do
       echo $PKG
        [ -z "$PKG" ] && continue #Ingore empty Lines
        installpkg $PKG #Install the package
        
        echo
        echo
    done
fi


###Exit
if [ $INSTSUCCESS != "true" ]; then
    clear
    echo "======================================================="
    echo "ERROR: Some packages have not been correctly installed!"
    echo "======================================================="
    echo "This may result in a unstable installation"
    echo "Please consult"
    echo "    $DEFAULTPATH/$ERRORLOG"
    echo "and" 
    echo "    $DEFAULTPATH/$INSTALLLOG"
    echo "for more information on what went wrong"
    echo "======================================================="
    exit 1
fi

exit 0


