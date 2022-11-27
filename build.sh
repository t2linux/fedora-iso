#!/bin/bash

set -eu -o pipefail

dnf install -y git pykickstart lorax anaconda lorax-lmc-novirt

git clone --single-branch --branch f37 https://pagure.io/fedora-kickstarts.git /tmp/fedora-kickstarts
cd /tmp/fedora-kickstarts
cp -rfv "/repo"/*.ks ./
sudo ksflatten -c t2linux-fedora-workstation-live.ks -o flat.ks

livemedia-creator --ks flat.ks --no-virt --resultdir /var/lmc --project Fedora-Workstation-T2Linux-Live --make-iso --volid Fedora-WS-T2-Live-37-1.7 --iso-only --iso-name Fedora-Workstation-T2Linux-Live-x86_64-37-1.7.iso --releasever 37 --macboot

cp -rfv /var/lmc/*.iso "/repo"/
cd "/repo"

mkdir -p ./output
if (( $(stat -c%s *.iso) > 199999999 )); then
    mv *.iso ./output/
else
    split -b 2000M -x ./*.iso  ./output/t2linux-fedora-workstation-37.iso.
fi
