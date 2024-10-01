# Makefile

.PHONY: all
all: project_name prep addons

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
	@echo "Building $(export_type) version of $(project_name) for $@"
	@mkdir -p exports/$(export_type)/$@
	$(GODOT_BIN) --headless --export-$(export_type) "Linux" 'exports/$(export_type)/$@/$(project_name)$(export_suffix).x86_64'

pck: | exports/.gdignore
	@echo "Packing $(export_type) version of $(project_name) as $@"
	@mkdir -p exports/$(export_type)
	$(GODOT_BIN) --headless --export-pack "Linux" 'exports/$(export_type)/$(project_name)$(export_suffix).$@'

zip: | exports/.gdignore
	@echo "Packing $(export_type) version of $(project_name) as $@"
	@mkdir -p exports/$(export_type)
	$(GODOT_BIN) --headless --export-pack "Linux" 'exports/$(export_type)/$(project_name)$(export_suffix).$@'

# PROJ NAME

.PHONY: project_name
project_name:
	$(eval $@_PROJECT_NAME = $(shell basename "${PWD}"))
	@echo "Setting project name to $($@_PROJECT_NAME)"
	@sed 's|\(config/name=\).*|config/name="$($@_PROJECT_NAME)"|g' -i project.godot
	@sed -z 's|\(config/name_localized[ ]*=[ ]*{[ ]*\n[ ]*"en_US"[ ]*:[ ]*"\)[^"]*\("\n}\)|\1$($@_PROJECT_NAME)\2|' -i project.godot

# PREP

.PHONY: prep
prep: icon.svg | content content/addons content/base content/base/assets content/base/resources content/base/src content/base/src/autoloads docs docs/.gdignore exports exports/.gdignore

content:
	@mkdir -p $@

content/addons: | content
	@mkdir -p $@

content/base: | content
	@mkdir -p $@

content/base/assets: | content/base
	@mkdir -p $@

content/base/resources: | content/base
	@mkdir -p $@

content/base/src: | content/base
	@mkdir -p $@

content/base/src/autoloads: | content/base/src
	@mkdir -p $@

docs:
	@mkdir -p $@

docs/.gdignore: | docs
	@touch $@

exports:
	@mkdir -p $@

exports/.gdignore: | exports
	@touch $@

html:
	@mkdir -p $@

html/.gdignore: | html
	@touch $@

icon.svg:
	@echo "Fetching $@"
	@curl -sLo $@ https://raw.githubusercontent.com/godotengine/godot/master/editor/icons/DefaultProjectIcon.svg

# CLEAN

.PHONY: clean
clean:
	@echo "Removing addons"
	@find addons -mindepth 1 -maxdepth 1 ! -name addons.mk -exec rm -rf {} \;
	@echo "Removing exports"
	@rm -rf .godot exports/debug exports/release
	@echo "Removing icon"
	@rm -f icon.svg icon.svg.import

# ADDONS

include addons/addons.mk

asset_library_uri = "https://godotengine.org/asset-library"

define install_addon
	$(eval $@_ADDON_ID = $(1))
	$(eval $@_TITLE = $(shell curl -s -X GET "${asset_library_uri}/api/asset/${$@_ADDON_ID}" | jq -r '.title'))
	$(eval $@_DOWNLOAD_URL = $(shell curl -s -X GET "${asset_library_uri}/api/asset/${$@_ADDON_ID}" | jq -r '.download_url'))
	$(eval $@_FILENAME = $(shell basename "${$@_DOWNLOAD_URL}"))
	$(eval $@_TEMP_DIR = $(shell mktemp -d))
	echo "Installing Godot addon: ${$@_TITLE}"
	curl -sLo "${$@_TEMP_DIR}/${$@_FILENAME}" "${$@_DOWNLOAD_URL}"
	unzip -qd "${$@_TEMP_DIR}" "${$@_TEMP_DIR}/${$@_FILENAME}"
	find "${$@_TEMP_DIR}" -mindepth 1 -maxdepth 2 -type d -name addons -exec rsync -a "{}" "${PWD}" \;
	rm -rf "${$@_TEMP_DIR}"
endef

npm_registry_uri = "https://registry.npmjs.org"

define install_npm
	$(eval $@_NPM_NAME = $(1))
	$(eval $@_TITLE = $(shell curl -s -X GET "${npm_registry_uri}/${$@_NPM_NAME}/latest" | jq -r '.description'))
	$(eval $@_DOWNLOAD_URL = $(shell curl -s -X GET "${npm_registry_uri}/${$@_NPM_NAME}/latest" | jq -r '.dist.tarball'))
	$(eval $@_FILENAME = $(shell basename "${$@_DOWNLOAD_URL}"))
	$(eval $@_TEMP_DIR = $(shell mktemp -d))
	echo "Installing NPM addon: ${$@_TITLE}"
	curl -sLo "${$@_TEMP_DIR}/${$@_FILENAME}" "${$@_DOWNLOAD_URL}"
	tar -xzf "${$@_TEMP_DIR}/${$@_FILENAME}" -C "${$@_TEMP_DIR}"
	rsync -a "${$@_TEMP_DIR}/package/" "${PWD}/addons/$(shell basename $($@_NPM_NAME))"
	rm -rf "${$@_TEMP_DIR}"
endef
