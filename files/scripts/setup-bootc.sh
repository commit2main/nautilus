#!/usr/bin/env bash
set -euxo pipefail

# Preserve bootc metadata used by bootloader update flows.
if command -v bootupctl >/dev/null 2>&1; then
  bootupctl backend generate-update-metadata
fi

# Redirect tmpfiles root-home handling to /var/roothome for immutable layout.
sed -i -e 's, /root, /var/roothome,' -e '/^d- \/var\/roothome /d' /usr/lib/tmpfiles.d/provision.conf
