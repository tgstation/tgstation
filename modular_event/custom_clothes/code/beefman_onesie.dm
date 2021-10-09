/obj/item/clothing/suit/hooded/beefman
	name = "beefman onesie"
	desc = "The Nanotrasen tailoring department had a hard time trying to find a way to make this look cute."
	icon = 'modular_event/custom_clothes/icons/beefman_icons.dmi'
	worn_icon = 'modular_event/custom_clothes/icons/beefman_icons_worn.dmi'
	icon_state = "onesie_beefman"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|FEET
	cold_protection = CHEST|GROIN|ARMS|LEGS|FEET
	flags_inv = HIDEJUMPSUIT
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)
	hoodtype = /obj/item/clothing/head/hooded/beefman

/obj/item/clothing/head/hooded/beefman
	name = "beefman hood"
	desc = "A beefboy hood for a onesie... wait are those teeth real?"
	icon = 'modular_event/custom_clothes/icons/beefman_icons.dmi'
	worn_icon = 'modular_event/custom_clothes/icons/beefman_icons_worn.dmi'
	icon_state = "onesie_beefman_hood"
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEEARS
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/shoes/beefman_shoes
	name = "meaty shoes"
	desc = "A special pair of shoes that makes you sound extra meaty when walking."
	icon = 'modular_event/custom_clothes/icons/beefman_icons.dmi'
	worn_icon = 'modular_event/custom_clothes/icons/beefman_icons_worn.dmi'
	icon_state = "onesie_beefman_shoes"

/obj/item/clothing/shoes/beefman_shoes/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list(
		'modular_event/custom_clothes/sounds/footstep_splat1.ogg' = 1,
		'modular_event/custom_clothes/sounds/footstep_splat2.ogg' = 1,
		'modular_event/custom_clothes/sounds/footstep_splat3.ogg' = 1,
		'modular_event/custom_clothes/sounds/footstep_splat4.ogg' = 1,
	), 50)
