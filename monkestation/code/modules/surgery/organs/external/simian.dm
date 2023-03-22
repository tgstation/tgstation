/obj/item/organ/external/tail/simian
	name = "simian tail"
	desc = "A severed simian tail. Somewhere, no doubt, a simian hater is very pleased with themselves."
	preference = "feature_tail_monkey"

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/simian

/datum/bodypart_overlay/mutant/tail/simian
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	feature_key = "tail_monkey"

/datum/bodypart_overlay/mutant/tail/simian/get_global_feature_list()
	return GLOB.tails_list_monkey

/datum/bodypart_overlay/mutant/tail/simian/get_base_icon_state()
	return sprite_datum.icon_state
