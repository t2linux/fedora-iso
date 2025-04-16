#!/usr/bin/bash
set -e

release="0"
profiles=( "Workstation-Live" "KDE-Desktop-Live" )

repo_dir="$PWD"
kiwi_dir="${repo_dir}/fedora-kiwi-descriptions"

function cleanup {
  rm -rf "${repo_dir}/outdir-build"
}
trap cleanup EXIT

for profile in "${profiles[@]}"; do
    rm -rf "${repo_dir}/outdir-build"
    cd "${kiwi_dir}"
    ./kiwi-build \
        --kiwi-file="Fedora.kiwi" \
        --image-type=iso \
        --image-profile="${profile}" \
        --image-release "${release}" \
        --output-dir "${repo_dir}/outdir"
    find "${repo_dir}/outdir"/*.iso -size +2G -exec sh -c 'split -b 1999M -x "$1" "$1". && rm "$1"' shell {} \;
done
