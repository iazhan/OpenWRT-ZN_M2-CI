#!/bin/bash

# 修改默认IP
sed -i 's/192.168.100.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 更改默认 Shell 为 zsh
# sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# TTYD 免登录
# sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

#安装和更新软件包
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=${4:-} 
	local REPO_NAME=$(echo $PKG_REPO | cut -d '/' -f 2)

	rm -rf $(find feeds/luci/ feeds/packages/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune)

	if [[ $PKG_REPO == http* ]]; then
	        git clone --depth=1 --single-branch --branch $PKG_BRANCH "$PKG_REPO" package/$PKG_NAME
	else
	        git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git" package/$PKG_NAME
	fi
 
	if [[ $PKG_SPECIAL == "pkg" ]]; then
		cp -rf $(find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune) ./
		rm -rf ./$REPO_NAME/
	elif [[ $PKG_SPECIAL == "name" ]]; then
		mv -f $REPO_NAME $PKG_NAME
	fi
}

#删掉垃圾源
sed -i "/kenzok8/d" "feeds.conf.default"
rm -rf package/feeds/small
rm -rf package/feeds/kenzo

# Themes
UPDATE_PACKAGE "luci-theme-argon" "https://github.com/jerrykuku/luci-theme-argon" "master"
UPDATE_PACKAGE "luci-app-argon-config" "https://github.com/jerrykuku/luci-app-argon-config" "master"

# Passwall
UPDATE_PACKAGE "luci-app-passwall" "https://github.com/xiaorouji/openwrt-passwall" "main" "pkg"

# SmartDNS
UPDATE_PACKAGE "smartdns" "https://github.com/pymumu/openwrt-smartdns" "master" "name"
UPDATE_PACKAGE "luci-app-smartdns" "https://github.com/pymumu/luci-app-smartdns" "master"

# AdguardHome
UPDATE_PACKAGE "luci-app-adguardhome" "https://github.com/ysuolmai/luci-app-adguardhome" "master"

# WOLPuls
UPDATE_PACKAGE "luci-app-wolplus" "https://github.com/tty228/luci-app-wolplus" "main"

# 在线用户
UPDATE_PACKAGE "luci-app-onliner" "https://github.com/danchexiaoyang/luci-app-onliner" "main" "pkg"
sed -i '$i uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
chmod 755 package/luci-app-onliner/root/usr/share/onliner/setnlbw.sh

# 修改本地时间格式
sed -i 's/os.date()/os.date("%a %Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.htm

# 修改版本为编译日期
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/R${date_version} by Haiibo/g" package/lean/default-settings/files/zzz-default-settings

# 修复 hostapd 报错
cp -f $GITHUB_WORKSPACE/scripts/011-fix-mbo-modules-build.patch package/network/services/hostapd/patches/011-fix-mbo-modules-build.patch

# 修复 armv8 设备 xfsprogs 报错
sed -i 's/TARGET_CFLAGS.*/TARGET_CFLAGS += -DHAVE_MAP_SYNC -D_LARGEFILE64_SOURCE/g' feeds/packages/utils/xfsprogs/Makefile

# 修改 Makefile
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g' {}

# 取消主题默认设置
# find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

./scripts/feeds update -a
./scripts/feeds install -a


