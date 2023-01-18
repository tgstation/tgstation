/obj/item/clothing/gloves/braces
	name = "combat braces"
	desc = "These tactical braces offer protection to the arms and hands."
	icon_state = "black"
	inhand_icon_state = "armor"
	greyscale_colors = null
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 80
	armor_type = /datum/armor/braces_combat
	resistance_flags = NONE
	body_parts_covered = ARMS|HANDS

/datum/armor/braces_combat
	bio = 90
	fire = 80
	acid = 50

/obj/item/clothing/gloves/braces/bulletproof
	name = "bulletproof braces"
	desc = "These tactical braces offer ballistic protection to the arms and hands."
	icon_state = "bulletproof"
	inhand_icon_state = "armor"
	greyscale_colors = null
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 80
	armor_type = /datum/armor/armor_bulletproof
	resistance_flags = NONE
	body_parts_covered = ARMS|HANDS

/obj/item/clothing/gloves/braces/riot
	name = "riot braces"
	desc = "These tactical braces offer protection to the arms and hands."
	icon_state = "riot"
	inhand_icon_state = "armor"
	greyscale_colors = null
	siemens_coefficient = 0
	cold_protection = HANDS|ARMS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS|ARMS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 80
	armor_type = /datum/armor/armor_riot
	resistance_flags = NONE
	body_parts_covered = ARMS|HANDS
