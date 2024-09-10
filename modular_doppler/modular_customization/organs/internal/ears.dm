/// Cat ears
//
/obj/item/organ/internal/ears/cat
	bodypart_overlay = /datum/bodypart_overlay/mutant/ears/cat_ears

/datum/bodypart_overlay/mutant/ears/cat_ears/get_global_feature_list()
	return SSaccessories.ears_list

/// Dog ears
//
/obj/item/organ/internal/ears/dog
	preference = "feature_dog_ears"
	bodypart_overlay = /datum/bodypart_overlay/mutant/ears/dog_ears

/datum/bodypart_overlay/mutant/ears/dog_ears/get_global_feature_list()
	return SSaccessories.ears_list_dog

/// Fox ears
//
/obj/item/organ/internal/ears/fox
	preference = "feature_fox_ears"
	bodypart_overlay = /datum/bodypart_overlay/mutant/ears/fox_ears

/datum/bodypart_overlay/mutant/ears/fox_ears/get_global_feature_list()
	return SSaccessories.ears_list_fox
