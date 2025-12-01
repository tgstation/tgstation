/atom/movable/screen/movable/action_button
	var/datum/action/linked_action
	var/datum/hud/our_hud
	var/actiontooltipstyle = ""
	screen_loc = null
	mouse_over_pointer = MOUSE_HAND_POINTER

	/// The icon state of our active overlay, used to prevent re-applying identical overlays
	var/active_overlay_icon_state
	/// The icon state of our active underlay, used to prevent re-applying identical underlays
	var/active_underlay_icon_state
	/// The overlay we have overtop our button
	var/mutable_appearance/button_overlay

	/// Where we are currently placed on the hud. SCRN_OBJ_DEFAULT asks the linked action what it thinks
	var/location = SCRN_OBJ_DEFAULT
	/// A unique bitflag, combined with the name of our linked action this lets us persistently remember any user changes to our position
	var/id
	/// A weakref of the last thing we hovered over
	/// God I hate how dragging works
	var/datum/weakref/last_hovored_ref
	/// overlay for keybind maptext
	var/mutable_appearance/keybind_maptext
	/// if observers can trigger this action at any time
	var/allow_observer_click = FALSE

/atom/movable/screen/movable/action_button/Destroy()
	if(our_hud)
		var/mob/viewer = our_hud.mymob
		our_hud.hide_action(src)
		viewer?.client?.screen -= src
		linked_action.viewers -= our_hud
		viewer.update_action_buttons()
		our_hud = null
	linked_action = null
	return ..()

/atom/movable/screen/movable/action_button/proc/can_use(mob/user)
	if(isobserver(user))
		var/mob/dead/observer/dead_mob = user
		if(allow_observer_click)
			return TRUE
		if(dead_mob.observetarget) // Observers can only click on action buttons if they're not observing something
			return FALSE

	if(linked_action)
		if(linked_action.viewers[user.hud_used])
			return TRUE
		return FALSE

	return TRUE

/atom/movable/screen/movable/action_button/Click(location,control,params)
	if(!can_use(usr))
		return FALSE

	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, ALT_CLICK))
		linked_action?.begin_creating_bind(src, usr)
		return TRUE
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
	linked_action.Trigger(usr, trigger_flags = trigger_flags)
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
	over_object?.MouseEntered(over_location, over_control, params)

/atom/movable/screen/movable/action_button/MouseEntered(location, control, params)
	. = ..()
	if(!QDELETED(src))
		openToolTip(usr, src, params, title = name, content = desc, theme = actiontooltipstyle)

/atom/movable/screen/movable/action_button/MouseExited(location, control, params)
	closeToolTip(usr)
	return ..()

/atom/movable/screen/movable/action_button/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
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
		save_position()
		our_hud.hide_landings()
		return

	if(istype(over_object, /atom/movable/screen/button_palette) || istype(over_object, /atom/movable/screen/palette_scroll))
		our_hud.position_action(src, SCRN_OBJ_IN_PALETTE)
		save_position()
		our_hud.hide_landings()
		return

	if(istype(over_object, /atom/movable/screen/movable/action_button))
		var/atom/movable/screen/movable/action_button/button = over_object
		our_hud.position_action_relative(src, button)
		save_position()
		our_hud.hide_landings()
		return

	. = ..()

	our_hud.position_action(src, screen_loc)
	save_position()
	our_hud.hide_landings()

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

/atom/movable/screen/movable/action_button/proc/update_keybind_maptext(key)
	cut_overlay(keybind_maptext)
	if(!key)
		return
	keybind_maptext = new
	keybind_maptext.maptext = MAPTEXT("<span style='text-align: right'>[key]</span>")
	keybind_maptext.transform = keybind_maptext.transform.Translate(-4, length(key) > 1 ? -6 : 2) //with modifiers, its placed lower so cooldown is visible
	add_overlay(keybind_maptext)

/**
 * This is a silly proc used in hud code code to determine what icon and icon state we should be using
 * for hud elements (such as action buttons) that don't have their own icon and icon state set.
 *
 * It returns a list, which is pretty much just a struct of info
 */
/datum/hud/proc/get_action_buttons_icons()
	. = list()
	.["bg_icon"] = ui_style
	.["bg_state"] = "template"
	.["bg_state_active"] = "template_active"

/**
 * Updates all action buttons this mob has.
 *
 * Arguments:
 * * update_flags - Which flags of the action should we update
 * * force - Force buttons update even if the given button icon state has not changed
 */
/mob/proc/update_mob_action_buttons(update_flags = ALL, force = FALSE)
	for(var/datum/action/current_action as anything in actions)
		current_action.build_all_button_icons(update_flags, force)

/**
 * This proc handles adding all of the mob's actions to their screen
 *
 * If you just need to update existing buttons, use [/mob/proc/update_mob_action_buttons]!
 *
 * Arguments:
 * * update_flags - reload_screen - bool, if TRUE, this proc will add the button to the screen of the passed mob as well
 */
/mob/proc/update_action_buttons(reload_screen = FALSE)
	if(!hud_used || !client)
		return

	if(hud_used.hud_shown != HUD_STYLE_STANDARD)
		return

	for(var/datum/action/action as anything in actions)
		var/atom/movable/screen/movable/action_button/button = action.viewers[hud_used]
		action.build_all_button_icons()
		if(reload_screen)
			client.screen += button

	if(reload_screen)
		hud_used.update_our_owner()
	// This holds the logic for the palette buttons
	hud_used.palette_actions.refresh_actions()

/**
 * Show (most) of the another mob's action buttons to this mob
 *
 * Used for observers viewing another mob's screen
 */
/mob/proc/show_other_mob_action_buttons(mob/take_from)
	if(!hud_used || !client)
		return

	for(var/datum/action/action as anything in take_from.actions)
		if(!action.show_to_observers || !action.owner_has_control)
			continue
		action.GiveAction(src)
	RegisterSignal(take_from, COMSIG_MOB_GRANTED_ACTION, PROC_REF(on_observing_action_granted))
	RegisterSignal(take_from, COMSIG_MOB_REMOVED_ACTION, PROC_REF(on_observing_action_removed))

/**
 * Hide another mob's action buttons from this mob
 *
 * Used for observers viewing another mob's screen
 */
/mob/proc/hide_other_mob_action_buttons(mob/take_from)
	for(var/datum/action/action as anything in take_from.actions)
		action.HideFrom(src)
	UnregisterSignal(take_from, list(COMSIG_MOB_GRANTED_ACTION, COMSIG_MOB_REMOVED_ACTION))

/// Signal proc for [COMSIG_MOB_GRANTED_ACTION] - If we're viewing another mob's action buttons,
/// we need to update with any newly added buttons granted to the mob.
/mob/proc/on_observing_action_granted(mob/living/source, datum/action/action)
	SIGNAL_HANDLER

	if(!action.show_to_observers || !action.owner_has_control)
		return
	action.GiveAction(src)

/// Signal proc for [COMSIG_MOB_REMOVED_ACTION] - If we're viewing another mob's action buttons,
/// we need to update with any removed buttons from the mob.
/mob/proc/on_observing_action_removed(mob/living/source, datum/action/action)
	SIGNAL_HANDLER

	action.HideFrom(src)

/atom/movable/screen/button_palette
	desc = "<b>Drag</b> buttons to move them<br><b>Shift-click</b> any button to reset it<br><b>Alt-click any button</b> to begin binding it to a key<br><b>Alt-click this</b> to reset all buttons"
	icon = 'icons/hud/64x16_actions.dmi'
	icon_state = "screen_gen_palette"
	screen_loc = ui_action_palette
	mouse_over_pointer = MOUSE_HAND_POINTER
	var/datum/hud/our_hud
	var/expanded = FALSE
	/// Id of any currently running timers that set our color matrix
	var/color_timer_id

/atom/movable/screen/button_palette/Destroy()
	if(our_hud)
		our_hud.mymob?.canon_client?.screen -= src
		our_hud.toggle_palette = null
		our_hud = null
	return ..()

/atom/movable/screen/button_palette/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	update_appearance()

/atom/movable/screen/button_palette/proc/set_hud(datum/hud/our_hud)
	src.our_hud = our_hud
	refresh_owner()
	disable_landing() // If our hud already has elements, don't force hide us

/atom/movable/screen/button_palette/update_name(updates)
	. = ..()
	if(expanded)
		name = "Hide Buttons"
	else
		name = "Show Buttons"

/atom/movable/screen/button_palette/proc/refresh_owner()
	var/mob/viewer = our_hud.mymob
	if(viewer.client)
		viewer.client.screen |= src

	var/list/settings = our_hud.get_action_buttons_icons()
	var/ui_icon = "[settings["bg_icon"]]"
	var/list/ui_segments = splittext(ui_icon, ".")
	var/list/ui_paths = splittext(ui_segments[1], "/")
	var/ui_name = ui_paths[length(ui_paths)]

	icon_state = "[ui_name]_palette"

/atom/movable/screen/button_palette/proc/activate_landing()
	// Reveal ourselves to the user
	invisibility = INVISIBILITY_NONE

/atom/movable/screen/button_palette/proc/disable_landing()
	// If we have no elements in the palette, hide your ugly self please
	if (!length(our_hud.palette_actions?.actions) && !length(our_hud.floating_actions))
		invisibility = INVISIBILITY_ABSTRACT

/atom/movable/screen/button_palette/proc/update_state()
	if (length(our_hud.floating_actions))
		activate_landing()
	else
		disable_landing()

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

GLOBAL_LIST_INIT(palette_added_matrix, list(0.4,0.5,0.2,0, 0,1.4,0,0, 0,0.4,0.6,0, 0,0,0,1, 0,0,0,0))
GLOBAL_LIST_INIT(palette_removed_matrix, list(1.4,0,0,0, 0.7,0.4,0,0, 0.4,0,0.6,0, 0,0,0,1, 0,0,0,0))

/atom/movable/screen/button_palette/proc/play_item_added()
	color_for_now(GLOB.palette_added_matrix)

/atom/movable/screen/button_palette/proc/play_item_removed()
	color_for_now(GLOB.palette_removed_matrix)

/atom/movable/screen/button_palette/proc/color_for_now(list/color)
	if(color_timer_id)
		return
	add_atom_colour(color, TEMPORARY_COLOUR_PRIORITY) //We unfortunately cannot animate matrix colors. Curse you lummy it would be ~~non~~trivial to interpolate between the two valuessssssssss
	color_timer_id = addtimer(CALLBACK(src, PROC_REF(remove_color), color), 2 SECONDS)

/atom/movable/screen/button_palette/proc/remove_color(list/to_remove)
	color_timer_id = null
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, to_remove)

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

/atom/movable/screen/button_palette/proc/clicked_while_open(datum/source, atom/target, atom/location, control, params, mob/user)
	if(istype(target, /atom/movable/screen/movable/action_button) || istype(target, /atom/movable/screen/palette_scroll) || target == src) // If you're clicking on an action button, or us, you can live
		return
	set_expanded(FALSE)
	if(source)
		UnregisterSignal(source, COMSIG_CLIENT_CLICK)

/atom/movable/screen/button_palette/proc/set_expanded(new_expanded)
	var/datum/action_group/our_group = our_hud.palette_actions
	if(!length(our_group.actions)) //Looks dumb, trust me lad
		new_expanded = FALSE
	if(expanded == new_expanded)
		return

	expanded = new_expanded
	our_group.refresh_actions()
	update_appearance()

	if(!usr.client)
		return

	if(expanded)
		RegisterSignal(usr.client, COMSIG_CLIENT_CLICK, PROC_REF(clicked_while_open))
	else
		UnregisterSignal(usr.client, COMSIG_CLIENT_CLICK)

	closeToolTip(usr) //Our tooltips are now invalid, can't seem to update them in one frame, so here, just close them

/atom/movable/screen/palette_scroll
	icon = 'icons/hud/screen_gen.dmi'
	screen_loc = ui_palette_scroll
	mouse_over_pointer = MOUSE_HAND_POINTER
	/// How should we move the palette's actions?
	/// Positive scrolls down the list, negative scrolls back
	var/scroll_direction = 0
	var/datum/hud/our_hud

/atom/movable/screen/palette_scroll/proc/can_use(mob/user)
	if (isobserver(user))
		var/mob/dead/observer/O = user
		return !O.observetarget
	return TRUE

/atom/movable/screen/palette_scroll/proc/set_hud(datum/hud/our_hud)
	src.our_hud = our_hud
	refresh_owner()

/atom/movable/screen/palette_scroll/proc/refresh_owner()
	var/mob/viewer = our_hud.mymob
	if(viewer.client)
		viewer.client.screen |= src

	var/list/settings = our_hud.get_action_buttons_icons()
	icon = settings["bg_icon"]

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
	icon_state = "scroll_down"
	scroll_direction = 1

/atom/movable/screen/palette_scroll/down/Destroy()
	if(our_hud)
		our_hud.mymob?.canon_client?.screen -= src
		our_hud.palette_down = null
		our_hud = null
	return ..()

/atom/movable/screen/palette_scroll/up
	name = "Scroll Up"
	desc = "<b>Click</b> on this to scroll the actions above up"
	icon_state = "scroll_up"
	scroll_direction = -1

/atom/movable/screen/palette_scroll/up/Destroy()
	if(our_hud)
		our_hud.mymob?.canon_client?.screen -= src
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
	if(owner)
		owner.landing = null
		owner?.owner?.mymob?.canon_client?.screen -= src
		owner.refresh_actions()
		owner = null
	return ..()

/atom/movable/screen/action_landing/proc/set_owner(datum/action_group/owner)
	src.owner = owner
	refresh_owner()

/atom/movable/screen/action_landing/proc/refresh_owner()
	var/datum/hud/our_hud = owner.owner
	var/mob/viewer = our_hud.mymob
	if(viewer.client)
		viewer.client.screen |= src

	var/list/settings = our_hud.get_action_buttons_icons()
	icon = settings["bg_icon"]

/// Reacts to having a button dropped on it
/atom/movable/screen/action_landing/proc/hit_by(atom/movable/screen/movable/action_button/button)
	var/datum/hud/our_hud = owner.owner
	our_hud.position_action(button, owner.location)
