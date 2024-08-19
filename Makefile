# Makefile

.PHONY: all
all: prep addons

# BUILD

project_name = $(shell echo "$(shell grep 'config/name=' project.godot | cut -d '=' -f 2)" | tr -d '"' | tr -d "'")
godot_flatpak_bin = /var/lib/flatpak/app/org.godotengine.Godot/current/active/export/bin/org.godotengine.Godot
GODOT_BIN = $(shell command -v godot &>/dev/null && echo 'godot' || (command -v &>/dev/null "$(godot_flatpak_bin)" && echo "$(godot_flatpak_bin)"))

ifdef debug
export_type = debug
export_suffix = _$(export_type)
else
export_type = release
export_suffix = 
endif

.PHONY: build linux pck zip
build: linux windows web pck zip

linux: | exports/.gdignore
	mkdir -p exports/$(export_type)/$@
	$(GODOT_BIN) --headless --export-$(export_type) "Linux" 'exports/$(export_type)/$@/$(project_name)$(export_suffix).x86_64'

pck: | exports/.gdignore
	mkdir -p exports/$(export_type)
	$(GODOT_BIN) --headless --export-pack "Linux" 'exports/$(export_type)/$(project_name)$(export_suffix).$@'

zip: | exports/.gdignore
	mkdir -p exports/$(export_type)
	$(GODOT_BIN) --headless --export-pack "Linux" 'exports/$(export_type)/$(project_name)$(export_suffix).$@'

# PREP

.PHONY: prep
prep: icon.svg | content content/addons content/base content/base/assets content/base/resources content/base/src content/base/src/autoloads docs docs/.gdignore exports exports/.gdignore

content:
	mkdir -p $@

content/addons: | content
	mkdir -p $@

content/base: | content
	mkdir -p $@

content/base/assets: | content/base
	mkdir -p $@

content/base/resources: | content/base
	mkdir -p $@

content/base/src: | content/base
	mkdir -p $@

content/base/src/autoloads: | content/base/src
	mkdir -p $@

docs:
	mkdir -p $@

docs/.gdignore: | docs
	touch $@

exports:
	mkdir -p $@

exports/.gdignore: | exports
	touch $@

html:
	mkdir -p $@

html/.gdignore: | html
	touch $@

icon.svg:
	curl -sLo $@ https://raw.githubusercontent.com/godotengine/godot/master/editor/icons/DefaultProjectIcon.svg

# CLEAN

.PHONY: clean
clean:
	find addons -mindepth 1 -maxdepth 1 ! -name addons.mk -exec rm -rf {} \;
	rm -rf .godot exports/debug exports/release
	rm -f icon.svg icon.svg.import

# ADDONS

include addons/addons.mk

asset_library_uri = "https://godotengine.org/asset-library"

define install_addon
	$(eval $@_ADDON_ID = $(1))
	$(eval $@_TITLE = $(shell curl -s -X GET "${asset_library_uri}/api/asset/${$@_ADDON_ID}" | jq -r '.title'))
	$(eval $@_DOWNLOAD_URL = $(shell curl -s -X GET "${asset_library_uri}/api/asset/${$@_ADDON_ID}" | jq -r '.download_url'))
	$(eval $@_FILENAME = $(shell basename "${$@_DOWNLOAD_URL}"))
	$(eval $@_TEMP_DIR = $(shell mktemp -d))
	echo "Installing addon: ${$@_TITLE}"
	curl -sLo "${$@_TEMP_DIR}/${$@_FILENAME}" "${$@_DOWNLOAD_URL}"
	unzip -qd "${$@_TEMP_DIR}" "${$@_TEMP_DIR}/${$@_FILENAME}"
	find "${$@_TEMP_DIR}" -maxdepth 2 -type d -name addons -exec rsync -a "{}" "${PWD}" \;
	rm -rf "${$@_TEMP_DIR}"
endef

npm_registry_uri = "https://registry.npmjs.org"

define install_npm
	echo $(eval $@_NPM_NAME = $(1))
	echo $(eval $@_TITLE = $(shell curl -s -X GET "${npm_registry_uri}/${$@_NPM_NAME}/latest" | jq -r '.description'))
	echo $(eval $@_DOWNLOAD_URL = $(shell curl -s -X GET "${npm_registry_uri}/${$@_NPM_NAME}/latest" | jq -r '.dist.tarball'))
	echo $(eval $@_FILENAME = $(shell basename "${$@_DOWNLOAD_URL}"))
	echo $(eval $@_TEMP_DIR = $(shell mktemp -d))
	echo "Installing addon: ${$@_TITLE}"
	curl -sLo "${$@_TEMP_DIR}/${$@_FILENAME}" "${$@_DOWNLOAD_URL}"
	tar -xzf "${$@_TEMP_DIR}/${$@_FILENAME}" -C "${$@_TEMP_DIR}"
	rsync -a "${$@_TEMP_DIR}/package/" "${PWD}/addons/$(shell basename $($@_NPM_NAME))"
	rm -rf "${$@_TEMP_DIR}"
endef
