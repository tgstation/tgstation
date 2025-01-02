/obj/item/clothing/gloves/latex/nitrile
	icon = 'modular_doppler/modular_cosmetics/icons/obj/hands/gloves.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/hands/gloves.dmi'
	greyscale_colors = "#B7DE5B"

/obj/item/clothing/gloves/lalune_long
	icon = 'modular_doppler/modular_cosmetics/icons/obj/hands/gloves.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/hands/gloves.dmi'
	name = "designer long gloves"
	desc = "A fancy set of bicep-length black gloves. The La Lune insignia is sewn into the rims."
	icon_state = "lalune_long"
	strip_delay = 40
	equip_delay_other = 20

/obj/item/clothing/gloves/bracer/wraps
	name = "cloth arm wraps"
	desc = "Used for aesthetics, used for wiping sweat from the brow, used for... well, what about you?"
	icon = 'modular_doppler/modular_cosmetics/icons/obj/hands/gloves.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/hands/gloves.dmi'
	icon_state = "arm_wraps"
	inhand_icon_state = "greyscale_gloves"
	greyscale_config = /datum/greyscale_config/armwraps
	greyscale_config_worn = /datum/greyscale_config/armwraps/worn
	greyscale_colors = "#FFFFFF"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/gloves/maid_arm_covers
	name = "maid arm covers"
	desc = "Maid in China."
	icon_state = "maid_arm_covers"
	greyscale_config = /datum/greyscale_config/maid_arm_covers
	greyscale_config_worn = /datum/greyscale_config/maid_arm_covers/worn
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_colors = "#7b9ab5#edf9ff"
	flags_1 = IS_PLAYER_COLORABLE_1
