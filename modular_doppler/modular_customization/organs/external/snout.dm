/// Lizard snout
//	TG's lizard snout is its parent type
/obj/item/organ/external/snout/lizard

/// Bunny snout
//
/obj/item/organ/external/snout/bunny
	name = "bunny snout"
	preference = "feature_bunny_snout"
	external_bodyshapes = BODYSHAPE_HUMANOID
	bodypart_overlay = /datum/bodypart_overlay/mutant/snout/bunny

/datum/bodypart_overlay/mutant/snout/bunny/get_global_feature_list()
	return SSaccessories.snouts_list_bunny

/// Mouse snout
//
/obj/item/organ/external/snout/mouse
	name = "mouse snout"
	preference = "feature_mouse_snout"
	external_bodyshapes = BODYSHAPE_HUMANOID
	bodypart_overlay = /datum/bodypart_overlay/mutant/snout/mouse

/datum/bodypart_overlay/mutant/snout/mouse/get_global_feature_list()
	return SSaccessories.snouts_list_mouse
