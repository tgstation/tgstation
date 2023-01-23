/// Defines for all the types of messages we can dispatch, since there are a few that are re-used in different contexts (like animals, mechanical)
#define ALIEN_SUICIDE_MESSAGE "alien message"
#define ANIMAL_SUICIDE_MESSAGE "animal message"
#define BRAIN_SUICIDE_MESSAGE "brain message"
#define HUMAN_BRAIN_DAMAGE_SUICIDE_MESSAGE "brain damaged message"
#define HUMAN_COMBAT_MODE_SUICIDE_MESSAGE "combat mode message"
#define HUMAN_DEFAULT_MODE_SUICIDE_MESSAGE "default mode message"
#define MECHANICAL_SUICIDE_MESSAGE "mechanical message"
#define PAI_SUICIDE_MESSAGE "pai message"

/mob/proc/set_suicide(suicide_state)
	suiciding = suicide_state
	if(suicide_state)
		add_to_mob_suicide_list()
	else
		remove_from_mob_suicide_list()

/mob/living/carbon/set_suicide(suicide_state) //you thought that box trick was pretty clever, didn't you? well now hardmode is on, boyo.
	. = ..()
	var/obj/item/organ/internal/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)
	if(brain)
		brain.suicided = suicide_state

/mob/living/silicon/robot/set_suicide(suicide_state)
	. = ..()
	if(mmi)
		if(mmi.brain)
			mmi.brain.suicided = suicide_state
		if(mmi.brainmob)
			mmi.brainmob.suiciding = suicide_state

/mob/living/carbon/human/verb/suicide()
	set hidden = TRUE
	if(!suicide_alert())
		return

	set_suicide(TRUE) //need to be called before calling suicide_act as fuck knows what suicide_act will do with your suicider
	var/obj/item/held_item = get_active_held_item()

	var/damage_type = SEND_SIGNAL(src, COMSIG_HUMAN_SUICIDE_ACT) || held_item?.suicide_act(src)
	if(damage_type)
		if(apply_suicide_damage(damage_type))
			final_checkout(held_item, do_damage = FALSE)
		return

	// if no specific item or damage type we want to deal, default to doing the deed with our own bare hands.
	if(!combat_mode)
		var/obj/item/organ/internal/brain/userbrain = getorgan(/obj/item/organ/internal/brain)
		if(userbrain?.damage >= 75)
			dispatch_message_from_tree(HUMAN_BRAIN_DAMAGE_SUICIDE_MESSAGE)
		else
			dispatch_message_from_tree(HUMAN_DEFAULT_MODE_SUICIDE_MESSAGE)
	else
		dispatch_message_from_tree(HUMAN_COMBAT_MODE_SUICIDE_MESSAGE)

	final_checkout(held_item)

/mob/living/brain/verb/suicide()
	set hidden = TRUE
	if(!suicide_alert())
		return

	set_suicide(TRUE)
	dispatch_message_from_tree(BRAIN_SUICIDE_MESSAGE)
	final_checkout(do_damage = FALSE)

/mob/living/silicon/ai/verb/suicide()
	set hidden = TRUE
	if(!suicide_alert())
		return

	set_suicide(TRUE)
	dispatch_message_from_tree(MECHANICAL_SUICIDE_MESSAGE)
	final_checkout()

/mob/living/silicon/robot/verb/suicide()
	set hidden = TRUE
	if(!suicide_alert())
		return

	set_suicide(TRUE)
	dispatch_message_from_tree(MECHANICAL_SUICIDE_MESSAGE)
	final_checkout()

/mob/living/silicon/pai/verb/suicide()
	set hidden = TRUE
	if(!suicide_alert())
		return

	dispatch_message_from_tree(PAI_SUICIDE_MESSAGE)
	final_checkout()

/mob/living/carbon/alien/adult/verb/suicide()
	set hidden = TRUE
	if(!suicide_alert())
		return

	set_suicide(TRUE)
	dispatch_message_from_tree(ALIEN_SUICIDE_MESSAGE)
	final_checkout()

/mob/living/simple_animal/verb/suicide()
	set hidden = TRUE
	if(!suicide_alert())
		return

	set_suicide(TRUE)
	dispatch_message_from_tree(ANIMAL_SUICIDE_MESSAGE)
	final_checkout()

/mob/living/basic/verb/suicide()
	set hidden = TRUE
	if(!suicide_alert())
		return

	set_suicide(TRUE)
	dispatch_message_from_tree(ANIMAL_SUICIDE_MESSAGE)
	final_checkout()

/// Inserts logging in both the mob's logs and the investigate log pertaining to their death. Suicide tool is the object we used to commit suicide, if one was held and used.
/mob/living/proc/suicide_log(obj/item/suicide_tool)
	investigate_log("has died from committing suicide.", INVESTIGATE_DEATHS)
	log_message("committed suicide as [src.type]", LOG_ATTACK)

/mob/living/carbon/human/suicide_log(obj/item/suicide_tool)
	investigate_log("has died from committing suicide[suicide_tool ? " with [suicide_tool]" : ""].", INVESTIGATE_DEATHS)
	log_message("(job: [src.job ? "[src.job]" : "None"]) committed suicide", LOG_ATTACK)

/// Sends a TGUI Alert to the person attempting to commit suicide. Returns TRUE if they confirm they want to die, FALSE otherwise. Check can_suicide here as well.
/mob/living/proc/suicide_alert()
	// Save this for later to ensure that if we change ckeys somehow, we exit out of the suicide.
	var/oldkey = ckey
	if(!can_suicide())
		return FALSE

	var/confirm = tgui_alert(src, "Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))

	// ensure our situation didn't change while we were sleeping waiting for the tgui_alert.
	if(!can_suicide() || (ckey != oldkey))
		return FALSE

	if(confirm == "Yes")
		return TRUE

	balloon_alert(src, "suicide attempt aborted!")
	return FALSE

/// Inserts in logging and death + mind dissociation when we're fully done with ending the life of our mob, as well as adjust the health. We will disallow re-entering the body when this is called.
/// The suicide_tool variable is currently only used for humans in order to allow suicide log to properly put stuff in investigate log.
/// Set do_damage to FALSE in order to not do damage (in case it's handled elsewhere in the verb or another proc that the suicide tree calls).
/mob/living/proc/final_checkout(obj/item/suicide_tool, do_damage = TRUE)
	if(do_damage) // enough to really drive home the point that they are DEAD.
		apply_damage()

	suicide_log(suicide_tool)
	death(FALSE)
	ghostize(FALSE)

/// The actual proc that will apply the damage to the suiciding mob. damage_type is the actual type of damage we want to deal, if that matters.
/// Return TRUE if we actually apply any real damage, FALSE otherwise.
/mob/living/proc/apply_suicide_damage(damage_type)
	adjustOxyLoss(max(maxHealth * 2 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
	return TRUE

/mob/living/carbon/human/apply_suicide_damage(damage_type == NONE)
	// if we don't have any damage_type passed in, default to parent.
	if(damage_type == NONE)
		return ..()

	if(damage_type & SHAME)
		adjustStaminaLoss(200)
		set_suicide(FALSE)
		add_mood_event("shameful_suicide", /datum/mood_event/shameful_suicide)
		return FALSE

	if(damage_type & MANUAL_SUICIDE_NONLETHAL) //Make sure to call the necessary procs if it does kill later
		set_suicide(FALSE)
		return FALSE

	var/damage_mod = 0
	for(var/type in list(BRUTELOSS, FIRELOSS, TOXLOSS, OXYLOSS))
		damage_mod += (type & damage_type) ? 1 : 0
	damage_mod = max(1, damage_mod)

	//Do 200 damage divided by the number of damage types applied.
	if(damage_type & BRUTELOSS)
		adjustBruteLoss(200/damage_mod)

	if(damage_type & FIRELOSS)
		adjustFireLoss(200/damage_mod)

	if(damage_type & TOXLOSS)
		adjustToxLoss(200/damage_mod)

	if(damage_type & OXYLOSS)
		adjustOxyLoss(200/damage_mod)

	if(damage_type & MANUAL_SUICIDE) //Assume the object will handle the death.
		suicide_log(held_item)
		return FALSE

	//If no specific damage_type, just do normal oxyloss (handled by parent proc)
	if(!(damage_type & (BRUTELOSS | FIRELOSS | TOXLOSS | OXYLOSS) ))
		return ..()

	return TRUE

/// We re-use a few messages in several contexts, so let's minimize some nasty footprint in the verbs.
/mob/living/proc/dispatch_message_from_tree(type)
	switch(type)
		if(ALIEN_SUICIDE_MESSAGE)
			visible_message(span_danger("[src] is thrashing wildly! It looks like [p_theyre()] trying to commit suicide."), \
			span_userdanger("[src] is thrashing wildly! It looks like [p_theyre()] trying to commit suicide."), \
			span_hear("You hear thrashing."))
		if(ANIMAL_SUICIDE_MESSAGE)
			visible_message(span_danger("[src] begins to fall down. It looks like [p_theyve()] lost the will to live."), \
			span_userdanger("[src] begins to fall down. It looks like [p_theyve()] lost the will to live."))
		if(BRAIN_SUICIDE_MESSAGE)
			visible_message(span_danger("[src]'s brain is growing dull and lifeless. [p_they(TRUE)] look[p_s()] like [p_theyve()] lost the will to live."), \
			span_userdanger("[src]'s brain is growing dull and lifeless. [p_they(TRUE)] look[p_s()] like [p_theyve()] lost the will to live."))
		if(MECHANICAL_SUICIDE_MESSAGE)
			visible_message(span_danger("[src] is powering down. It looks like [p_theyre()] trying to commit suicide."), \
			span_userdanger("[src] is powering down. It looks like [p_theyre()] trying to commit suicide."))
		if(PAI_SUICIDE_MESSAGE)
			var/turf/location = get_turf(src)
			location.visible_message(span_notice("[src] flashes a message across its screen, \"Wiping core files. Please acquire a new personality to continue using pAI device functions.\""), null, \
			span_notice("[src] bleeps electronically."))

/mob/living/carbon/human/dispatch_message_from_tree(type)
	var/suicide_message = ""
	switch(type)
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

	visible_message(span_danger("[suicide_message]"), span_userdanger("[suicide_message]"))

/// Checks if we are in a valid state to suicide (not already suiciding, capable of actually killing ourselves, area checks, etc.) Returns TRUE if we can suicide, FALSE if we can not.
/mob/living/proc/can_suicide()
	if(suiciding)
		to_chat(src, span_warning("You are already commiting suicide!"))
		return FALSE

	var/area/A = get_area(src)
	if(A.area_flags & BLOCK_SUICIDE)
		to_chat(src, span_warning("You can't commit suicide here! You can ghost if you'd like."))
		return FALSE

	switch(stat)
		if(CONSCIOUS)
			return TRUE
		if(SOFT_CRIT)
			to_chat(src, span_warning("You can't commit suicide while in a critical condition!"))
		if(UNCONSCIOUS, HARD_CRIT)
			to_chat(src, span_warning("You need to be conscious to commit suicide!"))
		if(DEAD)
			to_chat(src, span_warning("You're already dead!"))
	return FALSE

/mob/living/carbon/can_suicide()
	if(!..())
		return FALSE
	if(!(mobility_flags & MOBILITY_USE)) //just while I finish up the new 'fun' suiciding verb. This is to prevent metagaming via suicide
		to_chat(src, span_warning("You can't commit suicide whilst immobile! (You can type Ghost instead however)."))
		return FALSE
	return TRUE

#undef ALIEN_SUICIDE_MESSAGE
#undef ANIMAL_SUICIDE_MESSAGE
#undef BRAIN_SUICIDE_MESSAGE
#undef HUMAN_BRAIN_DAMAGE_SUICIDE_MESSAGE
#undef HUMAN_COMBAT_MODE_SUICIDE_MESSAGE
#undef HUMAN_DEFAULT_MODE_SUICIDE_MESSAGE
#undef MECHANICAL_SUICIDE_MESSAGE
#undef PAI_SUICIDE_MESSAGE
