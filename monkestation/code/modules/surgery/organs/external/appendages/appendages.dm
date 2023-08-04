/obj/item/organ/external/arachnid_appendages
	name = "arachnid appendages"
	desc = "Extra legs that go on your back, don't actually work for walking sadly."
	//I don't even know if these work
	//icon = 'monkestation/icons/mob/species/arachnid/arachnid_appendages.dmi'
	//icon_state = "long"

	preference = "feature_arachnid_appendages"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_WINGS

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/arachnid_appendages

/datum/bodypart_overlay/mutant/arachnid_appendages
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	feature_key = "arachnidappendages"

/datum/bodypart_overlay/mutant/arachnid_appendages/get_global_feature_list()
	return GLOB.arachnid_appendages_list

/datum/bodypart_overlay/mutant/arachnid_appendages/get_base_icon_state()
	return sprite_datum.icon_state //i hate you

/datum/bodypart_overlay/mutant/arachnid_appendages/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!human.wear_suit)
		return TRUE
	if(!(human.wear_suit.flags_inv & HIDEJUMPSUIT))
		return TRUE
	if(human.wear_suit.species_exception && is_type_in_list(src, human.wear_suit.species_exception))
		return TRUE
	return FALSE
