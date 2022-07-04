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
 * - [can_invoke][/datum/action/cooldown/spell/can_invoke] is run in can_cast_spell to check if
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
 * - [update_spell_name][/datum/action/cooldown/spell/update_spell_name] updates the prefix of the spell name based on its level.
 */
/datum/action/cooldown/spell
	name = "Spell"
	desc = "A wizard spell."
	background_icon_state = "bg_spell"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "spell_default"
	check_flags = AB_CHECK_CONSCIOUS
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
	if(spell_requirements & SPELL_REQUIRES_OFF_CENTCOM)
		RegisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED, .proc/update_icon_on_signal)
	if(spell_requirements & (SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_WIZARD_GARB))
		RegisterSignal(owner, COMSIG_MOB_EQUIPPED_ITEM, .proc/update_icon_on_signal)
	RegisterSignal(owner, list(COMSIG_MOB_ENTER_JAUNT, COMSIG_MOB_AFTER_EXIT_JAUNT), .proc/update_icon_on_signal)
	owner.client?.stat_panel.send_message("check_spells")

/datum/action/cooldown/spell/Remove(mob/living/remove_from)

	remove_from.client?.stat_panel.send_message("check_spells")
	UnregisterSignal(remove_from, list(
		COMSIG_MOB_AFTER_EXIT_JAUNT,
		COMSIG_MOB_ENTER_JAUNT,
		COMSIG_MOB_EQUIPPED_ITEM,
		COMSIG_MOVABLE_Z_CHANGED,
	))

	return ..()

/datum/action/cooldown/spell/IsAvailable()
	return ..() && can_cast_spell(feedback = FALSE)

/datum/action/cooldown/spell/Trigger(trigger_flags, atom/target)
	// We implement this can_cast_spell check before the parent call of Trigger()
	// to allow people to click unavailable abilities to get a feedback chat message
	// about why the ability is unavailable.
	// It is otherwise redundant, however, as IsAvailable() checks can_cast_spell as well.
	if(!can_cast_spell())
		return FALSE

	return ..()

/datum/action/cooldown/spell/set_click_ability(mob/on_who)
	if(SEND_SIGNAL(on_who, COMSIG_MOB_SPELL_ACTIVATED, src) & SPELL_CANCEL_CAST)
		return FALSE

	return ..()

// Where the cast chain starts
/datum/action/cooldown/spell/PreActivate(atom/target)
	if(!is_valid_target(target))
		return FALSE

	return Activate(target)

/// Checks if the owner of the spell can currently cast it.
/// Does not check anything involving potential targets.
/datum/action/cooldown/spell/proc/can_cast_spell(feedback = TRUE)
	if(!owner)
		CRASH("[type] - can_cast_spell called on a spell without an owner!")

	// Certain spells are not allowed on the centcom zlevel
	var/turf/caster_turf = get_turf(owner)
	if((spell_requirements & SPELL_REQUIRES_OFF_CENTCOM) && is_centcom_level(caster_turf.z))
		if(feedback)
			to_chat(owner, span_warning("You can't cast [src] here!"))
		return FALSE

	if((spell_requirements & SPELL_REQUIRES_MIND) && !owner.mind)
		// No point in feedback here, as mindless mobs aren't players
		return FALSE

	if((spell_requirements & SPELL_REQUIRES_MIME_VOW) && !owner.mind?.miming)
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

	if(!(spell_requirements & SPELL_CASTABLE_WHILE_PHASED) && HAS_TRAIT(owner, TRAIT_MAGICALLY_PHASED))
		if(feedback)
			to_chat(owner, span_warning("[src] cannot be cast unless you are completely manifested in the material plane!"))
		return FALSE

	if(!can_invoke(feedback = feedback))
		return FALSE

	if(ishuman(owner))
		if(spell_requirements & SPELL_REQUIRES_WIZARD_GARB)
			var/mob/living/carbon/human/human_owner = owner
			if(!(human_owner.wear_suit?.clothing_flags & CASTING_CLOTHES))
				to_chat(owner, span_warning("You don't feel strong enough without your robe!"))
				return FALSE
			if(!(human_owner.head?.clothing_flags & CASTING_CLOTHES))
				to_chat(owner, span_warning("You don't feel strong enough without your hat!"))
				return FALSE

	else
		// If the spell requires wizard equipment and we're not a human (can't wear robes or hats), that's just a given
		if(spell_requirements & (SPELL_REQUIRES_WIZARD_GARB|SPELL_REQUIRES_HUMAN))
			if(feedback)
				to_chat(owner, span_warning("[src] can only be cast by humans!"))
			return FALSE

		if(!(spell_requirements & SPELL_CASTABLE_AS_BRAIN) && isbrain(owner))
			if(feedback)
				to_chat(owner, span_warning("[src] can't be cast in this state!"))
			return FALSE

		// Being put into a card form breaks a lot of spells, so we'll just forbid them in these states
		if(ispAI(owner) || (isAI(owner) && istype(owner.loc, /obj/item/aicard)))
			return FALSE

	return TRUE

/**
 * Check if the target we're casting on is a valid target.
 * For self-casted spells, the target being checked (cast_on) is the caster.
 *
 * Return TRUE if cast_on is valid, FALSE otherwise
 */
/datum/action/cooldown/spell/proc/is_valid_target(atom/cast_on)
	return TRUE

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
		spell_feedback()

	// Actually cast the spell. Main effects go here
	cast(cast_on)

	if(!(precast_result & SPELL_NO_IMMEDIATE_COOLDOWN))
		// The entire spell is done, start the actual cooldown at its set duration
		StartCooldown()

	// And then proceed with the aftermath of the cast
	// Final effects that happen after all the casting is done can go here
	after_cast(cast_on)
	UpdateButtons()

	return TRUE

/**
 * Actions done before the actual cast is called.
 * This is the last chance to cancel the spell from being cast.
 *
 * Can be used for target selection or to validate checks on the caster (cast_on).
 *
 * Returns a bitflag.
 * - SPELL_CANCEL_CAST will stop the spell from being cast.
 * - SPELL_NO_FEEDBACK will prevent the spell from calling [proc/spell_feedback] on cast. (invocation, sounds)
 * - SPELL_NO_IMMEDIATE_COOLDOWN will prevent the spell from starting its cooldown between cast and before after_cast.
 */
/datum/action/cooldown/spell/proc/before_cast(atom/cast_on)
	SHOULD_CALL_PARENT(TRUE)

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

	SEND_SIGNAL(src, COMSIG_SPELL_AFTER_CAST, cast_on)
	if(!owner)
		return

	SEND_SIGNAL(owner, COMSIG_MOB_AFTER_SPELL_CAST, src, cast_on)

	// Sparks and smoke can only occur if there's an owner to source them from.
	if(sparks_amt)
		do_sparks(sparks_amt, FALSE, get_turf(owner))

	if(ispath(smoke_type, /datum/effect_system/fluid_spread/smoke))
		var/datum/effect_system/fluid_spread/smoke/smoke = new smoke_type()
		smoke.set_up(smoke_amt, holder = owner, location = get_turf(owner))
		smoke.start()

/// Provides feedback after a spell cast occurs, in the form of a cast sound and/or invocation
/datum/action/cooldown/spell/proc/spell_feedback()
	if(!owner)
		return

	if(invocation_type != INVOCATION_NONE)
		invocation()
	if(sound)
		playsound(get_turf(owner), sound, 50, TRUE)

/// The invocation that accompanies the spell, called from spell_feedback() before cast().
/datum/action/cooldown/spell/proc/invocation()
	switch(invocation_type)
		if(INVOCATION_SHOUT)
			if(prob(50))
				owner.say(invocation, forced = "spell ([src])")
			else
				owner.say(replacetext(invocation," ","`"), forced = "spell ([src])")

		if(INVOCATION_WHISPER)
			if(prob(50))
				owner.whisper(invocation, forced = "spell ([src])")
			else
				owner.whisper(replacetext(invocation," ","`"), forced = "spell ([src])")

		if(INVOCATION_EMOTE)
			owner.visible_message(invocation, invocation_self_message)

/// Checks if the current OWNER of the spell is in a valid state to say the spell's invocation
/datum/action/cooldown/spell/proc/can_invoke(feedback = TRUE)
	if(spell_requirements & SPELL_CASTABLE_WITHOUT_INVOCATION)
		return TRUE

	if(invocation_type == INVOCATION_NONE)
		return TRUE

	// If you want a spell usable by ghosts for some reason, it must be INVOCATION_NONE
	if(!isliving(owner))
		if(feedback)
			to_chat(owner, span_warning("You need to be living to invoke [src]!"))
		return FALSE

	var/mob/living/living_owner = owner
	if(invocation_type == INVOCATION_EMOTE && HAS_TRAIT(living_owner, TRAIT_EMOTEMUTE))
		if(feedback)
			to_chat(owner, span_warning("You can't position your hands correctly to invoke [src]!"))
		return FALSE

	if((invocation_type == INVOCATION_WHISPER || invocation_type == INVOCATION_SHOUT) && !living_owner.can_speak_vocal())
		if(feedback)
			to_chat(owner, span_warning("You can't get the words out to invoke [src]!"))
		return FALSE

	return TRUE

/// Resets the cooldown of the spell, sending COMSIG_SPELL_CAST_RESET
/// and allowing it to be used immediately (+ updating button icon accordingly)
/datum/action/cooldown/spell/proc/reset_spell_cooldown()
	SEND_SIGNAL(src, COMSIG_SPELL_CAST_RESET)
	next_use_time -= cooldown_time // Basically, ensures that the ability can be used now
	UpdateButtons()

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
	cooldown_time = max(cooldown_time - cooldown_reduction_per_rank, 0)
	update_spell_name()
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
	cooldown_time = min(cooldown_time + cooldown_reduction_per_rank, initial(cooldown_time))
	update_spell_name()
	return TRUE

/**
 * Updates the spell's name based on its level.
 */
/datum/action/cooldown/spell/proc/update_spell_name()
	var/spell_title = ""
	switch(spell_level)
		if(2)
			spell_title = "Efficient "
		if(3)
			spell_title = "Quickened "
		if(4)
			spell_title = "Free "
		if(5)
			spell_title = "Instant "
		if(6)
			spell_title = "Ludicrous "

	name = "[spell_title][initial(name)]"
	UpdateButtons()
