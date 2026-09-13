#!/bin/bash
set -e
shopt -s extglob
SHELL_FOLDER=$(dirname $(readlink -f "$0"))

sed -i -E -e 's/ ?root=\/dev\/fit0 rootwait//' -e "/rootdisk =/d" -e '/bootargs.* = ""/d' target/linux/mediatek/dts/*{qihoo-360t7,netcore-n60*,h3c-magic-nx30-pro,jdcloud-re-cp-03,cmcc-rax3000m,jcg-q30-pro,tplink-tl-xdr*,abt-asr3000,komi-a31,nokia-ea0326gmp,bt-r320}*.dts*

# Produce a complete persistent UBI image for older U-Boot installations that
# cannot consume the sysupgrade.itb container directly.
python3 - <<'PY'
from pathlib import Path

path = Path("target/linux/mediatek/image/filogic.mk")
data = path.read_text()
start = data.index("define Device/xiaomi_redmi-router-ax6000-ubootmod")
end = data.index("\nendef", start)
block = data[start:end]
if "IMAGE/factory.ubi := append-ubi" not in block:
    block += "\n  IMAGES += factory.ubi\n  IMAGE/factory.ubi := append-ubi"
    data = data[:start] + block + data[end:]
path.write_text(data)
PY

# TK跨境系统 root filesystem overlay (contains no user nodes, MACs or credentials)
mkdir -p files
base64 -d "$SHELL_FOLDER/tk-crossborder-overlay.tar.gz.b64" > /tmp/tk-crossborder-overlay.tar.gz
tar -xzf /tmp/tk-crossborder-overlay.tar.gz -C files
rm -f /tmp/tk-crossborder-overlay.tar.gz
chmod 0755 files/etc/uci-defaults/99-tk-crossborder files/etc/init.d/passwall-smart-incremental files/usr/libexec/passwall-smart/*

# Branding and first-boot LAN address
sed -i 's/Kwrt/TK跨境系统/g' package/base-files/files/bin/config_generate package/base-files/image-config.in config/Config-images.in include/version.mk 2>/dev/null || true
sed -i 's/10\.0\.0\.1/10.5.0.1/g' package/base-files/files/bin/config_generate 2>/dev/null || true
