# addons.mk

.PHONY: addons
addons: addons/input_helper addons/dialogue_manager addons/quest_system addons/limboai addons/gloot

addons/input_helper:
	@$(call install_addon,2107)

addons/dialogue_manager:
	@$(call install_addon,1432)

addons/quest_system:
	@$(call install_addon,2516)

addons/limboai:
	@$(call install_addon,2514)

addons/gloot:
	@$(call install_addon,1368)
