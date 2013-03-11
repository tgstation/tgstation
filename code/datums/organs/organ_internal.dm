/****************************************************
				INTERNAL ORGANS
****************************************************/

/*
/datum/organ/internal
	name = "internal"
	var/damage = 0
	var/max_damage = 100

/datum/organ/internal/skeleton
	name = "spooky scary skeleton"
	max_damage = 200

/datum/organ/internal/skin
	name = "skin"
	max_damage = 100

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

*/

/mob/living/carbon/human/var/list/internal_organs = list()

/datum/organ/internal
	// amount of damage to the organ
	var/damage = 0
	var/min_bruised_damage = 10
	var/min_broken_damage = 30
	var/parent_organ = "chest"

/datum/organ/internal/proc/is_bruised()
	return damage >= min_bruised_damage

/datum/organ/internal/proc/is_broken()
	return damage >= min_broken_damage


/datum/organ/internal/New(mob/living/carbon/human/H)
	..()
	var/datum/organ/external/E = H.organs_by_name[src.parent_organ]
	if(E.internal_organs == null)
		E.internal_organs = list()
	E.internal_organs += src
	H.internal_organs[src.name] = src
	src.owner = H

/datum/organ/internal/proc/take_damage(amount)
	src.damage += amount

	var/datum/organ/external/parent = owner.get_organ(parent_organ)
	owner.custom_pain("Something inside your [parent.display_name] hurts a lot.", 1)

/datum/organ/internal/heart
	name = "heart"
	parent_organ = "chest"


/datum/organ/internal/lungs
	name = "lungs"
	parent_organ = "chest"

/datum/organ/internal/liver
	name = "liver"
	parent_organ = "chest"


/datum/organ/internal/kidney
	name = "kidney"
	parent_organ = "chest"

/datum/organ/internal/brain
	name = "brain"
	parent_organ = "head"