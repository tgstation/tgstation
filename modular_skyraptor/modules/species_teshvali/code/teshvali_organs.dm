/obj/item/organ/internal/eyes/teshvali
	name = "teshvali eyes"
	desc = "All-seeing eyes built to survey from the skies."
	eye_icon_file = 'modular_skyraptor/modules/species_teshvali/icons/teshvali_external.dmi'
	eye_icon_state = "teshvalieyes"
	icon_state = "eyeballs-moth"



// SNOUT
/obj/item/organ/external/snout/teshvali
	name = "teshvali snout"
	desc = "A fierce little snoot from a fierce creature."
	icon_state = "snout"

	preference = "feature_teshvali_snout"

	bodypart_overlay = /datum/bodypart_overlay/mutant/snout/teshvali

/datum/bodypart_overlay/mutant/snout/teshvali
	feature_key = "snout_teshvali"

/datum/bodypart_overlay/mutant/snout/teshvali/get_global_feature_list()
	return GLOB.snouts_list_teshvali



// HORNS
/obj/item/organ/external/horns/teshvali
	name = "teshvali horns"
	desc = "Whoa, there's four of them!"
	icon_state = "horns"

	preference = "feature_teshvali_horns"

	bodypart_overlay = /datum/bodypart_overlay/mutant/horns/teshvali

/datum/bodypart_overlay/mutant/horns/teshvali
	feature_key = "horns_teshvali"

/datum/bodypart_overlay/mutant/horns/teshvali/get_global_feature_list()
	return GLOB.horns_list_teshvali



// TAILS
/obj/item/organ/external/tail/teshvali
	name = "teshvali tail"
	desc = "It's a feather fan!"

	preference = "feature_teshvali_tail"
	wag_flags = WAG_ABLE

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/teshvali

/datum/bodypart_overlay/mutant/tail/teshvali
	feature_key = "tail_teshvali"

/datum/bodypart_overlay/mutant/tail/teshvali/get_global_feature_list()
	return GLOB.tails_list_teshvali
