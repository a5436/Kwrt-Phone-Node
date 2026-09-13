#!/bin/bash

SHELL_FOLDER=$(dirname $(readlink -f "$0"))

#bash $SHELL_FOLDER/../common/kernel_6.6.sh

sed -i 's/Os/O2/g' include/target.mk

git_clone_path master https://github.com/coolsnowwolf/lede target/linux/x86/files target/linux/x86/patches-6.12

wget -N https://github.com/coolsnowwolf/lede/raw/refs/heads/master/target/linux/x86/Makefile -P target/linux/x86/
sed -i -e "s/ autocore-x86//" \
       -e "s/ automount//" target/linux/x86/Makefile

sed -i 's/kmod-r8169/kmod-r8168/' target/linux/x86/image/generic.mk

sed -i 's/256/1024/g' target/linux/x86/image/Makefile

sed -i "s/DEVICE_MODEL := x86/DEVICE_MODEL := x86\/32/" target/linux/x86/image/generic.mk


