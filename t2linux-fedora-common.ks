repo --install --name=t2linux-fedora --cost=98 --baseurl=https://t2linux-fedora-repo.netlify.app/repo/

bootloader --append="intel_iommu=on iommu=pt pcie_ports=compat"

%packages

curl
kernel-*.t2.*
-shim-ia32-15.[0-9]*-[0-9].x86_64
-shim-x64-15.[0-9]*-[0-9].x86_64

%end

%post
setenforce 0
echo -e 'hid-apple\nbcm5974\nsnd-seq\napple_bce' > /etc/modules-load.d/apple_bce.conf
echo -e 'add_drivers+=" hid_apple snd-seq apple_bce "\nforce_drivers+=" hid_apple snd-seq apple_bce "' > /etc/dracut.conf
dracut -f

%end

%post --nochroot

### Copy audio config files
mkdir -p ${INSTALL_ROOT}/usr/share/alsa/cards/
cp -rfv /tmp/kickstart_files/audio/AppleT2.conf ${INSTALL_ROOT}/usr/share/alsa/cards/AppleT2.conf
cp -rfv /tmp/kickstart_files/audio/apple-t2.conf ${INSTALL_ROOT}/usr/share/alsa-card-profile/mixer/profile-sets/apple-t2.conf
cp -rfv /tmp/kickstart_files/audio/91-pulseaudio-custom.rules ${INSTALL_ROOT}/usr/lib/udev/rules.d/91-pulseaudio-custom.rules

### Copy suspend fix
cp -rfv /tmp/kickstart_files/suspend/rmmod_tb.sh ${INSTALL_ROOT}/lib/systemd/system-sleep/rmmod_tb.sh
chmod +x ${INSTALL_ROOT}/lib/systemd/system-sleep/rmmod_tb.sh

%end
