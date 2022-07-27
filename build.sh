#!/bin/bash

set -eu -o pipefail

dnf install -y \
  git \
  curl \
  zip \
  make \
  livecd-tools

mkdir -p /tmp/kickstart_files/
cp -rfv files/* /tmp/kickstart_files/

git clone --single-branch --branch f36 https://pagure.io/fedora-kickstarts.git /tmp/fedora-kickstarts
cd /tmp/fedora-kickstarts

cp -rfv "/repo"/*.ks ./
mkdir -p /var/cache/live

livecd-creator --verbose --releasever=36 --config="t2linux-fedora-workstation-live.ks" --cache=/var/cache/live

cp -rfv ./*.iso "/repo"/
cd "/repo"

mkdir -p ./output
zip -s 2000m ./output/"t2linux-fedora-workstaion-36-iso.zip" ./*.iso
