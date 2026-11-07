#!/usr/bin/env bash
set -euxo pipefail

# talosctl isn't packaged by Fedora or Terra. Fetch the latest upstream release
# and verify its sigstore bundle against siderolabs' release workflow for that
# exact tag, so a tampered binary or re-uploaded asset fails the build.
repo=https://github.com/siderolabs/talos
tag=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "$repo/releases/latest")
tag=${tag##*/}
[[ $tag =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/talosctl" "$repo/releases/download/$tag/talosctl-linux-amd64"
curl -fsSL -o "$tmp/talosctl.bundle" "$repo/releases/download/$tag/talosctl-linux-amd64.bundle"

# /root is a dangling symlink on atomic images; keep cosign's TUF cache in tmp.
HOME=$tmp cosign verify-blob \
  --bundle "$tmp/talosctl.bundle" \
  --certificate-identity "$repo/.github/workflows/ci.yaml@refs/tags/$tag" \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  "$tmp/talosctl"

install -Dm0755 "$tmp/talosctl" /usr/bin/talosctl
