It's already extracted here so you dont need do it manually..

But never version you must get yourself from link below...

it is not in xbps so need to manually download from https://www.kraxel.org/repos/jenkins/edk2/ as of the writing of this build. Download the ovmf appropriate either 32 or 64 bit version then use

install rpmextract package xbps

rpm2cpio <file>.rpm | xz -d | cpio -idmv
otherwise you could try:

rpm2cpio <file>.rpm | lzma -d | cpio -idmv
to extract the files needed.

./user/share is inside the extracted filesystem

copy files in ./usr/share/edk2.git/ovmf-x64 to /usr/share/ovmf

and then set the config option in /etc/libvirt/qemu.conf

nvram to the appropriate locations. smm varients include secure boot code, csm varients include legacy compat modules.

code and vars are separate files that are both contained in OVMF base.
