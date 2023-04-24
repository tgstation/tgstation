///Wing base type. doesn't really do anything
/obj/item/organ/external/wings
	name = "wings"
	desc = "Spread your wings and FLLLLLLLLYYYYY!"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_WINGS

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/wings

///Checks if the wings can soften short falls
/obj/item/organ/external/wings/proc/can_soften_fall()
	return TRUE

///Bodypart overlay of default wings. Does not have any wing functionality
/datum/bodypart_overlay/mutant/wings
	layers = ALL_EXTERNAL_OVERLAYS
	feature_key = "wings"

/datum/bodypart_overlay/mutant/wings/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!human.wear_suit)
		return TRUE
	if(!(human.wear_suit.flags_inv & HIDEJUMPSUIT))
		return TRUE
	if(human.wear_suit.species_exception && is_type_in_list(src, human.wear_suit.species_exception))
		return TRUE
	return FALSE


