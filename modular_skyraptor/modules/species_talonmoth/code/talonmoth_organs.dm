/obj/item/organ/internal/eyes/talonmoth
	name = "talonmoth eyes"
	desc = "Tired eyes from a dying world."
	eye_icon_file = 'modular_skyraptor/modules/species_talonmoth/icons/talonmoth_external.dmi'
	eye_icon_state = "talonmotheyes"
	icon_state = "eyeballs-moth"



// SNOUT
/obj/item/organ/external/snout/talonmoth
	name = "talonmoth snout"
	desc = "Sharp and fierce, yet fluffy."
	icon_state = "snout"

	preference = "feature_talonmoth_snout"

	bodypart_overlay = /datum/bodypart_overlay/mutant/snout/talonmoth

/datum/bodypart_overlay/mutant/snout/talonmoth
	feature_key = "snout_talonmoth"

/datum/bodypart_overlay/mutant/snout/talonmoth/get_global_feature_list()
	return GLOB.snouts_list_talonmoth
