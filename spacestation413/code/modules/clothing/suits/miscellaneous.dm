

/obj/item/clothing/suit/hooded/husky_costume	//It's not fat, it's just a little husky
	name = "husky costume"
	desc = ":fathusky:"
	icon = 'spacestation413/icons/obj/clothing/suits.dmi'
	icon_state = "husky"
	item_state = "husky"
	alternate_worn_icon = 'spacestation413/icons/mob/suit.dmi'
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS 			//is he okay hes in SNOW
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	allowed = list()
	hoodtype = /obj/item/clothing/head/hooded/husky_hood
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/head/hooded/husky_hood
	name = "hoodsky"
	desc = ":fathoodsky:"
	icon = 'spacestation413/icons/obj/clothing/hats.dmi'
	icon_state = "husky"
	alternate_worn_icon = 'spacestation413/icons/mob/head.dmi'
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEEARS