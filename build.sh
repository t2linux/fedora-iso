#!/usr/bin/bash
set -e

kickstarts=( "fedora-live-workstation" )

mkdir -p /repo/builddir/iso
builddir=$(mktemp -d -p "/repo/builddir"); export builddir
function cleanup {
  rm -rf "$builddir"
}
trap cleanup EXIT

for ks in "${kickstarts[@]}"; do
    ks_builddir="$builddir/$ks"; mkdir -p $ks_builddir; cd "$ks_builddir"
    cp -r /repo/fedora-kickstarts/* .; cp -f /repo/*.ks .
    echo '%include t2linux-fedora-common.ks' >> "$ks.ks"
    sudo ksflatten --config "$ks.ks" --output "$ks-flat.ks" --version F39
    livemedia-creator \
        --make-iso \
        --iso-only \
        --no-virt \
        --resultdir results \
        --releasever 39 \
        --ks "$ks-flat.ks" \
        --project t2linux-Fedora-Live \
        --volid t2linux-Fedora-Live-39 \
        --iso-name "t2linux-$ks-39.iso"
    find results/*.iso -size +2G -exec sh -c "split -b 1999M -x {} {}. && rm {}" \;
    mv results/* /repo/builddir/iso/
done
cleanup
