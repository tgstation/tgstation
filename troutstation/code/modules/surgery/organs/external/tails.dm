/obj/item/organ/tail/anteater
	name = "anteater tail"
	desc = "Do not use as a feather duster. I know it's really tempting."
	preference = "feature_anteater_tail"

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/anteater
	dna_block = /datum/dna_block/feature/tail_anteater

/datum/bodypart_overlay/mutant/tail/anteater
	feature_key = FEATURE_ANTEATER_TAIL

/datum/bodypart_overlay/mutant/tail/anteater/get_global_feature_list()
	return SSaccessories.tails_list_anteater
