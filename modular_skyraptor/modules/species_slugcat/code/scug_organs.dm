/obj/item/organ/internal/eyes/slugcat
	name = "slugcat eyes"
	desc = "Wide eyes that watch for predators."
	eye_icon_file = 'modular_skyraptor/modules/species_slugcat/icons/slugcat_external.dmi'
	eye_icon_state = "scugeyes"
	icon_state = "eyeballs-moth"

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
