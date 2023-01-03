/obj/item/clothing/gloves/combat
	name = "combat gloves"
	desc = "These tactical gloves are fireproof and electrically insulated."
	icon_state = "combat"
	greyscale_colors = "#3d3c40"
	siemens_coefficient = 0
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor_type = /datum/armor/gloves_combat

/datum/armor/gloves_combat
	bio = 90
	fire = 80
	acid = 50

/obj/item/clothing/gloves/combat/wizard
	name = "enchanted gloves"
	desc = "These gloves have been enchanted with a spell that makes them electrically insulated and fireproof."
	icon_state = "wizard"
	greyscale_colors = null
	inhand_icon_state = null

/obj/item/clothing/gloves/combat/gauntlets
	name = "combat gauntlets"
	desc = "Fireproof and insulated combat equipment that extends up to the forearm."
	icon_state = "black_gauntlets"

/obj/item/clothing/gloves/combat/red
	name = "red gauntlets"
	icon_state = "trauma"
