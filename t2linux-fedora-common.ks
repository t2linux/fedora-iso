repo --name="copr_copr.fedorainfracloud.org_sharpenedblade_t2linux" --cost=80 --baseurl=https://download.copr.fedorainfracloud.org/results/sharpenedblade/t2linux/fedora-$releasever-$basearch/

bootloader --append="intel_iommu=on iommu=pt mem_sleep=s2idle"

%packages

kernel-core*.t2.*
t2linux-config
copr-sharpenedblade-t2linux-release

%end
