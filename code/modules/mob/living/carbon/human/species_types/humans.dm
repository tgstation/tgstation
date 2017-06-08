/datum/species/human
	name = "Human"
	id = "human"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	mutant_bodyparts = list("wings")
	default_features = list("mcolor" = "FFF", "wings" = "None")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	
/datum/species/human/qualifies_for_rank(rank, list/features)
	return TRUE	//Pure humans are always allowed in all roles.

/datum/species/human/space_move(mob/living/carbon/human/H)
	var/obj/item/device/flightpack/F = H.get_flightpack()
	if(istype(F) && (F.flight) && F.allow_thrust(0.01, src))
		return TRUE
