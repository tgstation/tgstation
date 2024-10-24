/// This file handles anything related to suicide related to humans, as it's a bit more involved/complex than suicide on any other type of mob.
/// Defines for all the types of messages we can dispatch.
#define HUMAN_BRAIN_DAMAGE_SUICIDE_MESSAGE "brain damaged message"
#define HUMAN_COMBAT_MODE_SUICIDE_MESSAGE "combat mode message"
#define HUMAN_DEFAULT_MODE_SUICIDE_MESSAGE "default mode message"

/mob/living/carbon/human/handle_suicide()
	if(!suicide_alert())
		return

	set_suicide(TRUE) //need to be called before calling suicide_act as fuck knows what suicide_act will do with your suicide

	var/obj/item/held_item = get_active_held_item()
	var/damage_type = SEND_SIGNAL(src, COMSIG_HUMAN_SUICIDE_ACT) || held_item?.suicide_act(src)

	if(damage_type)
		if(apply_suicide_damage(held_item, damage_type))
			final_checkout(held_item, apply_damage = FALSE)
		return

	// if no specific item or damage type we want to deal, default to doing the deed with our own bare hands.
	if(combat_mode)
		send_applicable_messages(HUMAN_COMBAT_MODE_SUICIDE_MESSAGE)
	else
		var/obj/item/organ/brain/userbrain = get_organ_by_type(/obj/item/organ/brain)
		if(userbrain?.damage >= 75)
			send_applicable_messages(HUMAN_BRAIN_DAMAGE_SUICIDE_MESSAGE)
		else
			send_applicable_messages(HUMAN_DEFAULT_MODE_SUICIDE_MESSAGE)

	final_checkout(held_item, apply_damage = TRUE)

/mob/living/carbon/human/apply_suicide_damage(obj/item/suicide_tool, damage_type = NONE)
	// if we don't have any damage_type passed in, default to parent.
	if(damage_type == NONE)
		return ..()

	if(damage_type & SHAME)
		adjustStaminaLoss(200)
		set_suicide(FALSE)
		add_mood_event("shameful_suicide", /datum/mood_event/shameful_suicide)
		return FALSE

	if(damage_type & MANUAL_SUICIDE_NONLETHAL)
		set_suicide(FALSE)
		return FALSE

	if(damage_type & MANUAL_SUICIDE) // Assume that the suicide tool will handle the death.
		suicide_log(suicide_tool)
		return FALSE

	if(damage_type & (BRUTELOSS | FIRELOSS | OXYLOSS | TOXLOSS))
		handle_suicide_damage_spread(damage_type)
		return TRUE

	return ..() //if all else fails, hope parent accounts for it or just do whatever damage that parent prescribes.

/// Any "special" suicide messages are handled by the related item that the mob uses to kill itself. This is just messages for when it's done with the bare hands.
/mob/living/carbon/human/send_applicable_messages(message_type)
	var/suicide_message = ""
	switch(message_type)
		if(HUMAN_BRAIN_DAMAGE_SUICIDE_MESSAGE) // god damn this message is fucking stupid
			suicide_message = "[src] pulls both arms outwards in front of [p_their()] chest and pumps them behind [p_their()] back, repeats this motion in a smaller range of motion \
			down to [p_their()] hips two times once more all while sliding [p_their()] legs in a faux walking motion, claps [p_their()] hands together \
			in front of [p_them()] while both [p_their()] knees knock together, pumps [p_their()] arms downward, pronating [p_their()] wrists and abducting \
			[p_their()] fingers outward while crossing [p_their()] legs back and forth, repeats this motion again two times while keeping [p_their()] shoulders low \
			and hunching over, does finger guns with right hand and left hand bent on [p_their()] hip while looking directly forward and putting [p_their()] left leg forward then \
			crossing [p_their()] arms and leaning back a little while bending [p_their()] knees at an angle! It looks like [p_theyre()] trying to commit suicide."

		if(HUMAN_COMBAT_MODE_SUICIDE_MESSAGE)
			suicide_message = pick(list(
				"[src] is attempting to bite [p_their()] tongue off! It looks like [p_theyre()] trying to commit suicide.",
				"[src] is holding [p_their()] breath! It looks like [p_theyre()] trying to commit suicide.",
				"[src] is jamming [p_their()] thumbs into [p_their()] eye sockets! It looks like [p_theyre()] trying to commit suicide.",
				"[src] is twisting [p_their()] own neck! It looks like [p_theyre()] trying to commit suicide.",
			))

		if(HUMAN_DEFAULT_MODE_SUICIDE_MESSAGE)
			suicide_message = pick(list(
				"[src] is getting too high on life! It looks like [p_theyre()] trying to commit suicide.",
				"[src] is high-fiving [p_them()]self to death! It looks like [p_theyre()] trying to commit suicide.",
				"[src] is hugging [p_them()]self to death! It looks like [p_theyre()] trying to commit suicide.",
			))

	visible_message(span_danger(suicide_message), span_userdanger(suicide_message), span_hear(get_blind_suicide_message()))

/mob/living/carbon/human/suicide_log(obj/item/suicide_tool)
	var/suicide_tool_type = suicide_tool?.type
	var/list/suicide_data = null // log_message() is nullsafe for the data field
	if(!isnull(suicide_tool))
		suicide_data = list("suicide tool" = suicide_tool_type)
		SSblackbox.record_feedback("tally", "suicide_item", 1, suicide_tool_type)

	investigate_log("has died from committing suicide[suicide_tool ? " with [suicide_tool] ([suicide_tool_type])" : ""].", INVESTIGATE_DEATHS)
	log_message("(job: [src.job ? "[src.job]" : "None"]) committed suicide", LOG_ATTACK, data = suicide_data)


#undef HUMAN_BRAIN_DAMAGE_SUICIDE_MESSAGE
#undef HUMAN_COMBAT_MODE_SUICIDE_MESSAGE
#undef HUMAN_DEFAULT_MODE_SUICIDE_MESSAGE
