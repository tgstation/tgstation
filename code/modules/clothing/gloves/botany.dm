/obj/item/clothing/gloves/botanic_leather
	name = "botanist's leather gloves"
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin.  They're also quite warm."
	icon_state = "leather"
	inhand_icon_state = null
	greyscale_colors = null
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	clothing_traits = list(TRAIT_PLANT_SAFE)
	armor_type = /datum/armor/gloves_botanic_leather

/obj/item/clothing/gloves/botanic_leather/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, -2)

/datum/armor/gloves_botanic_leather
	bio = 50
	fire = 70
	acid = 30
