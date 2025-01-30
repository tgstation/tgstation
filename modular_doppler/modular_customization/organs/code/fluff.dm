/obj/item/organ/fluff
	name = "fluff"
	desc = ""
	icon_state = "severedtail"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_FLUFF
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	preference = "feature_fluff"
	dna_block = null
	bodypart_overlay = /datum/bodypart_overlay/mutant/fluff

/datum/bodypart_overlay/mutant/fluff
	feature_key = "fluff"

/datum/bodypart_overlay/mutant/fluff/get_global_feature_list()
	return SSaccessories.fluff_list
