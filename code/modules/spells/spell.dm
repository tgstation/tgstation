/**
 * # The spell action
 *
 * This is the base action for how many of the game's
 * spells (and spell adjacent) abilities function.
 * These spells function off of a cooldown-based system.
 *
 * ## Pre-spell checks:
 * - [can_cast_spell][/datum/action/cooldown/spell/can_cast_spell] checks if the OWNER
 * of the spell is able to cast the spell.
 * - [is_valid_target][/datum/action/cooldown/spell/is_valid_target] checks if the TARGET
 * THE SPELL IS BEING CAST ON is a valid target for the spell. NOTE: The CAST TARGET is often THE SAME as THE OWNER OF THE SPELL,
 * but is not always - depending on how [Pre Activate][/datum/action/cooldown/spell/PreActivate] is resolved.
 * - [try_invoke][/datum/action/cooldown/spell/try_invoke] is run in can_cast_spell to check if
 * the OWNER of the spell is able to say the current invocation.
 *
 * ## The spell chain:
 * - [before_cast][/datum/action/cooldown/spell/before_cast] is the last chance for being able
 * to interrupt a spell cast. This returns a bitflag. if SPELL_CANCEL_CAST is set, the spell will not continue.
 * - [spell_feedback][/datum/action/cooldown/spell/spell_feedback] is called right before cast, and handles
 * invocation and sound effects. Overridable, if you want a special method of invocation or sound effects,
 * or you want your spell to handle invocation / sound via special means.
 * - [cast][/datum/action/cooldown/spell/cast] is where the brunt of the spell effects should be done
 * and implemented.
 * - [after_cast][/datum/action/cooldown/spell/after_cast] is the aftermath - final effects that follow
 * the main cast of the spell. By now, the spell cooldown has already started
 *
 * ## Other procs called / may be called within the chain:
 * - [invocation][/datum/action/cooldown/spell/invocation] handles saying any vocal (or emotive) invocations the spell
 * may have, and can be overriden or extended. Called by spell_feedback.
 * - [reset_spell_cooldown][/datum/action/cooldown/spell/reset_spell_cooldown] is a way to handle reverting a spell's
 * cooldown and making it ready again if it fails to go off at any point. Not called anywhere by default. If you
 * want to cancel a spell in before_cast and would like the cooldown restart, call this.
 *
 * ## Other procs of note:
 * - [level_spell][/datum/action/cooldown/spell/level_spell] is where the process of adding a spell level is handled.
 * this can be extended if you wish to add unique effects on level up for wizards.
 * - [delevel_spell][/datum/action/cooldown/spell/delevel_spell] is where the process of removing a spell level is handled.
 * this can be extended if you wish to undo unique effects on level up for wizards.
 * - [get_spell_title][/datum/action/cooldown/spell/get_spell_title] returns the prefix of the spell name based on its level,
 * for use in updating the button name / spell name.
 */
/datum/action/cooldown/spell
	name = "Spell"
	desc = "A wizard spell."
	background_icon_state = "bg_spell"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "spell_default"
	overlay_icon_state = "bg_spell_border"
	active_overlay_icon_state = "bg_spell_border_active_red"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_PHASED
	panel = "Spells"

	/// The sound played on cast.
	var/sound = null
	/// The school of magic the spell belongs to.
	/// Checked by some holy sects to punish the
	/// caster for casting things that do not align
	/// with their sect's alignment - see magic.dm in defines to learn more
	var/school = SCHOOL_UNSET
	/// If the spell uses the wizard spell rank system, the cooldown reduction per rank of the spell
	var/cooldown_reduction_per_rank = 0 SECONDS
	/// What is uttered when the user casts the spell
	var/invocation
	/// What is shown in chat when the user casts the spell, only matters for INVOCATION_EMOTE
	var/invocation_self_message
	/// if true, doesn't garble the invocation sometimes with backticks
	var/garbled_invocation_prob = 50
	/// What type of invocation the spell is.
	/// Can be "none", "whisper", "shout", "emote"
	var/invocation_type = INVOCATION_NONE
	/// Flag for certain states that the spell requires the user be in to cast.
	var/spell_requirements = SPELL_REQUIRES_WIZARD_GARB|SPELL_REQUIRES_NO_ANTIMAGIC
	/// This determines what type of antimagic is needed to block the spell.
	/// (MAGIC_RESISTANCE, MAGIC_RESISTANCE_MIND, MAGIC_RESISTANCE_HOLY)
	/// If SPELL_REQUIRES_NO_ANTIMAGIC is set in Spell requirements,
	/// The spell cannot be cast if the caster has any of the antimagic flags set.
	var/antimagic_flags = MAGIC_RESISTANCE
	/// The current spell level, if taken multiple times by a wizard
	var/spell_level = 1
	/// The max possible spell level
	var/spell_max_level = 5
	/// If set to a positive number, the spell will produce sparks when casted.
	var/sparks_amt = 0
	/// The typepath of the smoke to create on cast.
	var/smoke_type
	/// The amount of smoke to create on cast. This is a range, so a value of 5 will create enough smoke to cover everything within 5 steps.
	var/smoke_amt = 0

/datum/action/cooldown/spell/Grant(mob/grant_to)
	// If our spell is mind-bound, we only wanna grant it to our mind
	if(istype(target, /datum/mind))
		var/datum/mind/mind_target = target
		if(mind_target.current != grant_to)
			return

	. = ..()
	if(!owner)
		return

	// Register some signals so our button's icon stays up to date
	if(spell_requirements & SPELL_REQUIRES_STATION)
		RegisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(update_status_on_signal))
	if(spell_requirements & (SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_WIZARD_GARB))
		RegisterSignals(owner, list(COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_UNEQUIPPED_ITEM), PROC_REF(update_status_on_signal))
	if(invocation_type == INVOCATION_EMOTE)
		RegisterSignals(owner, list(SIGNAL_ADDTRAIT(TRAIT_EMOTEMUTE), SIGNAL_REMOVETRAIT(TRAIT_EMOTEMUTE)), PROC_REF(update_status_on_signal))
	if(invocation_type == INVOCATION_SHOUT || invocation_type == INVOCATION_WHISPER)
		RegisterSignals(owner, list(SIGNAL_ADDTRAIT(TRAIT_MUTE), SIGNAL_REMOVETRAIT(TRAIT_MUTE)), PROC_REF(update_status_on_signal))

	RegisterSignals(owner, list(COMSIG_MOB_ENTER_JAUNT, COMSIG_MOB_AFTER_EXIT_JAUNT), PROC_REF(update_status_on_signal))
	owner.client?.stat_panel.send_message("check_spells")

/datum/action/cooldown/spell/Remove(mob/living/remove_from)

	remove_from.client?.stat_panel.send_message("check_spells")
	UnregisterSignal(remove_from, list(
		COMSIG_MOB_AFTER_EXIT_JAUNT,
		COMSIG_MOB_ENTER_JAUNT,
		COMSIG_MOB_EQUIPPED_ITEM,
		COMSIG_MOB_UNEQUIPPED_ITEM,
		COMSIG_MOVABLE_Z_CHANGED,
		SIGNAL_ADDTRAIT(TRAIT_EMOTEMUTE),
		SIGNAL_REMOVETRAIT(TRAIT_EMOTEMUTE),
		SIGNAL_ADDTRAIT(TRAIT_MUTE),
		SIGNAL_REMOVETRAIT(TRAIT_MUTE),
	))

	return ..()

/datum/action/cooldown/spell/IsAvailable(feedback = FALSE)
	return ..() && can_cast_spell(feedback)

/datum/action/cooldown/spell/set_click_ability(mob/on_who)
	if(SEND_SIGNAL(on_who, COMSIG_MOB_SPELL_ACTIVATED, src) & SPELL_CANCEL_CAST)
		return FALSE

	return ..()

// Where the cast chain starts
/datum/action/cooldown/spell/PreActivate(atom/target)
	if(SEND_SIGNAL(owner, COMSIG_MOB_ABILITY_STARTED, src, target) & COMPONENT_BLOCK_ABILITY_START)
		return FALSE
	if(target == owner)
		target = get_caster_from_target(target)
	if(isnull(target) || !is_valid_target(target))
		return FALSE

	return Activate(target)

/// Checks if the owner of the spell can currently cast it.
/// Does not check anything involving potential targets.
/datum/action/cooldown/spell/proc/can_cast_spell(feedback = TRUE)
	if(!owner)
		CRASH("[type] - can_cast_spell called on a spell without an owner!")

	// Certain spells are not allowed on the centcom zlevel
	var/turf/caster_turf = get_turf(owner)
	// Spells which require being on the station
	if((spell_requirements & SPELL_REQUIRES_STATION) && !is_station_level(caster_turf.z))
		if(feedback)
			to_chat(owner, span_warning("You can't cast [src] here!"))
		return FALSE

	if((spell_requirements & SPELL_REQUIRES_MIND) && !owner.mind)
		// No point in feedback here, as mindless mobs aren't players
		return FALSE

	if((spell_requirements & SPELL_REQUIRES_MIME_VOW) && !HAS_MIND_TRAIT(owner, TRAIT_MIMING))
		// In the future this can be moved out of spell checks exactly
		if(feedback)
			to_chat(owner, span_warning("You must dedicate yourself to silence first!"))
		return FALSE

	// If the spell requires the user has no antimagic equipped, and they're holding antimagic
	// that corresponds with the spell's antimagic, then they can't actually cast the spell
	if((spell_requirements & SPELL_REQUIRES_NO_ANTIMAGIC) && !owner.can_cast_magic(antimagic_flags))
		if(feedback)
			to_chat(owner, span_warning("Some form of antimagic is preventing you from casting [src]!"))
		return FALSE

	if(!try_invoke(owner, feedback = feedback))
		return FALSE

	if(ishuman(owner))
		if(spell_requirements & SPELL_REQUIRES_WIZARD_GARB)
			var/mob/living/carbon/human/human_owner = owner
			if(!(human_owner.wear_suit?.clothing_flags & CASTING_CLOTHES) && !ismonkey(human_owner)) // Monkeys don't need robes to cast as they are inherently imbued with power from the banana dimension
				if(feedback)
					to_chat(owner, span_warning("You don't feel strong enough without your robe!"))
				return FALSE
			if(!(human_owner.head?.clothing_flags & CASTING_CLOTHES) && !(human_owner.glasses?.clothing_flags & CASTING_CLOTHES))
				if(feedback)
					to_chat(owner, span_warning("You don't feel strong enough without your hat!"))
				return FALSE

	else
		// If you strictly need to be a human, well, goodbye.
		if(spell_requirements & SPELL_REQUIRES_HUMAN)
			if(feedback)
				to_chat(owner, span_warning("[src] can only be cast by humans!"))
			return FALSE

		// Otherwise, we can check for contents if they have wizardly apparel. This isn't *quite* perfect, but it'll do, especially since many of the edge cases (gorilla holding a wizard hat) still more or less make sense.
		if(spell_requirements & SPELL_REQUIRES_WIZARD_GARB)
			var/any_casting = FALSE
			for(var/obj/item/clothing/item in owner)
				if(item.clothing_flags & CASTING_CLOTHES)
					any_casting = TRUE
					break

			if(!any_casting)
				if(feedback)
					to_chat(owner, span_warning("You don't feel strong enough without your hat!"))
				return FALSE

		if(!(spell_requirements & SPELL_CASTABLE_AS_BRAIN) && isbrain(owner))
			if(feedback)
				to_chat(owner, span_warning("[src] can't be cast in this state!"))
			return FALSE

	return TRUE

/**
 * Check if the target we're casting on is a valid target.
 * For self-casted spells, the target being checked (cast_on) is the caster.
 * For click_to_activate spells, the target being checked is the clicked atom.
 *
 * Return TRUE if cast_on is valid, FALSE otherwise
 */
/datum/action/cooldown/spell/proc/is_valid_target(atom/cast_on)
	return TRUE

/**
 * Used to get the cast_on atom if a self cast spell is being cast.
 *
 * Allows for some atoms to be used as casting sources if a spell caster is located within.
 */
/datum/action/cooldown/spell/proc/get_caster_from_target(atom/target)
	var/atom/cast_loc = target.loc
	if(isnull(cast_loc))
		return null // No magic in nullspace

	if(isturf(cast_loc))
		return target // They're just standing around, proceed as normal

	if(HAS_TRAIT(cast_loc, TRAIT_CASTABLE_LOC))
		if(HAS_TRAIT(cast_loc, TRAIT_SPELLS_TRANSFER_TO_LOC) && ismob(cast_loc.loc))
			return cast_loc.loc
		else
			return cast_loc
	// They're in an atom which allows casting, so redirect the caster to loc

	return null

// The actual cast chain occurs here, in Activate().
// You should generally not be overriding or extending Activate() for spells.
// Defer to any of the cast chain procs instead.
/datum/action/cooldown/spell/Activate(atom/cast_on)
	SHOULD_NOT_OVERRIDE(TRUE)

	// Pre-casting of the spell
	// Pre-cast is the very last chance for a spell to cancel
	// Stuff like target input can go here.
	var/precast_result = before_cast(cast_on)
	if(precast_result & SPELL_CANCEL_CAST)
		return FALSE

	// Spell is officially being cast
	if(!(precast_result & SPELL_NO_FEEDBACK))
		// We do invocation and sound effects here, before actual cast
		// That way stuff like teleports or shape-shifts can be invoked before ocurring
		spell_feedback(owner)

	// Actually cast the spell. Main effects go here
	cast(cast_on)

	if(!(precast_result & SPELL_NO_IMMEDIATE_COOLDOWN))
		// The entire spell is done, start the actual cooldown at its set duration
		StartCooldown()

	// And then proceed with the aftermath of the cast
	// Final effects that happen after all the casting is done can go here
	after_cast(cast_on)
	build_all_button_icons()

	return TRUE

/**
 * Actions done before the actual cast is called.
 * This is the last chance to cancel the spell from being cast.
 *
 * Can be used for target selection or to validate checks on the caster (cast_on).
 *
 * Returns a bitflag.
 * - SPELL_CANCEL_CAST will stop the spell from being cast.
 * - SPELL_NO_FEEDBACK will prevent the spell from calling [proc/spell_feedback] on cast. (invocation), sounds)
 * - SPELL_NO_IMMEDIATE_COOLDOWN will prevent the spell from starting its cooldown between cast and before after_cast.
 */
/datum/action/cooldown/spell/proc/before_cast(atom/cast_on)
	SHOULD_CALL_PARENT(TRUE)

	// Bonus invocation check done here:
	// If the caster has no tongue and it's a verbal spell,
	// Or has no hands and is a gesture spell - cancel it,
	// and show a funny message that they tried
	if(ishuman(owner) && !(spell_requirements & SPELL_CASTABLE_WITHOUT_INVOCATION))
		var/mob/living/carbon/human/caster = owner
		switch(invocation_type)
			if(INVOCATION_WHISPER, INVOCATION_SHOUT)
				if(!caster.get_organ_slot(ORGAN_SLOT_TONGUE))
					invocation(caster)
					to_chat(caster, span_warning("Your lack of tongue is making it difficult to say the correct words to cast [src]..."))
					StartCooldown(2 SECONDS)
					return SPELL_CANCEL_CAST

			if(INVOCATION_EMOTE)
				if(caster.usable_hands <= 0)
					var/arm_describer = (caster.num_hands >= 2 ? "arms limply" : (caster.num_hands == 1 ? "arm wildly" : "arm stumps"))
					caster.visible_message(
						span_warning("[caster] wiggles around [caster.p_their()] [arm_describer]."),
						ignored_mobs = caster,
					)
					to_chat(caster, span_warning("You can't position your hands correctly to invoke [src][caster.num_hands > 0 ? "" : ", as you have none"]..."))
					StartCooldown(2 SECONDS)
					return SPELL_CANCEL_CAST

	var/sig_return = SEND_SIGNAL(src, COMSIG_SPELL_BEFORE_CAST, cast_on)
	if(owner)
		sig_return |= SEND_SIGNAL(owner, COMSIG_MOB_BEFORE_SPELL_CAST, src, cast_on)

	return sig_return

/**
 * Actions done as the main effect of the spell.
 *
 * For spells without a click intercept, [cast_on] will be the owner.
 * For click spells, [cast_on] is whatever the owner clicked on in casting the spell.
 */
/datum/action/cooldown/spell/proc/cast(atom/cast_on)
	SHOULD_CALL_PARENT(TRUE)

	SEND_SIGNAL(src, COMSIG_SPELL_CAST, cast_on)
	if(owner)
		SEND_SIGNAL(owner, COMSIG_MOB_CAST_SPELL, src, cast_on)
		if(owner.ckey)
			owner.log_message("cast the spell [name][cast_on != owner ? " on / at [cast_on]":""].", LOG_ATTACK)

/**
 * Actions done after the main cast is finished.
 * This is called after the cooldown's already begun.
 *
 * It can be used to apply late spell effects where order matters
 * (for example, causing smoke *after* a teleport occurs in cast())
 * or to clean up variables or references post-cast.
 */
/datum/action/cooldown/spell/proc/after_cast(atom/cast_on)
	SHOULD_CALL_PARENT(TRUE)
	if(!owner) // Could have been destroyed by the effect of the spell
		SEND_SIGNAL(src, COMSIG_SPELL_AFTER_CAST, cast_on)
		return

	if(sparks_amt)
		do_sparks(sparks_amt, FALSE, get_turf(owner))
	if(ispath(smoke_type, /datum/effect_system/fluid_spread/smoke))
		var/datum/effect_system/fluid_spread/smoke/smoke = new smoke_type()
		smoke.set_up(smoke_amt, holder = owner, location = get_turf(owner))
		smoke.start()

	// Send signals last in case they delete the spell
	SEND_SIGNAL(owner, COMSIG_MOB_AFTER_SPELL_CAST, src, cast_on)
	SEND_SIGNAL(src, COMSIG_SPELL_AFTER_CAST, cast_on)

/// Provides feedback after a spell cast occurs, in the form of a cast sound and/or invocation
/datum/action/cooldown/spell/proc/spell_feedback(mob/living/invoker)
	if(!invoker)
		return

	///even INVOCATION_NONE should go through this because the signal might change that
	invocation(invoker)
	if(sound)
		playsound(invoker, sound, 50, vary = TRUE)

/// The invocation that accompanies the spell, called from spell_feedback() before cast().
/datum/action/cooldown/spell/proc/invocation(mob/living/invoker)
	//lists can be sent by reference, a string would be sent by value
	var/list/invocation_list = list(invocation, invocation_type, garbled_invocation_prob)
	SEND_SIGNAL(invoker, COMSIG_MOB_PRE_INVOCATION, src, invocation_list)
	var/used_invocation_message = invocation_list[INVOCATION_MESSAGE]
	var/used_invocation_type = invocation_list[INVOCATION_TYPE]
	var/used_invocation_garble_prob = invocation_list[INVOCATION_GARBLE_PROB]

	switch(used_invocation_type)
		if(INVOCATION_SHOUT)
			if(prob(used_invocation_garble_prob))
				invoker.say(replacetext(used_invocation_message," ","`"), forced = "spell ([src])")
			else
				invoker.say(used_invocation_message, forced = "spell ([src])")

		if(INVOCATION_WHISPER)
			if(prob(used_invocation_garble_prob))
				invoker.whisper(replacetext(used_invocation_message," ","`"), forced = "spell ([src])")
			else
				invoker.whisper(used_invocation_message, forced = "spell ([src])")

		if(INVOCATION_EMOTE)
			invoker.visible_message(
				capitalize(REPLACE_PRONOUNS(replacetext(used_invocation_message, "%CASTER", invoker.name), invoker)),
				capitalize(REPLACE_PRONOUNS(replacetext(invocation_self_message, "%CASTER", invoker.name), invoker)),
				visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
			)

/// Checks if the current OWNER of the spell is in a valid state to say the spell's invocation
/datum/action/cooldown/spell/proc/try_invoke(mob/living/invoker, feedback = TRUE)
	if(spell_requirements & SPELL_CASTABLE_WITHOUT_INVOCATION)
		return TRUE

	if(invocation_type == INVOCATION_NONE)
		return TRUE

	// If you want a spell usable by ghosts for some reason, it must be INVOCATION_NONE
	if(!istype(invoker))
		if(feedback)
			to_chat(invoker, span_warning("You need to be living to invoke [src]!"))
		return FALSE

	var/invoke_sig_return = SEND_SIGNAL(invoker, COMSIG_MOB_TRY_INVOKE_SPELL, src, feedback)
	if(invoke_sig_return & SPELL_INVOCATION_ALWAYS_SUCCEED)
		return TRUE // skips all of the following checks
	if(invoke_sig_return & SPELL_INVOCATION_FAIL)
		return FALSE

	if(invocation_type == INVOCATION_EMOTE && HAS_TRAIT(invoker, TRAIT_EMOTEMUTE))
		if(feedback)
			to_chat(invoker, span_warning("You can't position your hands correctly to invoke [src]!"))
		return FALSE

	if((invocation_type == INVOCATION_WHISPER || invocation_type == INVOCATION_SHOUT) && !invoker.can_speak())
		if(feedback)
			to_chat(invoker, span_warning("You can't get the words out to invoke [src]!"))
		return FALSE

	return TRUE

/// Resets the cooldown of the spell, sending COMSIG_SPELL_CAST_RESET
/// and allowing it to be used immediately (+ updating button icon accordingly)
/datum/action/cooldown/spell/proc/reset_spell_cooldown()
	SEND_SIGNAL(src, COMSIG_SPELL_CAST_RESET)
	next_use_time -= cooldown_time // Basically, ensures that the ability can be used now
	build_all_button_icons()

/**
 * Levels the spell up a single level, reducing the cooldown.
 * If bypass_cap is TRUE, will level the spell up past it's set cap.
 */
/datum/action/cooldown/spell/proc/level_spell(bypass_cap = FALSE)
	// Spell cannot be levelled
	if(spell_max_level <= 1)
		return FALSE

	// Spell is at cap, and we will not bypass it
	if(!bypass_cap && (spell_level >= spell_max_level))
		return FALSE

	spell_level++
	cooldown_time = max(cooldown_time - cooldown_reduction_per_rank, 0.25 SECONDS) // 0 second CD starts to break things.
	name = "[get_spell_title()][initial(name)]"
	build_all_button_icons(UPDATE_BUTTON_NAME)
	return TRUE

/**
 * Levels the spell down a single level, down to 1.
 */
/datum/action/cooldown/spell/proc/delevel_spell()
	// Spell cannot be levelled
	if(spell_max_level <= 1)
		return FALSE

	if(spell_level <= 1)
		return FALSE

	spell_level--
	if(cooldown_reduction_per_rank > 0 SECONDS)
		cooldown_time = min(cooldown_time + cooldown_reduction_per_rank, initial(cooldown_time))
	else
		cooldown_time = max(cooldown_time + cooldown_reduction_per_rank, initial(cooldown_time))

	name = "[get_spell_title()][initial(name)]"
	build_all_button_icons(UPDATE_BUTTON_NAME)
	return TRUE

/// Gets the title of the spell based on its level.
/datum/action/cooldown/spell/proc/get_spell_title()
	switch(spell_level)
		if(2)
			return "Efficient "
		if(3)
			return "Quickened "
		if(4)
			return "Free "
		if(5)
			return "Instant "
		if(6)
			return "Ludicrous "

	return ""
