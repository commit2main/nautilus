#!/usr/bin/env bash
set -euxo pipefail

# Keep automatic update cadence and staging semantics from legacy image behavior.
if [ -f /usr/lib/systemd/system/bootc-fetch-apply-updates.timer ]; then
  sed -i 's|^OnUnitInactiveSec=.*|OnUnitInactiveSec=7d\nPersistent=true|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer
fi

if [ -f /etc/rpm-ostreed.conf ]; then
  sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf
  sed -i 's|#LockLayering.*|LockLayering=true|' /etc/rpm-ostreed.conf
fi

if [ -f /usr/lib/systemd/system/bootc-fetch-apply-updates.service ]; then
  sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service
fi

# Keep rootless Podman working without setuid uid/gid helpers.
if [ -e /usr/bin/newuidmap ] && [ -e /usr/bin/newgidmap ]; then
  chmod 0755 /usr/bin/newuidmap /usr/bin/newgidmap
  chmod u-s /usr/bin/newuidmap /usr/bin/newgidmap
fi

# Persist SELinux policy store into /etc so policy survives image transitions.
if [ -f /etc/selinux/semanage.conf ]; then
  grep -q "store-root=/etc/selinux" /etc/selinux/semanage.conf || printf "\nstore-root=/etc/selinux\n" >> /etc/selinux/semanage.conf
fi
if [ -d /var/lib/selinux/targeted/active ]; then
  mkdir -p /etc/selinux/targeted
  cp -a /var/lib/selinux/targeted/active /etc/selinux/targeted/
fi
if [ -d /var/lib/selinux/final ]; then
  cp -a /var/lib/selinux/final /etc/selinux/
fi

# Rebuild font cache for newly layered font packages.
if command -v fc-cache >/dev/null 2>&1; then
  fc-cache --force --really-force --system-only --verbose
fi

if [ -e /usr/bin/rechunker-group-fix ]; then
  # Ensure helper is executable even if permissions drift during layering.
  chmod 0755 /usr/bin/rechunker-group-fix
fi
