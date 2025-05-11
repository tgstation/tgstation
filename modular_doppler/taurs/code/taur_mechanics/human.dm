/mob/living/carbon/human/mouse_buckle_handling(mob/living/buckling, mob/living/user)
	. = ..()

	if (.)
		return // we already had something happen

	return ride_saddle(buckling, user)

/// The amount of time it takes to mount a mob with a saddle on.
#define SADDLE_MOUNTING_TIME 1.5 SECONDS
/// The mult to be applied to SADDLE_MOUNTING_TIME if the user is mounting someone else onto the saddled mob.
#define SADDLE_MOUNTING_OTHER_MULT 3

/// Attempts to have buckling ride on our saddle, if we have one.
/mob/living/carbon/human/proc/ride_saddle(mob/living/buckling, mob/living/user)
	if (!can_be_ridden_by(buckling, user))
		return FALSE

	var/delay = SADDLE_MOUNTING_TIME
	var/ridee_string = ""
	var/list/mobs_with_special_messages = list(src)
	if (buckling != user)
		ridee_string = " [buckling] onto"
		mobs_with_special_messages += buckling
		delay *= SADDLE_MOUNTING_OTHER_MULT

	user.visible_message(span_warning("[user] starts to mount[ridee_string] [src]..."), span_notice("You start to mount[ridee_string] [src]..."), ignored_mobs = mobs_with_special_messages)
	to_chat(src, span_warning("[user] starts to mount[ridee_string] you!"))
	if (buckling != user)
		to_chat(buckling, span_boldwarning("[user] starts to mount you onto [src]!"))

	if (!do_after(user, SADDLE_MOUNTING_TIME, target = src))
		user.visible_message(span_warning("[user] fails to mount[ridee_string] [src]!"), span_warning("You fail to mount[ridee_string] [src]!"), ignored_mobs = mobs_with_special_messages)
		to_chat(src, span_warning("[user] fails to mount[ridee_string] you!"))
		if (buckling != user)
			to_chat(buckling, span_warning("[user] fails to mount you onto [src]!"))
		return FALSE

	if (!can_be_ridden_by(buckling, user)) // because we slept
		return FALSE // no feedback. this already gives some

	var/saddle_flags = SEND_SIGNAL(src, COMSIG_HUMAN_SADDLE_RIDE_ATTEMPT, buckling)
	if (!saddle_flags)
		saddle_flags = RIDER_NEEDS_ARMS

	return buckle_mob(buckling, force = TRUE, check_loc = TRUE, buckle_mob_flags = saddle_flags)

#undef SADDLE_MOUNTING_TIME
#undef SADDLE_MOUNTING_OTHER_MULT

/**
 * Determines if src can be ridden by to_buckle.
 *
 * Args:
 * * to_buckle: The mob trying to mount us. Non-nullable.
 * * user: The mob mounting to_buckle onto us, most likely to_buckle itself. Non-nullable.
 * * silent = FALSE: If FALSE, we do not send feedback messages. Boolean.
 * Returns:
 * * FALSE if we have no saddle, if we're trying to mount ourself, or if to_buckle can't be mounted. TRUE otherwise.
 */
/mob/living/carbon/human/proc/can_be_ridden_by(mob/living/to_buckle, mob/living/user, silent = FALSE)
	if (!HAS_TRAIT(src, TRAIT_SADDLED))
		return FALSE // no feedback as it's very very common

	if (user == src) // would open the inventory screen otherwise
		return FALSE // no feedback as you get your answer via the inventory screen

	/// Conditions that prevent riding, with a balloon alert
	var/cant_buckle_message
	if (to_buckle == src)
		cant_buckle_message = "can't ride self!"
	else if (body_position == LYING_DOWN)
		cant_buckle_message = "can't ride resting!"
	else if (incapacitated)
		cant_buckle_message = "can't mount incapacitated mobs!"
	else if (user.incapacitated)
		cant_buckle_message = "you are incapacitated!"
	else if (to_buckle.incapacitated)
		cant_buckle_message = "rider incapacitated!"
	else if (length(buckled_mobs))
		cant_buckle_message = "already being ridden!"

	if (cant_buckle_message)
		if (!silent)
			balloon_alert(user, cant_buckle_message)
		return FALSE

	if (!ishuman(to_buckle))
		return TRUE // no more checks need to be made

	var/mob/living/carbon/human/human_target = to_buckle

	var/obj/item/organ/taur_body/taur_body = get_organ_slot(ORGAN_SLOT_EXTERNAL_TAUR)
	var/obj/item/organ/taur_body/other_taur_body = human_target.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAUR)

	if (isnull(taur_body) || isnull(other_taur_body))
		return TRUE

	if (!other_taur_body.can_ride_saddled_taurs) // no stacking, sorry
		return FALSE

	return TRUE
