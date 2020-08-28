echo "$(tput setaf 1)						Installing VGA passthrough$(tput sgr 0)"
echo "#Edit grub: intel_iommu=on OR amd_iommu=on rd.driver.pre=vfio-pci kvm.ignore_msrs=1" >> /etc/default/grub
$EDITOR /etc/default/grub
echo "Updating grub"
grub-mkconfig -o /boot/grub/grub.cfg
echo "Getting GPU passthrough scripts ready"
cp INSTALL/vfio-pci-override-vga.sh /usr/bin/vfio-pci-override-vga.sh
chmod 755 /usr/bin/vfio-pci-override-vga.sh
echo "install vfio-pci /usr/bin/vfio-pci-override-vga.sh" > /etc/modprobe.d/local.conf
cp INSTALL/local.conf /etc/dracut.conf.d/local.conf
echo "Generating initramfs"
dracut -f --kver $(uname -r)
