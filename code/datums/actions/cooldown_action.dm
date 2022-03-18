
//Preset for an action with a cooldown
/datum/action/cooldown
	check_flags = NONE
	transparent_when_unavailable = FALSE

	// Internal use
	/// The actual next time this ability can be used
	var/next_use_time = 0

	// Public use
	/// The default cooldown applied when StartCooldown() is called
	var/cooldown_time = 0
	/// Whether or not you want the cooldown for the ability to display in text form
	var/text_cooldown = TRUE
	/// Setting for intercepting clicks before activating the ability
	var/click_to_activate = FALSE
	/// What icon to replace our mouse cursor with when active. Optional, Requires click_to_activate
	var/ranged_mousepointer
	/// The cooldown added onto the user's next click. Requires click_to_activate
	var/click_cd_override = CLICK_CD_CLICK_ABILITY
	/// If TRUE, we will unset after using our click intercept. Requires click_to_activate
	var/unset_after_click = TRUE
	/// Shares cooldowns with other cooldown abilities of the same value, not active if null
	var/shared_cooldown

/datum/action/cooldown/New(Target)
	..()
	button.maptext = ""
	button.maptext_x = 8
	button.maptext_y = 0
	button.maptext_width = 24
	button.maptext_height = 12

/datum/action/cooldown/IsAvailable()
	return ..() && (next_use_time <= world.time)

/datum/action/cooldown/Remove(mob/living/user)
	if(click_to_activate && user.click_intercept == src)
		unset_click_ability()
	return ..()

/datum/action/cooldown/Unshare(mob/freeloader)
	// MELBERT TODO support for shared cooldown click intercepts
	return ..()

/// Starts a cooldown time to be shared with similar abilities, will use default cooldown time if an override is not specified
/datum/action/cooldown/proc/StartCooldown(override_cooldown_time)
	if(shared_cooldown)
		for(var/datum/action/cooldown/shared_ability in owner.actions - src)
			if(shared_cooldown == shared_ability.shared_cooldown)
				if(isnum(override_cooldown_time))
					shared_ability.StartCooldownSelf(override_cooldown_time)
				else
					shared_ability.StartCooldownSelf(cooldown_time)
	StartCooldownSelf(override_cooldown_time)

/// Starts a cooldown time for this ability only, will use default cooldown time if an override is not specified
/datum/action/cooldown/proc/StartCooldownSelf(override_cooldown_time)
	if(isnum(override_cooldown_time))
		next_use_time = world.time + override_cooldown_time
	else
		next_use_time = world.time + cooldown_time
	UpdateButtonIcon()
	START_PROCESSING(SSfastprocess, src)

/datum/action/cooldown/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	if(!owner)
		return FALSE
	if(click_to_activate)
		if(target)
			// For automatic / mob handling
			return InterceptClickOn(owner, null, target)
		var/click_result = FALSE
		if(owner.click_intercept == src)
			click_result = unset_click_ability()
		else
			click_result = set_click_ability()
		if(click_result)
			// We may have had another button active that's being deactivated by our own activation
			// ...So just make sure any buttons have their correct icons
			for(var/datum/action/cooldown/ability in owner.actions)
				ability.UpdateButtonIcon()
		return click_result
	return PreActivate(owner)

/// Intercepts client owner clicks to activate the ability
/datum/action/cooldown/proc/InterceptClickOn(mob/living/caller, params, atom/target)
	if(!IsAvailable())
		return FALSE
	if(!target)
		return FALSE
	// The actual spell begins here
	if(!PreActivate(target))
		return FALSE

	// And if we reach here, the spell was cast successfully
	if(unset_after_click)
		unset_click_ability()
	caller.next_click = world.time + click_cd_override

	return TRUE

/// For signal calling
/datum/action/cooldown/proc/PreActivate(atom/target)
	if(SEND_SIGNAL(owner, COMSIG_ABILITY_STARTED, src) & COMPONENT_BLOCK_ABILITY_START)
		return
	. = Activate(target)
	SEND_SIGNAL(owner, COMSIG_ABILITY_FINISHED, src)

/// To be implemented by subtypes
/datum/action/cooldown/proc/Activate(atom/target)
	return

/datum/action/cooldown/proc/set_click_ability()
	owner.click_intercept = src
	if(ranged_mousepointer)
		owner.client?.mouse_pointer_icon = ranged_mousepointer
	return TRUE

/datum/action/cooldown/proc/unset_click_ability()
	owner.click_intercept = null
	if(ranged_mousepointer)
		owner.client?.mouse_pointer_icon = initial(owner.client?.mouse_pointer_icon)
	return TRUE

/datum/action/cooldown/UpdateButtonIcon(status_only = FALSE, force = FALSE)
	. = ..()
	if(button)
		update_button_text()
		if(IsAvailable() && owner.click_intercept == src)
			button.color = COLOR_GREEN

/datum/action/cooldown/proc/update_button_text()
	var/time_left = max(next_use_time - world.time, 0)
	if(text_cooldown && time_left >= 0)
		button.maptext = MAPTEXT("<b>[round(time_left/10, 0.1)]</b>")
	else
		button.maptext = ""

/datum/action/cooldown/process()
	if(!owner || (next_use_time - world.time) <= 0)
		UpdateButtonIcon()
		STOP_PROCESSING(SSfastprocess, src)

	update_button_text()

/datum/action/cooldown/Grant(mob/M)
	. = ..()
	if(owner)
		UpdateButtonIcon()
		if(next_use_time > world.time)
			START_PROCESSING(SSfastprocess, src)
