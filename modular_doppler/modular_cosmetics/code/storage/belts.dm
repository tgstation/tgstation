/obj/item/storage/belt/fannypack/custom
	name = "fannypack"
	icon_state = "fannypack"
	worn_icon_state = "fannypack"
	greyscale_colors = "#FF0000"
	greyscale_config = /datum/greyscale_config/fannypack
	greyscale_config_worn = /datum/greyscale_config/fannypack/worn
	flags_1 = IS_PLAYER_COLORABLE_1

// MODULAR EDIT: adjusting size to make it more useful
/obj/item/storage/belt/fannypack/Initialize(mapload)
	. = ..()
	//atom_storage.max_slots = 3
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
