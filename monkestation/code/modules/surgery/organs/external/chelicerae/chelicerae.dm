/obj/item/organ/external/chelicerae
	name = "arachnid chelicerae"
	desc = "Some fang things, spooky."

	preference = "feature_arachnid_chelicerae"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_ANTENNAE

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/arachnid_chelicerae

/datum/bodypart_overlay/mutant/arachnid_chelicerae
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	feature_key = "arachnid_chelicerae"

/datum/bodypart_overlay/mutant/arachnid_chelicerae/get_global_feature_list()
	return GLOB.arachnid_chelicerae_list

/datum/bodypart_overlay/mutant/arachnid_chelicerae/get_base_icon_state()
	return sprite_datum.icon_state //i still hate you

/datum/bodypart_overlay/mutant/arachnid_chelicerae/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!(human.wear_mask?.flags_inv & HIDESNOUT) && !(human.head?.flags_inv & HIDESNOUT))
		return TRUE
	return FALSE
