#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=node
PKG_VERSION:=$(shell curl -s https://downloads.openwrt.org/releases/packages-23.05/aarch64_generic/packages/ | grep node_v | grep -oP 'node_v\d+\.\d+\.\d+-\d+' | sed -n 's/node_//p' | head -n1)

PKG_MAINTAINER:=Hirokazu MORIKAWA <morikw2@gmail.com>, Adrian Panella <ianchi74@outlook.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:nodejs:node.js

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/node
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Node.js
  TITLE:=Node.js is a platform built on Chrome's JavaScript runtime
  URL:=https://nodejs.org/
  DEPENDS:=@HAS_FPU @(i386||x86_64||arm||aarch64||mipsel) \
	   +libstdcpp +libopenssl +zlib +libnghttp2 +libuv \
	   +libcares +libatomic +NODEJS_ICU_SYSTEM:icu +NODEJS_ICU_SYSTEM:icu-full-data
endef

define Package/node/description
  Node.js® is a JavaScript runtime built on Chrome's V8 JavaScript engine. Node.js uses
  an event-driven, non-blocking I/O model that makes it lightweight and efficient. Node.js'
   package ecosystem, npm, is the largest ecosystem of open source libraries in the world.
  *** The following preparations must be made on the host side. ***
      1. gcc 8.3 or higher is required.
      2. To build a 32-bit target, gcc-multilib, g++-multilib are required.
      3. Requires libatomic package. (If necessary, install the 32-bit library at the same time.)
     ex) sudo apt-get install gcc-multilib g++-multilib
endef

define Package/node-npm
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Node.js
  TITLE:=NPM stands for Node Package Manager
  URL:=https://www.npmjs.com/
  DEPENDS:=+node
endef

define Package/node-npm/description
	NPM is the package manager for NodeJS
endef

define Build/Compile
	( \
		pushd $(PKG_BUILD_DIR) ; \
		wget -O node.ipk https://downloads.openwrt.org/releases/packages-23.05/$(ARCH_PACKAGES)/packages/node_$(PKG_VERSION)_$(ARCH_PACKAGES).ipk ; \
		$(TAR) -zxvf node.ipk ; \
		$(TAR) -zxvf data.tar.gz ; \
		popd ; \
	)
endef

define Package/node/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/bin/node $(1)/usr/bin/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,node))
$(eval $(call BuildPackage,node-npm))
