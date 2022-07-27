#!/bin/bash

set -eu -o pipefail

dnf install -y \
  git \
  curl \
  zip \
  make \
  livecd-tools

mkdir -p /tmp/kickstart_files/
cp -rf /repo/files/* /tmp/kickstart_files/

git clone --single-branch --branch 36 https://pagure.io/fedora-kickstarts.git
cd fedora-kickstarts
git checkout 36

cp -rfv /repo/t2linux-fedora-*.ks ./

livecd-creator --verbose --releasever=36 --config="t2linux-fedora-live-workstation.ks"

cp -rfv ./*.iso /output/
