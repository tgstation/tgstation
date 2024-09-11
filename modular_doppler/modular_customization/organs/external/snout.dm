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

/// Cat snout
//
/obj/item/organ/external/snout/cat
	name = "cat snout"
	preference = "feature_cat_snout"
	external_bodyshapes = BODYSHAPE_HUMANOID
	bodypart_overlay = /datum/bodypart_overlay/mutant/snout/cat

/datum/bodypart_overlay/mutant/snout/cat/get_global_feature_list()
	return SSaccessories.snouts_list_cat

/// Bird snout
//
/obj/item/organ/external/snout/bird
	name = "bird beak"
	preference = "feature_bird_snout"
	external_bodyshapes = BODYSHAPE_SNOUTED
	bodypart_overlay = /datum/bodypart_overlay/mutant/snout/bird

/datum/bodypart_overlay/mutant/snout/bird/get_global_feature_list()
	return SSaccessories.snouts_list_bird
