#!/usr/bin/env bash
set -euxo pipefail

if [ -f /etc/rpm-ostreed.conf ]; then
  sed -i 's|#LockLayering.*|LockLayering=true|' /etc/rpm-ostreed.conf
fi

# Rebuild font cache for newly layered font packages.
if command -v fc-cache >/dev/null 2>&1; then
  fc-cache --really-force --system-only --verbose
fi

# Existing installs have /etc/containers/policy.json symlinked to the old
# factory copy; point that path at the image's default policy (which carries
# the signing module's sigstore entry) so the symlink doesn't dangle.
mkdir -p /usr/share/factory/etc/containers
ln -sf /usr/etc/containers/policy.json /usr/share/factory/etc/containers/policy.json
