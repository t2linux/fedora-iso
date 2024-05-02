# %post script to include initial metadata for PackageKit

%post --nochroot
# Copy over files needed for networking inside the chroot
for f in /etc/resolv.conf /etc/hosts ; do
  test -f $f && cp $f /mnt/sysimage/$f.kickstart
done
%end

%post

# Use host machine's resolv.conf and hosts files
for f in /etc/resolv.conf /etc/hosts ; do
  test -f $f && mv $f $f.orig
  test -f $f.kickstart && mv -f $f.kickstart $f
done

PK_PREFIX=`mktemp -d`
mkdir -p $PK_PREFIX/etc/yum.repos.d
if [ -f /etc/yum.repos.d/fedora.repo ] ; then
  cp /etc/yum.repos.d/fedora.repo $PK_PREFIX/etc/yum.repos.d/
  sed -i -e 's|^metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-$releasever&arch=$basearch|baseurl=https://kojipkgs.fedoraproject.org/compose/branched/latest-Fedora-/compose/Everything/$basearch/os/|' \
         $PK_PREFIX/etc/yum.repos.d/fedora.repo
fi
if [ -f /etc/yum.repos.d/fedora-updates.repo ] ; then
  cp /etc/yum.repos.d/fedora-updates.repo $PK_PREFIX/etc/yum.repos.d/
  sed -i -e 's|^metalink=https://mirrors.fedoraproject.org/metalink?repo=updates-released-f$releasever&arch=$basearch|baseurl=https://kojipkgs.fedoraproject.org/mash/updates/f$releasever-updates/$basearch/|' \
         $PK_PREFIX/etc/yum.repos.d/fedora-updates.repo
fi
if [ -f /etc/yum.repos.d/fedora-updates-testing.repo ] ; then
  cp /etc/yum.repos.d/fedora-updates-testing.repo $PK_PREFIX/etc/yum.repos.d/
  sed -i -e 's|^metalink=https://mirrors.fedoraproject.org/metalink?repo=updates-testing-f$releasever&arch=$basearch|baseurl=https://kojipkgs.fedoraproject.org/mash/updates/f$releasever-updates-testing/$basearch/|' \
         $PK_PREFIX/etc/yum.repos.d/fedora-updates-testing.repo
fi
if [ -f /etc/yum.repos.d/fedora-rawhide.repo ] ; then
  cp /etc/yum.repos.d/fedora-rawhide.repo $PK_PREFIX/etc/yum.repos.d/
  sed -i -e 's|^metalink=https://mirrors.fedoraproject.org/metalink?repo=rawhide&arch=$basearch|baseurl=https://kojipkgs.fedoraproject.org/compose/rawhide/latest-Fedora-/compose/Everything/$basearch/os/|' \
         $PK_PREFIX/etc/yum.repos.d/fedora-rawhide.repo
fi
rpm --root=$PK_PREFIX --initdb
DESTDIR=$PK_PREFIX /usr/libexec/packagekit-direct refresh
if [ -d /var/cache/PackageKit ] ; then
  mv $PK_PREFIX/var/cache/PackageKit/* /var/cache/PackageKit/
fi
rm -rf $PK_PREFIX

# Restore original resolv.conf and hosts files
for f in /etc/resolv.conf /etc/hosts ; do
  rm -f $f
  test -f $f.orig && mv $f.orig $f
done

%end
