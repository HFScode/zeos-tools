#!/bin/bash


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

DEFAULZEOSGITPATH="zeos-tools" #Default path for the git repo clone
INSTSUCCESS="true" #true of false depends on install success or not
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
function checklock {
    echo "Checking for a file lock on $1"
    INFLOOPWARNING="false"
    grep -Fxq "$1" $DEFAULTPATH/$CURRINSTPKGLST
    if [ $? == "0" ]; then
	INFLOOPWARNING="true"
    fi
    grep -Fxq "bypass" $DEFAULTPATH/$CURRINSTPKGLST
      if [ $? == "0" ]; then
	INFLOOPWARNING="false"
    fi  
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
            exit 1
        elif [ $REMOVELOCK == "Y" ] || [ $REMOVELOCK == "y" ]; then
	      echo "bypass" >> $DEFAULTPATH/$CURRINSTPKGLST
              echo "BYPASS MODE ENABLED"
        else
            INSTSUCCESS="false"
            exit 1
        fi

    fi
    }


#########################################################################################
# Variables and constants
#########################################################################################

echo "Installing prequisite package $1"
echo "checking for file lock"
checklock $1
echo ">>>Installing package $1"
#Put a lock on this script to avoid recursive calls
echo $1 >> $DEFAULTPATH/$CURRINSTPKGLST
echo "Checking if package alread installed"
grep -Fxq "$1" $DEFAULTPATH/$INSTPKGLIST
if [ $? != "0" ]; then
    echo "Script is not installed"
    echo "Running $1 script at path : $DEFAULTPATH/$DEFAULTSCRIPTDIR/$1"
    echo 
    echo
    if [ -f $DEFAULTPATH/$DEFAULTSCRIPTDIR/$1 ]; then
        echo "+++++    $1 script output   +++++"
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
    echo "+++++End of $1 script output+++++"
else
    echo "Package $1 already installed. Ignoring"
fi
echo 
echo
#remove lock for this file
echo "Removing lock for $1"
sed -i "/$1/d" $DEFAULTPATH/$CURRINSTPKGLST
###Exit
if [ $INSTSUCCESS != "true" ]; then
    exit 1
fi
exit 0
