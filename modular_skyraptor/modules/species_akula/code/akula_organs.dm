// SNOUT
/obj/item/organ/external/snout/akula
	name = "akula snout"
	desc = "Pointy and keen."
	icon_state = "snout"

	preference = "feature_akula_snout"

	bodypart_overlay = /datum/bodypart_overlay/mutant/snout/akula

/datum/bodypart_overlay/mutant/snout/akula
	feature_key = "snout_akula"

/datum/bodypart_overlay/mutant/snout/akula/get_global_feature_list()
	return GLOB.snouts_list_akula



// HORNS
/obj/item/organ/external/horns/akula
	name = "akula horns"
	desc = "These really seem more like ears, but the actual heary bits are well past this."
	icon_state = "horns"

	preference = "feature_akula_horns"

	bodypart_overlay = /datum/bodypart_overlay/mutant/horns/akula

/datum/bodypart_overlay/mutant/horns/akula
	feature_key = "horns_akula"

/datum/bodypart_overlay/mutant/horns/akula/get_global_feature_list()
	return GLOB.horns_list_akula



// TAILS
/obj/item/organ/external/tail/akula
	name = "akula tail"
	desc = "A lithe, muscular tail, perfect for guiding one through the water.  It's really not as useful in your hands."

	preference = "feature_akula_tail"
	wag_flags = WAG_ABLE

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/akula

/datum/bodypart_overlay/mutant/tail/akula
	feature_key = "tail_akula"

/datum/bodypart_overlay/mutant/tail/akula/get_global_feature_list()
	return GLOB.tails_list_akula
