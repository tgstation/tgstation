/obj/item/clothing/suit/sweater
	name = "turtleneck sweater"
	desc = "Space is cold, bring a sweater."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "sweater"
	worn_icon = 'icons/mob/clothing/suit.dmi'
	body_parts_covered = CHEST|ARMS
	cold_protection = CHEST|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	allowed = list(
		/obj/item/flashlight,
		/obj/item/lighter,
		/obj/item/modular_computer/tablet,
		/obj/item/pda,
		/obj/item/radio,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy
		)
	greyscale_config = /datum/greyscale_config/sweater
	greyscale_config_worn = /datum/greyscale_config/sweater_worn
	greyscale_colors = "#44A510"
