/datum/action/cooldown/bloodsucker
	name = "Vampiric Gift"
	desc = "A vampiric gift."
	//This is the FILE for the background icon
	button_icon = 'icons/mob/actions/actions_bloodsucker.dmi'
	//This is the ICON_STATE for the background icon
	background_icon_state = "vamp_power_off"
	active_background_icon_state = "vamp_power_on"
	background_icon = 'icons/mob/actions/actions_bloodsucker.dmi'
	button_icon_state = "power_feed"
	buttontooltipstyle = "cult"

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
	var/purchase_flags = NONE // BLOODSUCKER_CAN_BUY|TREMERE_CAN_BUY|VASSAL_CAN_BUY|HUNTER_CAN_BUY

	// VARS //
	/// If the Power is currently active.
	var/active = FALSE
	/// Cooldown you'll have to wait between each use, decreases depending on level.
	var/cooldown = 2 SECONDS
	///Can increase to yield new abilities - Each Power ranks up each Rank
	var/level_current = 0
	///The cost to ACTIVATE this Power
	var/bloodcost = 0
	///The cost to MAINTAIN this Power - Only used for Constant Cost Powers
	var/constant_bloodcost = 0

// Modify description to add cost.
/datum/action/cooldown/bloodsucker/New(Target)
	. = ..()
	cooldown_time = cooldown
	UpdateDesc()

/datum/action/cooldown/bloodsucker/proc/UpdateDesc()
	desc = initial(desc)
	if(bloodcost > 0)
		desc += "<br><br><b>COST:</b> [bloodcost] Blood"
	if(constant_bloodcost > 0)
		desc += "<br><br><b>CONSTANT COST:</b><i> [name] costs [constant_bloodcost] Blood maintain active.</i>"
	if(power_flags & BP_AM_SINGLEUSE)
		desc += "<br><br><b>SINGLE USE:</br><i> [name] can only be used once per night.</i>"
	if(level_current > 0)
		desc += "<br><br><b>LEVEL:</b><i> [name] is currently level [level_current].</i>"

/datum/action/cooldown/bloodsucker/Destroy()
	bloodsuckerdatum_power = null
	return ..()

/datum/action/cooldown/bloodsucker/IsAvailable()
	return TRUE

/datum/action/cooldown/bloodsucker/Grant(mob/user)
	. = ..()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(owner)
	if(bloodsuckerdatum)
		bloodsuckerdatum_power = bloodsuckerdatum

//This is when we CLICK on the ability Icon, not USING.
/datum/action/cooldown/bloodsucker/Trigger(trigger_flags)
	if(active && CheckCanDeactivate()) // Active? DEACTIVATE AND END!
		DeactivatePower()
		return FALSE
	if(!CheckCanPayCost() || !CheckCanUse(owner))
		return FALSE
	PayCost()
	ActivatePower()
	if(power_flags & BP_AM_SINGLEUSE)
		RemoveAfterUse()
		return TRUE
	if(!(power_flags & BP_AM_TOGGLE) || !active)
		StartCooldown() // Must come AFTER UpdateButtonIcon(), otherwise icon will revert!
	return TRUE

/datum/action/cooldown/bloodsucker/IsAvailable()
	CheckCanUse(owner, TRUE)

/datum/action/cooldown/bloodsucker/proc/CheckCanPayCost(silent = FALSE)
	if(!owner || !owner.mind)
		return FALSE
	// Cooldown?
	if(!next_use_time <= world.time)
		to_chat(owner, span_warning("[src] on cooldown!"))
		return FALSE
	// Have enough blood? Bloodsuckers in a Frenzy don't need to pay them
	var/mob/living/user = owner
	if(bloodsuckerdatum_power?.frenzied)
		return TRUE
	if(user.blood_volume < bloodcost)
		to_chat(owner, span_warning("You need at least [bloodcost] blood to activate [name]"))
		return FALSE
	return TRUE

///Checks if the Power is available to use.
/datum/action/cooldown/bloodsucker/proc/CheckCanUse(mob/living/carbon/user, silent = FALSE)
	if(!owner)
		return FALSE
	if(!isliving(user))
		return FALSE
	// Torpor?
	if((check_flags & BP_CANT_USE_IN_TORPOR) && HAS_TRAIT(user, TRAIT_NODEATH))
		if(!silent)
			to_chat(user, span_warning("Not while you're in Torpor."))
		return FALSE
	// Frenzy?
	if((check_flags & BP_CANT_USE_IN_FRENZY) && (bloodsuckerdatum_power?.frenzied))
		if(!silent)
			to_chat(user, span_warning("You cannot use powers while in a Frenzy!"))
		return FALSE
	// Stake?
	if((check_flags & BP_CANT_USE_WHILE_STAKED) && user.AmStaked())
		if(!silent)
			to_chat(user, span_warning("You have a stake in your chest! Your powers are useless."))
		return FALSE
	// Conscious? -- We use our own (AB_CHECK_CONSCIOUS) here so we can control it more, like the error message.
	if((check_flags & BP_CANT_USE_WHILE_UNCONSCIOUS) && user.stat != CONSCIOUS)
		if(!silent)
			to_chat(user, span_warning("You can't do this while you are unconcious!"))
		return FALSE
	// Incapacitated?
	if((check_flags & BP_CANT_USE_WHILE_INCAPACITATED) && (user.incapacitated(ignore_restraints = TRUE, ignore_grab = TRUE)))
		if(!silent)
			to_chat(user, span_warning("Not while you're incapacitated!"))
		return FALSE
	// Constant Cost (out of blood)
	if(constant_bloodcost > 0 && user.blood_volume <= 0)
		if(!silent)
			to_chat(user, span_warning("You don't have the blood to upkeep [src]."))
		return FALSE
	return TRUE

/// NOTE: With this formula, you'll hit half cooldown at level 8 for that power.
/datum/action/cooldown/bloodsucker/StartCooldown()
	// Calculate Cooldown (by power's level)
	var/this_cooldown
	if(!power_flags & BP_AM_STATIC_COOLDOWN)
		this_cooldown = max(initial(cooldown) / 2, initial(cooldown) - (initial(cooldown) / 16 * (level_current-1)))

	. = ..()

/datum/action/cooldown/bloodsucker/proc/CheckCanDeactivate()
	return TRUE

/datum/action/cooldown/bloodsucker/proc/PayCost()
	// Bloodsuckers in a Frenzy don't have enough Blood to pay it, so just don't.
	if(bloodsuckerdatum_power?.frenzied)
		return
	var/mob/living/carbon/human/user = owner
	user.blood_volume -= bloodcost
	bloodsuckerdatum_power?.update_hud()

/datum/action/cooldown/bloodsucker/proc/ActivatePower()
	active = TRUE
	if(power_flags & BP_AM_TOGGLE)
		RegisterSignal(owner, COMSIG_LIVING_BIOLOGICAL_LIFE, .proc/UsePower)
	owner.log_message("used [src].", LOG_ATTACK, color="red")

/datum/action/cooldown/bloodsucker/proc/DeactivatePower()
	if(power_flags & BP_AM_TOGGLE)
		UnregisterSignal(owner, COMSIG_LIVING_BIOLOGICAL_LIFE)
	active = FALSE
	StartCooldown()

///Used by powers that are continuously active (That have BP_AM_TOGGLE flag)
/datum/action/cooldown/bloodsucker/proc/UsePower(mob/living/user)
	if(!active) // Power isn't active? Then stop here, so we dont keep looping UsePower for a non existent Power.
		return FALSE
	if(!ContinueActive(user)) // We can't afford the Power? Deactivate it.
		DeactivatePower()
		return FALSE
	// We can keep this up (For now), so Pay Cost!
	if(!(power_flags & BP_AM_COSTLESS_UNCONSCIOUS) && user.stat != CONSCIOUS)
		bloodsuckerdatum_power?.AddBloodVolume(-constant_bloodcost)
	return TRUE

/// Checks to make sure this power can stay active
/datum/action/cooldown/bloodsucker/proc/ContinueActive(mob/living/user, mob/living/target)
	if(!active)
		return FALSE
	if(!user)
		return FALSE
	if(!constant_bloodcost > 0 || user.blood_volume > 0)
		return TRUE

/// Used to unlearn Single-Use Powers
/datum/action/cooldown/bloodsucker/proc/RemoveAfterUse()
	bloodsuckerdatum_power?.powers -= src
	Remove(owner)
