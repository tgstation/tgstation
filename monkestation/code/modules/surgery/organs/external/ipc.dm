/obj/item/organ/external/antennae/ipc
	name = "moth antennae"
	desc = "A moths antennae. What is it telling them? What are they sensing?"
	icon_state = "antennae"

	zone = BODY_ZONE_HEAD

	preference = "feature_ipc_antennae"

	bodypart_overlay = /datum/bodypart_overlay/mutant/antennae/ipc


/obj/item/organ/external/antennae/ipc/try_burn_antennae(mob/living/carbon/human/human)
	return

/datum/bodypart_overlay/mutant/antennae/ipc
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	feature_key = "ipc_antennae"

/datum/bodypart_overlay/mutant/antennae/ipc/get_global_feature_list()
	return GLOB.ipc_antennas_list
