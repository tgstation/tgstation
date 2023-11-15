/// Verb to simply kill yourself (in a very visual way to all players) in game! How family-friendly. Can be governed by a series of multiple checks (i.e. confirmation, is it allowed in this area, etc.) which are
/// handled and called by the proc this verb invokes. It's okay to block this, because we typically always give mobs in-game the ability to Ghost out of their current mob irregardless of context. This, in contrast,
/// can have as many different checks as you desire to prevent people from doing the deed to themselves.
/mob/living/verb/suicide()
	set hidden = TRUE
	handle_suicide()

/// Actually handles the bare basics of the suicide process. Message type is the message we want to dispatch in the world regarding the suicide, using the defines in this file.
/// Override this ENTIRELY if you want to add any special behavior to your suicide handling, if you fuck up the order of operations then shit will break.
/mob/living/proc/handle_suicide()
	SHOULD_CALL_PARENT(FALSE)
	if(!suicide_alert())
		return

	set_suicide(TRUE)
	send_applicable_messages()
	final_checkout()

/// Proc that handles adding the TRAIT_SUICIDED on the mob in question, as well as additional operations to ensure that everything goes smoothly when we're certain that this person is going to kill themself.
/// suicide_state is a boolean, and we handle adding/removing the trait in question. Have the trait function reference this mob as the source if we want to do in-depth tracking of where a suicided trait comes from.
/// For example, the /mob/dead/observer that will inevitably come from the suicidee will inherit the suicided trait upon creation, and keep this reference. Handy for doing checking should we need it.
/mob/living/proc/set_suicide(suicide_state)
	if(suicide_state)
		ADD_TRAIT(src, TRAIT_SUICIDED, REF(src))
		add_to_mob_suicide_list()
	else
		REMOVE_TRAIT(src, TRAIT_SUICIDED, REF(src))
		remove_from_mob_suicide_list()

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

/// Checks if we are in a valid state to suicide (not already suiciding, capable of actually killing ourselves, area checks, etc.) Returns TRUE if we can suicide, FALSE if we can not.
/mob/living/proc/can_suicide()
	if(HAS_TRAIT_FROM_ONLY(src, TRAIT_SUICIDED, REF(src)))
		to_chat(src, span_warning("You are already commiting suicide!"))
		return FALSE

	var/area/checkable = get_area(src)
	if(checkable.area_flags & BLOCK_SUICIDE)
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

/// Inserts in logging and death + mind dissociation when we're fully done with ending the life of our mob, as well as adjust the health. We will disallow re-entering the body when this is called.
/// The suicide_tool variable is currently only used for humans in order to allow suicide log to properly put stuff in investigate log.
/// Set apply_damage to FALSE in order to not do damage (in case it's handled elsewhere in the verb or another proc that the suicide tree calls). Will dissociate client from mind and ghost the player regardless.
/mob/living/proc/final_checkout(obj/item/suicide_tool, apply_damage = TRUE)
	if(apply_damage) // enough to really drive home the point that they are DEAD.
		apply_suicide_damage()

	suicide_log(suicide_tool)
	death(FALSE)
	ghostize(FALSE)

/// Send all suicide-related messages out to the world. message_type can be used to change out the dispatched suicide message depending on the suicide context.
/mob/living/proc/send_applicable_messages(message_type)
	visible_message(span_danger(get_visible_suicide_message()), span_userdanger(get_visible_suicide_message()), span_hear(get_blind_suicide_message()))

/// Returns a subtype-specific flavorful string pertaining to this exact living mob's ending their own life to those who can see it (visible message).
/// If you don't want a message, prefer to override send_applicable_messages() on your subtype instead.
/mob/living/proc/get_visible_suicide_message()
	return "[src] begins to fall down. It looks like [p_theyve()] lost the will to live."

/// Returns an appropriate string for what people who lack visibility hear when this mob kills itself.
/// If you don't want a message, prefer to override send_applicable_messages() on your subtype instead.
/mob/living/proc/get_blind_suicide_message()
	return "You hear something hitting the floor."

/// Inserts logging in both the mob's logs and the investigate log pertaining to their death. Suicide tool is the object we used to commit suicide, if one was held and used (presently only humans use this arg).
/mob/living/proc/suicide_log(obj/item/suicide_tool)
	investigate_log("has died from committing suicide.", INVESTIGATE_DEATHS)
	log_message("committed suicide as [src.type]", LOG_ATTACK)

/// The actual proc that will apply the damage to the suiciding mob. damage_type is the actual type of damage we want to deal, if that matters.
/// Return TRUE if we actually apply any real damage, FALSE otherwise.
/mob/living/proc/apply_suicide_damage(obj/item/suicide_tool, damage_type = NONE)
	adjustOxyLoss(max(maxHealth * 2 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
	return TRUE

/// If we want to apply multiple types of damage to a carbon mob based on the way they suicide, this is the proc that handles that.
/// Currently only compatible with Brute, Burn, Toxin, and Suffocation Damage. damage_type is the bitflag that carries the information.
/mob/living/proc/handle_suicide_damage_spread(damage_type)
	// We split up double the total health the mob has, then spread it out.
	var/damage_to_apply = (maxHealth * 2) // For humans, this value comes out to 200.
	// The multiplier that we divide damage_to_apply by.
	var/damage_mod = 0
	// We don't want to damage_type again and again, this will hold the results.
	var/list/filtered_damage_types = list()

	for(var/type in list(BRUTELOSS, FIRELOSS, OXYLOSS, TOXLOSS))
		if(!(type & damage_type))
			continue
		damage_mod++
		filtered_damage_types += type

	damage_mod = max(1, damage_mod) // division by zero is silly
	damage_to_apply = (damage_to_apply / damage_mod)

	for(var/filtered_type in filtered_damage_types)
		switch(filtered_type)
			if(BRUTELOSS)
				adjustBruteLoss(damage_to_apply)
			if(FIRELOSS)
				adjustFireLoss(damage_to_apply)
			if(OXYLOSS)
				adjustOxyLoss(damage_to_apply)
			if(TOXLOSS)
				adjustToxLoss(damage_to_apply)
