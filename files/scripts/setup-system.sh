#!/usr/bin/env bash
set -euxo pipefail

if [ -f /etc/rpm-ostreed.conf ]; then
  sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf
  sed -i 's|#LockLayering.*|LockLayering=true|' /etc/rpm-ostreed.conf
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
  if ! [ /var/lib/selinux/targeted/active -ef /etc/selinux/targeted/active ]; then
    cp -a /var/lib/selinux/targeted/active /etc/selinux/targeted/
  fi
fi
if [ -d /var/lib/selinux/final ]; then
  if ! [ /var/lib/selinux/final -ef /etc/selinux/final ]; then
    cp -a /var/lib/selinux/final /etc/selinux/
  fi
fi

# Rebuild font cache for newly layered font packages.
if command -v fc-cache >/dev/null 2>&1; then
  fc-cache --force --really-force --system-only --verbose
fi

if [ -e /usr/bin/rechunker-group-fix ]; then
  # Ensure helper is executable even if permissions drift during layering.
  chmod 0755 /usr/bin/rechunker-group-fix
fi
