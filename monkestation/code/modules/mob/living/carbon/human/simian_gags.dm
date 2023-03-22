/obj/item
	/// Icon file for mob worn overlays, if the user is a teshari.
	var/icon/worn_icon_simian
	/// The config type to use for greyscaled worn sprites for Simian characters. Both this and greyscale_colors must be assigned to work.
	var/greyscale_config_worn_simian

	var/datum/greyscale_config/greyscale_config_worn_simian_fallback
	var/datum/greyscale_config/greyscale_config_worn_simian_fallback_skirt

/obj/item/storage/backpack
	species_clothing_color_coords = list(list(BACK_COLORPIXEL_X_1, BACK_COLORPIXEL_Y_1))
	greyscale_config_worn_simian_fallback = /datum/greyscale_config/simian/backpack

/obj/item/clothing/glasses
	species_clothing_color_coords = list(list(GLASSES_COLORPIXEL_X_1, GLASSES_COLORPIXEL_Y_1), list(GLASSES_COLORPIXEL_X_2, GLASSES_COLORPIXEL_Y_2))
	greyscale_config_worn_simian_fallback = /datum/greyscale_config/simian/glasses

/obj/item/clothing/gloves
	species_clothing_color_coords = list(list(GLOVES_COLORPIXEL_X_1, GLOVES_COLORPIXEL_Y_1))
	greyscale_config_worn_simian_fallback = /datum/greyscale_config/simian/gloves

/obj/item/clothing/neck
	species_clothing_color_coords = list(list(SCARF_COLORPIXEL_X_1, SCARF_COLORPIXEL_Y_1))
	greyscale_config_worn_simian_fallback = /datum/greyscale_config/simian/scarf

/obj/item/clothing/neck/cloak
	species_clothing_color_coords = list(list(CLOAK_COLORPIXEL_X_1, CLOAK_COLORPIXEL_Y_1), list(CLOAK_COLORPIXEL_X_2, CLOAK_COLORPIXEL_Y_2))
	greyscale_config_worn_simian_fallback = /datum/greyscale_config/simian/cloak

/obj/item/clothing/neck/tie
	species_clothing_color_coords = list(list(TIE_COLORPIXEL_X_1, TIE_COLORPIXEL_Y_1))
	greyscale_config_worn_simian_fallback = /datum/greyscale_config/simian/tie

/obj/item/clothing/shoes
	species_clothing_color_coords = list(list(SHOES_COLORPIXEL_X_1, SHOES_COLORPIXEL_Y_1))
	greyscale_config_worn_simian_fallback = /datum/greyscale_config/simian/shoes

/obj/item/clothing/suit
	species_clothing_color_coords = list(list(COAT_COLORPIXEL_X_1, COAT_COLORPIXEL_Y_1))
	greyscale_config_worn_simian_fallback = /datum/greyscale_config/simian/coat

/obj/item/clothing/suit/armor
	species_clothing_color_coords = list(list(ARMOR_COLORPIXEL_X_1, ARMOR_COLORPIXEL_Y_1))
	greyscale_config_worn_simian_fallback = /datum/greyscale_config/simian/armor

/obj/item/clothing/suit/space
	species_clothing_color_coords = list(list(SPACESUIT_COLORPIXEL_X_1, SPACESUIT_COLORPIXEL_Y_1))
	greyscale_config_worn_simian_fallback = /datum/greyscale_config/simian/spacesuit

/obj/item/clothing/suit/mod
	species_clothing_color_coords = list(list(MODSUIT_COLORPIXEL_X_1, MODSUIT_COLORPIXEL_Y_1), list(MODSUIT_COLORPIXEL_X_2, MODSUIT_COLORPIXEL_Y_2), list(MODSUIT_COLORPIXEL_X_3, MODSUIT_COLORPIXEL_Y_3))
	greyscale_config_worn_simian_fallback = /datum/greyscale_config/simian/hardsuit

/obj/item/clothing/under
	species_clothing_color_coords = list(list(UNDER_COLORPIXEL_X_1, UNDER_COLORPIXEL_Y_1), list(UNDER_COLORPIXEL_X_2, UNDER_COLORPIXEL_Y_2), list(UNDER_COLORPIXEL_X_3, UNDER_COLORPIXEL_Y_3))
	greyscale_config_worn_simian_fallback = /datum/greyscale_config/simian/under
	greyscale_config_worn_simian_fallback_skirt = /datum/greyscale_config/simian/under_skirt

/obj/item/mod/control
	species_clothing_color_coords = list(list(MODCONTROL_COLORPIXEL_X_1, MODCONTROL_COLORPIXEL_Y_1))
	greyscale_config_worn_simian_fallback = /datum/greyscale_config/simian/modcontrol

///GAGS below here
/*
/obj/item/clothing/under/color
	greyscale_config_worn_simian = /datum/greyscale_config/jumpsuit_worn/simian

/obj/item/clothing/under/color/jumpskirt
	greyscale_config_worn_simian = /datum/greyscale_config/jumpsuit_worn/simian

/obj/item/clothing/shoes/sneakers
	greyscale_config_worn_simian = /datum/greyscale_config/sneakers_worn/simian

/obj/item/clothing/shoes/sneakers/orange
	greyscale_config_worn_simian = /datum/greyscale_config/sneakers_orange_worn/simian

/obj/item/clothing/head/collectable/beret
	greyscale_config_worn_simian = /datum/greyscale_config/beret/worn/simian

/obj/item/clothing/head/collectable/flatcap
	greyscale_config_worn_simian = /datum/greyscale_config/beret/worn/simian

/obj/item/clothing/head/frenchberet
	greyscale_config_worn_simian = /datum/greyscale_config/beret/worn/simian

/obj/item/clothing/head/flatcap
	greyscale_config_worn_simian = /datum/greyscale_config/beret/worn/simian

/obj/item/clothing/head/caphat/beret
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge/worn/simian

/obj/item/clothing/head/beret
	greyscale_config_worn_simian = /datum/greyscale_config/beret/worn/simian

/obj/item/clothing/head/beret/badge
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge/worn/simian

/obj/item/clothing/head/hats/hos/beret
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge/worn/simian

/obj/item/clothing/head/beret/sec
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge/worn/simian

/obj/item/clothing/head/beret/science/fancy
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge/worn/simian

/obj/item/clothing/head/beret/science/rd
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge/worn/simian

/obj/item/clothing/head/beret/durathread
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge/worn/simian

/obj/item/clothing/head/beret/centcom_formal
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge/worn/simian

/obj/item/clothing/head/beret/sec/navywarden
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge_fancy/worn/simian

/obj/item/clothing/head/beret/medical
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge/worn/simian

/obj/item/clothing/head/beret/engi
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge/worn/simian

/obj/item/clothing/head/beret/atmos
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge/worn/simian

/obj/item/clothing/head/beret/cargo/qm
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge/worn/simian

/obj/item/clothing/head/hopcap/beret
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge/worn/simian

/obj/item/clothing/head/beret/blueshield
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge/worn/simian

/obj/item/clothing/head/flatcap
	greyscale_config_worn_simian = /datum/greyscale_config/beret/worn/simian

/obj/item/clothing/head/frenchberet
	greyscale_config_worn_simian = /datum/greyscale_config/beret/worn/simian

/obj/item/clothing/head/beret/sec/navywarden/syndicate
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge/worn/simian

/obj/item/clothing/head/nanotrasen_consultant/beret
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge/worn/simian

/obj/item/clothing/head/beret/sec/peacekeeper/armadyne
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge_fancy/worn/simian

/obj/item/clothing/head/beret/sec/peacekeeper
	greyscale_config_worn_simian = /datum/greyscale_config/beret_badge/worn/simian

/obj/item/clothing/neck/ranger_poncho
	greyscale_config_worn_simian = /datum/greyscale_config/ranger_poncho/worn/simian

/obj/item/clothing/under/dress/skirt/plaid
	greyscale_config_worn_simian = /datum/greyscale_config/plaidskirt_worn/simian

/obj/item/clothing/under/dress/sundress
	greyscale_config_worn_simian = /datum/greyscale_config/sundress_worn/simian
*/
