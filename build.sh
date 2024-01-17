#!/usr/bin/bash
set -e

profiles=( "Workstation-Live" "KDE-Live" )

mkdir -p /repo/builddir/iso
builddir=$(mktemp -d); export builddir
function cleanup {
    rm -rf "$builddir"
}
trap cleanup EXIT

for profile in "${profiles[@]}"; do
    profile_builddir="$builddir/$profile";
    mkdir -p $profile_builddir; cd "$profile_builddir"
    /repo/kiwi-build \
        --image-type=iso \
        --image-profile="$profile" \
        --kiwi-description-dir=/repo/ \
        --output-dir results
    find \
        results/*.iso \
        -size +2G \
        -exec sh -c "split -b 1999M -x {} {}. && rm {}" \;
    mv results/* /repo/builddir/iso/
done
cleanup
