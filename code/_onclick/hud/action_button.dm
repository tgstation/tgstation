// Todo:
// Make the palette icon state smaller
// Add green/red shimmer for add/remove to palette
// Make the palette match theme
// Add proper garbage collection
// Cry yourself to sleep over the existence of hud code
#define ACTION_BUTTON_DEFAULT_BACKGROUND "default"

/atom/movable/screen/movable/action_button
	var/datum/action/linked_action
	var/datum/hud/our_hud
	var/actiontooltipstyle = ""
	screen_loc = null

	var/button_icon_state
	var/appearance_cache

	/// Where we are currently placed on the hud. SCRN_OBJ_DEFAULT asks the linked action what it thinks
	var/location = SCRN_OBJ_DEFAULT
	/// A unique bitflag, combined with the name of our linked action this lets us persistently remember any user changes to our position
	var/id
	/// A weakref of the last thing we hovered over
	/// God I hate how dragging works
	var/datum/weakref/last_hovored_ref

/atom/movable/screen/movable/action_button/Destroy()
	var/mob/viewer = our_hud.mymob
	our_hud.hide_action(src)
	viewer?.client?.screen -= src
	linked_action.viewers -= our_hud
	viewer.update_action_buttons()
	return ..()

/atom/movable/screen/movable/action_button/proc/can_use(mob/user)
	if(linked_action)
		if(linked_action.viewers[user.hud_used])
			return TRUE
		return FALSE
	else if (isobserver(user))
		var/mob/dead/observer/O = user
		return !O.observetarget
	else
		return TRUE

/atom/movable/screen/movable/action_button/Click(location,control,params)
	if (!can_use(usr))
		return FALSE

	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		var/datum/hud/our_hud = usr.hud_used
		our_hud.position_action(src, SCRN_OBJ_DEFAULT)
		return TRUE
	if(usr.next_click > world.time)
		return
	usr.next_click = world.time + 1
	var/trigger_flags
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		trigger_flags |= TRIGGER_SECONDARY_ACTION
	linked_action.Trigger(trigger_flags = trigger_flags)
	return TRUE

// Entered and Exited won't fire while you're dragging something, because you're still "holding" it
// Very much byond logic, but I want nice behavior, so we fake it with drag
/atom/movable/screen/movable/action_button/MouseDrag(atom/over_object, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(!can_use(usr))
		return
	if(IS_WEAKREF_OF(over_object, last_hovored_ref))
		return
	var/atom/old_object
	if(last_hovored_ref)
		old_object = last_hovored_ref?.resolve()
	else // If there's no current ref, we assume it was us. We also treat this as our "first go" location
		old_object = src
		var/datum/hud/our_hud = usr.hud_used
		our_hud?.generate_landings(src)

	if(old_object)
		old_object.MouseExited(over_location, over_control, params)

	last_hovored_ref = WEAKREF(over_object)
	over_object.MouseEntered(over_location, over_control, params)

/atom/movable/screen/movable/action_button/MouseEntered(location, control, params)
	. = ..()
	if(!QDELETED(src))
		openToolTip(usr, src, params, title = name, content = desc, theme = actiontooltipstyle)

/atom/movable/screen/movable/action_button/MouseExited(location, control, params)
	closeToolTip(usr)
	return ..()

/atom/movable/screen/movable/action_button/MouseDrop(over_object)
	last_hovored_ref = null
	if(!can_use(usr))
		return
	var/datum/hud/our_hud = usr.hud_used
	if(over_object == src)
		our_hud.hide_landings()
		return
	if(istype(over_object, /atom/movable/screen/action_landing))
		var/atom/movable/screen/action_landing/reserve = over_object
		reserve.hit_by(src)
		our_hud.hide_landings()
		save_position()
		return

	our_hud.hide_landings()
	if(istype(over_object, /atom/movable/screen/button_palette))
		our_hud.position_action(src, SCRN_OBJ_IN_PALETTE)
		save_position()
		return
	if(istype(over_object, /atom/movable/screen/movable/action_button))
		var/atom/movable/screen/movable/action_button/button = over_object
		our_hud.position_action_relative(src, button)
		save_position()
		return
	. = ..()
	our_hud.position_action(src, screen_loc)
	save_position()

/atom/movable/screen/movable/action_button/proc/save_position()
	var/mob/user = our_hud.mymob
	if(!user?.client)
		return
	var/position_info = ""
	switch(location)
		if(SCRN_OBJ_FLOATING)
			position_info = screen_loc
		if(SCRN_OBJ_IN_LIST)
			position_info = SCRN_OBJ_IN_LIST
		if(SCRN_OBJ_IN_PALETTE)
			position_info = SCRN_OBJ_IN_PALETTE

	user.client.prefs.action_buttons_screen_locs["[name]_[id]"] = position_info

/atom/movable/screen/movable/action_button/proc/load_position()
	var/mob/user = our_hud.mymob
	if(!user)
		return
	var/position_info = user.client?.prefs?.action_buttons_screen_locs["[name]_[id]"] || SCRN_OBJ_DEFAULT
	user.hud_used.position_action(src, position_info)

/atom/movable/screen/movable/action_button/proc/dump_save()
	var/mob/user = our_hud.mymob
	if(!user?.client)
		return
	user.client.prefs.action_buttons_screen_locs -= "[name]_[id]"

/datum/hud/proc/get_action_buttons_icons()
	. = list()
	.["bg_icon"] = ui_style
	.["bg_state"] = "template"

//see human and alien hud for specific implementations.

/mob/proc/update_action_buttons_icon(status_only = FALSE)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtons(status_only)

//This is the proc used to update all the action buttons.
/mob/proc/update_action_buttons(reload_screen)
	if(!hud_used || !client)
		return

	if(hud_used.hud_shown != HUD_STYLE_STANDARD)
		return

	for(var/datum/action/action as anything in actions)
		var/atom/movable/screen/movable/action_button/button = action.viewers[hud_used]
		action.UpdateButtons()
		if(reload_screen)
			client.screen += button

	// Yes I know this doesn't work, the landings aren't added to the client's screen again
	// But setting the screen to a new list is dumb regardless, and I refuse to design around it. Suck my nuts
	hud_used.refresh_landings()
	// This holds the logic for the palette buttons
	hud_used.palette_actions.refresh_actions()

	if(reload_screen)
		client.screen += hud_used.toggle_palette
		client.screen += hud_used.palette_down
		client.screen += hud_used.palette_up

/atom/movable/screen/button_palette
	name = "Show Palette"
	desc = "<b>Drag</b> buttons to move them<br><b>Shift-click</b> any button to reset it<br><b>Alt-click</b> this to reset all buttons"
	icon = 'icons/hud/64x32_actions.dmi'
	icon_state = "expand"
	screen_loc = ui_action_palette
	var/datum/hud/our_hud
	var/expanded = FALSE

/atom/movable/screen/button_palette/Destroy()
	if(our_hud)
		our_hud.mymob?.client?.screen -= src
		our_hud.toggle_palette = null
		our_hud = null
	return ..()

/atom/movable/screen/button_palette/update_name(updates)
	. = ..()
	if(expanded)
		name = "Hide Palette"
		icon_state = "contract"
	else
		name = "Show Palette"
		icon_state = "expand"

/atom/movable/screen/button_palette/MouseEntered(location, control, params)
	. = ..()
	if(QDELETED(src))
		return
	show_tooltip(params)

/atom/movable/screen/button_palette/MouseExited()
	closeToolTip(usr)
	return ..()

/atom/movable/screen/button_palette/proc/show_tooltip(params)
	openToolTip(usr, src, params, title = name, content = desc)

/atom/movable/screen/button_palette/proc/can_use(mob/user)
	if (isobserver(user))
		var/mob/dead/observer/O = user
		return !O.observetarget
	return TRUE

/atom/movable/screen/button_palette/Click(location, control, params)
	if(!can_use(usr))
		return

	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, ALT_CLICK))
		for(var/datum/action/action as anything in usr.actions) // Reset action positions to default
			for(var/datum/hud/hud as anything in action.viewers)
				var/atom/movable/screen/movable/action_button/button = action.viewers[hud]
				hud.position_action(button, SCRN_OBJ_DEFAULT)
		to_chat(usr, span_notice("Action button positions have been reset."))
		return TRUE

	set_expanded(!expanded)

	if(!usr.client)
		return

	if(expanded)
		RegisterSignal(usr.client, COMSIG_CLIENT_CLICK, .proc/clicked_while_open)
	else
		UnregisterSignal(usr.client, COMSIG_CLIENT_CLICK)

/atom/movable/screen/button_palette/proc/clicked_while_open(datum/source, atom/target, atom/location, control, params, mob/user)
	if(istype(target, /atom/movable/screen/movable/action_button) || istype(target, /atom/movable/screen/palette_scroll) || target == src) // If you're clicking on an action button, or us, you can live
		return
	set_expanded(FALSE)
	if(source)
		UnregisterSignal(source, COMSIG_CLIENT_CLICK)

/atom/movable/screen/button_palette/proc/set_expanded(new_expanded)
	expanded = new_expanded
	our_hud.palette_actions.refresh_actions()
	update_appearance()
	closeToolTip(usr) //Our tooltips are now invalid, can't seem to update them in one frame, so here, just close them

/atom/movable/screen/palette_scroll
	icon = 'icons/hud/64x35_actions.dmi' // Need to resprite this, but if the size isn't exact tooltips get sad
	screen_loc = ui_palette_scroll
	/// How should we move the palette's actions?
	/// Positive scrolls down the list, negative scrolls back
	var/scroll_direction = 0
	var/datum/hud/our_hud

/atom/movable/screen/palette_scroll/proc/can_use(mob/user)
	if (isobserver(user))
		var/mob/dead/observer/O = user
		return !O.observetarget
	return TRUE

/atom/movable/screen/palette_scroll/Click(location, control, params)
	if(!can_use(usr))
		return
	our_hud.palette_actions.scroll(scroll_direction)

/atom/movable/screen/palette_scroll/MouseEntered(location, control, params)
	. = ..()
	if(QDELETED(src))
		return
	openToolTip(usr, src, params, title = name, content = desc)

/atom/movable/screen/palette_scroll/MouseExited()
	closeToolTip(usr)
	return ..()

/atom/movable/screen/palette_scroll/down
	name = "Scroll Down"
	desc = "<b>Click</b> on this to scroll the actions above down"
	icon_state = "down"
	scroll_direction = 1

/atom/movable/screen/button_palette/down/Destroy()
	if(our_hud)
		our_hud.mymob?.client?.screen -= src
		our_hud.palette_down = null
		our_hud = null
	return ..()

/atom/movable/screen/palette_scroll/up
	name = "Scroll Up"
	desc = "<b>Click</b> on this to scroll the actions above up"
	icon_state = "up"
	scroll_direction = -1

/atom/movable/screen/button_palette/up/Destroy()
	if(our_hud)
		our_hud.mymob?.client?.screen -= src
		our_hud.palette_up = null
		our_hud = null
	return ..()

/// Exists so you have a place to put your buttons when you move them around
/atom/movable/screen/action_landing
	name = "Button Space"
	desc = "<b>Drag and drop</b> a button into this spot<br>to add it to the group"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "reserved"
	// We want our whole 32x32 space to be clickable, so dropping's forgiving
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	var/datum/action_group/owner

/atom/movable/screen/action_landing/Destroy()
	owner.landing = null
	owner?.owner?.mymob?.client?.screen -= src
	owner.refresh_actions()
	owner = null
	return ..()

/atom/movable/screen/action_landing/proc/set_owner(datum/action_group/owner)
	var/datum/hud/our_hud = owner.owner
	var/mob/viewer = our_hud.mymob

	if(viewer.client)
		viewer.client.screen += src
	src.owner = owner
	update_style()

/atom/movable/screen/action_landing/proc/update_style()
	var/datum/hud/our_hud = owner.owner
	var/list/settings = our_hud.get_action_buttons_icons()
	icon = settings["bg_icon"]

/// Reacts to having a button dropped on it
/atom/movable/screen/action_landing/proc/hit_by(atom/movable/screen/movable/action_button/button)
	var/datum/hud/our_hud = owner.owner
	our_hud.position_action(button, owner.location)
