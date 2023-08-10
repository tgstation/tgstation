/obj/item/organ/external/goblin_ears
	name = "goblin ears"
	desc = "They don't actually let you hear better."
	icon_state = "goblin_ears"

	preference = "feature_goblin_ears"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_FRILLS

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/goblin_ears

/datum/bodypart_overlay/mutant/goblin_ears
	layers = EXTERNAL_ADJACENT | EXTERNAL_FRONT
	feature_key = "goblin_ears"

/datum/bodypart_overlay/mutant/goblin_ears/get_global_feature_list()
	return GLOB.goblin_ears_list

/datum/bodypart_overlay/mutant/goblin_ears/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/goblin_ears/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE

//Remove when eyes work with dwarfism
/obj/item/organ/external/goblin_eyes
	name = "goblin eyes"
	desc = "You're not supposed to be able to see these."
	icon_state = "goblin_eyes"

	preference = "feature_goblin_eyes"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_FRILLS

	use_mob_sprite_as_obj_sprite = FALSE

/datum/bodypart_overlay/mutant/goblin_eyes
	layers = EXTERNAL_FRONT
	feature_key = "goblin_eyes"

/datum/bodypart_overlay/mutant/goblin_eyes/get_global_feature_list()
	return GLOB.goblin_eyes_list

/datum/bodypart_overlay/mutant/goblin_eyes/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/goblin_eyes/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE
