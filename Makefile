include $(TOPDIR)/rules.mk

# Name, version and release number
# The name and version of your package are used to define the variable to point to the build directory of your package: $(PKG_BUILD_DIR)
PKG_NAME:=helloserver
PKG_VERSION:=1.0
PKG_RELEASE:=0

# Source settings (i.e. where to find the source codes)
# This is a custom variable, used below
SOURCE_DIR:=/home/buildbot/U03/helloserver/

include $(INCLUDE_DIR)/package.mk

# Package definition; instructs on how and where our package will appear in the overall configuration menu ('make menuconfig')
define Package/helloserver
  SECTION:=U03
  CATEGORY:=U03
  TITLE:=helloserver pour openwrt
  DEPENDS:=+libuci
endef

# Package description; a more verbose description on what our package does
define Package/helloserver/description
  U03: helloserver pour openwrt.
endef

# Package preparation instructions; create the build directory and copy the source code. 
# The last command is necessary to ensure our preparation instructions remain compatible with the patching system.
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp $(SOURCE_DIR)/* $(PKG_BUILD_DIR)
	$(Build/Patch)
endef

# Package build instructions; invoke the target-specific compiler to first compile the source file, and then to link the file into the final executable
define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -o $(PKG_BUILD_DIR)/helloserver.o -c $(PKG_BUILD_DIR)/helloserver.c
	$(TARGET_CC) $(TARGET_LDFLAGS) -o $(PKG_BUILD_DIR)/$1 $(PKG_BUILD_DIR)/helloserver.o -luci
endef

# Package install instructions; create a directory inside the package to hold our executable, and then copy the executable we built previously into the folder
define Package/helloserver/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/helloserver $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./etc_init_d_helloserver $(1)/etc/init.d/helloserver
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d/
	$(INSTALL_DATA) ./usr_share_luci_menu_d_helloserver.json $(1)/usr/share/luci/menu.d/helloserver.json
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/helloserver
	$(INSTALL_DATA) ./usr_lib_lua_luci_model_cbi_helloserver_configuration.lua $(1)/usr/lib/lua/luci/model/cbi/helloserver/configuration.lua
endef

# This command is always the last, it uses the definitions and variables we give above in order to get the job done
$(eval $(call BuildPackage,helloserver))

