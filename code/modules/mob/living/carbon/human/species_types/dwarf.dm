/datum/species/dwarf //not to be confused with the genetic manlets
	name = "Dwarf"
	id = "dwarf"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,NOBREATH,NO_UNDERWEAR)
	mutant_bodyparts = list("tail_human", "ears", "wings")
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None")
	limbs_id = "dwarf"
	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,0), OFFSET_EARS = list(0,0), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), OFFSET_HAIR = list(0,-4), OFFSET_FACE = list(0,-3), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))
	use_skintones = 1
	speedmod = 1
	blacklisted = TRUE
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