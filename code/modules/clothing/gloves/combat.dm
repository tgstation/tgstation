/obj/item/clothing/gloves/combat
	name = "combat gloves"
	desc = "These tactical gloves are fireproof and electrically insulated."
	icon_state = "black"
	greyscale_colors = "#2f2e31"
	siemens_coefficient = 0
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor_type = /datum/armor/gloves_combat
	clothing_traits = list(TRAIT_FAST_CUFFING)

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

/obj/item/clothing/gloves/combat/wizard/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, -3) //something something wizard casting

/obj/item/clothing/gloves/combat/floortile
	name = "floortile camouflage gloves"
	desc = "Is it just me or is there a pair of gloves on the floor?"
	icon_state = "ftc_gloves"
	inhand_icon_state = "greyscale_gloves"

/obj/item/clothing/gloves/combat/floortiletile/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, -3) //tacticool
