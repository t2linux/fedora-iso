#!/usr/bin/bash
set -e

profiles=( "Workstation-Live" )

mkdir -p /repo/builddir/iso

if [ -e "/sys/fs/selinux/enforce" ]; then
    # Disable SELinux enforcement during the build if it's enforcing
    selinux_enforcing="$(cat /sys/fs/selinux/enforce)"
    if [ "$selinux_enforcing" = "1" ]; then
        setenforce 0
    fi
fi

for profile in "${profiles[@]}"; do
    rm -rf /var/kiwi/build; mkdir -p /var/kiwi/{build,tmp}
    kiwi-ng \
        --debug \
        --color-output \
        --temp-dir /var/kiwi/tmp \
        --type iso \
        --profile Workstation-Live \
        system build \
        --description /repo \
        --target-dir /var/kiwi/build
    find \
        /var/kiwi/build/*.iso \
        -size +2G \
        -exec sh -c "split -b 1999M -x {} {}. && rm {}" \;
    mv /var/kiwi/build/* /repo/builddir/iso/
done

if [ -e "/sys/fs/selinux/enforce" ]; then
    # Re-enable SELinux enforcement now that the build is done
    if [ "$selinux_enforcing" = "1" ]; then
        setenforce 1
    fi
fi
