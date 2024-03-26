#!/bin/sh
echo "###" "$0" "$@"

# set arch-specific variables
case "$(uname -m)" in
    aarch64) arch="aa64"; ARCH="AA64"; uuid="b921b045-1df0-41c3-af44-4c6f280d3fae"; rootfs="2";;
    x86_64)  arch="x64";  ARCH="X64";  uuid="4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709"; rootfs="3";;
esac

# figure where shim.efi and BOOT.CSV are located
shim="$(ls boot/efi/EFI/*/shim${arch}.efi)"
csv="${shim%/*}/BOOT${ARCH}.CSV"

# copy UKI images (typically one) to ${ESP}/EFI/Linux and
# generate BOOT.CSV with one entry per UKI.
echo "# csv: $csv"
echo -ne '\xff\xfe' > "$csv"
for uki in lib/modules/*/vmlinuz*.efi; do
    echo "# uki: $uki"
    ver=${uki#lib/modules/}
    ver=${ver%/*}
    mkdir -p boot/efi/EFI/Linux
    cp --reflink=auto $uki boot/efi/EFI/Linux/${ver}.efi
    echo "shim${arch}.efi,$ver,\\EFI\\Linux\\${ver}.efi ,Comment" \
        | iconv -f utf-8 -t ucs-2le >> "$csv"
done

# kiwi doesn't setup discoverable partitions, so fixup after the fact
# here.  The UKI depends on that to find the root filesystem.
#  * The image is loop-mounted, partitions:
#    - biosboot (on x86 only, can this be disabled?).
#    - EFI ESP.
#    - root filesystem (this needs fixup).
echo "# hack: rootfs: $uuid"
sfdisk --part-type /dev/loop0 "$rootfs" "$uuid"

# bz2240989: shim has a hard dependency on grub.  grub has a hard
# dependency on dracut.  Ideally we would simply not install
# grub+dracut, but given we can't until the shim bug is fixed disable
# their kernel-install plugins instead.
echo "# hack: kernel-install - disable plugins"
touch etc/kernel/install.d/20-grub.install
touch etc/kernel/install.d/50-dracut.install

# package install ran kernel-install scripts, cleanup the leftovers.
echo "# hack: kernel-install - cleanup leftovers"
rm -v boot/initramfs*
rm -v boot/EFI/Linux/*
