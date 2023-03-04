/**
 * # Action system
 *
 * A simple base for an modular behavior attached to atom or datum.
 */
/datum/action
	/// The name of the action
	var/name = "Generic Action"
	/// The description of what the action does, shown in button tooltips
	var/desc
	/// The target the action is attached to. If the target datum is deleted, the action is as well.
	/// Set in New() via the proc link_to(). PLEASE set a target if you're making an action
	var/datum/target
	/// Where any buttons we create should be by default. Accepts screen_loc and location defines
	var/default_button_position = SCRN_OBJ_IN_LIST
	/// This is who currently owns the action, and most often, this is who is using the action if it is triggered
	/// This can be the same as "target" but is not ALWAYS the same - this is set and unset with Grant() and Remove()
	var/mob/owner
	/// If False, the owner of this action does not get a hud and cannot activate it on their own
	var/owner_has_control = TRUE
	/// Flags that will determine of the owner / user of the action can... use the action
	var/check_flags = NONE
	/// Whether the button becomes transparent when it can't be used, or just reddened
	var/transparent_when_unavailable = TRUE
	///List of all mobs that are viewing our action button -> A unique movable for them to view.
	var/list/viewers = list()
	/// If TRUE, this action button will be shown to observers / other mobs who view from this action's owner's eyes.
	/// Used in [/mob/proc/show_other_mob_action_buttons]
	var/show_to_observers = TRUE

	/// The style the button's tooltips appear to be
	var/buttontooltipstyle = ""

	/// This is the file for the BACKGROUND underlay icon of the button
	var/background_icon = 'icons/mob/actions/backgrounds.dmi'
	/// This is the icon state state for the BACKGROUND underlay icon of the button
	/// (If set to ACTION_BUTTON_DEFAULT_BACKGROUND, uses the hud's default background)
	var/background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND

	/// This is the file for the icon that appears on the button
	var/button_icon = 'icons/hud/actions.dmi'
	/// This is the icon state for the icon that appears on the button
	var/button_icon_state = "default"

	/// This is the file for any FOREGROUND overlay icons on the button (such as borders)
	var/overlay_icon = 'icons/mob/actions/backgrounds.dmi'
	/// This is the icon state for any FOREGROUND overlay icons on the button (such as borders)
	var/overlay_icon_state

/datum/action/New(Target)
	link_to(Target)

/// Links the passed target to our action, registering any relevant signals
/datum/action/proc/link_to(Target)
	target = Target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(clear_ref), override = TRUE)

	if(isatom(target))
		RegisterSignal(target, COMSIG_ATOM_UPDATED_ICON, PROC_REF(on_target_icon_update))

	if(istype(target, /datum/mind))
		RegisterSignal(target, COMSIG_MIND_TRANSFERRED, PROC_REF(on_target_mind_swapped))

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	target = null
	QDEL_LIST_ASSOC_VAL(viewers) // Qdel the buttons in the viewers list **NOT THE HUDS**
	return ..()

/// Signal proc that clears any references based on the owner or target deleting
/// If the owner's deleted, we will simply remove from them, but if the target's deleted, we will self-delete
/datum/action/proc/clear_ref(datum/ref)
	SIGNAL_HANDLER
	if(ref == owner)
		Remove(owner)
	if(ref == target)
		qdel(src)

/// Grants the action to the passed mob, making it the owner
/datum/action/proc/Grant(mob/grant_to)
	if(!grant_to)
		Remove(owner)
		return
	if(owner)
		if(owner == grant_to)
			return
		Remove(owner)
	SEND_SIGNAL(src, COMSIG_ACTION_GRANTED, grant_to)
	SEND_SIGNAL(grant_to, COMSIG_MOB_GRANTED_ACTION, src)
	owner = grant_to
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(clear_ref), override = TRUE)

	// Register some signals based on our check_flags
	// so that our button icon updates when relevant
	if(check_flags & AB_CHECK_CONSCIOUS)
		RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(update_status_on_signal))
	if(check_flags & AB_CHECK_INCAPACITATED)
		RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED), PROC_REF(update_status_on_signal))
	if(check_flags & AB_CHECK_IMMOBILE)
		RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED), PROC_REF(update_status_on_signal))
	if(check_flags & AB_CHECK_HANDS_BLOCKED)
		RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), PROC_REF(update_status_on_signal))
	if(check_flags & AB_CHECK_LYING)
		RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(update_status_on_signal))

	if(owner_has_control)
		GiveAction(grant_to)

/// Remove the passed mob from being owner of our action
/datum/action/proc/Remove(mob/remove_from)
	SHOULD_CALL_PARENT(TRUE)

	for(var/datum/hud/hud in viewers)
		if(!hud.mymob)
			continue
		HideFrom(hud.mymob)
	LAZYREMOVE(remove_from.actions, src) // We aren't always properly inserted into the viewers list, gotta make sure that action's cleared
	viewers = list()

	if(owner)
		SEND_SIGNAL(src, COMSIG_ACTION_REMOVED, owner)
		SEND_SIGNAL(owner, COMSIG_MOB_REMOVED_ACTION, src)
		UnregisterSignal(owner, COMSIG_PARENT_QDELETING)

		// Clean up our check_flag signals
		UnregisterSignal(owner, list(
			COMSIG_LIVING_SET_BODY_POSITION,
			COMSIG_MOB_STATCHANGE,
			SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED),
			SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED),
			SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED),
		))

		if(target == owner)
			RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(clear_ref))
		owner = null

/// Actually triggers the effects of the action.
/// Called when the on-screen button is clicked, for example.
/datum/action/proc/Trigger(trigger_flags)
	if(!IsAvailable(feedback = TRUE))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	return TRUE

/**
 * Whether our action is currently available to use or not
 * * feedback - If true this is being called to check if we have any messages to show to the owner
 */
/datum/action/proc/IsAvailable(feedback = FALSE)
	if(!owner)
		return FALSE
	if((check_flags & AB_CHECK_HANDS_BLOCKED) && HAS_TRAIT(owner, TRAIT_HANDS_BLOCKED))
		if (feedback)
			owner.balloon_alert(owner, "hands blocked!")
		return FALSE
	if((check_flags & AB_CHECK_IMMOBILE) && HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		if (feedback)
			owner.balloon_alert(owner, "can't move!")
		return FALSE
	if((check_flags & AB_CHECK_INCAPACITATED) && HAS_TRAIT(owner, TRAIT_INCAPACITATED))
		if (feedback)
			owner.balloon_alert(owner, "incapacitated!")
		return FALSE
	if((check_flags & AB_CHECK_LYING) && isliving(owner))
		var/mob/living/action_owner = owner
		if(action_owner.body_position == LYING_DOWN)
			if (feedback)
				owner.balloon_alert(owner, "must stand up!")
			return FALSE
	if((check_flags & AB_CHECK_CONSCIOUS) && owner.stat != CONSCIOUS)
		if (feedback)
			owner.balloon_alert(owner, "unconscious!")
		return FALSE
	return TRUE

/// Builds / updates all buttons we have shared or given out
/datum/action/proc/build_all_button_icons(update_flags = ALL, force)
	for(var/datum/hud/hud as anything in viewers)
		build_button_icon(viewers[hud], update_flags, force)

/**
 * Builds the icon of the button.
 *
 * Concept:
 * - Underlay (Background icon)
 * - Icon (button icon)
 * - Maptext
 * - Overlay (Background border)
 *
 * button - which button we are modifying the icon of
 * force - whether we're forcing a full update
 */
/datum/action/proc/build_button_icon(atom/movable/screen/movable/action_button/button, update_flags = ALL, force = FALSE)
	if(!button)
		return

	if(update_flags & UPDATE_BUTTON_NAME)
		update_button_name(button, force)

	if(update_flags & UPDATE_BUTTON_BACKGROUND)
		apply_button_background(button, force)

	if(update_flags & UPDATE_BUTTON_ICON)
		apply_button_icon(button, force)

	if(update_flags & UPDATE_BUTTON_OVERLAY)
		apply_button_overlay(button, force)

	if(update_flags & UPDATE_BUTTON_STATUS)
		update_button_status(button, force)

/**
 * Updates the name and description of the button to match our action name and discription.
 *
 * current_button - what button are we editing?
 * force - whether an update is forced regardless of existing status
 */
/datum/action/proc/update_button_name(atom/movable/screen/movable/action_button/button, force = FALSE)
	button.name = name
	if(desc)
		button.desc = desc

/**
 * Creates the background underlay for the button
 *
 * current_button - what button are we editing?
 * force - whether an update is forced regardless of existing status
 */
/datum/action/proc/apply_button_background(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(!background_icon || !background_icon_state || (current_button.active_underlay_icon_state == background_icon_state && !force))
		return

	// What icons we use for our background
	var/list/icon_settings = list(
		// The icon file
		"bg_icon" = background_icon,
		// The icon state, if is_action_active() returns FALSE
		"bg_state" = background_icon_state,
		// The icon state, if is_action_active() returns TRUE
		"bg_state_active" = background_icon_state,
	)

	// If background_icon_state is ACTION_BUTTON_DEFAULT_BACKGROUND instead use our hud's action button scheme
	if(background_icon_state == ACTION_BUTTON_DEFAULT_BACKGROUND && owner?.hud_used)
		icon_settings = owner.hud_used.get_action_buttons_icons()

	// Determine which icon to use
	var/used_icon_key = is_action_active(current_button) ? "bg_state_active" : "bg_state"

	// Make the underlay
	current_button.underlays.Cut()
	current_button.underlays += image(icon = icon_settings["bg_icon"], icon_state = icon_settings[used_icon_key])
	current_button.active_underlay_icon_state = icon_settings[used_icon_key]

/**
 * Applies our button icon and icon state to the button
 *
 * current_button - what button are we editing?
 * force - whether an update is forced regardless of existing status
 */
/datum/action/proc/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(!button_icon || !button_icon_state || (current_button.icon_state == button_icon_state && !force))
		return

	current_button.icon = button_icon
	current_button.icon_state = button_icon_state

/**
 * Applies any overlays to our button
 *
 * current_button - what button are we editing?
 * force - whether an update is forced regardless of existing status
 */
/datum/action/proc/apply_button_overlay(atom/movable/screen/movable/action_button/current_button, force = FALSE)

	SEND_SIGNAL(src, COMSIG_ACTION_OVERLAY_APPLY, current_button, force)

	if(!overlay_icon || !overlay_icon_state || (current_button.active_overlay_icon_state == overlay_icon_state && !force))
		return

	current_button.cut_overlay(current_button.button_overlay)
	current_button.button_overlay = mutable_appearance(icon = overlay_icon, icon_state = overlay_icon_state)
	current_button.add_overlay(current_button.button_overlay)
	current_button.active_overlay_icon_state = overlay_icon_state

/**
 * Any other miscellaneous "status" updates within the action button is handled here,
 * such as redding out when unavailable or modifying maptext.
 *
 * current_button - what button are we editing?
 * force - whether an update is forced regardless of existing status
 */
/datum/action/proc/update_button_status(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(IsAvailable())
		current_button.color = rgb(255,255,255,255)
	else
		current_button.color = transparent_when_unavailable ? rgb(128,0,0,128) : rgb(128,0,0)

/// Gives our action to the passed viewer.
/// Puts our action in their actions list and shows them the button.
/datum/action/proc/GiveAction(mob/viewer)
	var/datum/hud/our_hud = viewer.hud_used
	if(viewers[our_hud]) // Already have a copy of us? go away
		return

	LAZYOR(viewer.actions, src) // Move this in
	ShowTo(viewer)

/// Adds our action button to the screen of the passed viewer.
/datum/action/proc/ShowTo(mob/viewer)
	var/datum/hud/our_hud = viewer.hud_used
	if(!our_hud || viewers[our_hud]) // There's no point in this if you have no hud in the first place
		return

	var/atom/movable/screen/movable/action_button/button = create_button()
	SetId(button, viewer)

	button.our_hud = our_hud
	viewers[our_hud] = button
	if(viewer.client)
		viewer.client.screen += button

	button.load_position(viewer)
	viewer.update_action_buttons()

/// Removes our action from the passed viewer.
/datum/action/proc/HideFrom(mob/viewer)
	var/datum/hud/our_hud = viewer.hud_used
	var/atom/movable/screen/movable/action_button/button = viewers[our_hud]
	LAZYREMOVE(viewer.actions, src)
	if(button)
		qdel(button)

/// Creates an action button movable for the passed mob, and returns it.
/datum/action/proc/create_button()
	var/atom/movable/screen/movable/action_button/button = new()
	button.linked_action = src
	build_button_icon(button, ALL, TRUE)
	return button

/datum/action/proc/SetId(atom/movable/screen/movable/action_button/our_button, mob/owner)
	//button id generation
	var/bitfield = 0
	for(var/datum/action/action in owner.actions)
		if(action == src) // This could be us, which is dumb
			continue
		var/atom/movable/screen/movable/action_button/button = action.viewers[owner.hud_used]
		if(action.name == name && button.id)
			bitfield |= button.id

	bitfield = ~bitfield // Flip our possible ids, so we can check if we've found a unique one
	for(var/i in 0 to 23) // We get 24 possible bitflags in dm
		var/bitflag = 1 << i // Shift us over one
		if(bitfield & bitflag)
			our_button.id = bitflag
			return

/// Updates our buttons if our target's icon was updated
/datum/action/proc/on_target_icon_update(datum/source, updates, updated)
	SIGNAL_HANDLER

	var/update_flag = NONE
	var/forced = FALSE
	if(updates & UPDATE_ICON_STATE)
		update_flag |= UPDATE_BUTTON_ICON
		forced = TRUE
	if(updates & UPDATE_OVERLAYS)
		update_flag |= UPDATE_BUTTON_OVERLAY
		forced = TRUE
	if(updates & (UPDATE_NAME|UPDATE_DESC))
		update_flag |= UPDATE_BUTTON_NAME
	// Status is not relevant, and background is not relevant. Neither will change

	// Force the update if an icon state or overlay change was done
	build_all_button_icons(update_flag, forced)

/// A general use signal proc that reacts to an event and updates JUST our button's status
/datum/action/proc/update_status_on_signal(datum/source)
	SIGNAL_HANDLER

	build_all_button_icons(UPDATE_BUTTON_STATUS)

/// Signal proc for COMSIG_MIND_TRANSFERRED - for minds, transfers our action to our new mob on mind transfer
/datum/action/proc/on_target_mind_swapped(datum/mind/source, mob/old_current)
	SIGNAL_HANDLER

	// Grant() calls Remove() from the existing owner so we're covered on that
	Grant(source.current)

/// Checks if our action is actively selected. Used for selecting icons primarily.
/datum/action/proc/is_action_active(atom/movable/screen/movable/action_button/current_button)
	return FALSE
