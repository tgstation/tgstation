/obj/item/clothing/suit/mothcoat
	name = "mothic flightsuit"
	desc = "This peculiar utility harness is a common sight among the moth fleet's crews due to its ability to fasten the wings to the body without impacting mobility inside cramped ship interiors. It looks somewhat crude yet it's surprisingly comfortable."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/mothcoat"
	post_init_icon_state = "mothcoat"
	greyscale_config = /datum/greyscale_config/mothcoat
	greyscale_config_worn = /datum/greyscale_config/mothcoat/worn
	greyscale_colors = "#eaeaea"
	flags_1 = IS_PLAYER_COLORABLE_1
	flags_inv = HIDEMUTWINGS
	body_parts_covered = CHEST
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/flashlight/lantern) //lamp

/obj/item/clothing/suit/mothcoat/original
	desc = "An old-school flightsuit from the moth fleet. A perfect token of mothic survivalistic and adaptable attitude, yet a bitter reminder that with the loss of their home planet and institution of the fleet, their beloved wings remain as a burden to bear, condemned to never fly again."
	icon_state = "/obj/item/clothing/suit/mothcoat/original"
	greyscale_colors = "#dfa409"

/obj/item/clothing/suit/mothcoat/original/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, -5)
	create_storage(storage_type = /datum/storage/pockets)

/obj/item/clothing/suit/mothcoat/winter
	name = "mothic mantella"
	desc = "A thick garment that keeps warm and protects those precious wings from harsh weather, also commonly used during festivities. Feels much heavier than it looks."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/mothcoat/winter"
	post_init_icon_state = "mothcoat_winter"
	greyscale_config = /datum/greyscale_config/mothcoat_winter
	greyscale_config_worn = /datum/greyscale_config/mothcoat_winter/worn
	greyscale_colors = "#557979#795e55"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	cold_protection = CHEST|GROIN|ARMS|LEGS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
