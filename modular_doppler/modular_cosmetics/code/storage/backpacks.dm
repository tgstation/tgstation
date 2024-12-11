// regular backpacks
/obj/item/storage/backpack/custom
	name = "custom backpack"
	icon_state = "backpack"
	greyscale_colors = "#333333#FF0000"
	greyscale_config = /datum/greyscale_config/backpack
	greyscale_config_worn = /datum/greyscale_config/backpack/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/storage/backpack/industrial/custom
	name = "custom industrial backpack"
	icon_state = "backpack_industrial"
	greyscale_colors = "#333333#FF0000"
	greyscale_config = /datum/greyscale_config/backpack
	greyscale_config_worn = /datum/greyscale_config/backpack/worn
	flags_1 = IS_PLAYER_COLORABLE_1

// satchels
/obj/item/storage/backpack/satchel/custom
	name = "custom satchel"
	icon_state = "satchel"
	greyscale_colors = "#333333#FF0000"
	greyscale_config = /datum/greyscale_config/backpack/satchel
	greyscale_config_worn = /datum/greyscale_config/backpack/satchel/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/storage/backpack/satchel/eng/custom
	name = "custom industrial satchel"
	icon_state = "satchel_industrial"
	greyscale_colors = "#333333#FF0000"
	greyscale_config = /datum/greyscale_config/backpack/satchel
	greyscale_config_worn = /datum/greyscale_config/backpack/satchel/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/storage/backpack/satchel/crusader	//Not very special, really just a satchel texture
	icon = 'modular_doppler/modular_cosmetics/icons/obj/storage/crusaderbandolier.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/storage/crusaderbandolier.dmi'
	name = "adventurer's bandolier"
	desc = "A bandolier-satchel combination for holding all your dungeon loot."
	icon_state = "crusader_bandolier"
	inhand_icon_state = "explorerpack"
	w_class = WEIGHT_CLASS_BULKY

/datum/crafting_recipe/crusader_satchel
	name = "Adventurer's Bandolier"
	result = /obj/item/storage/backpack/satchel/crusader
	reqs = list(/obj/item/stack/sheet/cloth = 2, /obj/item/stack/sheet/leather = 1)	//Cheap because it's really just a re-texture of the satchel
	tool_behaviors = list(TOOL_WIRECUTTER)
	time = 15
	category = CAT_CLOTHING

// duffelbags
/obj/item/storage/backpack/duffelbag/custom
	name = "custom duffelbag"
	icon_state = "duffel"
	greyscale_colors = "#333333#FF0000"
	greyscale_config = /datum/greyscale_config/backpack/duffel
	greyscale_config_worn = /datum/greyscale_config/backpack/duffel/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/storage/backpack/duffelbag/engineering/custom
	name = "custom industrial duffelbag"
	icon_state = "duffel_industrial"
	greyscale_colors = "#333333#FF0000"
	greyscale_config = /datum/greyscale_config/backpack/duffel
	greyscale_config_worn = /datum/greyscale_config/backpack/duffel/worn
	flags_1 = IS_PLAYER_COLORABLE_1

// messenger bags
/obj/item/storage/backpack/messenger/custom
	name = "custom messenger bag"
	icon_state = "messenger"
	greyscale_colors = "#333333#FF0000"
	greyscale_config = /datum/greyscale_config/backpack/messenger
	greyscale_config_worn = /datum/greyscale_config/backpack/messenger/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/storage/backpack/messenger/eng/custom
	name = "custom industrial messenger bag"
	icon_state = "messenger"
	greyscale_colors = "#333333#FF0000"
	greyscale_config = /datum/greyscale_config/backpack/messenger
	greyscale_config_worn = /datum/greyscale_config/backpack/messenger/worn
	flags_1 = IS_PLAYER_COLORABLE_1

// slimpacks
/obj/item/storage/backpack/satchel/flat/empty/custom
	name = "custom flatpack"
	desc = "An ultra-light-weight slim storage option that fits above the belt- or slipped into other bags or under floor tiles."
	icon_state = "slimpack"
	greyscale_colors = "#333333#FF0000"
	greyscale_config = /datum/greyscale_config/backpack/slimpack
	greyscale_config_worn = /datum/greyscale_config/backpack/slimpack/worn
	flags_1 = IS_PLAYER_COLORABLE_1
