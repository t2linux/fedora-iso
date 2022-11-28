repo --name=tmp --cost=98 --baseurl=https://t2linux-fedora-repo.netlify.app/repo/

bootloader --append="intel_iommu=on iommu=pt pcie_ports=compat"

%packages

kernel-*.t2.*
t2linux-config
t2linux-repo

%end

%post

if cat /etc/fstab | grep hfsplus ; then
    EFI_DEV=$(df | grep boot/efi | tail -1 | awk '{print $1}')
    EFI_PARTITION=${EFI_DEV: -1}
    mkdir -p /tmp/efi_backup
    shopt  -s dotglob
    cp -rf /boot/efi/* /tmp/efi_backup/
    fuser -k /boot/efi
    umount $EFI_DEV
    mkfs.vfat $EFI_DEV
    mount $EFI_DEV /boot/efi/
    cp -rf /tmp/efi_backup/* /boot/efi/
    umount $EFI_DEV

    parted ${EFI_DEV::-1} set ${EFI_PARTITION} esp on
    mount $EFI_DEV /boot/efi
    rm -rf /tmp/efi_backup
    sed -i '/hfsplus/d' /etc/fstab
    EFI_FAT_UUID=$(blkid ${EFI_DEV} -o export | grep -e '^UUID')
    echo "${EFI_FAT_UUID} /boot/efi vfat defaults 0 2" >> /etc/fstab
    grub2-mkconfig -o /boot/grub2/grub.cfg
fi

%end
