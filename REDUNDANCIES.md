# Intentional deltas from Zirconium

Nautilus ports config from [Zirconium](https://github.com/zirconium-dev/zirconium).
Zirconium builds from scratch with mkosi; Nautilus starts from
`ghcr.io/blue-build/base-images/fedora-base`, which already provides some of that config.
The items below were removed or trimmed here because they are redundant on this base or
within the repo. Use this list when diffing against Zirconium so they aren't re-added.

Checked against `fedora-base:45` on 2026-11-07.

## Redundant with the base image

| Removed from Nautilus | Zirconium source | Provided by base image |
|---|---|---|
| `setup-bootc.sh`: `HOME=/var/home` sed, `rm -rf` + rootfs symlinks (`/home`, `/root`, `/mnt`, `/media`, `/srv`, `/opt`, `/ostree`, `/usr/local`) | `mkosi.profiles/bootc-ostree/mkosi.postinst.chroot` | symlinks and `/etc/default/useradd` already set |
| `setup-bootc.sh`: `local-fs.target.wants/tmp.mount` link | same | shipped by systemd |
| `setup-system.sh`: `newuidmap`/`newgidmap` chmod | Zirconium postinst | already `0755`, not setuid |
| `setup-system.sh`: SELinux `store-root` + policy store copy | Zirconium postinst | `store-root=/etc/selinux` set, `/etc/selinux/targeted/active` present |
| `usr/lib/tmpfiles.d/bootc-base-directories.conf` | `bootc-ostree/mkosi.extra` | `rpm-ostree-0-integration*.conf`, `rpm-ostree-autovar.conf` |
| `usr/lib/systemd/journald.conf.d/10-bootc-persistent.conf` | `bootc-ostree/.../10-persistent-journald.conf` | `journald.conf.d/10-persistent.conf` |
| `usr/lib/systemd/zram-generator.conf` | `bootc-ostree/mkosi.extra` | same setting from `zram-generator-defaults` |
| `usr/share/dnf5/libdnf.conf.d/20-ostree-installonlypkgs.conf` | `bootc-ostree/mkosi.extra` | byte-identical file |
| `dracut.conf.d/20-bootc-base.conf`: `hostonly=no`, `ostree` module (file kept, lines trimmed) | `bootc-ostree/mkosi.extra` | `20-atomic-nohostonly.conf`, `20-atomic-bootc-ostree.conf` |
| `dracut.conf.d/bootc-initramfs.conf` | `bootc-ostree/mkosi.extra` | `reproducible=yes` (`01-dist.conf`), `compress=zstd` (`10-compression.conf`), `hostonly`/`ostree` as above |
| `dracut.conf.d/49-bootc-tpm2-tss.conf` | `bootc-ostree/mkosi.extra` | `20-atomic-tpm-luks.conf` |

## Duplicated within the repo

| Removed from Nautilus | Zirconium source | Reason |
|---|---|---|
| `dracut.conf.d/lvm2.conf` | `zirconium-bootc-ostree/mkosi.extra` | byte-identical to `30-bootc-standard.conf` |
| `xdg-user-dirs` in `dnf/extras.yml` | `zirconium.conf` | also in `dnf/base.yml` (from `base-desktop.conf`) |
| `glibc-minimal-langpack` in `dnf/base.yml` | `base/.../base.conf` | superseded by `glibc-all-langpacks` |
| `google-noto-color-emoji-fonts` in `dnf/extras.yml` | `zirconium.conf` | required by `default-fonts-core-emoji` |
| `custom-flatpaks.yml` merged into `default-flatpaks.yml` | `default-flatpaks.yml` mirrored `zirconium.preinstall` (TextEditor not installed) | same module settings |
| Commented `remove:` entries in `dnf/extras.yml` | — | duplicated `exclude:` in `dnf/niri.yml` |
| Commented `foot` package and `foot-server` units | `zirconium.conf`, `01-zirconium.preset` | replaced by kitty |
| `setup-bootc.sh`: duplicate `/usr/local` in `rm -rf`, `> /dev/null` on `sed -i` | Zirconium postinst | removed with the block above; the redirect worked around rpm-ostree#5388 |

## Moved or changed

| Nautilus change | Zirconium source | Reason |
|---|---|---|
| `profile.d/fcitx5.sh`, `font-settings.sh`, `dms-vars.sh` (and Nautilus' `proton.sh`) → `usr/lib/environment.d/60-nautilus.conf`; matching `99-factory.conf` lines dropped | `factory/etc/profile.d/fcitx5.sh`, `zirconium-font-settings.sh`, `zirconium-dms-vars.sh` | fish doesn't source `/etc/profile.d`; environment.d reaches the user manager, niri and services regardless of shell |
| `setup-system.sh`: `AutomaticUpdatePolicy=stage` sed dropped (`LockLayering` kept) | `bootc-ostree/mkosi.postinst.chroot` | uupd owns updates; `bootc-fetch-apply-updates.timer` is disabled |
