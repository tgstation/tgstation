
GLOBAL_LIST_INIT(spells, subtypesof(/datum/action/cooldown/spell)) //needed for the badmin verb for now

/datum/action/cooldown/spell



/obj/effect/proc_holder
	var/panel = "Debug"//What panel the proc holder needs to go on.
	var/active = FALSE //Used by toggle based abilities.
	var/ranged_mousepointer
	var/mob/living/ranged_ability_user
	var/ranged_clickcd_override = -1
	var/has_action = TRUE
	var/datum/action/spell_action/action = null
	var/action_icon = 'icons/mob/actions/actions_spells.dmi'
	var/action_icon_state = "spell_default"
	var/action_background_icon_state = "bg_spell"
	var/base_action = /datum/action/spell_action
	var/datum/weakref/owner

/obj/effect/proc_holder/Initialize(mapload, mob/living/new_owner)
	. = ..()
	owner = WEAKREF(new_owner)
	if(has_action)
		action = new base_action(src)

/obj/effect/proc_holder/Destroy()
	if(!QDELETED(action))
		qdel(action)
	action = null
	return ..()

/obj/effect/proc_holder/proc/on_gain(mob/living/user)
	return

/obj/effect/proc_holder/proc/on_lose(mob/living/user)
	return

/obj/effect/proc_holder/proc/fire(mob/living/user)
	return TRUE

/obj/effect/proc_holder/proc/get_panel_text()
	return ""


/obj/effect/proc_holder/proc/InterceptClickOn(mob/living/caller, params, atom/A)
	if(caller.ranged_ability != src || ranged_ability_user != caller) //I'm not actually sure how these would trigger, but, uh, safety, I guess?
		to_chat(caller, span_warning("<b>[caller.ranged_ability.name]</b> has been disabled."))
		caller.ranged_ability.remove_ranged_ability()
		return TRUE //TRUE for failed, FALSE for passed.
	if(ranged_clickcd_override >= 0)
		ranged_ability_user.next_click = world.time + ranged_clickcd_override
	else
		ranged_ability_user.next_click = world.time + CLICK_CD_CLICK_ABILITY
	ranged_ability_user.face_atom(A)
	return FALSE

/obj/effect/proc_holder/proc/add_ranged_ability(mob/living/user, msg, forced)
	if(!user || !user.client)
		return
	if(user.ranged_ability && user.ranged_ability != src)
		if(forced)
			to_chat(user, span_warning("<b>[user.ranged_ability.name]</b> has been replaced by <b>[name]</b>."))
			user.ranged_ability.remove_ranged_ability()
		else
			return
	user.ranged_ability = src
	user.click_intercept = src
	user.update_mouse_pointer()
	ranged_ability_user = user
	if(msg)
		to_chat(ranged_ability_user, msg)
	active = TRUE
	update_appearance()

/obj/effect/proc_holder/proc/remove_ranged_ability(msg)
	if(!ranged_ability_user || !ranged_ability_user.client || (ranged_ability_user.ranged_ability && ranged_ability_user.ranged_ability != src)) //To avoid removing the wrong ability
		return
	ranged_ability_user.ranged_ability = null
	ranged_ability_user.click_intercept = null
	ranged_ability_user.update_mouse_pointer()
	if(msg)
		to_chat(ranged_ability_user, msg)
	ranged_ability_user = null
	active = FALSE
	update_appearance()

/datum/action/cooldown/spell
	name = "Spell"
	desc = "A wizard spell."
	action_icon = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "spell_default"
	action_background_icon_state = "bg_spell"

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
	var/invocation = "HURP DURP"
	/// What is shown in chat when the user casts the spell, only matters for INVOCATION_EMOTE
	var/invocation_self_message
	/// What type of invocation the spell is.
	/// Can be "none", "whisper", "shout", "emote"
	var/invocation_type = INVOCATION_NONE
	/// Flag for certain states that the spell requires the user be in to cast.
	var/spell_requirements = SPELL_REQUIRES_WIZARD_GARB
	/// The range of the spell.
	var/range = 7
	/// What is shown to people afflicted by the spell
	var/on_afflicted_message = ""
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
		if((invocation_type == INVOCATION_WHISPER || invocation_type == INVOCATION_SHOUT) && !living_owner.can_speak_vocal())
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

/datum/action/cooldown/spell/Activate(atom/target)

	// Targeted spell: `target` is what was clicked on
	// Self spell: `target` is the owner of the spell
	StartCooldown(10 SECONDS)
	if(!before_cast(target))
		return FALSE

	if(owner?.ckey)
		owner.log_message(span_danger("cast the spell [name]."), LOG_ATTACK)
	invocation()
	if(sound)
		playsound(get_turf(owner), sound, 50, TRUE)

	SEND_SIGNAL(owner, COMSIG_SPELL_CAST, src)
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
	if(SEND_SIGNAL(owner, COMSIG_SPELL_BEFORE_CAST, src) & COMPONENT_CANCEL_SPELL)
		return FALSE
	return TRUE

/**
 * Actions done as the main effect of the spell.
 *
 * For self targeted spells, `cast_on` is the same as `owner`.
 * For click spells, `cast_on` is whatever the owner clicked on.
 */
/datum/action/cooldown/spell/proc/cast(atom/cast_on)

/// Actions done after the main cast is finished.
/datum/action/cooldown/spell/proc/after_cast(atom/cast_on)
	SEND_SIGNAL(owner, COMSIG_SPELL_AFTER_CAST, src)
	if(isliving(cast_on) && on_afflicted_message)
		to_chat(cast_on, on_afflicted_message)

	if(sparks_amt)
		do_sparks(sparks_amt, FALSE, get_turf(cast_on))

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
		smoke.set_up(smoke_amt, get_turf(cast_on))
		smoke.start()

	return TRUE

/datum/action/cooldown/spell/proc/invocation()
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
