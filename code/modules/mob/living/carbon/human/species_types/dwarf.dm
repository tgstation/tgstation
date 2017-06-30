/datum/species/dwarf //not to be confused with the genetic manlets
	name = "Dwarf"
	id = "dwarf"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,NOBREATH,NO_UNDERWEAR)
	mutant_bodyparts = list("tail_human", "ears", "wings")
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None")
	limbs_id = "dwarf"
	face_y_offset = -3
	hair_y_offset = -4
	use_skintones = 1
	speedmod = 1
	damage_overlay_type = "monkey" //fits surprisngly well, so why add more icons?
	skinned_type = /obj/item/stack/sheet/animalhide/human
	brutemod = 0.9
	coldmod = 0.85
	punchdamagehigh = 11
	mutant_organs = list(/obj/item/organ/alcoholvessel)
	mutanteyes = /obj/item/organ/eyes/night_vision

/datum/species/dwarf/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	var/dwarf_hair = pick("Dwarf Beard", "Very Long Beard", "Full Beard")
	var/mob/living/carbon/human/H = C
	H.grant_language(/datum/language/dwarvish)
	H.remove_language(/datum/language/common)
	H.facial_hair_style = dwarf_hair
	H.update_hair()

	var/obj/item/organ/alcoholvessel/dwarf
	dwarf = H.getorganslot("dwarf_organ")
	if(!dwarf)
		dwarf = new()
		dwarf.Insert(H)

/datum/species/dwarf/random_name(gender,unique,lastname)
	return dwarf_name()