/obj/item/clothing/head/standalone_hood
	name = "hood"
	desc = "A hood with a bit of support around the neck so it actually stays in place, for all those times you want a hood without the coat."
	icon = 'modular_doppler/modular_cosmetics/GAGS/icons/obj/head.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/GAGS/icons/mob/head.dmi'
	icon_state = "hood"
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEEARS|HIDEHAIR
	flags_1 = IS_PLAYER_COLORABLE_1
	greyscale_colors = "#4e4a43#F1F1F1"
	greyscale_config = /datum/greyscale_config/standalone_hood
	greyscale_config_worn = /datum/greyscale_config/standalone_hood/worn

/obj/item/clothing/head/costume/papakha
	name = "papakha"
	desc = "A big wooly clump of fur designed to go on your head."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/head/costume.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/head/costume.dmi'
	icon_state = "papakha"
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT

/obj/item/clothing/head/costume/papakha/white
	icon_state = "papakha_white"

/obj/item/clothing/head/maid_headband
	name = "maid headband"
	desc = "Just like from one of those Chinese cartoons!"
	icon_state = "maid_headband"
	greyscale_config = /datum/greyscale_config/maid_headband
	greyscale_config_worn = /datum/greyscale_config/maid_headband/worn
	greyscale_colors = "#edf9ff"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/hooded/winterhood
	icon = 'modular_doppler/modular_cosmetics/icons/obj/head/hoods.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/head/hoods.dmi'
