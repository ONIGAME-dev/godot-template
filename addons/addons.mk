# addons.mk

.PHONY: addons
addons: addons/gdcli addons/gloot addons/dialogue_manager addons/gut addons/input_helper addons/kenney_input_prompts addons/kenney_prototype_textures addons/limboai addons/quest_system

addons/gdcli:
	@$(call install_npm,"@bendn/gdcli")

addons/gloot:
	@$(call install_addon,1368)

addons/dialogue_manager:
	@$(call install_addon,1432)

addons/gut:
	@$(call install_addon,1709)

addons/input_helper:
	@$(call install_addon,2107)

addons/kenney_input_prompts:
	@$(call install_addon,2655)

addons/kenney_prototype_textures:
	@$(call install_addon,781)

addons/limboai:
	@$(call install_addon,2514)

addons/quest_system:
	@$(call install_addon,2516)
