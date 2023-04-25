#!/bin/bash

set -eu -o pipefail

dnf install -y --quiet git pykickstart lorax anaconda lorax-lmc-novirt

git clone --quiet --single-branch --depth 1 --branch f38 https://pagure.io/fedora-kickstarts.git /var/fedora-kickstarts
cd /var/fedora-kickstarts
cp -rfv "/repo"/*.ks ./
sudo ksflatten -c t2linux-fedora-workstation-live.ks -o flat.ks

livemedia-creator --ks flat.ks --no-virt --resultdir /var/lmc --project Fedora-Workstation-Live-t2linux --make-iso --volid Fedora-WS-Live-t2-38-3.0.0 --iso-only --iso-name Fedora-Workstation-Live-t2linux-x86_64-38-3.0.0.iso --releasever 38

cp -rfv /var/lmc/*.iso "/repo"/
cd "/repo"

mkdir -p ./output
if (( $(stat -c%s *.iso) > 199999999 )); then
    mv *.iso ./output/
else
    split -b 2000M -x ./*.iso  ./output/Fedora-Workstation-Live-t2linux-x86_64-38-2.0.0.iso. 
fi
