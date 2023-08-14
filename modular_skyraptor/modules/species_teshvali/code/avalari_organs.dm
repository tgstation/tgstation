/obj/item/organ/internal/eyes/avalari
	name = "avalari eyes"
	desc = "All-seeing eyes built to survey from the skies."
	eye_icon_file = 'modular_skyraptor/modules/species_teshvali/icons/avalari_external.dmi'
	eye_icon_state = "avalarieyes"
	icon_state = "eyeballs-moth"



// SNOUT
/obj/item/organ/external/snout/avalari
	name = "avalari snout"
	desc = "A fierce little snoot from a fierce creature."
	icon_state = "snout"

	preference = "feature_avalari_snout"

	bodypart_overlay = /datum/bodypart_overlay/mutant/snout/avalari

/datum/bodypart_overlay/mutant/snout/avalari
	feature_key = "snout_avalari"

/datum/bodypart_overlay/mutant/snout/avalari/get_global_feature_list()
	return GLOB.snouts_list_avalari



// HORNS
/obj/item/organ/external/horns/avalari
	name = "avalari horns"
	desc = "Whoa, there's four of them!"
	icon_state = "horns"

	preference = "feature_avalari_horns"

	bodypart_overlay = /datum/bodypart_overlay/mutant/horns/avalari

/datum/bodypart_overlay/mutant/horns/avalari
	feature_key = "horns_avalari"

/datum/bodypart_overlay/mutant/horns/avalari/get_global_feature_list()
	return GLOB.horns_list_avalari



// TAILS
/obj/item/organ/external/tail/avalari
	name = "avalari tail"
	desc = "It's a feather fan!"

	preference = "feature_avalari_tail"
	wag_flags = WAG_ABLE

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/avalari

/datum/bodypart_overlay/mutant/tail/avalari
	feature_key = "tail_avalari"

/datum/bodypart_overlay/mutant/tail/avalari/get_global_feature_list()
	return GLOB.tails_list_avalari
