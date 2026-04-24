#!/usr/bin/env bash
set -euxo pipefail

# Preserve bootc metadata used by bootloader update flows.
if command -v bootupctl >/dev/null 2>&1; then
  bootupctl backend generate-update-metadata
fi

sed -i 's|^HOME=.*|HOME=/var/home|' "/etc/default/useradd"

# Align rootfs layout with ostree/bootc expectations (stateful paths under /var).
rm -rf /home /root /usr/local /srv /opt /mnt /usr/local /boot
mkdir -p /boot /var /sysroot/ostree
ln -sfn sysroot/ostree /ostree
ln -sfnT var/home /home
ln -sfnT var/mnt /mnt
ln -sfnT var/opt /opt
ln -sfnT var/roothome /root
ln -sfnT var/srv /srv
ln -sfnT ../../var/usrlocal /usr/local

# Ensure /tmp is mounted as tmpfs during normal boots.
mkdir -p /usr/lib/systemd/system/local-fs.target.wants
if [ ! -f /usr/lib/systemd/system/local-fs.target.wants/tmp.mount ]; then
  ln -sf ../tmp.mount /usr/lib/systemd/system/local-fs.target.wants/tmp.mount
fi

# Redirect tmpfiles root-home handling to /var/roothome for immutable layout.
sed -i -e 's, /root, /var/roothome,' /usr/lib/tmpfiles.d/provision.conf >/dev/null
sed -i -e '/^d- \/var\/roothome /d' /usr/lib/tmpfiles.d/provision.conf >/dev/null
