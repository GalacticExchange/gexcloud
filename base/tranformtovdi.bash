#! /bin/bash
VBoxManage internalcommands sethduuid "$1.vmdk"
VBoxManage clonehd "$1.vmdk" "$1.vdi" --format vdi
VBoxManage modifyhd "$1.vdi" --resize 256000
VBoxManage internalcommands sethduuid "$1.vmdk"
VBoxManage clonehd "$1.vdi" "$1.vmdk" --format vmdk
rm -rf $1.vmdk
mv -rf $1.vmdk 
