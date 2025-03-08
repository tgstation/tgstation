/**
 * Root Powers
 */
/datum/power/medical
	name = "Medical Specialty"
	desc = "Your specialty lies in caring for the wounded. Applying sutures and other similar items is faster."
	cost = 6
	root_power = /datum/power/medical
	power_type = TRAIT_PATH_SUBTYPE_EXPERT
	power_traits = list(TRAIT_POWER_MEDICAL)

/datum/power/engineering
	name = "Engineering Specialty"
	desc = "Your specialty lies in construction and deconstruction. You're slightly faster at using all tools."
	cost = 6
	root_power = /datum/power/engineering
	power_type = TRAIT_PATH_SUBTYPE_EXPERT
	power_traits = list(TRAIT_POWER_ENGINEERING)

/datum/power/service
	name = "Service Speciality"
	desc = "Your speciality lies in supporting the station."
	cost = 6
	root_power = /datum/power/service
	power_type = TRAIT_PATH_SUBTYPE_EXPERT
	power_traits = list(TRAIT_POWER_SERVICE)

/**
 * Basic powers
 */
/datum/power/seasoned_chef
	name = "Seasoned Chef"
	desc = "You are a seasoned chef."
	cost = 4
	root_power = /datum/power/service
	power_type = TRAIT_PATH_SUBTYPE_EXPERT

/datum/power/green_thumb
	name = "Green Thumb"
	desc = "You are a green thumb."
	cost = 2
	root_power = /datum/power/service
	power_type = TRAIT_PATH_SUBTYPE_EXPERT

/**
 * Advanced powers
 */

/datum/power/master_chef
	name = "Master Chef"
	desc = "You are a master chef. Requires Green Thumb and Master Chef"
	cost = 8
	root_power = /datum/power/service
	power_type = TRAIT_PATH_SUBTYPE_EXPERT
	advanced = TRUE
	required_powers = list(/datum/power/green_thumb, /datum/power/seasoned_chef)
