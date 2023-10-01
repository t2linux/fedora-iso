#!/usr/bin/bash

cd /repo/fedora-kickstarts
cp -rfv /repo/*.ks .
sudo ksflatten -c t2linux-fedora-workstation-live.ks -o flat.ks

livemedia-creator --ks flat.ks --no-virt --resultdir /var/lmc --project Fedora-Workstation-Live-t2linux --make-iso --volid Fedora-WS-Live-t2-38-3.0.0 --iso-only --iso-name Fedora-Workstation-Live-t2linux-x86_64-38-3.0.0.iso --releasever 38

mkdir -p _output && mv /var/lmc/*.iso _output/
