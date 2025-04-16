#!/usr/bin/bash
set -e

release="0"
profiles=( "Workstation-Live" )

kiwi_dir="/repo/fedora-kiwi-descriptions"

mkdir -p /repo/builddir/iso
function cleanup {
  rm -rf "/repo/outdir-build"
}
trap cleanup EXIT

for profile in "${profiles[@]}"; do
    rm -rf "/repo/outdir-build"
    "${kiwi_dir}"/kiwi-build \
        --kiwi-file="${kiwi_dir}/Fedora.kiwi" \
        --image-type=iso \
        --image-profile="${profile}" \
        --image-release "${release}" \
        --output-dir "/repo/outdir"
    find /repo/outdir/*.iso -size +2G -exec sh -c 'split -b 1999M -x "$1" "$1". && rm "$1"' shell {} \;
done
