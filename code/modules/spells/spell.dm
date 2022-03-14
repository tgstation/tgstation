#define TARGET_CLOSEST 0
#define TARGET_RANDOM 1

#define NO_SMOKE 0
#define SMOKE_HARMLESS 1
#define SMOKE_HARMFUL 2
#define SMOKE_SLEEPING 3

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
	base_action = /datum/action/spell_action/spell

	/// The panel this action shows up in the stat panel in.
	var/panel = "Spells"
	/// The sound played on cast.
	var/sound = null
	/// The school of magic the spell belongs to.
	/// Checked by some holy sects to punish the caster
	/// for casting things that do not align
	/// with their sect's alignment - see magic.dm in defines to learn more
	var/school = SCHOOL_UNSET
	/// Can be recharge or charges, see charge_max and charge_counter descriptions;
	// can also be based on the holder's vars now, use "holder_var" for that
	var/charge_type = "recharge"
	/// Recharge time (in deciseconds) if charge_type = "recharge"
	/// or starting charges if charge_type = "charges"
	var/charge_max = 10 SECONDS
	/// The recharge time (in deciseconds) assuming this spell is at max rank.
	/// Only needs to be set for spells which use wizard spell levels.
	var/charge_min = 0
	/// Can only cast spells if it equals recharge,
	/// ++ each decisecond if charge_type = "recharge"
	/// or -- each cast if charge_type = "charges"
	var/charge_counter = 0
	/// The message displayed if someone tries to cast the spell when it's not ready yet
	var/still_recharging_msg = span_notice("The spell is still recharging.")
	/// Whether the spell is currently recharging
	var/recharging = TRUE
	/// Only used if charge_type equals to "holder_var".
	/// The var to reduce on use
	var/holder_var_type = "bruteloss"
	/// Only used if charge_type equals to "holder_var".
	/// The amount adjusted with the mob's var when the spell is used
	var/holder_var_amount = 20
	/// Whether the spell requires wizard clothes
	var/requires_wizard_garb = TRUE
	/// Whether the spell can only be cast by humans
	var/requires_human = FALSE
	/// Whether the spell can only be cast by mobs that are physical entities
	var/requires_non_abstract = FALSE
	/// Whether the spell must check for the caster being conscious/alive. Need to set to TRUE for ghost spells.
	var/requires_conscious = FALSE
	/// Whether the spell can be cast while phased, such as blood crawling or ethereal jaunting
	var/requires_unphased = FALSE
	/// Whethert he spell can be cast while the user has antimagic on them
	var/antimagic_allowed = FALSE
	/// What is uttered when the user casts the spell
	var/invocation = "HURP DURP"
	/// What is shown in chat when the user casts the spell
	var/invocation_self_message
	/// What type of invocation the spell is.
	/// Can be "none", "whisper", "shout", "emote"
	var/invocation_type = INVOCATION_NONE
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
	/// Whether or not the spell should be allowed on z2
	var/can_cast_on_centcom = TRUE

/datum/action/cooldown/spell/New()
	. = ..()
	still_recharging_msg = span_warning("[name] is still recharging!")
	charge_counter = charge_max

/datum/action/cooldown/spell/PreActivate(atom/target)
	if(SEND_SIGNAL(user, COMSIG_MOB_PRE_CAST_SPELL, src) & COMPONENT_CANCEL_SPELL)
		return FALSE
	if(!can_cast_spell())
		return FALSE
	if(!is_valid_target(target))
		return FALSE

	switch(charge_type)
		if("recharge")
			charge_counter = 0 //doesn't start recharging until the targets selecting ends
		if("charges")
			charge_counter-- //returns the charge if the targets selecting fails
		if("holdervar")
			adjust_var(user, holder_var_type, holder_var_amount)

	UpdateButtonIcon()
	return Activate()

/datum/action/cooldown/spell/proc/can_cast_spell()
	// Certain spells are not allowed on the centcom zlevel
	var/turf/caster_turf = get_turf(owner)
	if(!can_cast_on_centcom && is_centcom_level(caster_turf.z))
		to_chat(user, span_warning("You can't cast [src] here!"))
		return FALSE

	/*
	if(!charge_check(user))
		return FALSE
	*/

	if(requires_conscious && user.stat > CONSCIOUS)
		to_chat(user, span_warning("You need to be conscious to cast [src]!"))
		return FALSE

	if(!antimagic_allowed)
		var/antimagic = user.anti_magic_check(TRUE, FALSE, FALSE, 0, TRUE)
		if(antimagic)
			if(isitem(antimagic))
				to_chat(user, span_notice("[antimagic] is interfering with your ability to cast [src]."))
			else
				to_chat(user, span_warning("Magic seems to flee from you - You can't gather enough power to cast [src]."))
			return FALSE

	if(requires_unphased && istype(user.loc, /obj/effect/dummy))
		to_chat(user, span_warning("[src] cannot be cast unless you are completely manifested in the material plane!"))
		return FALSE

	if(isliving(owner))
		var/mob/living/living_owner = owner
		if((invocation_type == INVOCATION_WHISPER || invocation_type == INVOCATION_SHOUT) && !living_owner.can_speak_vocal())
			to_chat(user, span_warning("You can't get the words out to cast [src]!"))
			return FALSE

	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		if(requires_wizard_garb)
			if(!HAS_TRAIT(human_owner.wear_suit, TRAIT_WIZARD_ROBES))
				to_chat(owner, span_warning("You don't feel strong enough to cast [src] without your robes!"))
				return FALSE
			if(!HAS_TRAIT(human_owner.head, TRAIT_WIZARD_HAT))
				to_chat(owner, span_warning("You don't feel strong enough to cast [src] without your hat!"))
				return FALSE
	else
		if(requires_wizard_garb || requires_human)
			to_chat(owner, span_warning("[src] can only be cast by humans!"))
			return FALSE

		if(requires_non_abstract && (isbrain(user) || ispAI(user)))
			to_chat(user, span_warning("[src] can only be cast by physical beings!"))
			return FALSE

	return TRUE

/datum/action/cooldown/spell/Activate(atom/target)

	// Targeted spell: `target` is what was clicked on
	// Self spell: `target` is the owner of the spell

	StartCooldown(10 SECONDS)
	if(!pre_cast(target))
		return

	if(owner?.ckey)
		owner.log_message(span_danger("cast the spell [name]."), LOG_ATTACK)
	invocation()
	if(sound)
		playsound(get_turf(owner), sound, 50, TRUE)

	SEND_SIGNAL(owner, COMSIG_MOB_CAST_SPELL, src)
	StartCooldown()

	if(!cast(target))
		return

	after_cast(target)
	UpdateButtonIcon()

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
/datum/action/cooldown/spell/proc/before_cast(atom/cast_on)

/// Actions done as the main effect of the spell.
/datum/action/cooldown/spell/proc/cast(atom/cast_on)

/// Actions done after the main cast is finished.
/datum/action/cooldown/spell/proc/after_cast(atom/cast_on)

	if(isliving(target) && on_afflicted_message)
		to_chat(target, on_afflicted_message)

	if(sparks_amt)
		do_sparks(sparks_amt, FALSE, location)

	if(smoke_spread)
		var/smoke_type
		switch(smoke_spread)
			if(SMOKE_HARMLESS)
				smoke_type = /datum/effect_system/smoke_spread
			if(SMOKE_HARMFUL)
				smoke_type = /datum/effect_system/smoke_spread/bad
			if(SMOKE_SLEEPING)
				smoke_type = /datum/effect_system/smoke_spread/sleeping

		if(!ispath(smoke_type))
			CRASH("Invalid smoke type for spell [type]. Got [smoke_type].")

		var/datum/effect_system/smoke = new smoke_type()
		smoke.set_up(smoke_amt, location)
		smoke.start()

/datum/action/cooldown/spell/proc/invocation()
	switch(invocation_type)
		if(INVOCATION_SHOUT)
			//Auto-mute? Fuck that noise
			if(prob(50))
				user.say(invocation, forced = "spell ([src])")
			else
				user.say(replacetext(invocation," ","`"), forced = "spell ([src])")
		if(INVOCATION_WHISPER)
			if(prob(50))
				user.whisper(invocation)
			else
				user.whisper(replacetext(invocation," ","`"))
		if(INVOCATION_EMOTE)
			user.visible_message(invocation, invocation_self_message)


/datum/action/cooldown/spell/proc/revert_cast()
	switch(charge_type)
		if("recharge")
			charge_counter = charge_max
		if("charges")
			charge_counter++
		if("holdervar")
			adjust_var(user, holder_var_type, -holder_var_amount)
	UpdateButtonIcon()

/datum/action/cooldown/spell/proc/adjust_var(type, amount)
	switch(type)
		if("bruteloss")
			owner.adjustBruteLoss(amount)
		if("fireloss")
			owner.adjustFireLoss(amount)
		if("toxloss")
			owner.adjustToxLoss(amount)
		if("oxyloss")
			owner.adjustOxyLoss(amount)
		if("stun")
			owner.AdjustStun(amount)
		if("knockdown")
			owner.AdjustKnockdown(amount)
		if("paralyze")
			owner.AdjustParalyzed(amount)
		if("immobilize")
			owner.AdjustImmobilized(amount)
		if("unconscious")
			owner.AdjustUnconscious(amount)
		else
			//I bear no responsibility for the runtimes
			// that'll happen if you try to adjust
			// non-numeric or even non-existent vars
			owner.vars[type] += amount

/// AOE turf - the spell is cast on all turfs around the caster.
///
/datum/action/cooldown/spell/aoe_turf
	/// The outside radius of the aoe.
	var/outer_radius = 7
	/// The inside radius of the aoe.
	var/inner_radius = -1

/datum/action/cooldown/spell/aoe_turf/choose_targets(mob/user = usr)
	var/list/targets = list()

	for(var/turf/target in view_or_range(range, user, selection_type))
		if(!can_target(target, user, TRUE))
			continue
		if(!(target in view_or_range(inner_radius, user, selection_type)))
			targets += target

	if(!length(targets)) //doesn't waste the spell
		revert_cast()
		return

	perform(targets,user=user)

/datum/action/cooldown/spell/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	if(requires_wizard_garb)
		VV_DROPDOWN_OPTION(VV_HK_SPELL_SET_ROBELESS, "Set Robeless")
	else
		VV_DROPDOWN_OPTION(VV_HK_SPELL_UNSET_ROBELESS, "Unset Robeless")

	if(requires_human)
		VV_DROPDOWN_OPTION(VV_HK_SPELL_UNSET_HUMANONLY, "Unset Require Humanoid Mob")
	else
		VV_DROPDOWN_OPTION(VV_HK_SPELL_SET_HUMANONLY, "Set Require Humanoid Mob")

	if(requires_non_abstract)
		VV_DROPDOWN_OPTION(VV_HK_SPELL_UNSET_NONABSTRACT, "Unset Require Body")
	else
		VV_DROPDOWN_OPTION(VV_HK_SPELL_SET_NONABSTRACT, "Set Require Body")

/datum/action/cooldown/spell/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_SPELL_SET_ROBELESS])
		requires_wizard_garb = FALSE
		return
	if(href_list[VV_HK_SPELL_UNSET_ROBELESS])
		requires_wizard_garb = TRUE
		return

	if(href_list[VV_HK_SPELL_UNSET_HUMANONLY])
		requires_human = FALSE
		return
	if(href_list[VV_HK_SPELL_SET_HUMANONLY])
		requires_human = TRUE
		return

	if(href_list[VV_HK_SPELL_UNSET_NONABSTRACT])
		requires_non_abstract = FALSE
		return
	if(href_list[VV_HK_SPELL_SET_NONABSTRACT])
		requires_non_abstract = TRUE
		return
