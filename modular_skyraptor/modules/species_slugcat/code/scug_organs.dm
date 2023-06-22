/obj/item/organ/internal/eyes/slugcat
	name = "slugcat eyes"
	desc = "Wide eyes that watch for predators."
	eye_icon_file = 'modular_skyraptor/modules/species_slugcat/icons/slugcat_external.dmi'
	eye_icon_state = "scugeyes"
	icon_state = "eyeballs-moth"



// SNOUT
/obj/item/organ/external/snout/slugcat
	name = "slugcat snout"
	desc = "Woa...Sluggy."
	icon_state = "snout"

	preference = "feature_slugcat_snout"

	bodypart_overlay = /datum/bodypart_overlay/mutant/snout/slugcat

/datum/bodypart_overlay/mutant/snout/slugcat
	feature_key = "snout_scug"

/datum/bodypart_overlay/mutant/snout/slugcat/get_global_feature_list()
	return GLOB.snouts_list_slugcat



// HORNS
/obj/item/organ/external/horns/slugcat
	name = "slugcat horns"
	desc = "Taking the place of ears for a little bit because hrngh."
	icon_state = "horns"

	preference = "feature_slugcat_horns"

	bodypart_overlay = /datum/bodypart_overlay/mutant/horns/slugcat

/datum/bodypart_overlay/mutant/horns/slugcat
	feature_key = "horns_scug"

/datum/bodypart_overlay/mutant/horns/slugcat/get_global_feature_list()
	return GLOB.horns_list_slugcat



// TAILS
/obj/item/organ/external/tail/slugcat
	name = "slugcat tail"
	desc = "A soft and weighty tail that feels more like one of those chiropractic pillows than a regular tail."

	preference = "feature_slugcat_tail"
	wag_flags = WAG_ABLE

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/slugcat

/datum/bodypart_overlay/mutant/tail/slugcat
	feature_key = "tail_scug"

/datum/bodypart_overlay/mutant/tail/slugcat/get_global_feature_list()
	return GLOB.tails_list_slugcat



// FRILLS
/obj/item/organ/external/frills/slugcat
	name = "slugcat frills"
	desc = "Somewhere between fluff and gills, depending on the slugcat."

	preference = "feature_slugcat_frills"

	bodypart_overlay = /datum/bodypart_overlay/mutant/frills/slugcat

/datum/bodypart_overlay/mutant/frills/slugcat
	feature_key = "frills_scug"

/datum/bodypart_overlay/mutant/frills/slugcat/get_global_feature_list()
	return GLOB.frills_list_slugcat
