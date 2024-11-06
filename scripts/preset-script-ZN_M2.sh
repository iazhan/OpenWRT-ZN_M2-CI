#!/bin/bash

# 将 files/usr/bin/AdGuardHome 重命名为 AdGuardHome1
mv files/usr/bin/AdGuardHome files/usr/bin/AdGuardHome1

# 在 files/usr/bin 目录下创建 AdGuardHome 文件夹
mkdir -p files/usr/bin/AdGuardHome

# 将 AdGuardHome1 文件移动到新建的 AdGuardHome 文件夹中
mv files/usr/bin/AdGuardHome1 files/usr/bin/AdGuardHome/

# 将文件名改回 AdGuardHome
mv files/usr/bin/AdGuardHome/AdGuardHome1 files/usr/bin/AdGuardHome/AdGuardHome

chmod +x files/usr/bin/AdGuardHome/AdGuardHome

# Set default theme to luci-theme-argon
# uci set luci.main.mediaurlbase='/luci-static/argon'
# uci commit luci
# exit 0
