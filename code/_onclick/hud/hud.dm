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
	"Glass" = 'icons/hud/screen_glass.dmi',
	"Trasen-Knox" = 'icons/hud/screen_trasenknox.dmi',
	"Detective" = 'icons/hud/screen_detective.dmi',
))

/proc/ui_style2icon(ui_style)
	return GLOB.available_ui_styles[ui_style] || GLOB.available_ui_styles[GLOB.available_ui_styles[1]]

/datum/hud
	var/mob/mymob
	/// Used for the HUD toggle (F12)
	var/hud_shown = TRUE
	/// Current displayed version of the HUD
	var/hud_version = HUD_STYLE_STANDARD
	/// Equipped item inventory
	var/inventory_shown = FALSE
	/// This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)
	var/hotkey_ui_hidden = FALSE

	/// Assoc list of key => "plane master groups"
	/// This is normally just the main window, but it'll occasionally contain things like spyglasses windows
	var/list/datum/plane_master_group/master_groups = list()
	///Assoc list of controller groups, associated with key string group name with value of the plane master controller ref
	var/list/atom/movable/plane_master_controller/plane_master_controllers = list()

	/// Think of multiz as a stack of z levels. Each index in that stack has its own group of plane masters
	/// This variable is the plane offset our mob/client is currently "on"
	/// We use it to track what we should show/not show
	/// Goes from 0 to the max (z level stack size - 1)
	var/current_plane_offset = 0

	/// UI for screentips that appear when you mouse over things
	/// Stored directly as it is used in very hot MouseEntered code
	var/atom/movable/screen/screentip/screentip_text = null

	/// Whether or not screentips are enabled.
	/// This is updated by the preference for cheaper reads than would be
	/// had with a proc call, especially on one of the hottest procs in the
	/// game (MouseEntered).
	var/screentips_enabled = SCREENTIP_PREFERENCE_ENABLED
	/// Whether to use text or images for click hints.
	/// Same behavior as `screentips_enabled`--very hot, updated when the preference is updated.
	var/screentip_images = TRUE
	/// If this client is being shown atmos debug overlays or not
	var/atmos_debug_overlays = FALSE

	/// The color to use for the screentips.
	/// This is updated by the preference for cheaper reads than would be
	/// had with a proc call, especially on one of the hottest procs in the game (MouseEntered).
	var/screentip_color = null

	var/datum/action_group/palette/palette_actions = null
	var/datum/action_group/listed/listed_actions = null
	var/list/floating_actions = null

	/// Subtypes can override this to force a specific UI style
	var/ui_style = null
	/// List of all screen objects we hold
	var/list/atom/movable/screen/screen_objects = list()
	/// List of screen objects by their screen group
	var/list/screen_groups[SCREEN_GROUP_AMT]
	/// List of all inventory slot screen objects by their slot ID. Some slots are fake and will be missing from here!
	var/list/inv_slots[SLOTS_AMT]
	/// List of hand slot objects, kept separate from the rest of inventory as mobs can have varying amount of hands
	var/list/atom/movable/screen/inventory/hand/hand_slots = null

	/// List of typepaths of /datum/inventory_slot which will be used to automatically create inventory slot UI elements
	/// If assigned a typepath instead of a list, it will instead use all valid subtypes of said typepath
	/// Safe to change in initialize_screen_objects() but not later
	var/list/inventory_slots = null

	/// List of weakrefs to objects that we add to our screen that we don't expect to DO anything
	/// They typically use * in their render target. They exist solely so we can reuse them,
	/// and avoid needing to make changes to all idk 300 consumers if we want to change the appearance
	var/list/asset_refs_for_reuse = list()

/datum/hud/New(mob/owner)
	mymob = owner

	if (!ui_style)
		// will fall back to the default if any of these are null
		ui_style = ui_style2icon(owner.client?.prefs?.read_preference(/datum/preference/choiced/ui_style))

	add_screen_object(/atom/movable/screen/button_palette, HUD_MOB_TOGGLE_PALETTE)
	add_screen_object(/atom/movable/screen/palette_scroll/down, HUD_MOB_PALETTE_DOWN)
	add_screen_object(/atom/movable/screen/palette_scroll/up, HUD_MOB_PALETTE_UP)

	hand_slots = list()

	var/datum/plane_master_group/main/main_group = new(PLANE_GROUP_MAIN)
	main_group.attach_to(src)

	var/datum/preferences/preferences = owner?.client?.prefs
	screentip_color = preferences?.read_preference(/datum/preference/color/screentip_color)
	screentips_enabled = preferences?.read_preference(/datum/preference/choiced/enable_screentips)
	screentip_images = preferences?.read_preference(/datum/preference/toggle/screentip_images)
	screentip_text = add_screen_object(/atom/movable/screen/screentip, HUD_MOB_SCREENTIP)

	for(var/mytype in subtypesof(/atom/movable/plane_master_controller))
		var/atom/movable/plane_master_controller/controller_instance = new mytype(null,src)
		plane_master_controllers[controller_instance.name] = controller_instance

	owner.overlay_fullscreen("see_through_darkness", /atom/movable/screen/fullscreen/see_through_darkness)

	// Register onto the global spacelight appearances
	// So they can be render targeted by anything in the world
	for(var/obj/starlight_appearance/starlight as anything in GLOB.starlight_objects)
		register_reuse(starlight)

	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(on_plane_increase))
	RegisterSignal(mymob, COMSIG_MOB_LOGIN, PROC_REF(client_refresh))
	RegisterSignal(mymob, COMSIG_MOB_LOGOUT, PROC_REF(clear_client))
	RegisterSignal(mymob, COMSIG_MOB_SIGHT_CHANGE, PROC_REF(update_sightflags))
	RegisterSignal(mymob, COMSIG_VIEWDATA_UPDATE, PROC_REF(on_viewdata_update))

	initialize_screen_objects()
	create_inventory_slots()
	update_locked_slots()

	update_sightflags(mymob, mymob.sight, NONE)

/datum/hud/Destroy()
	if(mymob.hud_used == src)
		mymob.hud_used = null

	screen_groups = null
	inv_slots.Cut()
	hand_slots.Cut()
	QDEL_LIST_ASSOC_VAL(screen_objects)
	QDEL_LIST_ASSOC_VAL(master_groups)
	QDEL_LIST_ASSOC_VAL(plane_master_controllers)
	mymob = null

	return ..()

/// Creates and registers a managed screen object
/datum/hud/proc/add_screen_object(atom/movable/screen/new_object, hud_key, group_key = HUD_GROUP_STATIC, ui_icon, ui_loc, update_screen = FALSE)
	if (ispath(new_object))
		new_object = new new_object(null, src)

	if (isnull(hud_key))
		hud_key = REF(new_object)

	if (!isnull(ui_icon))
		new_object.icon = ui_icon

	if (!isnull(ui_loc))
		new_object.screen_loc = ui_loc

	new_object.hud_key = hud_key
	if (screen_objects[hud_key])
		CRASH("Attempted to add a new [new_object] screen object to the [src] hud while an object with the same key [hud_key] is already present!")

	screen_objects[hud_key] = hud_key

	if (group_key)
		LAZYADD(screen_groups[group_key], new_object)
		new_object.hud_group_key = group_key

	if (update_screen)
		show_hud(hud_version)
	return new_object

/// Proc for children to spawn their screen object in
/datum/hud/proc/initialize_screen_objects()
	return

/datum/hud/proc/client_refresh(datum/source)
	SIGNAL_HANDLER
	var/client/client = mymob.canon_client
	RegisterSignal(client, COMSIG_CLIENT_SET_EYE, PROC_REF(on_eye_change))
	on_eye_change(null, null, client.eye)

/datum/hud/proc/clear_client(datum/source)
	SIGNAL_HANDLER
	if(mymob.canon_client)
		UnregisterSignal(mymob.canon_client, COMSIG_CLIENT_SET_EYE)

/datum/hud/proc/on_viewdata_update(datum/source, view)
	SIGNAL_HANDLER

	view_audit_buttons()

/datum/hud/proc/on_eye_change(datum/source, atom/old_eye, atom/new_eye)
	SIGNAL_HANDLER
	SEND_SIGNAL(src, COMSIG_HUD_EYE_CHANGED, old_eye, new_eye)

	if(old_eye)
		UnregisterSignal(old_eye, COMSIG_MOVABLE_Z_CHANGED)
	if(new_eye)
		// By the time logout runs, the client's eye has already changed
		// There's just no log of the old eye, so we need to override
		// :sadkirby:
		RegisterSignal(new_eye, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(eye_z_changed), override = TRUE)
	eye_z_changed(new_eye)

/datum/hud/proc/update_sightflags(datum/source, new_sight, old_sight)
	SIGNAL_HANDLER
	// If neither the old and new flags can see turfs but not objects, don't transform the turfs
	// This is to ensure parallax works when you can't see holder objects
	if(should_sight_scale(new_sight) == should_sight_scale(old_sight))
		return

	for(var/group_key in master_groups)
		var/datum/plane_master_group/group = master_groups[group_key]
		group.build_planes_offset(src, current_plane_offset)

/datum/hud/proc/should_use_scale()
	return should_sight_scale(mymob.sight)

/datum/hud/proc/should_sight_scale(sight_flags)
	return (sight_flags & (SEE_TURFS | SEE_OBJS)) != SEE_TURFS

/datum/hud/proc/eye_z_changed(atom/eye)
	SIGNAL_HANDLER
	update_parallax_pref() // If your eye changes z level, so should your parallax prefs
	var/turf/eye_turf = get_turf(eye)
	if(!eye_turf)
		return
	SEND_SIGNAL(src, COMSIG_HUD_Z_CHANGED, eye_turf.z)
	var/new_offset = GET_TURF_PLANE_OFFSET(eye_turf)
	if(current_plane_offset == new_offset)
		return
	var/old_offset = current_plane_offset
	current_plane_offset = new_offset

	SEND_SIGNAL(src, COMSIG_HUD_OFFSET_CHANGED, old_offset, new_offset)
	for(var/group_key in master_groups)
		var/datum/plane_master_group/group = master_groups[group_key]
		group.build_planes_offset(src, new_offset)

/datum/hud/proc/on_plane_increase(datum/source, old_max_offset, new_max_offset)
	SIGNAL_HANDLER
	for(var/i in old_max_offset + 1 to new_max_offset)
		register_reuse(GLOB.starlight_objects[i + 1])
	build_plane_groups(old_max_offset + 1, new_max_offset)

/// Creates the required plane masters to fill out new z layers (because each "level" of multiz gets its own plane master set)
/datum/hud/proc/build_plane_groups(starting_offset, ending_offset)
	for(var/group_key in master_groups)
		var/datum/plane_master_group/group = master_groups[group_key]
		group.build_plane_masters(starting_offset, ending_offset)

/// Returns the plane master that matches the input plane from the passed in group
/datum/hud/proc/get_plane_master(plane, group_key = PLANE_GROUP_MAIN)
	var/plane_key = "[plane]"
	var/datum/plane_master_group/group = master_groups[group_key]
	return group.plane_masters[plane_key]

/// Returns a list of all plane masters that match the input true plane, drawn from the passed in group (ignores z layer offsets)
/datum/hud/proc/get_true_plane_masters(true_plane, group_key = PLANE_GROUP_MAIN)
	var/list/atom/movable/screen/plane_master/masters = list()
	for(var/plane in TRUE_PLANE_TO_OFFSETS(true_plane))
		masters += get_plane_master(plane, group_key)
	return masters

/// Returns all the planes belonging to the passed in group key
/datum/hud/proc/get_planes_from(group_key)
	var/datum/plane_master_group/group = master_groups[group_key]
	return group.plane_masters

/// Returns the corresponding plane group datum if one exists
/datum/hud/proc/get_plane_group(key)
	return master_groups[key]

///Creates the mob's visible HUD, returns FALSE if it can't, TRUE if it did.
/mob/proc/create_mob_hud()
	if(!client || hud_used)
		return FALSE
	set_hud_used(new hud_type(src))
	update_sight()
	SEND_SIGNAL(src, COMSIG_MOB_HUD_CREATED)
	return TRUE

/mob/proc/set_hud_used(datum/hud/new_hud)
	hud_used = new_hud
	new_hud.build_action_groups()

/**
 * Shows this hud's hud to some mob
 *
 * Arguments
 * * version - denotes which style should be displayed. blank or 0 means "next version"
 * * viewmob - what mob to show the hud to. Can be this hud's mob, can be another mob, can be null (will use this hud's mob if so)
 */
/datum/hud/proc/show_hud(version = 0, mob/viewmob)
	if (!ismob(mymob))
		return FALSE

	var/mob/screenmob = viewmob || mymob
	if (!screenmob.client)
		return FALSE

	// This code is the absolute fucking worst, I want it to go die in a fire
	// Seriously, why
	// I'm sorry
	screenmob.client.clear_screen()
	screenmob.client.apply_clickcatcher()

	var/display_hud_version = version
	if (!display_hud_version) // If 0 or blank, display the next hud version
		display_hud_version = hud_version + 1

	// If the requested version number is greater than the available versions, reset back to the first version
	if (display_hud_version > HUD_VERSIONS)
		display_hud_version = HUD_STYLE_STANDARD

	var/list/group_static = screen_groups[HUD_GROUP_STATIC]
	var/list/group_toggleable = screen_groups[HUD_GROUP_TOGGLEABLE_INVENTORY]
	var/list/group_hotkeys = screen_groups[HUD_GROUP_HOTKEYS]
	var/list/group_info = screen_groups[HUD_GROUP_INFO]
	var/list/group_screen = screen_groups[HUD_GROUP_SCREEN_OVERLAYS]
	var/list/group_storage = screen_groups[HUD_GROUP_STORAGE]

	// Screen overlays get added regardless of the HUD state
	if (length(group_screen))
		screenmob.client.screen += group_screen

	var/atom/movable/screen/button_palette/palette = screen_objects[HUD_MOB_TOGGLE_PALETTE]
	var/atom/movable/screen/action_intent = screen_objects[HUD_MOB_INTENTS]

	switch (display_hud_version)
		if (HUD_STYLE_STANDARD)
			hud_shown = TRUE

			if (length(group_static))
				screenmob.client.screen += group_static
			if (length(group_toggleable) && screenmob.hud_used && screenmob.hud_used.inventory_shown)
				screenmob.client.screen += group_toggleable
			if (length(group_hotkeys) && !hotkey_ui_hidden)
				screenmob.client.screen += group_hotkeys
			if (length(group_info))
				screenmob.client.screen += group_info
			if (length(group_storage))
				screenmob.client.screen += group_storage

			screenmob.client.screen += palette

			if (action_intent)
				// Restore intent selection to the original position
				action_intent.screen_loc = initial(action_intent.screen_loc)

		if (HUD_STYLE_REDUCED)
			hud_shown = FALSE

			if (length(group_info))
				screenmob.client.screen += group_info

			// Hands are apart of the static group but still should be presetn in the reduced mode
			for (var/atom/movable/screen/hand in hand_slots)
				screenmob.client.screen += hand

			if(action_intent)
				screenmob.client.screen += action_intent
				// Move this to the alternative position, where zone_select usually is.
				action_intent.screen_loc = ui_acti_alt

		if (HUD_STYLE_NOHUD)
			hud_shown = FALSE

	hud_version = display_hud_version
	persistent_inventory_update(screenmob)
	// Gives all of the actions the screenmob owes to their hud
	screenmob.update_action_buttons(TRUE)
	// Handles alerts - the things on the right side of the screen
	reorganize_alerts(screenmob)
	screenmob.reload_fullscreen()

	if(screenmob == mymob)
		update_parallax_pref(screenmob)
	else
		viewmob.hud_used.update_parallax_pref()

	update_reuse(screenmob)

	// ensure observers get an accurate and up-to-date view
	if (!viewmob)
		plane_masters_update()
		for(var/M in mymob.observers)
			show_hud(hud_version, M)
	else if (viewmob.hud_used)
		viewmob.hide_other_mob_action_buttons(mymob)
		viewmob.hud_used.plane_masters_update()
		viewmob.show_other_mob_action_buttons(mymob)

	SEND_SIGNAL(screenmob, COMSIG_MOB_HUD_REFRESHED, src)
	return TRUE

/datum/hud/proc/plane_masters_update()
	for(var/group_key in master_groups)
		var/datum/plane_master_group/group = master_groups[group_key]
		// Plane masters are always shown to OUR mob, never to observers
		group.refresh_hud()

/datum/hud/human/show_hud(version = 0,mob/viewmob)
	. = ..()
	if(!.)
		return
	var/mob/screenmob = viewmob || mymob
	hidden_inventory_update(screenmob)

/datum/hud/new_player/show_hud(version = 0, mob/viewmob)
	. = ..()
	if(.)
		show_station_trait_buttons()

/datum/hud/proc/hidden_inventory_update()
	return

/datum/hud/proc/persistent_inventory_update(mob/viewer)
	if(!mymob)
		return

/datum/hud/proc/update_ui_style(new_ui_style)
	// do nothing if overridden by a subtype or already on that style
	if (initial(ui_style) || ui_style == new_ui_style)
		return

	for(var/atom/item in screen_objects)
		if (item.icon == ui_style)
			item.icon = new_ui_style

	ui_style = new_ui_style
	build_hand_slots(update_hud = TRUE)

/datum/hud/proc/register_reuse(atom/movable/screen/reuse)
	asset_refs_for_reuse += WEAKREF(reuse)
	mymob?.client?.screen += reuse

/datum/hud/proc/unregister_reuse(atom/movable/screen/reuse)
	asset_refs_for_reuse -= WEAKREF(reuse)
	mymob?.client?.screen -= reuse

/datum/hud/proc/update_reuse(mob/show_to)
	for(var/datum/weakref/screen_ref as anything in asset_refs_for_reuse)
		var/atom/movable/screen/reuse = screen_ref.resolve()
		if(isnull(reuse))
			asset_refs_for_reuse -= screen_ref
			continue
		show_to.client?.screen += reuse

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12()
	set name = "F12"
	set hidden = TRUE

	if(hud_used && client)
		hud_used.show_hud() //Shows the next hud preset
		to_chat(usr, span_info("Switched HUD mode. Press F12 to toggle."))
	else
		to_chat(usr, span_warning("This mob type does not use a HUD."))

/// Rebuilds our mob's hand slot screen elements
/datum/hud/proc/build_hand_slots(update_hud = FALSE)
	QDEL_LIST(hand_slots)
	hand_slots = new /list(length(mymob.held_items))

	for(var/i in 1 to length(mymob.held_items))
		var/atom/movable/screen/inventory/hand/hand_box = add_screen_object(/atom/movable/screen/inventory/hand, HUD_KEY_HAND_SLOT(i), HUD_GROUP_STATIC, ui_style, ui_hand_position(i))
		hand_box.name = mymob.get_held_index_name(i)
		hand_box.icon_state = "hand_[mymob.held_index_to_dir(i)]"
		hand_box.held_index = i
		hand_box.update_appearance()
		hand_slots[i] = hand_box

	var/num_of_swaps = 0
	for(var/atom/movable/screen/swap_hand/swap_hands in screen_groups[HUD_GROUP_STATIC])
		num_of_swaps += 1

	var/hand_num = 1
	for(var/atom/movable/screen/swap_hand/swap_hands in screen_groups[HUD_GROUP_STATIC])
		var/hand_ind = RIGHT_HANDS
		if (num_of_swaps > 1)
			hand_ind = IS_RIGHT_INDEX(hand_num) ? LEFT_HANDS : RIGHT_HANDS
		swap_hands.screen_loc = ui_swaphand_position(mymob, hand_ind)
		hand_num += 1

	hand_num = 1

	for(var/atom/movable/screen/drop/swap_hands in screen_groups[HUD_GROUP_STATIC])
		var/hand_ind = LEFT_HANDS
		if (num_of_swaps > 1)
			hand_ind = IS_LEFT_INDEX(hand_num) ? LEFT_HANDS : RIGHT_HANDS
		swap_hands.screen_loc = ui_swaphand_position(mymob, hand_ind)
		hand_num += 1

	if(update_hud && mymob?.hud_used == src)
		show_hud(hud_version)

/// Handles dimming inventory slots that a mob can't equip items to in their current state
/datum/hud/proc/update_locked_slots()
	return

/// Creates inventory slot screen elements based on our assigned inventory_slots
/datum/hud/proc/create_inventory_slots()
	var/list/created_paths = inventory_slots
	if (ispath(inventory_slots))
		created_paths = valid_subtypesof(inventory_slots)

	for (var/datum/inventory_slot/slot_type as anything in created_paths)
		var/datum/inventory_slot/inv_slot = GLOB.inventory_slot_datums[slot_type]
		if (!inv_slot)
			stack_trace("[src] attempted to use an invalid inventory slot: [slot_type]")
			continue
		inv_slot.create_element(src)

	update_inventory_slots()

/// Updates all of our inventory slots
/// Avoid calling directly in favor of specific update procs
/datum/hud/proc/update_inventory_slots()
	for(var/atom/movable/screen/inventory/inv in screen_groups[HUD_GROUP_STATIC] + screen_groups[HUD_GROUP_TOGGLEABLE_INVENTORY])
		if(inv.slot_id)
			inv_slots[TOBITSHIFT(inv.slot_id) + 1] = inv
			inv.update_appearance()

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
		if(SCRN_OBJ_INSERT_FIRST)
			listed_actions.insert_action(button, index = 1)
			position = SCRN_OBJ_IN_LIST
		else // If we don't have it as a define, this is a screen_loc, and we should be floating
			floating_actions += button
			button.screen_loc = position
			position = SCRN_OBJ_FLOATING
			var/atom/movable/screen/button_palette/toggle_palette = screen_objects[HUD_MOB_TOGGLE_PALETTE]
			toggle_palette.update_state()

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
			var/client/our_client = mymob.canon_client
			if(!our_client)
				position_action(button, button.linked_action.default_button_position)
				return

			// Asks for a location adjacent to our button that won't overflow the map
			button.screen_loc = get_valid_screen_location(relative_to.screen_loc, ICON_SIZE_ALL, our_client.view_size.getView())
			var/atom/movable/screen/button_palette/toggle_palette = screen_objects[HUD_MOB_TOGGLE_PALETTE]
			toggle_palette.update_state()

	button.location = relative_to.location

/// Removes the passed in action from its current position on the screen
/datum/hud/proc/hide_action(atom/movable/screen/movable/action_button/button)
	switch(button.location)
		if(SCRN_OBJ_DEFAULT) // Invalid
			CRASH("We just tried to hide an action buttion that somehow has the default position as its location, you done fucked up")

		if(SCRN_OBJ_FLOATING)
			floating_actions -= button
			var/atom/movable/screen/button_palette/toggle_palette = screen_objects[HUD_MOB_TOGGLE_PALETTE]
			toggle_palette.update_state()

		if(SCRN_OBJ_IN_LIST)
			listed_actions.remove_action(button)

		if(SCRN_OBJ_IN_PALETTE)
			palette_actions.remove_action(button)

	button.screen_loc = null

/// Generates visual landings for all groups that the button is not a memeber of
/datum/hud/proc/generate_landings(atom/movable/screen/movable/action_button/button)
	listed_actions.generate_landing()
	palette_actions.generate_landing()
	var/atom/movable/screen/button_palette/toggle_palette = screen_objects[HUD_MOB_TOGGLE_PALETTE]
	toggle_palette.activate_landing()

/// Clears all currently visible landings
/datum/hud/proc/hide_landings()
	listed_actions.clear_landing()
	palette_actions.clear_landing()
	var/atom/movable/screen/button_palette/toggle_palette = screen_objects[HUD_MOB_TOGGLE_PALETTE]
	toggle_palette.disable_landing()

// Updates any existing "owned" visuals, ensures they continue to be visible
/datum/hud/proc/update_our_owner()
	var/atom/movable/screen/button_palette/toggle_palette = screen_objects[HUD_MOB_TOGGLE_PALETTE]
	var/atom/movable/screen/palette_scroll/palette_down = screen_objects[HUD_MOB_PALETTE_DOWN]
	var/atom/movable/screen/palette_scroll/palette_up = screen_objects[HUD_MOB_PALETTE_UP]

	toggle_palette.refresh_owner()
	palette_down.refresh_owner()
	palette_up.refresh_owner()

	listed_actions.update_landing()
	palette_actions.update_landing()

/// Ensures all of our buttons are properly within the bounds of our client's view, moves them if they're not
/datum/hud/proc/view_audit_buttons()
	var/our_view = mymob?.canon_client?.view
	if(!our_view)
		return
	listed_actions.check_against_view()
	palette_actions.check_against_view()
	for(var/atom/movable/screen/movable/action_button/floating_button as anything in floating_actions)
		var/list/current_offsets = screen_loc_to_offset(floating_button.screen_loc, our_view)
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
