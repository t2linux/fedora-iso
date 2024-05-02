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

%packages
fedora-release-sway
@^sway-desktop-environment
@firefox
@swaywm-extended
%end
