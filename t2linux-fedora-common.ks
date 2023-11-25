repo --name=tmp-t2linux  --cost=98 --baseurl=https://download.copr.fedorainfracloud.org/results/sharpenedblade/t2linux/fedora-$releasever-$basearch/

bootloader --append="intel_iommu=on iommu=pt"

%packages

kernel-core*.t2.*
t2linux-config
copr-sharpenedblade-t2linux-release

%end
