/**
 * # Action system
 *
 * A simple base for an modular behavior attached to atom or datum.
 */
/datum/action
	/// The name of the action
	var/name = "Generic Action"
	/// The description of what the action does
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
	/// The style the button's tooltips appear to be
	var/buttontooltipstyle = ""
	/// Whether the button becomes transparent when it can't be used or just reddened
	var/transparent_when_unavailable = TRUE
	/// This is the file for the BACKGROUND icon of the button
	var/button_icon = 'icons/mob/actions/backgrounds.dmi'
	/// This is the icon state state for the BACKGROUND icon of the button
	var/background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND
	/// This is the file for the icon that appears OVER the button background
	var/icon_icon = 'icons/hud/actions.dmi'
	/// This is the icon state for the icon that appears OVER the button background
	var/button_icon_state = "default"
	var/button_overlay_state
	///List of all mobs that are viewing our action button -> A unique movable for them to view.
	var/list/viewers = list()

/datum/action/New(Target)
	link_to(Target)

/// Links the passed target to our action, registering any relevant signals
/datum/action/proc/link_to(Target)
	target = Target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/clear_ref, override = TRUE)

	if(isatom(target))
		RegisterSignal(target, COMSIG_ATOM_UPDATED_ICON, .proc/update_icon_on_signal)

	if(istype(target, /datum/mind))
		RegisterSignal(target, COMSIG_MIND_TRANSFERRED, .proc/on_target_mind_swapped)

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
	owner = grant_to
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, .proc/clear_ref, override = TRUE)

	// Register some signals based on our check_flags
	// so that our button icon updates when relevant
	if(check_flags & AB_CHECK_CONSCIOUS)
		RegisterSignal(owner, COMSIG_MOB_STATCHANGE, .proc/update_icon_on_signal)
	if(check_flags & AB_CHECK_IMMOBILE)
		RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED), .proc/update_icon_on_signal)
	if(check_flags & AB_CHECK_HANDS_BLOCKED)
		RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), .proc/update_icon_on_signal)
	if(check_flags & AB_CHECK_LYING)
		RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, .proc/update_icon_on_signal)

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
		UnregisterSignal(owner, COMSIG_PARENT_QDELETING)

		// Clean up our check_flag signals
		UnregisterSignal(owner, list(
			COMSIG_LIVING_SET_BODY_POSITION,
			COMSIG_MOB_STATCHANGE,
			SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED),
			SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED),
		))

		if(target == owner)
			RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/clear_ref)
		owner = null

/// Actually triggers the effects of the action.
/// Called when the on-screen button is clicked, for example.
/datum/action/proc/Trigger(trigger_flags)
	if(!IsAvailable())
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	return TRUE

/// Whether our action is currently available to use or not
/datum/action/proc/IsAvailable()
	if(!owner)
		return FALSE
	if((check_flags & AB_CHECK_HANDS_BLOCKED) && HAS_TRAIT(owner, TRAIT_HANDS_BLOCKED))
		return FALSE
	if((check_flags & AB_CHECK_IMMOBILE) && HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		return FALSE
	if((check_flags & AB_CHECK_LYING) && isliving(owner))
		var/mob/living/action_user = owner
		if(action_user.body_position == LYING_DOWN)
			return FALSE
	if((check_flags & AB_CHECK_CONSCIOUS) && owner.stat != CONSCIOUS)
		return FALSE
	return TRUE

/datum/action/proc/UpdateButtons(status_only, force)
	for(var/datum/hud/hud in viewers)
		var/atom/movable/screen/movable/button = viewers[hud]
		UpdateButton(button, status_only, force)

/datum/action/proc/UpdateButton(atom/movable/screen/movable/action_button/button, status_only = FALSE, force = FALSE)
	if(!button)
		return
	if(!status_only)
		button.name = name
		button.desc = desc
		if(owner?.hud_used && background_icon_state == ACTION_BUTTON_DEFAULT_BACKGROUND)
			var/list/settings = owner.hud_used.get_action_buttons_icons()
			if(button.icon != settings["bg_icon"])
				button.icon = settings["bg_icon"]
			if(button.icon_state != settings["bg_state"])
				button.icon_state = settings["bg_state"]
		else
			if(button.icon != button_icon)
				button.icon = button_icon
			if(button.icon_state != background_icon_state)
				button.icon_state = background_icon_state

		ApplyIcon(button, force)

	if(button_overlay_state)
		button.cut_overlay(button.button_overlay)
		button.button_overlay = mutable_appearance(icon = 'icons/hud/actions.dmi', icon_state = button_overlay_state)
		button.add_overlay(button.button_overlay)

	var/available = IsAvailable()
	if(available)
		button.color = rgb(255,255,255,255)
	else
		button.color = transparent_when_unavailable ? rgb(128,0,0,128) : rgb(128,0,0)
	return available

/// Applies our button icon over top the background icon of the action
/datum/action/proc/ApplyIcon(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(icon_icon && button_icon_state && ((current_button.button_icon_state != button_icon_state) || force))
		current_button.cut_overlays(TRUE)
		current_button.add_overlay(mutable_appearance(icon_icon, button_icon_state))
		current_button.button_icon_state = button_icon_state

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

	var/atom/movable/screen/movable/action_button/button = CreateButton()
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
/datum/action/proc/CreateButton()
	var/atom/movable/screen/movable/action_button/button = new()
	button.linked_action = src
	button.name = name
	button.actiontooltipstyle = buttontooltipstyle
	if(desc)
		button.desc = desc
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

/// A general use signal proc that reacts to an event and updates our button icon in accordance
/datum/action/proc/update_icon_on_signal(datum/source)
	SIGNAL_HANDLER

	UpdateButtons()

/// Signal proc for COMSIG_MIND_TRANSFERRED - for minds, transfers our action to our new mob on mind transfer
/datum/action/proc/on_target_mind_swapped(datum/mind/source, mob/old_current)
	SIGNAL_HANDLER

	// Grant() calls Remove() from the existing owner so we're covered on that
	Grant(source.current)
