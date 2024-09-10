/// Bunny snout
//
/obj/item/organ/external/snout/bunny
	name = "bunny snout"
	preference = "feature_bunny_snout"
	external_bodyshapes = BODYSHAPE_HUMANOID
	bodypart_overlay = /datum/bodypart_overlay/mutant/snout/bunny

/datum/bodypart_overlay/mutant/snout/bunny/get_global_feature_list()
	return SSaccessories.snouts_list_bunny
