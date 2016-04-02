# zeos-tools
This repository contains tools for developing and building zeos iso image.

- the install.sh script is executed via curl on an installed distribution vm-image
- install.sh downloads stuff from /patches to installation, or modify installation directly (with rm, sed, etc)
- things are tested locally by user
- when everything seems ok, makeiso.sh is used to build an installable iso image

## Quick Start
Download the last version of the ISO or build it (see below) and install it on your VM then from a terminal on your VM type :
```shell
sudo bash -c "$(curl -s https://raw.githubusercontent.com/HFScode/zeos-tools/master/install.sh)"
```

This command allows two parameters :
* ``--gitpull or -p`` that must be set to true or false (true by default) and that will make the script to clone or pull the git repo
* ``--pkglist or -l`` that must be a path to a text file that contains the list of update scripts to be run.

If you don’t specify any argument, the script will download and install all the patches, which is normally what you’ll want.

## Building the ISO

To build a fresh ISO with all the patches applied use :
```shell
sudo bash -c "$(curl -s https://raw.githubusercontent.com/HFScode/zeos-tools/master/makeiso.sh)"
```

Building a complete ISO is really time, disk space and proc ressources consuming. Don't do that on your production computer.

