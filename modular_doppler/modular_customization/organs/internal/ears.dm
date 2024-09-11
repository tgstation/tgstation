/// Cat ears
//
/obj/item/organ/internal/ears/cat
	bodypart_overlay = /datum/bodypart_overlay/mutant/ears/cat_ears

/datum/bodypart_overlay/mutant/ears/cat_ears/get_global_feature_list()
	return SSaccessories.ears_list

/// Fox ears
//
/obj/item/organ/internal/ears/fox
	preference = "feature_fox_ears"
	bodypart_overlay = /datum/bodypart_overlay/mutant/ears/fox_ears

/datum/bodypart_overlay/mutant/ears/fox_ears/get_global_feature_list()
	return SSaccessories.ears_list_fox

/// Dog ears
//
/obj/item/organ/internal/ears/dog
	preference = "feature_dog_ears"
	bodypart_overlay = /datum/bodypart_overlay/mutant/ears/dog_ears

/datum/bodypart_overlay/mutant/ears/dog_ears/get_global_feature_list()
	return SSaccessories.ears_list_dog

/// Bunny ears
//
/obj/item/organ/internal/ears/bunny
	preference = "feature_bunny_ears"
	bodypart_overlay = /datum/bodypart_overlay/mutant/ears/bunny_ears

/datum/bodypart_overlay/mutant/ears/bunny_ears/get_global_feature_list()
	return SSaccessories.ears_list_bunny

/// Mouse ears
//
/obj/item/organ/internal/ears/mouse
	preference = "feature_mouse_ears"
	bodypart_overlay = /datum/bodypart_overlay/mutant/ears/mouse_ears

/datum/bodypart_overlay/mutant/ears/mouse_ears/get_global_feature_list()
	return SSaccessories.ears_list_mouse
