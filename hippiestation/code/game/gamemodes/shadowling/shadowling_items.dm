/obj/item/clothing/under/shadowling
	name = "blackened flesh"
	desc = "Black, chitinous skin."
	item_state = null
	origin_tech = null
	icon_state = "shadowling"
	has_sensor = 0
	flags = ABSTRACT | NODROP | UNACIDABLE


/obj/item/clothing/suit/space/shadowling
	name = "chitin shell"
	desc = "A dark, semi-transparent shell. Protects against vacuum, but not against the light of the stars." //Still takes damage from spacewalking but is immune to space itself
	alternate_worn_icon = 'hippiestation/icons/mob/suit.dmi'
	icon = 'hippiestation/icons/obj/clothing/suits.dmi'
	icon_state = "sl_shell"
	item_state = "sl_shell"
	body_parts_covered = FULL_BODY //Shadowlings are immune to space
	cold_protection = FULL_BODY
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	slowdown = 0
	heat_protection = null //You didn't expect a light-sensitive creature to have heat resistance, did you?
	max_heat_protection_temperature = null
	armor = list(melee = 25, bullet = 0, laser = 0, energy = 0, bomb = 25, bio = 100, rad = 100)
	flags = ABSTRACT | NODROP | THICKMATERIAL | STOPSPRESSUREDMAGE | UNACIDABLE


/obj/item/clothing/shoes/shadowling
	name = "chitin feet"
	desc = "Charred-looking feet. They have minature hooks that latch onto flooring."
	icon_state = "shadowling"
	item_state = null
	flags = NOSLIP | ABSTRACT | NODROP | UNACIDABLE


/obj/item/clothing/mask/gas/shadowling
	name = "chitin mask"
	desc = "A mask-like formation with slots for facial features. A red film covers the eyes."
	icon_state = "shadowling"
	item_state = null
	origin_tech = null
	siemens_coefficient = 0
	flags = ABSTRACT | NODROP | UNACIDABLE


/obj/item/clothing/gloves/shadowling
	name = "chitin hands"
	desc = "An electricity-resistant covering of the hands."
	icon_state = "shadowling"
	item_state = null
	origin_tech = null
	siemens_coefficient = 0
	flags = ABSTRACT | NODROP | UNACIDABLE


/obj/item/clothing/head/shadowling
	name = "chitin helm"
	desc = "A helmet-like enclosure of the head."
	alternate_worn_icon = 'hippiestation/icons/mob/suit.dmi'
	icon = 'hippiestation/icons/obj/clothing/suits.dmi'
	icon_state = "sl_head"
	item_state = "sl_head"
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	origin_tech = null
	flags = ABSTRACT | NODROP | STOPSPRESSUREDMAGE | UNACIDABLE
