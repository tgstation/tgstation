// Nanotrasen Representative
/obj/item/clothing/head/hats/nanotrasen_representative
	name = "Nanotrasen Representative's hat"
	desc = "A cap issued to Nanotrasen Representatives."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/hats.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/hats.dmi'
	icon_state = "nanotrasen_representative"

// Blueshield
/obj/item/clothing/head/beret/blueshield
	name = "blueshield's beret"
	desc = "A blue beret made of durathread with a genuine golden badge, denoting its owner as a Blueshield Lieuteneant. \
		It seems to be padded with nano-kevlar, making it tougher than standard reinforced berets."
	icon = 'icons/map_icons/clothing/head/beret.dmi'
	icon_state = "/obj/item/clothing/head/beret/blueshield"
	post_init_icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#3A4E7D#DEB63D"
	armor_type = /datum/armor/suit_armor

/obj/item/clothing/head/beret/blueshield/navy
	name = "navy blueshield's beret"
	desc = "A navy-blue beret made of durathread with a silver badge, denoting its owner as a Blueshield Lieuteneant. \
		It seems to be padded with nano-kevlar, making it tougher than standard reinforced berets."
	greyscale_colors = "#3C485A#BBBBBB"
