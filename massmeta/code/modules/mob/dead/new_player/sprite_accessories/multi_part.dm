/datum/sprite_accessory
	///the body slots outside of the main slot this accessory exists in, so we can draw to those spots seperately
	var/list/body_slots = list()
	/// the list of external organs covered
	var/list/external_slots = list()

/datum/sprite_accessory/body_markings
	color_src = TRAIT_MUTANT_COLORS_SECONDARY

/datum/sprite_accessory/body_markings/light_belly
	name = "Light Belly"
	body_slots = list(BODY_ZONE_HEAD)
	external_slots = list(ORGAN_SLOT_EXTERNAL_TAIL)
	icon = 'massmeta/icons/mob/species/lizard/multipart.dmi'
	icon_state = "lbelly"
	gender_specific = 1

/*
/datum/sprite_accessory/body_markings/glow_belly
	name = "Glow Belly"
	body_slots = list(BODY_ZONE_HEAD)
	external_slots = list(ORGAN_SLOT_EXTERNAL_TAIL)
	icon = 'massmeta/icons/mob/species/lizard/multipart.dmi'
	icon_state = "lbelly"
	is_emissive = TRUE
*/
/*
/datum/sprite_accessory/spines/short
	name = "Short"
	icon_state = "short"
	external_slots = list(ORGAN_SLOT_EXTERNAL_TAIL)
	icon = 'massmeta/icons/mob/species/lizard/multipart.dmi'

/datum/sprite_accessory/spines_animated/short
	name = "Short"
	icon_state = "short"
	external_slots = list(ORGAN_SLOT_EXTERNAL_TAIL)
	icon = 'massmeta/icons/mob/species/lizard/multipart.dmi'

/datum/sprite_accessory/spines/shortmeme
	name = "Short + Membrane"
	icon_state = "shortmeme"
	external_slots = list(ORGAN_SLOT_EXTERNAL_TAIL)
	icon = 'massmeta/icons/mob/species/lizard/multipart.dmi'

/datum/sprite_accessory/spines_animated/shortmeme
	name = "Short + Membrane"
	icon_state = "shortmeme"
	external_slots = list(ORGAN_SLOT_EXTERNAL_TAIL)
	icon = 'massmeta/icons/mob/species/lizard/multipart.dmi'

/datum/sprite_accessory/spines/long
	name = "Long"
	icon_state = "long"
	external_slots = list(ORGAN_SLOT_EXTERNAL_TAIL)
	icon = 'massmeta/icons/mob/species/lizard/multipart.dmi'

/datum/sprite_accessory/spines_animated/long
	name = "Long"
	icon_state = "long"
	external_slots = list(ORGAN_SLOT_EXTERNAL_TAIL)
	icon = 'massmeta/icons/mob/species/lizard/multipart.dmi'

/datum/sprite_accessory/spines/longmeme
	name = "Long + Membrane"
	icon_state = "longmeme"
	external_slots = list(ORGAN_SLOT_EXTERNAL_TAIL)
	icon = 'massmeta/icons/mob/species/lizard/multipart.dmi'

/datum/sprite_accessory/spines_animated/longmeme
	name = "Long + Membrane"
	icon_state = "longmeme"
	external_slots = list(ORGAN_SLOT_EXTERNAL_TAIL)
	icon = 'massmeta/icons/mob/species/lizard/multipart.dmi'

/datum/sprite_accessory/spines/aqautic
	name = "Aquatic"
	icon_state = "aqua"
	body_slots = list(BODY_ZONE_HEAD)
	external_slots = list(ORGAN_SLOT_EXTERNAL_TAIL)
	icon = 'massmeta/icons/mob/species/lizard/multipart.dmi'

/datum/sprite_accessory/spines_animated/aqautic
	name = "Aquatic"
	icon_state = "aqua"
	body_slots = list(BODY_ZONE_HEAD)
	external_slots = list(ORGAN_SLOT_EXTERNAL_TAIL)
	icon = 'massmeta/icons/mob/species/lizard/multipart.dmi'
*/