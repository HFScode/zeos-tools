# zeos-tools
This repository contains tools for developing and building zeos iso image.

- the install.sh script is executed via curl on an installed distribution vm-image
- install.sh downloads stuff from /patches to installation, or modify installation directly (with rm, sed, etc)
- things are tested locally by user
- when everything seems ok, makeiso.sh is used to build an installable iso image
