/datum/sprite_accessory
	///the body slots outside of the main slot this accessory exists in, so we can draw to those spots seperately
	var/list/body_slots = list()
	/// the list of external organs covered
	var/list/external_slots = list()

/datum/sprite_accessory/body_markings/cbelly
	icon = 'massmeta/icons/mob/species/lizard/multipart.dmi'
	name = "Color Belly"
	body_slots = list(BODY_ZONE_HEAD)
	external_slots = list(ORGAN_SLOT_EXTERNAL_TAIL)
	icon_state = "cbelly"
	gender_specific = 1
	color_src = MUTANT_COLOR_SECONDARY