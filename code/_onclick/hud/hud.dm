/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

// The default UI style is the first one in the list
GLOBAL_LIST_INIT(available_ui_styles, list(
	"Midnight" = 'icons/hud/screen_midnight.dmi',
	"Retro" = 'icons/hud/screen_retro.dmi',
	"Plasmafire" = 'icons/hud/screen_plasmafire.dmi',
	"Slimecore" = 'icons/hud/screen_slimecore.dmi',
	"Operative" = 'icons/hud/screen_operative.dmi',
	"Clockwork" = 'icons/hud/screen_clockwork.dmi',
	"Glass" = 'icons/hud/screen_glass.dmi'
))

/proc/ui_style2icon(ui_style)
	return GLOB.available_ui_styles[ui_style] || GLOB.available_ui_styles[GLOB.available_ui_styles[1]]

/datum/hud
	var/mob/mymob

	var/hud_shown = TRUE //Used for the HUD toggle (F12)
	var/hud_version = HUD_STYLE_STANDARD //Current displayed version of the HUD
	var/inventory_shown = FALSE //Equipped item inventory
	var/hotkey_ui_hidden = FALSE //This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/atom/movable/screen/blobpwrdisplay

	var/atom/movable/screen/alien_plasma_display
	var/atom/movable/screen/alien_queen_finder

	var/atom/movable/screen/combo/combo_display

	var/atom/movable/screen/action_intent
	var/atom/movable/screen/zone_select
	var/atom/movable/screen/pull_icon
	var/atom/movable/screen/rest_icon
	var/atom/movable/screen/throw_icon
	var/atom/movable/screen/module_store_icon

	var/list/static_inventory = list() //the screen objects which are static
	var/list/toggleable_inventory = list() //the screen objects which can be hidden
	var/list/atom/movable/screen/hotkeybuttons = list() //the buttons that can be used via hotkeys
	var/list/infodisplay = list() //the screen objects that display mob info (health, alien plasma, etc...)
	var/list/screenoverlays = list() //the screen objects used as whole screen overlays (flash, damageoverlay, etc...)
	var/list/inv_slots[SLOTS_AMT] // /atom/movable/screen/inventory objects, ordered by their slot ID.
	var/list/hand_slots // /atom/movable/screen/inventory/hand objects, assoc list of "[held_index]" = object
	var/list/atom/movable/screen/plane_master/plane_masters = list() // see "appearance_flags" in the ref, assoc list of "[plane]" = object
	///Assoc list of controller groups, associated with key string group name with value of the plane master controller ref
	var/list/atom/movable/plane_master_controller/plane_master_controllers = list()


	///UI for screentips that appear when you mouse over things
	var/atom/movable/screen/screentip/screentip_text

	/// Whether or not screentips are enabled.
	/// This is updated by the preference for cheaper reads than would be
	/// had with a proc call, especially on one of the hottest procs in the
	/// game (MouseEntered).
	var/screentips_enabled = SCREENTIP_PREFERENCE_ENABLED

	/// The color to use for the screentips.
	/// This is updated by the preference for cheaper reads than would be
	/// had with a proc call, especially on one of the hottest procs in the
	/// game (MouseEntered).
	var/screentip_color

	var/atom/movable/screen/button_palette/toggle_palette
	var/atom/movable/screen/palette_scroll/down/palette_down
	var/atom/movable/screen/palette_scroll/up/palette_up

	var/datum/action_group/palette/palette_actions
	var/datum/action_group/listed/listed_actions
	var/list/floating_actions

	var/atom/movable/screen/healths
	var/atom/movable/screen/stamina
	var/atom/movable/screen/healthdoll
	var/atom/movable/screen/internals
	var/atom/movable/screen/spacesuit
	// subtypes can override this to force a specific UI style
	var/ui_style

/datum/hud/New(mob/owner)
	mymob = owner

	if (!ui_style)
		// will fall back to the default if any of these are null
		ui_style = ui_style2icon(owner.client?.prefs?.read_preference(/datum/preference/choiced/ui_style))

	toggle_palette = new()
	toggle_palette.set_hud(src)
	palette_down = new()
	palette_down.set_hud(src)
	palette_up = new()
	palette_up.set_hud(src)

	hand_slots = list()

	for(var/mytype in subtypesof(/atom/movable/screen/plane_master)- /atom/movable/screen/plane_master/rendering_plate)
		var/atom/movable/screen/plane_master/instance = new mytype()
		plane_masters["[instance.plane]"] = instance
		instance.backdrop(mymob)

	var/datum/preferences/preferences = owner?.client?.prefs
	screentip_color = preferences?.read_preference(/datum/preference/color/screentip_color)
	screentips_enabled = preferences?.read_preference(/datum/preference/choiced/enable_screentips)
	screentip_text = new(null, src)
	static_inventory += screentip_text

	for(var/mytype in subtypesof(/atom/movable/plane_master_controller))
		var/atom/movable/plane_master_controller/controller_instance = new mytype(null,src)
		plane_master_controllers[controller_instance.name] = controller_instance

	owner.overlay_fullscreen("see_through_darkness", /atom/movable/screen/fullscreen/see_through_darkness)

	AddComponent(/datum/component/zparallax, owner.client)

/datum/hud/Destroy()
	if(mymob.hud_used == src)
		mymob.hud_used = null

	QDEL_NULL(toggle_palette)
	QDEL_NULL(palette_down)
	QDEL_NULL(palette_up)
	QDEL_NULL(palette_actions)
	QDEL_NULL(listed_actions)
	QDEL_LIST(floating_actions)

	QDEL_NULL(module_store_icon)
	QDEL_LIST(static_inventory)

	inv_slots.Cut()
	action_intent = null
	zone_select = null
	pull_icon = null

	QDEL_LIST(toggleable_inventory)
	QDEL_LIST(hotkeybuttons)
	throw_icon = null
	QDEL_LIST(infodisplay)

	healths = null
	stamina = null
	healthdoll = null
	internals = null
	spacesuit = null
	blobpwrdisplay = null
	alien_plasma_display = null
	alien_queen_finder = null
	combo_display = null

	QDEL_LIST_ASSOC_VAL(plane_masters)
	QDEL_LIST_ASSOC_VAL(plane_master_controllers)
	QDEL_LIST(screenoverlays)
	mymob = null

	QDEL_NULL(screentip_text)

	return ..()

/mob/proc/create_mob_hud()
	if(!client || hud_used)
		return
	set_hud_used(new hud_type(src))
	update_sight()
	SEND_SIGNAL(src, COMSIG_MOB_HUD_CREATED)

/mob/proc/set_hud_used(datum/hud/new_hud)
	hud_used = new_hud
	new_hud.build_action_groups()

//Version denotes which style should be displayed. blank or 0 means "next version"
/datum/hud/proc/show_hud(version = 0, mob/viewmob)
	if(!ismob(mymob))
		return FALSE
	var/mob/screenmob = viewmob || mymob
	if(!screenmob.client)
		return FALSE

	// This code is the absolute fucking worst, I want it to go die in a fire
	// Seriously, why
	screenmob.client.screen = list()
	screenmob.client.apply_clickcatcher()

	var/display_hud_version = version
	if(!display_hud_version) //If 0 or blank, display the next hud version
		display_hud_version = hud_version + 1
	if(display_hud_version > HUD_VERSIONS) //If the requested version number is greater than the available versions, reset back to the first version
		display_hud_version = 1

	switch(display_hud_version)
		if(HUD_STYLE_STANDARD) //Default HUD
			hud_shown = TRUE //Governs behavior of other procs
			if(static_inventory.len)
				screenmob.client.screen += static_inventory
			if(toggleable_inventory.len && screenmob.hud_used && screenmob.hud_used.inventory_shown)
				screenmob.client.screen += toggleable_inventory
			if(hotkeybuttons.len && !hotkey_ui_hidden)
				screenmob.client.screen += hotkeybuttons
			if(infodisplay.len)
				screenmob.client.screen += infodisplay

			screenmob.client.screen += toggle_palette

			if(action_intent)
				action_intent.screen_loc = initial(action_intent.screen_loc) //Restore intent selection to the original position

		if(HUD_STYLE_REDUCED) //Reduced HUD
			hud_shown = FALSE //Governs behavior of other procs
			if(static_inventory.len)
				screenmob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				screenmob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				screenmob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				screenmob.client.screen += infodisplay

			//These ones are a part of 'static_inventory', 'toggleable_inventory' or 'hotkeybuttons' but we want them to stay
			for(var/h in hand_slots)
				var/atom/movable/screen/hand = hand_slots[h]
				if(hand)
					screenmob.client.screen += hand
			if(action_intent)
				screenmob.client.screen += action_intent //we want the intent switcher visible
				action_intent.screen_loc = ui_acti_alt //move this to the alternative position, where zone_select usually is.

		if(HUD_STYLE_NOHUD) //No HUD
			hud_shown = FALSE //Governs behavior of other procs
			if(static_inventory.len)
				screenmob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				screenmob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				screenmob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				screenmob.client.screen -= infodisplay

	hud_version = display_hud_version
	persistent_inventory_update(screenmob)
	screenmob.update_action_buttons(1)
	reorganize_alerts(screenmob)
	screenmob.reload_fullscreen()
	update_parallax_pref(screenmob)

	// ensure observers get an accurate and up-to-date view
	if (!viewmob)
		plane_masters_update()
		for(var/M in mymob.observers)
			show_hud(hud_version, M)
	else if (viewmob.hud_used)
		viewmob.hud_used.plane_masters_update()

	return TRUE

/datum/hud/proc/plane_masters_update()
	// Plane masters are always shown to OUR mob, never to observers
	for(var/thing in plane_masters)
		var/atom/movable/screen/plane_master/PM = plane_masters[thing]
		PM.backdrop(mymob)
		mymob.client.screen += PM

/datum/hud/human/show_hud(version = 0,mob/viewmob)
	. = ..()
	if(!.)
		return
	var/mob/screenmob = viewmob || mymob
	hidden_inventory_update(screenmob)

/datum/hud/robot/show_hud(version = 0, mob/viewmob)
	. = ..()
	if(!.)
		return
	update_robot_modules_display()

/datum/hud/proc/hidden_inventory_update()
	return

/datum/hud/proc/persistent_inventory_update(mob/viewer)
	if(!mymob)
		return

/datum/hud/proc/update_ui_style(new_ui_style)
	// do nothing if overridden by a subtype or already on that style
	if (initial(ui_style) || ui_style == new_ui_style)
		return

	for(var/atom/item in static_inventory + toggleable_inventory + hotkeybuttons + infodisplay + screenoverlays + inv_slots)
		if (item.icon == ui_style)
			item.icon = new_ui_style

	ui_style = new_ui_style
	build_hand_slots()

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12()
	set name = "F12"
	set hidden = TRUE

	if(hud_used && client)
		hud_used.show_hud() //Shows the next hud preset
		to_chat(usr, span_info("Switched HUD mode. Press F12 to toggle."))
	else
		to_chat(usr, span_warning("This mob type does not use a HUD."))


//(re)builds the hand ui slots, throwing away old ones
//not really worth jugglying existing ones so we just scrap+rebuild
//9/10 this is only called once per mob and only for 2 hands
/datum/hud/proc/build_hand_slots()
	for(var/h in hand_slots)
		var/atom/movable/screen/inventory/hand/H = hand_slots[h]
		if(H)
			static_inventory -= H
	hand_slots = list()
	var/atom/movable/screen/inventory/hand/hand_box
	for(var/i in 1 to mymob.held_items.len)
		hand_box = new /atom/movable/screen/inventory/hand()
		hand_box.name = mymob.get_held_index_name(i)
		hand_box.icon = ui_style
		hand_box.icon_state = "hand_[mymob.held_index_to_dir(i)]"
		hand_box.screen_loc = ui_hand_position(i)
		hand_box.held_index = i
		hand_slots["[i]"] = hand_box
		hand_box.hud = src
		static_inventory += hand_box
		hand_box.update_appearance()

	var/i = 1
	for(var/atom/movable/screen/swap_hand/SH in static_inventory)
		SH.screen_loc = ui_swaphand_position(mymob,!(i % 2) ? 2: 1)
		i++
	for(var/atom/movable/screen/human/equip/E in static_inventory)
		E.screen_loc = ui_equip_position(mymob)

	if(ismob(mymob) && mymob.hud_used == src)
		show_hud(hud_version)

/datum/hud/proc/update_locked_slots()
	return

/datum/hud/proc/position_action(atom/movable/screen/movable/action_button/button, position)
	// This is kinda a hack, I'm sorry.
	// Basically, FLOATING is never a valid position to pass into this proc. It exists as a generic marker for manually positioned buttons
	// Not as a position to target
	if(position == SCRN_OBJ_FLOATING)
		return
	if(button.location != SCRN_OBJ_DEFAULT)
		hide_action(button)
	switch(position)
		if(SCRN_OBJ_DEFAULT) // Reset to the default
			button.dump_save() // Nuke any existing saves
			position_action(button, button.linked_action.default_button_position)
			return
		if(SCRN_OBJ_IN_LIST)
			listed_actions.insert_action(button)
		if(SCRN_OBJ_IN_PALETTE)
			palette_actions.insert_action(button)
		else // If we don't have it as a define, this is a screen_loc, and we should be floating
			floating_actions += button
			button.screen_loc = position
			position = SCRN_OBJ_FLOATING

	button.location = position

/datum/hud/proc/position_action_relative(atom/movable/screen/movable/action_button/button, atom/movable/screen/movable/action_button/relative_to)
	if(button.location != SCRN_OBJ_DEFAULT)
		hide_action(button)
	switch(relative_to.location)
		if(SCRN_OBJ_IN_LIST)
			listed_actions.insert_action(button, listed_actions.index_of(relative_to))
		if(SCRN_OBJ_IN_PALETTE)
			palette_actions.insert_action(button, palette_actions.index_of(relative_to))
		if(SCRN_OBJ_FLOATING) // If we don't have it as a define, this is a screen_loc, and we should be floating
			floating_actions += button
			var/client/our_client = mymob.client
			if(!our_client)
				position_action(button, button.linked_action.default_button_position)
				return
			button.screen_loc = get_valid_screen_location(relative_to.screen_loc, world.icon_size, our_client.view_size.getView()) // Asks for a location adjacent to our button that won't overflow the map

	button.location = relative_to.location

/// Removes the passed in action from its current position on the screen
/datum/hud/proc/hide_action(atom/movable/screen/movable/action_button/button)
	switch(button.location)
		if(SCRN_OBJ_DEFAULT) // Invalid
			CRASH("We just tried to hide an action buttion that somehow has the default position as its location, you done fucked up")
		if(SCRN_OBJ_FLOATING)
			floating_actions -= button
		if(SCRN_OBJ_IN_LIST)
			listed_actions.remove_action(button)
		if(SCRN_OBJ_IN_PALETTE)
			palette_actions.remove_action(button)
	button.screen_loc = null

/// Generates visual landings for all groups that the button is not a memeber of
/datum/hud/proc/generate_landings(atom/movable/screen/movable/action_button/button)
	listed_actions.generate_landing()
	palette_actions.generate_landing()

/// Clears all currently visible landings
/datum/hud/proc/hide_landings()
	listed_actions.clear_landing()
	palette_actions.clear_landing()

// Updates any existing "owned" visuals, ensures they continue to be visible
/datum/hud/proc/update_our_owner()
	toggle_palette.refresh_owner()
	palette_down.refresh_owner()
	palette_up.refresh_owner()
	listed_actions.update_landing()
	palette_actions.update_landing()

/// Ensures all of our buttons are properly within the bounds of our client's view, moves them if they're not
/datum/hud/proc/view_audit_buttons()
	var/our_view = mymob?.client?.view
	if(!our_view)
		return
	listed_actions.check_against_view()
	palette_actions.check_against_view()
	for(var/atom/movable/screen/movable/action_button/floating_button as anything in floating_actions)
		var/list/current_offsets = screen_loc_to_offset(floating_button.screen_loc)
		// We set the view arg here, so the output will be properly hemm'd in by our new view
		floating_button.screen_loc = offset_to_screen_loc(current_offsets[1], current_offsets[2], view = our_view)

/// Generates and fills new action groups with our mob's current actions
/datum/hud/proc/build_action_groups()
	listed_actions = new(src)
	palette_actions = new(src)
	floating_actions = list()
	for(var/datum/action/action as anything in mymob.actions)
		var/atom/movable/screen/movable/action_button/button = action.viewers[src]
		if(!button)
			action.ShowTo(mymob)
		else
			position_action(button, button.location)

/datum/action_group
	/// The hud we're owned by
	var/datum/hud/owner
	/// The actions we're managing
	var/list/atom/movable/screen/movable/action_button/actions
	/// The initial vertical offset of our action buttons
	var/north_offset = 0
	/// The pixel vertical offset of our action buttons
	var/pixel_north_offset = 0
	/// Max amount of buttons we can have per row
	/// Indexes at 1
	var/column_max = 0
	/// How far "ahead" of the first row we start. Lets us "scroll" our rows
	/// Indexes at 1
	var/row_offset = 0
	/// How many rows of actions we can have at max before we just stop hiding
	/// Indexes at 1
	var/max_rows = INFINITY
	/// The screen location we go by
	var/location
	/// Our landing screen object
	var/atom/movable/screen/action_landing/landing

/datum/action_group/New(datum/hud/owner)
	..()
	actions = list()
	src.owner = owner

/datum/action_group/Destroy()
	owner = null
	QDEL_NULL(landing)
	QDEL_LIST(actions)
	return ..()

/datum/action_group/proc/insert_action(atom/movable/screen/action, index)
	if(action in actions)
		if(actions[index] == action)
			return
		actions -= action // Don't dupe, come on
	if(!index)
		index = length(actions) + 1
	index = min(length(actions) + 1, index)
	actions.Insert(index, action)
	refresh_actions()

/datum/action_group/proc/remove_action(atom/movable/screen/action)
	actions -= action
	refresh_actions()

/datum/action_group/proc/refresh_actions()

	// We don't use size() here because landings are not canon
	var/total_rows = ROUND_UP(length(actions) / column_max)
	total_rows -= max_rows // Lets get the amount of rows we're off from our max
	row_offset = clamp(row_offset, 0, total_rows) // You're not allowed to offset so far that we have a row of blank space

	var/button_number = 0
	for(var/atom/movable/screen/button as anything in actions)
		var/postion = ButtonNumberToScreenCoords(button_number )
		button.screen_loc = postion
		button_number++

	if(landing)
		var/postion = ButtonNumberToScreenCoords(button_number, landing = TRUE) // Need a good way to count buttons off screen, but allow this to display in the right place if it's being placed with no concern for dropdown
		landing.screen_loc = postion
		button_number++

/// Accepts a number represeting our position in the group, indexes at 0 to make the math nicer
/datum/action_group/proc/ButtonNumberToScreenCoords(number, landing = FALSE)
	var/row = round(number / column_max)
	row -= row_offset // If you're less then 0, you don't get to render, this lets us "scroll" rows ya feel?
	if(row < 0)
		return null

	// Could use >= here, but I think it's worth noting that the two start at different places, since row is based on number here
	if(row > max_rows - 1)
		if(!landing) // If you're not a landing, go away please. thx
			return null
		// We always want to render landings, even if their action button can't be displayed.
		// So we set a row equal to the max amount of rows + 1. Willing to overrun that max slightly to properly display the landing spot
		row = max_rows // Remembering that max_rows indexes at 1, and row indexes at 0

		// We're going to need to set our column to match the first item in the last row, so let's set number properly now
		number = row * column_max

	var/visual_row = row + north_offset
	var/coord_row = visual_row ? "-[visual_row]" : "+0"

	var/visual_column = number % column_max
	var/coord_col = "+[visual_column]"
	var/coord_col_offset = 4 + 2 * (visual_column + 1)
	return "WEST[coord_col]:[coord_col_offset],NORTH[coord_row]:-[pixel_north_offset]"

/datum/action_group/proc/check_against_view()
	var/owner_view = owner?.mymob?.client?.view
	if(!owner_view)
		return
	// Unlikey as it is, we may have been changed. Want to start from our target position and fail down
	column_max = initial(column_max)
	// Convert our viewer's view var into a workable offset
	var/list/view_size = view_to_pixels(owner_view)

	// We're primarially concerned about width here, if someone makes us 1x2000 I wish them a swift and watery death
	var/furthest_screen_loc = ButtonNumberToScreenCoords(column_max - 1)
	var/list/offsets = screen_loc_to_offset(furthest_screen_loc, owner_view)
	if(offsets[1] > world.icon_size && offsets[1] < view_size[1] && offsets[2] > world.icon_size && offsets[2] < view_size[2]) // We're all good
		return

	for(column_max in column_max - 1 to 1 step -1) // Yes I could do this by unwrapping ButtonNumberToScreenCoords, but I don't feel like it
		var/tested_screen_loc = ButtonNumberToScreenCoords(column_max)
		offsets = screen_loc_to_offset(tested_screen_loc, owner_view)
		// We've found a valid max length, pack it in
		if(offsets[1] > world.icon_size && offsets[1] < view_size[1] && offsets[2] > world.icon_size && offsets[2] < view_size[2])
			break
	// Use our newly resized column max
	refresh_actions()

/// Returns the amount of objects we're storing at the moment
/datum/action_group/proc/size()
	var/amount = length(actions)
	if(landing)
		amount += 1
	return amount

/datum/action_group/proc/index_of(atom/movable/screen/get_location)
	return actions.Find(get_location)

/// Generates a landing object that can be dropped on to join this group
/datum/action_group/proc/generate_landing()
	if(landing)
		return
	landing = new()
	landing.set_owner(src)
	refresh_actions()

/// Clears any landing objects we may currently have
/datum/action_group/proc/clear_landing()
	QDEL_NULL(landing)

/datum/action_group/proc/update_landing()
	if(!landing)
		return
	landing.refresh_owner()

/datum/action_group/proc/scroll(amount)
	row_offset += amount
	refresh_actions()

/datum/action_group/palette
	north_offset = 2
	column_max = 3
	max_rows = 3
	location = SCRN_OBJ_IN_PALETTE

/datum/action_group/palette/insert_action(atom/movable/screen/action, index)
	. = ..()
	var/atom/movable/screen/button_palette/palette = owner.toggle_palette
	palette.play_item_added()

/datum/action_group/palette/remove_action(atom/movable/screen/action)
	. = ..()
	var/atom/movable/screen/button_palette/palette = owner.toggle_palette
	palette.play_item_removed()
	if(!length(actions))
		palette.set_expanded(FALSE)

/datum/action_group/palette/refresh_actions()
	var/atom/movable/screen/button_palette/palette = owner.toggle_palette
	var/atom/movable/screen/palette_scroll/scroll_down = owner.palette_down
	var/atom/movable/screen/palette_scroll/scroll_up = owner.palette_up

	var/actions_above = round((owner.listed_actions.size() - 1) / owner.listed_actions.column_max)
	north_offset = initial(north_offset) + actions_above

	palette.screen_loc = ui_action_palette_offset(actions_above)
	var/action_count = length(owner?.mymob?.actions)
	var/our_row_count = round((length(actions) - 1) / column_max)
	if(!action_count)
		palette.screen_loc = null

	if(palette.expanded && action_count && our_row_count >= max_rows)
		scroll_down.screen_loc = ui_palette_scroll_offset(actions_above)
		scroll_up.screen_loc = ui_palette_scroll_offset(actions_above)
	else
		scroll_down.screen_loc = null
		scroll_up.screen_loc = null

	return ..()

/datum/action_group/palette/ButtonNumberToScreenCoords(number, landing)
	var/atom/movable/screen/button_palette/palette = owner.toggle_palette
	if(palette.expanded)
		return ..()

	if(!landing)
		return null

	// We only render the landing in this case, so we force it to be the second item displayed (Second rather then first since it looks nicer)
	// Remember the number var indexes at 0
	return ..(1 + (row_offset * column_max), landing)


/datum/action_group/listed
	pixel_north_offset = 6
	column_max = 10
	location = SCRN_OBJ_IN_LIST

/datum/action_group/listed/refresh_actions()
	. = ..()
	owner.palette_actions.refresh_actions() // We effect them, so we gotta refresh em
