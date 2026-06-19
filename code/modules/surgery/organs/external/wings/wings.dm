///Wing base type. doesn't really do anything
/obj/item/organ/wings
	name = "wings"
	desc = "Spread your wings and FLLLLLLLLYYYYY!"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_WINGS

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/wings

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL
	abstract_type = /obj/item/organ/wings

///Checks if the wings can soften short falls
/obj/item/organ/wings/proc/can_soften_fall()
	return TRUE

///Implement as needed to play a sound effect on *flap emote
/obj/item/organ/wings/proc/make_flap_sound(mob/living/carbon/wing_owner)
	return

///Bodypart overlay of default wings. Does not have any wing functionality
/datum/bodypart_overlay/mutant/wings
	layers = list(
		EXTERNAL_FRONT = BODY_FRONT_LAYER,
		EXTERNAL_BEHIND = BODY_BEHIND_LAYER,
		EXTERNAL_ADJACENT = BODY_ADJ_LAYER,
	)
	feature_key = FEATURE_WINGS
	offset_location = ENTIRE_BODY
	/// Slot we check against
	var/slot_blocker = HIDEJUMPSUIT

/datum/bodypart_overlay/mutant/wings/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner)
	return ..() && !(bodypart_owner.owner?.obscured_slots & slot_blocker)
