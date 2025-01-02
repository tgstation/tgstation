/obj/item/clothing/suit/apron/chef/colorable_apron
	name = "apron"
	desc = "A basic apron."
	icon = 'modular_doppler/modular_cosmetics/GAGS/icons/obj/suit.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/GAGS/icons/mob/suit.dmi'
	icon_state = "apron"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	// gets_cropped_on_taurs = FALSE
	greyscale_colors = "#ffffff"
	greyscale_config = /datum/greyscale_config/apron
	greyscale_config_worn = /datum/greyscale_config/apron/worn
	flags_1 = IS_PLAYER_COLORABLE_1

// Janitor
/obj/item/clothing/suit/apron/janitor_cloak
	name = "waterproof poncho"
	desc = "A transparent, waterproof cloak for your cleaning needs."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/suit/working.dmi'
	icon_state = "janicloak"
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/suit/working.dmi'
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
