#!/bin/bash

set -eu -o pipefail

dnf install -y --quiet git pykickstart lorax anaconda lorax-lmc-novirt

git clone --quiet --single-branch --depth 1 --branch f37 https://pagure.io/fedora-kickstarts.git /var/fedora-kickstarts
cd /var/fedora-kickstarts
cp -rfv "/repo"/*.ks ./
sudo ksflatten -c t2linux-fedora-workstation-live.ks -o flat.ks

livemedia-creator --ks flat.ks --no-virt --resultdir /var/lmc --project Fedora-Workstation-t2linux-Live --make-iso --volid Fedora-WS-t2-Live-37-1.7 --iso-only --iso-name Fedora-Workstation-t2linux-Live-x86_64-37-1.7.iso --releasever 37

cp -rfv /var/lmc/*.iso "/repo"/
cd "/repo"

mkdir -p ./output
if (( $(stat -c%s *.iso) > 199999999 )); then
    mv *.iso ./output/
else
    split -b 2000M -x ./*.iso  ./output/Fedora-Workstation-t2linux-Live-x86_64-37-1.7.iso. 
fi
