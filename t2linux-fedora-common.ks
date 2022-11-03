repo --name=tmp --cost=98 --baseurl=https://t2linux-fedora-repo.netlify.app/repo/

bootloader --append="intel_iommu=on iommu=pt pcie_ports=compat"

%packages

curl
kernel-*.t2.*
t2linux-config
t2linux-repo

%end

%post
setenforce 0
dracut -f

%end
