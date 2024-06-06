/datum/action/cooldown/bloodsucker
	name = "Vampiric Gift"
	desc = "A vampiric gift."
	background_icon = 'monkestation/icons/bloodsuckers/actions_bloodsucker.dmi'
	background_icon_state = "vamp_power_off"
	button_icon = 'monkestation/icons/bloodsuckers/actions_bloodsucker.dmi'
	button_icon_state = "power_feed"
	buttontooltipstyle = "cult"
	transparent_when_unavailable = TRUE

	/// Cooldown you'll have to wait between each use, decreases depending on level.
	cooldown_time = 2 SECONDS

	///Background icon when the Power is active.
	active_background_icon_state = "vamp_power_on"
	///Background icon when the Power is NOT active.
	base_background_icon_state = "vamp_power_off"

	/// The text that appears when using the help verb, meant to explain how the Power changes when ranking up.
	var/power_explanation = ""
	///The owner's stored Bloodsucker datum
	var/datum/antagonist/bloodsucker/bloodsuckerdatum_power

	// FLAGS //
	/// The effects on this Power (Toggled/Single Use/Static Cooldown)
	var/power_flags = BP_AM_TOGGLE|BP_AM_SINGLEUSE|BP_AM_STATIC_COOLDOWN|BP_AM_COSTLESS_UNCONSCIOUS
	/// Requirement flags for checks
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_STAKED|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	/// Who can purchase the Power
	var/purchase_flags = NONE // BLOODSUCKER_CAN_BUY|BLOODSUCKER_DEFAULT_POWER|TREMERE_CAN_BUY|VASSAL_CAN_BUY

	// VARS //
	/// If the Power is currently active, differs from action cooldown because of how powers are handled.
	var/active = FALSE
	///Can increase to yield new abilities - Each Power ranks up each Rank
	var/level_current = 0
	///The cost to ACTIVATE this Power
	var/bloodcost = 0
	///The cost to MAINTAIN this Power - Only used for Constant Cost Powers
	var/constant_bloodcost = 0

// Modify description to add cost.
/datum/action/cooldown/bloodsucker/New(Target)
	. = ..()
	if(bloodcost > 0)
		desc += "<br><br><b>COST:</b> [bloodcost] Blood"
	if(constant_bloodcost > 0)
		desc += "<br><br><b>CONSTANT COST:</b><i> [name] costs [constant_bloodcost] Blood maintain active.</i>"
	if(power_flags & BP_AM_SINGLEUSE)
		desc += "<br><br><b>SINGLE USE:</br><i> [name] can only be used once per night.</i>"

/datum/action/cooldown/bloodsucker/Destroy()
	bloodsuckerdatum_power = null
	return ..()

/datum/action/cooldown/bloodsucker/IsAvailable(feedback = FALSE)
	return COOLDOWN_FINISHED(src, next_use_time)

/datum/action/cooldown/bloodsucker/Grant(mob/user)
	. = ..()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(owner)
	if(bloodsuckerdatum)
		bloodsuckerdatum_power = bloodsuckerdatum

//This is when we CLICK on the ability Icon, not USING.
/datum/action/cooldown/bloodsucker/Trigger(trigger_flags, atom/target)
	if(active && can_deactivate()) // Active? DEACTIVATE AND END!
		DeactivatePower()
		return FALSE
	if(!can_pay_cost() || !can_use(owner, trigger_flags))
		return FALSE
	pay_cost()
	ActivatePower(trigger_flags)
	if(!(power_flags & BP_AM_TOGGLE) || !active)
		StartCooldown()
	return TRUE

/datum/action/cooldown/bloodsucker/proc/can_pay_cost()
	if(QDELETED(owner) || QDELETED(owner.mind))
		return FALSE
	// Cooldown?
	if(!COOLDOWN_FINISHED(src, next_use_time))
		owner.balloon_alert(owner, "power unavailable!")
		return FALSE
	if(!bloodsuckerdatum_power)
		var/mob/living/living_owner = owner
		if(!HAS_TRAIT(living_owner, TRAIT_NOBLOOD) && living_owner.blood_volume < bloodcost)
			to_chat(owner, span_warning("You need at least [bloodcost] blood to activate [name]"))
			return FALSE
		return TRUE

	// Have enough blood? Bloodsuckers in a Frenzy don't need to pay them
	if(bloodsuckerdatum_power.frenzied)
		return TRUE
	if(bloodsuckerdatum_power.bloodsucker_blood_volume < bloodcost)
		to_chat(owner, span_warning("You need at least [bloodcost] blood to activate [name]"))
		return FALSE
	return TRUE

///Called when the Power is upgraded.
/datum/action/cooldown/bloodsucker/proc/upgrade_power()
	level_current++

///Checks if the Power is available to use.
/datum/action/cooldown/bloodsucker/proc/can_use(mob/living/carbon/user, trigger_flags)
	if(!owner)
		return FALSE
	if(!isliving(user))
		return FALSE
	// Torpor?
	if((check_flags & BP_CANT_USE_IN_TORPOR) && HAS_TRAIT_FROM(user, TRAIT_NODEATH, TORPOR_TRAIT))
		to_chat(user, span_warning("Not while you're in Torpor."))
		return FALSE
	// Frenzy?
	if((check_flags & BP_CANT_USE_IN_FRENZY) && (bloodsuckerdatum_power?.frenzied))
		to_chat(user, span_warning("You cannot use powers while in a Frenzy!"))
		return FALSE
	// Stake?
	if((check_flags & BP_CANT_USE_WHILE_STAKED) && user.am_staked())
		to_chat(user, span_warning("You have a stake in your chest! Your powers are useless."))
		return FALSE
	// Conscious? -- We use our own (AB_CHECK_CONSCIOUS) here so we can control it more, like the error message.
	if((check_flags & BP_CANT_USE_WHILE_UNCONSCIOUS) && user.stat != CONSCIOUS)
		to_chat(user, span_warning("You can't do this while you are unconcious!"))
		return FALSE
	// Incapacitated?
	if((check_flags & BP_CANT_USE_WHILE_INCAPACITATED) && (user.incapacitated(IGNORE_RESTRAINTS, IGNORE_GRAB)))
		to_chat(user, span_warning("Not while you're incapacitated!"))
		return FALSE
	// Constant Cost (out of blood)
	if(constant_bloodcost > 0 && bloodsuckerdatum_power?.bloodsucker_blood_volume <= 0)
		to_chat(user, span_warning("You don't have the blood to upkeep [src]."))
		return FALSE
	return TRUE

/// NOTE: With this formula, you'll hit half cooldown at level 8 for that power.
/datum/action/cooldown/bloodsucker/StartCooldown()
	// Calculate Cooldown (by power's level)
	if(power_flags & BP_AM_STATIC_COOLDOWN)
		cooldown_time = initial(cooldown_time)
	else
		cooldown_time = max(initial(cooldown_time) / 2, initial(cooldown_time) - (initial(cooldown_time) / 16 * (level_current-1)))

	return ..()

/datum/action/cooldown/bloodsucker/proc/can_deactivate()
	return TRUE

/datum/action/cooldown/bloodsucker/is_action_active()
	return active

/datum/action/cooldown/bloodsucker/proc/pay_cost()
	// Non-bloodsuckers will pay in other ways.
	if(!bloodsuckerdatum_power)
		var/mob/living/living_owner = owner
		if(!HAS_TRAIT(living_owner, TRAIT_NOBLOOD))
			living_owner.blood_volume -= bloodcost
		return
	// Bloodsuckers in a Frenzy don't have enough Blood to pay it, so just don't.
	if(bloodsuckerdatum_power.frenzied)
		return
	bloodsuckerdatum_power.bloodsucker_blood_volume -= bloodcost
	bloodsuckerdatum_power.update_hud()

/datum/action/cooldown/bloodsucker/proc/ActivatePower(trigger_flags)
	active = TRUE
	if(power_flags & BP_AM_TOGGLE)
		START_PROCESSING(SSprocessing, src)

	owner.log_message("used [src][bloodcost != 0 ? " at the cost of [bloodcost]" : ""].", LOG_ATTACK, color="red")
	build_all_button_icons()

/datum/action/cooldown/bloodsucker/proc/DeactivatePower()
	if(!active) //Already inactive? Return
		return
	if(power_flags & BP_AM_TOGGLE)
		STOP_PROCESSING(SSprocessing, src)
	if(power_flags & BP_AM_SINGLEUSE)
		remove_after_use()
		return
	active = FALSE
	StartCooldown()
	build_all_button_icons()

///Used by powers that are continuously active (That have BP_AM_TOGGLE flag)
/datum/action/cooldown/bloodsucker/process(seconds_per_tick)
	SHOULD_CALL_PARENT(TRUE) //Need this to call parent so the cooldown system works
	. = ..()
	if(!active) // if we're not active anyways, then we shouldn't be processing!!!
		return PROCESS_KILL
	if(!ContinueActive(owner)) // We can't afford the Power? Deactivate it.
		DeactivatePower()
		return PROCESS_KILL
	// We can keep this up (For now), so Pay Cost!
	if(!(power_flags & BP_AM_COSTLESS_UNCONSCIOUS) && owner.stat != CONSCIOUS)
		if(bloodsuckerdatum_power)
			bloodsuckerdatum_power.AddBloodVolume(-constant_bloodcost)
		else
			var/mob/living/living_owner = owner
			if(!HAS_TRAIT(living_owner, TRAIT_NOBLOOD))
				living_owner.blood_volume -= constant_bloodcost
	return TRUE

/// Checks to make sure this power can stay active
/datum/action/cooldown/bloodsucker/proc/ContinueActive(mob/living/user, mob/living/target)
	if(!user)
		return FALSE
	if(!constant_bloodcost > 0 || bloodsuckerdatum_power.bloodsucker_blood_volume > 0)
		return TRUE

/// Used to unlearn Single-Use Powers
/datum/action/cooldown/bloodsucker/proc/remove_after_use()
	bloodsuckerdatum_power?.powers -= src
	Remove(owner)
