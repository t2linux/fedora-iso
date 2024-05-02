# fedora-livecd-sway.ks
#
# Description:
# - Fedora Live Spin with the tiling window manager Sway
#
# Maintainer(s):
# - Aleksei Bavshin         <alebastr89@gmail.com>
# - Jiří Konečný            <jkonecny@redhat.com>
# - Anthony Rabbito         <hello@anthonyrabbito.com>
# - Fabio Alessandro Locati <me@fale.io>

%include fedora-live-base.ks
%include fedora-live-minimization.ks
%include fedora-sway-common.ks

%packages
# To be able to show installation instructions on background
nwg-wrapper
%end

%post
# create /etc/sysconfig/desktop (needed for installation)
cat > /etc/sysconfig/desktop <<EOF
PREFERRED=/usr/bin/sway
DISPLAYMANAGER=/bin/sddm
EOF

# set livesys session type
sed -i 's/^livesys_session=.*/livesys_session="sway"/' /etc/sysconfig/livesys

%end

