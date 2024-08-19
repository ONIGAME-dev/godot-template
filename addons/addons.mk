# addons.mk

.PHONY: addons
addons: addons/gloot addons/dialogue_manager addons/gut addons/input_helper addons/limboai addons/quest_system

addons/gloot:
	@$(call install_addon,1368)

addons/dialogue_manager:
	@$(call install_addon,1432)

addons/gut:
	@$(call install_addon,1709)

addons/input_helper:
	@$(call install_addon,2107)

addons/limboai:
	@$(call install_addon,2514)

addons/quest_system:
	@$(call install_addon,2516)
