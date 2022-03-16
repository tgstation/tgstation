
/// Needed for the badmin verb for now
GLOBAL_LIST_INIT(spells, subtypesof(/datum/action/cooldown/spell))

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
	/// The message displayed if someone tries to cast the spell when it's not ready yet
	var/still_recharging_msg = span_notice("The spell is still recharging!")
	/// If the spell uses the wizard spell rank system, the cooldown reduction per rank of the spell
	var/cooldown_reduction_per_rank = 0 SECONDS
	/// Only used if charge_type equals to "holder_var".
	/// The var to reduce on use
	var/holder_var_type = "bruteloss"
	/// Only used if charge_type equals to "holder_var".
	/// The amount adjusted with the mob's var when the spell is used
	var/holder_var_amount = 20
	/// What is uttered when the user casts the spell
	var/invocation
	/// What is shown in chat when the user casts the spell, only matters for INVOCATION_EMOTE
	var/invocation_self_message
	/// What type of invocation the spell is.
	/// Can be "none", "whisper", "shout", "emote"
	var/invocation_type = INVOCATION_NONE
	/// Flag for certain states that the spell requires the user be in to cast.
	var/spell_requirements = SPELL_REQUIRES_WIZARD_GARB
	/// The range of the spell.
	var/range = 7
	/// The current spell level if taken multiple times by a wizard
	var/spell_level = 0
	/// The max possible spell level
	var/level_max = 4
	/// If set to a positive number, the spell will produce sparks when casted.
	var/sparks_amt = 0
	/// What type of smoke is spread on cast. Harmless, harmful, or sleeping smoke.
	var/smoke_type = NO_SMOKE
	/// The amount of smoke spread.
	var/smoke_amt = 0

/datum/action/cooldown/spell/New()
	. = ..()
	still_recharging_msg = span_warning("[name] is still recharging!")

/datum/action/cooldown/spell/PreActivate(atom/target)
	if(!can_cast_spell())
		return FALSE
	if(!is_valid_target(target))
		return FALSE

	UpdateButtonIcon()
	return Activate()

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

	if(isliving(owner))
		var/mob/living/living_owner = owner
		if(!CAN_INVOKE(invocation_type, living_owner))
			to_chat(owner, span_warning("You can't get the words out to cast [src]!"))
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

// click_to_activate spells: [target] is what was clicked on
// All other spells: [target] is the owner of the spell
/datum/action/cooldown/spell/Activate(atom/target)
	SHOULD_NOT_OVERRIDE(TRUE)

	StartCooldown(cooldown_time / 4)
	if(!before_cast(target))
		return FALSE

	cast(target)
	after_cast(target)

	StartCooldown()
	UpdateButtonIcon()

	return TRUE

/*
/obj/effect/proc_holder/spell/proc/charge_check(mob/user, silent = FALSE)
	switch(charge_type)
		if("recharge")
			if(charge_counter < charge_max)
				if(!silent)
					to_chat(user, still_recharging_msg)
				return FALSE
		if("charges")
			if(!charge_counter)
				if(!silent)
					to_chat(user, span_warning("[name] has no charges left!"))
				return FALSE
	return TRUE
*/

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
	// No "should call parent" for after cast, as
	// spells should be free to override to have no after-cast at all

	SEND_SIGNAL(owner, COMSIG_MOB_AFTER_SPELL_CAST, src)
	SEND_SIGNAL(src, COMSIG_SPELL_AFTER_CAST)

	invocation()
	play_spell_sound()

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

/datum/action/cooldown/spell/proc/play_spell_sound()
	if(!sound)
		return FALSE

	playsound(get_turf(owner), sound, 50, TRUE)
	return TRUE

/datum/action/cooldown/spell/proc/revert_cast()
	next_use_time = 0
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
