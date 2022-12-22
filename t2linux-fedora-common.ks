repo --name=tmp --cost=98 --baseurl=https://t2linux-fedora-repo.netlify.app/

bootloader --append="intel_iommu=on iommu=pt pcie_ports=compat"

%packages

kernel-*.t2.*
t2linux-config
t2linux-repo
python3-blivet-3.5.0

%end
