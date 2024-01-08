#!/bin/bash

set -euxo pipefail

#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]-[$kiwi_profiles]..."

#======================================
# Set SELinux booleans
#--------------------------------------
if [[ "$kiwi_profiles" != *"Container"* ]]; then
	## Fixes KDE Plasma, see rhbz#2058657
	setsebool -P selinuxuser_execmod 1
fi

#======================================
# Clear machine specific configuration
#--------------------------------------
## Clear machine-id on pre generated images
rm -f /etc/machine-id
echo 'uninitialized' > /etc/machine-id
## remove random seed, the newly installed instance should make its own
rm -f /var/lib/systemd/random-seed

#======================================
# Configure grub correctly
#--------------------------------------
if [[ "$kiwi_profiles" != *"Container"* ]]; then
	## Works around issues with grub-bls
	## See: https://github.com/OSInside/kiwi/issues/2198
	echo "GRUB_DEFAULT=saved" >> /etc/default/grub
	## Disable submenus to match Fedora
	echo "GRUB_DISABLE_SUBMENU=true" >> /etc/default/grub
	## Disable recovery entries to match Fedora
	echo "GRUB_DISABLE_RECOVERY=true" >> /etc/default/grub
fi

#======================================
# Delete & lock the root user password
#--------------------------------------
if [[ "$kiwi_profiles" == *"Cloud"* ]] || [[ "$kiwi_profiles" == *"Live"* ]]; then
	passwd -d root
	passwd -l root
fi

#======================================
# Setup default services
#--------------------------------------

if [[ "$kiwi_profiles" == *"Live"* ]]; then
	## Configure livesys session
	if [[ "$kiwi_profiles" == *"GNOME"* ]]; then
		echo 'livesys_session="gnome"' > /etc/sysconfig/livesys
	fi
	if [[ "$kiwi_profiles" == *"KDE"* ]]; then
		echo 'livesys_session="kde"' > /etc/sysconfig/livesys
	fi
fi

#======================================
# Setup default target
#--------------------------------------
if [[ "$kiwi_profiles" != *"Container"* ]]; then
	if [[ "$kiwi_profiles" == *"GNOME"* ]] || [[ "$kiwi_profiles" == *"KDE"* ]]; then
		systemctl set-default graphical.target
	else
		systemctl set-default multi-user.target
	fi
fi

#======================================
# Setup default customizations
#--------------------------------------

if [[ "$kiwi_profiles" == *"Azure"* ]]; then
cat > /etc/ssh/sshd_config.d/50-client-alive-interval.conf << EOF
ClientAliveInterval 120
EOF

cat >> /etc/chrony.conf << EOF
# Azure's virtual time source:
# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/time-sync#check-for-ptp-clock-source
refclock PHC /dev/ptp_hyperv poll 3 dpoll -2 offset 0
EOF
fi

if [[ "$kiwi_profiles" == *"GCE"* ]]; then
cat <<EOF > /etc/NetworkManager/conf.d/gcp-mtu.conf
# In GCP it is recommended to use 1460 as the MTU.
# Set it to 1460 for all connections.
# https://cloud.google.com/network-connectivity/docs/vpn/concepts/mtu-considerations
[connection]
ethernet.mtu = 1460
EOF
fi

if [[ "$kiwi_profiles" == *"Vagrant"* ]]; then
sed -e 's/.*UseDNS.*/UseDNS no/' -i /etc/ssh/sshd_config
mkdir -m 0700 -p ~vagrant/.ssh
cat > ~vagrant/.ssh/authorized_keys << EOKEYS
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOKEYS
chmod 600 ~vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant ~vagrant/.ssh/

cat > /etc/ssh/sshd_config.d/10-vagrant-insecure-rsa-key.conf <<EOF
# For now the vagrant insecure key is an rsa key
# https://github.com/hashicorp/vagrant/issues/11783
PubkeyAcceptedKeyTypes=+ssh-rsa
EOF

# Further suggestion from @purpleidea (James Shubin) - extend key to root users as well
mkdir -m 0700 -p /root/.ssh
cp /home/vagrant/.ssh/authorized_keys /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
chown -R root:root /root/.ssh
fi

if [[ "$kiwi_profiles" == *"Container"* ]]; then
	# Set install langs macro so that new rpms that get installed will
	# only install langs that we limit it to.
	LANG="en_US"
	echo "%_install_langs $LANG" > /etc/rpm/macros.image-language-conf

	# https://bugzilla.redhat.com/show_bug.cgi?id=1727489
	echo 'LANG="C.UTF-8"' >  /etc/locale.conf

	# https://bugzilla.redhat.com/show_bug.cgi?id=1400682
	echo "Import RPM GPG key"
	releasever=$(rpm --eval '%{?fedora}')

	# When building ELN containers, we don't have the %{fedora} macro
	if [ -z $releasever ]; then
		releasever=eln
	fi

	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-primary

	echo "# fstab intentionally empty for containers" > /etc/fstab

	# Remove machine-id on pre generated images
	rm -f /etc/machine-id
	touch /etc/machine-id

	echo "# resolv placeholder" > /etc/resolv.conf
	chmod 644 /etc/resolv.conf

	# Remove extraneous files
	rm -rf /tmp/*

	# https://pagure.io/atomic-wg/issue/308
	printf "tsflags=nodocs\n" >>/etc/dnf/dnf.conf

	if [[ "$kiwi_profiles" == *"Base-Generic-Minimal"* ]]; then
		# remove some random help txt files
		rm -fv /usr/share/gnupg/help*.txt

		# Pruning random things
		rm /usr/lib/rpm/rpm.daily
		rm -rfv /usr/lib64/nss/unsupported-tools/  # unsupported

		# Statically linked crap
		rm -fv /usr/sbin/{glibc_post_upgrade.x86_64,sln}
		ln /usr/bin/ln usr/sbin/sln

		# Remove some dnf info
		rm -rfv /var/lib/dnf

		# don't need icons
		rm -rfv /usr/share/icons/*

		#some random not-that-useful binaries
		rm -fv /usr/bin/pinky

		# we lose presets by removing /usr/lib/systemd but we do not care
		rm -rfv /usr/lib/systemd
	fi
	if [[ "$kiwi_profiles" == *"Toolbox"* ]]; then
		# Remove macros.image-language-conf file
		rm -f /etc/rpm/macros.image-language-conf

		# Remove 'tsflags=nodocs' line from dnf.conf
		sed -i '/tsflags=nodocs/d' /etc/dnf/dnf.conf
	fi
fi

exit 0
