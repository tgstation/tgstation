/datum/organ
	var/name = "organ"
	var/owner = null

/datum/organ/external
	name = "external"
	var/icon_name = null
	var/body_part = null

	var/damage_state = "00"
	var/brute_dam = 0
	var/burn_dam = 0
	var/bandaged = 0
	var/max_damage = 0
	var/wound_size = 0
	var/max_size = 0

/datum/organ/external/chest
	name = "chest"
	icon_name = "chest"
	max_damage = 150
	body_part = UPPER_TORSO

/datum/organ/external/groin
	name = "groin"
	icon_name = "groin"
	max_damage = 115
	body_part = LOWER_TORSO

/datum/organ/external/head
	name = "head"
	icon_name = "head"
	max_damage = 125
	body_part = HEAD

/datum/organ/external/l_arm
	name = "l arm"
	icon_name = "l_arm"
	max_damage = 75
	body_part = ARM_LEFT

/datum/organ/external/l_foot
	name = "l foot"
	icon_name = "l_foot"
	max_damage = 40
	body_part = FOOT_LEFT

/datum/organ/external/l_hand
	name = "l hand"
	icon_name = "l_hand"
	max_damage = 40
	body_part = HAND_LEFT

/datum/organ/external/l_leg
	name = "l leg"
	icon_name = "l_leg"
	max_damage = 75
	body_part = LEG_LEFT

/datum/organ/external/r_arm
	name = "r arm"
	icon_name = "r_arm"
	max_damage = 75
	body_part = ARM_RIGHT

/datum/organ/external/r_foot
	name = "r foot"
	icon_name = "r_foot"
	max_damage = 40
	body_part = FOOT_RIGHT

/datum/organ/external/r_hand
	name = "r hand"
	icon_name = "r_hand"
	max_damage = 40
	body_part = HAND_RIGHT

/datum/organ/external/r_leg
	name = "r leg"
	icon_name = "r_leg"
	max_damage = 75
	body_part = LEG_RIGHT

/datum/organ/internal
	name = "internal"

/datum/organ/internal/blood_vessels
	name = "blood vessels"
	var/heart = null
	var/lungs = null
	var/kidneys = null

/datum/organ/internal/brain
	name = "brain"
	var/head = null

/datum/organ/internal/excretory
	name = "excretory"
	var/excretory = 7.0
	var/blood_vessels = null

/datum/organ/internal/heart
	name = "heart"

/datum/organ/internal/immune_system
	name = "immune system"
	var/blood_vessels = null
	var/isys = null

/datum/organ/internal/intestines
	name = "intestines"
	var/intestines = 3.0
	var/blood_vessels = null

/datum/organ/internal/liver
	name = "liver"
	var/intestines = null
	var/blood_vessels = null

/datum/organ/internal/lungs
	name = "lungs"
	var/lungs = 3.0
	var/throat = null
	var/blood_vessels = null

/datum/organ/internal/stomach
	name = "stomach"
	var/intestines = null

/datum/organ/internal/throat
	name = "throat"
	var/lungs = null
	var/stomach = null