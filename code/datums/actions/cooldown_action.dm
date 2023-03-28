#define COOLDOWN_NO_DISPLAY_TIME (180 SECONDS)

/// Preset for an action that has a cooldown.
/datum/action/cooldown
	check_flags = NONE
	transparent_when_unavailable = FALSE

	/// The actual next time this ability can be used
	var/next_use_time = 0
	/// The stat panel this action shows up in the stat panel in. If null, will not show up.
	var/panel
	/// The default cooldown applied when StartCooldown() is called
	var/cooldown_time = 0
	/// The default melee cooldown applied after the ability ends
	var/melee_cooldown_time
	/// The actual next time the owner of this action can melee
	var/next_melee_use_time = 0
	/// Whether or not you want the cooldown for the ability to display in text form
	var/text_cooldown = TRUE
	/// Significant figures to round cooldown to
	var/cooldown_rounding = 0.1
	/// Shares cooldowns with other abiliies, bitflag
	var/shared_cooldown
	/// List of prerequisite actions that are used in this sequenced ability, you cannot put other sequenced abilities in this
	var/list/sequence_actions
	/// List of prerequisite actions that have been initialized
	var/list/initialized_actions

	// These are only used for click_to_activate actions
	/// Setting for intercepting clicks before activating the ability
	var/click_to_activate = FALSE
	/// The cooldown added onto the user's next click.
	var/click_cd_override = CLICK_CD_CLICK_ABILITY
	/// If TRUE, we will unset after using our click intercept.
	var/unset_after_click = TRUE
	/// What icon to replace our mouse cursor with when active. Optional
	var/ranged_mousepointer
	/// The base icon_state of this action's background
	var/base_background_icon_state
	/// The icon state the background uses when active
	var/active_background_icon_state
	/// The base icon_state of the overlay we apply
	var/base_overlay_icon_state
	/// The active icon_state of the overlay we apply
	var/active_overlay_icon_state
	/// The base icon state of the spell's button icon, used for editing the icon "off"
	var/base_icon_state
	/// The active icon state of the spell's button icon, used for editing the icon "on"
	var/active_icon_state

/datum/action/cooldown/New(Target, original = TRUE)
	. = ..()
	if(active_background_icon_state)
		base_background_icon_state ||= background_icon_state
	if(active_overlay_icon_state)
		base_overlay_icon_state ||= overlay_icon_state
	if(active_icon_state)
		base_icon_state ||= button_icon_state

	if(isnull(melee_cooldown_time))
		melee_cooldown_time = cooldown_time

	if(original)
		create_sequence_actions()

/datum/action/cooldown/create_button()
	var/atom/movable/screen/movable/action_button/button = ..()
	button.maptext = ""
	button.maptext_x = 6
	button.maptext_y = 2
	button.maptext_width = 24
	button.maptext_height = 12
	return button

/datum/action/cooldown/update_button_status(atom/movable/screen/movable/action_button/button, force = FALSE)
	. = ..()
	var/time_left = max(next_use_time - world.time, 0)
	if(!text_cooldown || !owner || time_left == 0 || time_left >= COOLDOWN_NO_DISPLAY_TIME)
		button.maptext = ""
	else
		if (cooldown_rounding > 0)
			button.maptext = MAPTEXT("<b>[round(time_left/10, cooldown_rounding)]</b>")
		else
			button.maptext = MAPTEXT("<b>[round(time_left/10)]</b>")

	if(!IsAvailable() || !is_action_active(button))
		return
	// If we don't change the icon state, or don't apply a special overlay,
	if(active_background_icon_state || active_icon_state || active_overlay_icon_state)
		return
	// ...we need to show it's active somehow. So, make it greeeen
	button.color = COLOR_GREEN

/datum/action/cooldown/apply_button_background(atom/movable/screen/movable/action_button/current_button, force)
	if(active_background_icon_state)
		background_icon_state = is_action_active(current_button) ? active_background_icon_state : base_background_icon_state
	return ..()

/datum/action/cooldown/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force)
	if(active_icon_state)
		button_icon_state = is_action_active(current_button) ? active_icon_state : base_icon_state
	return ..()

/datum/action/cooldown/apply_button_overlay(atom/movable/screen/movable/action_button/current_button, force)
	if(active_overlay_icon_state)
		overlay_icon_state = is_action_active(current_button) ? active_overlay_icon_state : base_overlay_icon_state
	return ..()

/datum/action/cooldown/is_action_active(atom/movable/screen/movable/action_button/current_button)
	return click_to_activate && current_button.our_hud?.mymob?.click_intercept == src

/datum/action/cooldown/Destroy()
	QDEL_LIST(initialized_actions)
	return ..()

/datum/action/cooldown/Grant(mob/granted_to)
	. = ..()
	if(!owner)
		return
	build_all_button_icons()
	if(next_use_time > world.time)
		START_PROCESSING(SSfastprocess, src)
	RegisterSignal(granted_to, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(handle_melee_attack))
	for(var/datum/action/cooldown/ability as anything in initialized_actions)
		ability.Grant(granted_to)

/datum/action/cooldown/Remove(mob/removed_from)
	UnregisterSignal(removed_from, COMSIG_HOSTILE_PRE_ATTACKINGTARGET)
	if(click_to_activate && removed_from.click_intercept == src)
		unset_click_ability(removed_from, refund_cooldown = FALSE)
	for(var/datum/action/cooldown/ability as anything in initialized_actions)
		ability.Remove(removed_from)
	return ..()

/datum/action/cooldown/IsAvailable(feedback = FALSE)
	return ..() && (next_use_time <= world.time)

/// Initializes any sequence actions
/datum/action/cooldown/proc/create_sequence_actions()
	if(!LAZYLEN(sequence_actions))
		return
	// remove existing actions if any
	QDEL_LIST(initialized_actions)
	initialized_actions = list()
	for(var/type_path in sequence_actions)
		var/datum/action/cooldown/ability = new type_path(target, original = FALSE)
		// prevents clients from using the individual abilities in sequences (this stops it from being added to mob actions when granted as well)
		ability.owner_has_control = FALSE
		// [ability] = delay
		initialized_actions[ability] = sequence_actions[type_path]

/// Starts a cooldown time to be shared with similar abilities
/// Will use default cooldown time if an override is not specified
/datum/action/cooldown/proc/StartCooldown(override_cooldown_time, override_melee_cooldown_time)
	// "Shared cooldowns" covers actions which are not the same type,
	// but have the same cooldown group and are on the same mob
	if(shared_cooldown)
		StartCooldownOthers(override_cooldown_time)

	StartCooldownSelf(override_cooldown_time)

	if(isnum(override_melee_cooldown_time))
		next_melee_use_time = world.time + override_melee_cooldown_time
	else
		next_melee_use_time = world.time + melee_cooldown_time

/// Starts a cooldown time for this ability only
/// Will use default cooldown time if an override is not specified
/datum/action/cooldown/proc/StartCooldownSelf(override_cooldown_time)
	if(isnum(override_cooldown_time))
		next_use_time = world.time + override_cooldown_time
	else
		next_use_time = world.time + cooldown_time
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	START_PROCESSING(SSfastprocess, src)

/// Starts a cooldown time for other abilities that share a cooldown with this. Has some niche usage with more complicated attack ai!
/// Will use default cooldown time if an override is not specified
/datum/action/cooldown/proc/StartCooldownOthers(override_cooldown_time)
	for(var/datum/action/cooldown/shared_ability in owner.actions - src)
		if(!(shared_cooldown & shared_ability.shared_cooldown))
			continue
		if(isnum(override_cooldown_time))
			shared_ability.StartCooldownSelf(override_cooldown_time)
		else
			shared_ability.StartCooldownSelf(cooldown_time)

/datum/action/cooldown/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	if(!owner)
		return FALSE

	var/mob/user = usr || owner

	// If our cooldown action is a click_to_activate action:
	// The actual action is activated on whatever the user clicks on -
	// the target is what the action is being used on
	// In trigger, we handle setting the click intercept
	if(click_to_activate)
		if(target)
			// For automatic / mob handling
			return InterceptClickOn(user, null, target)

		var/datum/action/cooldown/already_set = user.click_intercept
		if(already_set == src)
			// if we clicked ourself and we're already set, unset and return
			return unset_click_ability(user, refund_cooldown = TRUE)

		else if(istype(already_set))
			// if we have an active set already, unset it before we set our's
			already_set.unset_click_ability(user, refund_cooldown = TRUE)

		return set_click_ability(user)

	// If our cooldown action is not a click_to_activate action:
	// We can just continue on and use the action
	// the target is the user of the action (often, the owner)
	return PreActivate(user)

/// Intercepts client owner clicks to activate the ability
/datum/action/cooldown/proc/InterceptClickOn(mob/living/caller, params, atom/target)
	if(!IsAvailable(feedback = TRUE))
		return FALSE
	if(!target)
		return FALSE
	// The actual action begins here
	if(!PreActivate(target))
		return FALSE

	// And if we reach here, the action was complete successfully
	if(unset_after_click)
		unset_click_ability(caller, refund_cooldown = FALSE)
	caller.next_click = world.time + click_cd_override

	return TRUE

/// For signal calling
/datum/action/cooldown/proc/PreActivate(atom/target)
	if(SEND_SIGNAL(owner, COMSIG_MOB_ABILITY_STARTED, src) & COMPONENT_BLOCK_ABILITY_START)
		return
	// Note, that PreActivate handles no cooldowns at all by default.
	// Be sure to call StartCooldown() in Activate() where necessary.
	. = Activate(target)
	// There is a possibility our action (or owner) is qdeleted in Activate().
	if(!QDELETED(src) && !QDELETED(owner))
		SEND_SIGNAL(owner, COMSIG_MOB_ABILITY_FINISHED, src)

/// To be implemented by subtypes (if not generic)
/datum/action/cooldown/proc/Activate(atom/target)
	var/total_delay = 0
	for(var/datum/action/cooldown/ability as anything in initialized_actions)
		if(LAZYLEN(ability.initialized_actions) > 0)
			ability.initialized_actions = list()
		addtimer(CALLBACK(ability, PROC_REF(Activate), target), total_delay)
		total_delay += initialized_actions[ability]
	StartCooldown()

/// Cancels melee attacks if they are on cooldown.
/datum/action/cooldown/proc/handle_melee_attack(mob/source, mob/target)
	SIGNAL_HANDLER
	if(next_melee_use_time > world.time)
		return COMPONENT_HOSTILE_NO_ATTACK

/datum/action/cooldown/process()
	if(!owner || (next_use_time - world.time) <= 0)
		build_all_button_icons(UPDATE_BUTTON_STATUS)
		STOP_PROCESSING(SSfastprocess, src)
		return

	build_all_button_icons(UPDATE_BUTTON_STATUS)

/**
 * Set our action as the click override on the passed mob.
 */
/datum/action/cooldown/proc/set_click_ability(mob/on_who)
	SHOULD_CALL_PARENT(TRUE)

	on_who.click_intercept = src
	if(ranged_mousepointer)
		on_who.client?.mouse_override_icon = ranged_mousepointer
		on_who.update_mouse_pointer()
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	return TRUE

/**
 * Unset our action as the click override of the passed mob.
 *
 * if refund_cooldown is TRUE, we are being unset by the user clicking the action off
 * if refund_cooldown is FALSE, we are being forcefully unset, likely by someone actually using the action
 */
/datum/action/cooldown/proc/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	on_who.click_intercept = null
	if(ranged_mousepointer)
		on_who.client?.mouse_override_icon = initial(on_who.client?.mouse_override_icon)
		on_who.update_mouse_pointer()
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	return TRUE

/// Formats the action to be returned to the stat panel.
/datum/action/cooldown/proc/set_statpanel_format()
	if(!panel)
		return null

	var/time_remaining = max(next_use_time - world.time, 0)
	var/time_remaining_in_seconds = round(time_remaining / 10, 0.1)
	var/cooldown_time_in_seconds =  round(cooldown_time / 10, 0.1)

	var/list/stat_panel_data = list()

	// Pass on what panel we should be displayed in.
	stat_panel_data[PANEL_DISPLAY_PANEL] = panel
	// Also pass on the name of the spell, with some spacing
	stat_panel_data[PANEL_DISPLAY_NAME] = " - [name]"

	// No cooldown time at all, just show the ability
	if(cooldown_time_in_seconds <= 0)
		stat_panel_data[PANEL_DISPLAY_STATUS] = ""

	// It's a toggle-active ability, show if it's active
	else if(click_to_activate && owner.click_intercept == src)
		stat_panel_data[PANEL_DISPLAY_STATUS] = "ACTIVE"

	// It's on cooldown, show the cooldown
	else if(time_remaining_in_seconds > 0)
		stat_panel_data[PANEL_DISPLAY_STATUS] = "CD - [time_remaining_in_seconds]s / [cooldown_time_in_seconds]s"

	// It's not on cooldown, show that it is ready
	else
		stat_panel_data[PANEL_DISPLAY_STATUS] = "READY"

	SEND_SIGNAL(src, COMSIG_ACTION_SET_STATPANEL, stat_panel_data)

	return stat_panel_data
