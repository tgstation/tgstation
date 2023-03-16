/obj/item/organ/external/antennae/ipc
	name = "ipcs antennae"
	desc = "An ipc's antennae. What is it telling them? What are they sensing?"
	icon_state = "antennae"

	zone = BODY_ZONE_HEAD

	preference = "feature_ipc_antenna"

	bodypart_overlay = /datum/bodypart_overlay/mutant/antennae/ipc


/obj/item/organ/external/antennae/ipc/try_burn_antennae(mob/living/carbon/human/human)
	return

/datum/bodypart_overlay/mutant/antennae/ipc
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	feature_key = "ipc_antenna"

/datum/bodypart_overlay/mutant/antennae/ipc/get_global_feature_list()
	return GLOB.ipc_antennas_list

/datum/bodypart_overlay/mutant/antennae/ipc/get_base_icon_state()
	return sprite_datum.icon_state
