/obj/item/organ/external/horns/lizard
	name = "horns"
	desc = "Why do lizards even have horns? Well, this one obviously doesn't."
	icon_state = "horns"

	preference = "feature_lizard_horns"

	bodypart_overlay = /datum/bodypart_overlay/mutant/horns/lizard

/datum/bodypart_overlay/mutant/horns/lizard
	feature_key = "horns_lizard"

/datum/bodypart_overlay/mutant/horns/lizard/get_global_feature_list()
	return GLOB.horns_list_lizard



/obj/item/organ/external/frills/lizard
	name = "frills"
	desc = "Ear-like external organs often seen on aquatic reptillians."
	icon_state = "frills"

	preference = "feature_lizard_frills"

	bodypart_overlay = /datum/bodypart_overlay/mutant/frills/lizard

/datum/bodypart_overlay/mutant/frills/lizard
	feature_key = "frills_lizard"

/datum/bodypart_overlay/mutant/frills/lizard/get_global_feature_list()
	return GLOB.frills_list_lizard