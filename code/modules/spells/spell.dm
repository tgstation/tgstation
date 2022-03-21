
/// Needed for the badmin verb for now
GLOBAL_LIST_INIT(spells, subtypesof(/datum/action/cooldown/spell))

/**
 * # The spell action
 *
 * This is the base action for how many of the game's
 * spells (and spell adjacent) abilities function.
 *
 * These spells function off of a cooldown-based system,
 * but can be ajusted to function with other methods
 * via components or otherwise.
 *
 * ## Pre-spell checks:
 * - [can_cast_spell][/datum/action/cooldown/spell/can_cast_spell] checks if the OWNER
 * of the spell is able to cast the spell. Note that in rare occasions, such as shared spells,
 * the owner may not be the caster of the spell.
 * - [is_valid_target][/datum/action/cooldown/spell/is_valid_target] checks if the TARGET
 * THE SPELL IS BEING CAST ON is a valid target for the spell. NOTE: The CAST TARGET is often THE SAME as
 * THE OWNER OF THE SPELL, but is not always - click_to_activate spells will pass the clicked target
 * into is_valid_target, while every other spell will use owner in is_valid_target.
 * - [can_invoke][/datum/action/cooldown/spell/can_invoke] is run in can_cast_spell to check if
 * the OWNER of the spell is able to say the current invocation.
 *
 * ## The spell chain:
 * - [before_cast][/datum/action/cooldown/spell/before_cast] is the last chance for being able
 * to interrupt a spell cast. Returning FALSE from it will stop a spell from casting. You can hook
 * additional checks into this.
 * - [spell_feedback][/datum/action/cooldown/spell/spell_feedback] is called right before cast, and handles
 * invocation and sound effects. Overridable, if you want a special method of invocation or sound effects,
 * or if you wish to call it in a different location (such as after_cast).
 * - [cast][/datum/action/cooldown/spell/cast] is where the brunt of the spell effects should be done
 * and implemented.
 * - [after_cast][/datum/action/cooldown/spell/after_cast] is any aftermath, final effects that follow
 * the main cast of the spell.
 *
 * ## Other procs called / may be called within the chain:
 * - [invocation][/datum/action/cooldown/spell/invocation] handles saying any vocal invocations the spell
 * may have, and can be overriden or extended. Called by spell_feedback().
 * - [revert_cast][/datum/action/cooldown/spell/revert_cast] is a way to handle reverting a spell's
 * cooldown and making it ready again if it fails to go off during cast. Not called anywhere by default.
 *
 * ## Other procs of note:
 * - [level_spell][/datum/action/cooldown/spell/level_spell] is where the process of adding a spell level is handled.
 * this can be extended if you wish to add special effects on level.
 * - [delevel_spell][/datum/action/cooldown/spell/delevel_spell] is where the process of removing a spell level is handled.
 * this can be extended if you wish to add special effects on level.
 */
/datum/action/cooldown/spell
	name = "Spell"
	desc = "A wizard spell."
	background_icon_state = "bg_spell"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "spell_default"

	/// The panel this action shows up in the stat panel in.
	var/panel = "Spells"
	/// The sound played on cast.
	var/sound = null
	/// The school of magic the spell belongs to.
	/// Checked by some holy sects to punish the caster
	/// for casting things that do not align
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
	var/spell_requirements = SPELL_REQUIRES_WIZARD_GARB
	/// The current spell level, if taken multiple times by a wizard
	var/spell_level = 1
	/// The max possible spell level
	var/spell_max_level = 5
	/// If set to a positive number, the spell will produce sparks when casted.
	var/sparks_amt = 0
	/// What type of smoke is spread on cast. Harmless, harmful, or sleeping smoke.
	var/smoke_type = NO_SMOKE
	/// The amount of smoke spread.
	var/smoke_amt = 0

/datum/action/cooldown/spell/Grant(mob/grant_to)
	if(!target)
		stack_trace("Someone tried to grant a spell to someone which was incorrectly created. Please assign a target in New()!")

	if(istype(target, /datum/mind))
		var/datum/mind/mind_target = target
		if(mind_target.current != grant_to)
			return

	if(spell_requirements & SPELL_REQUIRES_OFF_CENTCOM)
		RegisterSignal(grant_to, COMSIG_MOVABLE_Z_CHANGED, .proc/update_icon_on_signal)
	if(spell_requirements & SPELL_REQUIRES_CONSCIOUS)
		RegisterSignal(grant_to, COMSIG_MOB_STATCHANGE, .proc/update_icon_on_signal)
	if(spell_requirements & (SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_WIZARD_GARB))
		RegisterSignal(grant_to, COMSIG_MOB_EQUIPPED_ITEM, .proc/update_icon_on_signal)

	return ..()

/datum/action/cooldown/spell/Remove(mob/living/remove_from)
	UnregisterSignal(remove_from, list(COMSIG_MOVABLE_Z_CHANGED, COMSIG_MOB_STATCHANGE, COMSIG_MOB_EQUIPPED_ITEM))
	return ..()

/// A simple helper signal proc that calls UpdateButtonIcon
/// when a signal relevant to our spell requirements has been caught.
/datum/action/cooldown/spell/proc/update_icon_on_signal(datum/source)
	SIGNAL_HANDLER

	UpdateButtonIcon()

/datum/action/cooldown/spell/PreActivate(atom/target)
	if(!can_cast_spell())
		return FALSE
	if(!is_valid_target(target))
		return FALSE

	UpdateButtonIcon()
	return Activate()

/datum/action/cooldown/spell/IsAvailable()
	return ..() && can_cast_spell()

/// Checks if the owner of the spell can currently cast it.
/// Does not check anything involving potential targets.
/datum/action/cooldown/spell/proc/can_cast_spell()
	// Certain spells are not allowed on the centcom zlevel
	var/turf/caster_turf = get_turf(owner)
	if((spell_requirements & SPELL_REQUIRES_OFF_CENTCOM) && is_centcom_level(caster_turf.z))
		to_chat(owner, span_warning("You can't cast [src] here!"))
		return FALSE

	/*
	if(!charge_check(user))
		return FALSE
	*/

	if((spell_requirements & SPELL_REQUIRES_MIND) && !owner.mind)
		return FALSE

	if((spell_requirements & SPELL_REQUIRES_CONSCIOUS) && owner.stat > CONSCIOUS)
		to_chat(owner, span_warning("You need to be conscious to cast [src]!"))
		return FALSE

	if(!(spell_requirements & SPELL_REQUIRES_NO_ANTIMAGIC))
		var/antimagic = owner.anti_magic_check(TRUE, FALSE, FALSE, 0, TRUE)
		if(antimagic)
			if(isitem(antimagic))
				to_chat(owner, span_notice("[antimagic] is interfering with your ability to cast [src]."))
			else
				to_chat(owner, span_warning("Magic seems to flee from you - You can't gather enough power to cast [src]."))
			return FALSE

	if((spell_requirements & SPELL_REQUIRES_UNPHASED) && istype(owner.loc, /obj/effect/dummy))
		to_chat(owner, span_warning("[src] cannot be cast unless you are completely manifested in the material plane!"))
		return FALSE

	if(!can_invoke())
		return FALSE

	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		if(spell_requirements & SPELL_REQUIRES_WIZARD_GARB)
			if(!HAS_TRAIT(human_owner.wear_suit, TRAIT_WIZARD_ROBES))
				to_chat(owner, span_warning("You don't feel strong enough to cast [src] without your robes!"))
				return FALSE
			if(!HAS_TRAIT(human_owner.head, TRAIT_WIZARD_HAT))
				to_chat(owner, span_warning("You don't feel strong enough to cast [src] without your hat!"))
				return FALSE
	else
		if(spell_requirements & (SPELL_REQUIRES_WIZARD_GARB|SPELL_REQUIRES_HUMAN))
			to_chat(owner, span_warning("[src] can only be cast by humans!"))
			return FALSE

		if((spell_requirements & SPELL_REQUIRES_NON_ABSTRACT) && (isbrain(owner) || ispAI(owner)))
			to_chat(owner, span_warning("[src] can only be cast by physical beings!"))
			return FALSE

	return TRUE

/// Check if the target we're casting on is a valid target.
/// For spells with click_to_activate = TRUE, cast_on will be whatever is clicked
/// For all other spells, cast_on will be the caster of the spell
/datum/action/cooldown/spell/proc/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/Activate(atom/target)
	SHOULD_NOT_OVERRIDE(TRUE)

	// First, start a short "buffer" cooldown to prevent them spamming the button
	StartCooldown(cooldown_time / 4)
	// Pre-casting of the spell
	// Pre-cast is the very last chance for a spell to cancel
	// Stuff like target input would go here.
	if(!before_cast(target))
		return FALSE

	// Spell is officially being cast
	// We do invocation and sound effects here, before cast
	// (That way stuff like teleports or shape-shifts can be said before done)
	spell_feedback()

	// Actually cast the spell. Main effects go here
	cast(target)
	// And then proceed with the aftermath of the cast
	// Final effects that happen after all the casting is done can go here
	after_cast(target)

	// The entire spell is done, start the cooldown at its set duration
	// and update the icon so it looks disabled
	StartCooldown()
	UpdateButtonIcon()

	return TRUE

/// Actions done before the actual cast() is called.
/// Return FALSE to cancel the spell casat before it occurs, TRUE to let it happen
/datum/action/cooldown/spell/proc/before_cast(atom/cast_on)
	SHOULD_CALL_PARENT(TRUE)

	var/sig_return = SEND_SIGNAL(src, COMSIG_SPELL_BEFORE_CAST) | SEND_SIGNAL(owner, COMSIG_MOB_BEFORE_SPELL_CAST, src)
	if(sig_return & COMPONENT_CANCEL_SPELL)
		return FALSE

	return TRUE

/**
 * Actions done as the main effect of the spell.
 *
 * For spells without a click intercept, [cast_on] will be the owner.
 * For click spells, [cast_on] is whatever the owner clicked on in casting the spell.
 */
/datum/action/cooldown/spell/proc/cast(atom/cast_on)
	SHOULD_CALL_PARENT(TRUE)

	SEND_SIGNAL(src, COMSIG_SPELL_CAST)
	SEND_SIGNAL(owner, COMSIG_MOB_CAST_SPELL, src)

	if(owner?.ckey)
		owner.log_message("cast the spell [name][cast_on != owner ? " on [cast_on]":""].", LOG_ATTACK)

/// Actions done after the main cast is finished.
/datum/action/cooldown/spell/proc/after_cast(atom/cast_on)
	SHOULD_CALL_PARENT(TRUE)

	SEND_SIGNAL(owner, COMSIG_MOB_AFTER_SPELL_CAST, src)
	SEND_SIGNAL(src, COMSIG_SPELL_AFTER_CAST)

	if(sparks_amt)
		do_sparks(sparks_amt, FALSE, get_turf(owner))

	if(smoke_type)
		var/smoke_type
		switch(smoke_type)
			if(SMOKE_HARMLESS)
				smoke_type = /datum/effect_system/smoke_spread
			if(SMOKE_HARMFUL)
				smoke_type = /datum/effect_system/smoke_spread/bad
			if(SMOKE_SLEEPING)
				smoke_type = /datum/effect_system/smoke_spread/sleeping

		if(!ispath(smoke_type))
			CRASH("Invalid smoke type for spell [type]. Got [smoke_type].")

		var/datum/effect_system/smoke = new smoke_type()
		smoke.set_up(smoke_amt, get_turf(owner))
		smoke.start()

/datum/action/cooldown/spell/proc/spell_feedback()
	if(invocation_type != INVOCATION_NONE)
		invocation()
	if(sound)
		playsound(get_turf(owner), sound, 50, TRUE)

/datum/action/cooldown/spell/proc/invocation()
	/* MELBERT TODO Unit test this
	if(!invocation || invocation_type == INVOCATION_NONE)
		return
	*/
	switch(invocation_type)
		if(INVOCATION_SHOUT)
			//Auto-mute? Fuck that noise
			if(prob(50))
				owner.say(invocation, forced = "spell ([src])")
			else
				owner.say(replacetext(invocation," ","`"), forced = "spell ([src])")
		if(INVOCATION_WHISPER)
			if(prob(50))
				owner.whisper(invocation)
			else
				owner.whisper(replacetext(invocation," ","`"))
		if(INVOCATION_EMOTE)
			owner.visible_message(invocation, invocation_self_message)

/datum/action/cooldown/spell/proc/can_invoke()
	if(SEND_SIGNAL(src, COMSIG_SPELL_CAN_INVOKE) & COMPONENT_CANCEL_INVOKE)
		return FALSE

	if(invocation_type == INVOCATION_NONE)
		return TRUE

	// If you want a spell usable by ghosts for some reason, it must be INVOCATION_NONE
	if(!isliving(owner))
		to_chat(owner, span_warning("You need to be living to invoke [src]!"))
		return FALSE

	var/mob/living/living_owner = owner
	if(invocation_type == INVOCATION_EMOTE && HAS_TRAIT(living_owner, TRAIT_EMOTEMUTE)) // melbert todo cl
		to_chat(owner, span_warning("You can't get form to invoke [src]!"))
		return FALSE

	if((invocation_type == INVOCATION_WHISPER || invocation_type == INVOCATION_SHOUT) && !living_owner.can_speak_vocal())
		to_chat(owner, span_warning("You can't get the words out to invoke [src]!"))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/proc/revert_cast()
	next_use_time = world.time // Basically, ensures that the ability can be used now
	UpdateButtonIcon()

/*
/datum/action/cooldown/spell/proc/adjust_var(type, amount)
	if(!isliving(owner))
		return

	var/mob/living/living_owner = owner
	switch(type)
		if("bruteloss")
			living_owner.adjustBruteLoss(amount)
		if("fireloss")
			living_owner.adjustFireLoss(amount)
		if("toxloss")
			living_owner.adjustToxLoss(amount)
		if("oxyloss")
			living_owner.adjustOxyLoss(amount)
		if("stun")
			living_owner.AdjustStun(amount)
		if("knockdown")
			living_owner.AdjustKnockdown(amount)
		if("paralyze")
			living_owner.AdjustParalyzed(amount)
		if("immobilize")
			living_owner.AdjustImmobilized(amount)
		if("unconscious")
			living_owner.AdjustUnconscious(amount)
		else
			//I bear no responsibility for the runtimes
			// that'll happen if you try to adjust
			// non-numeric or even non-existent vars
			owner.vars[type] += amount
*/

/// TODO: This is ugly, and should be replaced
/datum/action/cooldown/spell/proc/los_check(atom/from_atom, atom/to_atom)
	//Checks for obstacles from A to B
	var/obj/dummy = new(from_atom.loc)
	dummy.pass_flags |= PASSTABLE
	var/turf/previous_step = get_turf(from_atom)
	var/first_step = TRUE
	for(var/turf/next_step as anything in (get_line(from_atom, to_atom) - previous_step))
		if(first_step)
			for(var/obj/blocker in previous_step)
				if(!blocker.density || !(blocker.flags_1 & ON_BORDER_1))
					continue
				if(blocker.CanPass(dummy, get_dir(previous_step, next_step)))
					continue
				return FALSE // Could not leave the first turf.
			first_step = FALSE
		for(var/atom/movable/movable as anything in next_step)
			if(!movable.CanPass(dummy, get_dir(next_step, previous_step)))
				qdel(dummy)
				return FALSE
		previous_step = next_step
	qdel(dummy)
	return TRUE

/datum/action/cooldown/spell/proc/get_statpanel_format()
	var/time_remaining = max(next_use_time - world.time, 0)
	var/time_remaining_in_seconds = round(time_remaining / 10, 0.1)

	return list(
		"[panel]",
		"[time_remaining_in_seconds]/[cooldown_time / 10]",
		name,
		REF(src),
	)

// MELBERT TODO unit test this (ensure upgradable spells have cooldown_reduction_per_rank etc)
/**
 * Levels the spell up a single level, reducing the cooldown.
 * If bypass_cap is TRUE, will level the spell up past it's set cap.
 */
/datum/action/cooldown/spell/proc/level_spell(bypass_cap = FALSE)
	// Spell cannot be levelled or gains no benefit from  being levelled
	if(spell_max_level <= 1 || !cooldown_time || !cooldown_reduction_per_rank)
		return FALSE

	// Spell is at cap, and we will not bypass it
	if(!bypass_cap && (spell_level >= spell_max_level))
		return FALSE

	spell_level++
	cooldown_time -= cooldown_reduction_per_rank
	update_spell_name()
	return TRUE

/**
 * Levels the spell down a single level, down to 1.
 */
/datum/action/cooldown/spell/proc/delevel_spell()
	// Spell cannot be levelled
	if(spell_max_level <= 1 || !cooldown_reduction_per_rank)
		return FALSE

	if(spell_level <= 1)
		return FALSE

	spell_level--
	cooldown_time += cooldown_reduction_per_rank
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

/datum/action/cooldown/spell/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	if(spell_requirements & SPELL_REQUIRES_WIZARD_GARB)
		VV_DROPDOWN_OPTION(VV_HK_SPELL_SET_ROBELESS, "Set Robeless")
	else
		VV_DROPDOWN_OPTION(VV_HK_SPELL_UNSET_ROBELESS, "Unset Robeless")

	if(spell_requirements & SPELL_REQUIRES_HUMAN)
		VV_DROPDOWN_OPTION(VV_HK_SPELL_UNSET_HUMANONLY, "Unset Require Humanoid Mob")
	else
		VV_DROPDOWN_OPTION(VV_HK_SPELL_SET_HUMANONLY, "Set Require Humanoid Mob")

	if(spell_requirements & SPELL_REQUIRES_NON_ABSTRACT)
		VV_DROPDOWN_OPTION(VV_HK_SPELL_UNSET_NONABSTRACT, "Unset Require Body")
	else
		VV_DROPDOWN_OPTION(VV_HK_SPELL_SET_NONABSTRACT, "Set Require Body")

/datum/action/cooldown/spell/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_SPELL_SET_ROBELESS])
		spell_requirements |= SPELL_REQUIRES_WIZARD_GARB
		return
	if(href_list[VV_HK_SPELL_UNSET_ROBELESS])
		spell_requirements &= ~SPELL_REQUIRES_WIZARD_GARB
		return

	if(href_list[VV_HK_SPELL_UNSET_HUMANONLY])
		spell_requirements |= SPELL_REQUIRES_HUMAN
		return
	if(href_list[VV_HK_SPELL_SET_HUMANONLY])
		spell_requirements &= ~SPELL_REQUIRES_HUMAN
		return

	if(href_list[VV_HK_SPELL_UNSET_NONABSTRACT])
		spell_requirements |= SPELL_REQUIRES_NON_ABSTRACT
		return
	if(href_list[VV_HK_SPELL_SET_NONABSTRACT])
		spell_requirements  &= ~SPELL_REQUIRES_NON_ABSTRACT
		return
