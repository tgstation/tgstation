#define WHERE_FLOOR_BELOW_MOB "Current location"
#define WHERE_SUPPLY_BELOW_MOB "Current location (droppod)"
#define WHERE_MOB_HAND "In own mob's hand"
#define WHERE_MARKED_OBJECT "At a marked object"
#define WHERE_IN_MARKED_OBJECT "In the marked object"
#define WHERE_TARGETED_LOCATION "Targeted location"
#define WHERE_TARGETED_LOCATION_POD "Targeted location (droppod)"
#define WHERE_TARGETED_MOB_HAND "In targeted mob's hand"

#define PRECISE_MODE_OFF "Off"
#define PRECISE_MODE_TARGET "Target"
#define PRECISE_MODE_MARK "Mark"
#define PRECISE_MODE_COPY "Copy"

#define OFFSET_ABSOLUTE "Absolute offset"
#define OFFSET_RELATIVE "Relative offset"

GLOBAL_LIST_INIT(spawnpanels_by_ckey, list())

/datum/spawnpanel
	var/owner_ckey
	var/where_target_type = WHERE_FLOOR_BELOW_MOB
	var/atom/selected_atom = null
	// var/copied_type = null
	var/selected_atom_icon = null
	var/selected_atom_icon_state = null
	var/custom_icon = null
	var/custom_icon_state = null
	var/custom_icon_size = 100
	var/list/available_icon_states = null
	var/object_count = 1
	var/object_name
	var/object_desc
	var/dir = 1
	var/offset = ""
	var/offset_type = "relative"
	var/precise_mode = PRECISE_MODE_OFF

/datum/spawnpanel/ui_interact(mob/user, datum/tgui/ui)
	if(user.client.ckey != owner_ckey)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpawnPanel")
		ui.open()

/// Returns a `spawnpanel` instance belonging to this `user`, or creates and registers a new one
/datum/spawnpanel/proc/get_spawnpanel_for_admin(mob/user)
	if(!user?.client?.ckey)
		return null

	var/ckey = user.client.ckey

	if(GLOB.spawnpanels_by_ckey[ckey])
		return GLOB.spawnpanels_by_ckey[ckey]

	var/datum/spawnpanel/new_panel = new()
	new_panel.owner_ckey = ckey
	GLOB.spawnpanels_by_ckey[ckey] = new_panel

	return new_panel

/datum/spawnpanel/ui_close(mob/user)
	. = ..()
	if (precise_mode && precise_mode != PRECISE_MODE_OFF)
		toggle_precise_mode(PRECISE_MODE_OFF)

/datum/spawnpanel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/spawnpanel/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("pick-icon")
			var/icon/new_icon = input("Select a new icon file:", "Icon") as null|icon
			if(new_icon)
				custom_icon = new_icon
				available_icon_states = icon_states(custom_icon)
			custom_icon_state = available_icon_states[1]
			SStgui.update_uis(src)
			return TRUE

		if("reset-icon")
			custom_icon = null
			custom_icon_state = null
			if(selected_atom)
				selected_atom_icon = initial(selected_atom.icon)
				selected_atom_icon_state = initial(selected_atom.icon_state)
				available_icon_states = icon_states(selected_atom_icon)
			SStgui.update_uis(src)
			return TRUE

		if("pick-icon-state")
			custom_icon_state = params["new_state"]
			SStgui.update_uis(src)
			return TRUE

		if("reset-icon-state")
			custom_icon_state = null
			if(selected_atom)
				selected_atom_icon_state = initial(selected_atom.icon_state)
			SStgui.update_uis(src)
			return TRUE

		if("set-icon-size")
			custom_icon_size = params["size"]
			SStgui.update_uis(src)
			return TRUE

		if("reset-icon-size")
			custom_icon_size = 100
			SStgui.update_uis(src)
			return TRUE

		if("get-icon-states")
			available_icon_states = icon_states(selected_atom_icon)
			SStgui.update_uis(src)
			return TRUE

		if("selected-object-changed")
			var/path = text2path(params?["newObj"])
			if(path)
				var/atom/temp_atom = path
				selected_atom_icon = initial(temp_atom.icon)
				selected_atom_icon_state = initial(temp_atom.icon_state)
				available_icon_states = icon_states(selected_atom_icon)
				selected_atom = temp_atom
			return TRUE

		if("create-object-action")
			spawn_item(list(
				object_list = selected_atom,
				object_count = text2num(params["object_count"]) || 1,
				offset = params["offset"],
				object_dir = text2num(params["dir"]) || 1,
				object_name = params["object_name"],
				object_where = params["where_target_type"] || WHERE_FLOOR_BELOW_MOB,
				offset_type = params["offset_type"] || OFFSET_RELATIVE,
				custom_icon = params["custom_icon"],
				custom_icon_state = params["custom_icon_state"],
				custom_icon_size = params["custom_icon_size"]
				),
				usr
			)
			return TRUE

		if("toggle-precise-mode")
			var/precise_type = params["newPreciseType"]
			if(precise_type == PRECISE_MODE_TARGET && params["where_target_type"])
				where_target_type = params["where_target_type"]
			toggle_precise_mode(precise_type)
			return TRUE

		if("update-settings")
			if(params["object_count"])
				object_count = text2num(params["object_count"])
			if(params["dir"])
				dir = text2num(params["dir"])
			if(params["offset"])
				offset = params["offset"]
			if(params["object_name"])
				object_name = params["object_name"]
			if(params["where_target_type"])
				where_target_type = params["where_target_type"]
			if(params["offset_type"])
				offset_type = params["offset_type"]
			if(params["custom_icon"])
				custom_icon = params["custom_icon"]
			if(params["custom_icon_state"])
				custom_icon_state = params["custom_icon_state"]
			if(params["custom_icon_size"])
				custom_icon_size = text2num(params["custom_icon_size"])
			return TRUE

/datum/spawnpanel/proc/toggle_precise_mode(precise_type)
	precise_mode = precise_type
	var/client/admin_client = usr.client
	if (!admin_client)
		return

	admin_client.mouse_up_icon = null
	admin_client.mouse_down_icon = null
	admin_client.mouse_override_icon = null
	admin_client.click_intercept = null

	if (precise_mode != PRECISE_MODE_OFF)
		admin_client.mouse_up_icon = 'icons/effects/mouse_pointers/supplypod_pickturf.dmi'
		admin_client.mouse_down_icon = 'icons/effects/mouse_pointers/supplypod_pickturf_down.dmi'
		admin_client.mouse_override_icon = admin_client.mouse_up_icon
		admin_client.mouse_pointer_icon = admin_client.mouse_override_icon
		admin_client.click_intercept = src

		winset(admin_client, "mapwindow.map", "right-click=true")
	else
		winset(admin_client, "mapwindow.map", "right-click=false")

	var/mob/holder_mob = admin_client.mob
	holder_mob?.update_mouse_pointer()

/datum/spawnpanel/proc/InterceptClickOn(mob/user, params, atom/target)
	var/list/modifiers = params2list(params)
	var/left_click = LAZYACCESS(modifiers, LEFT_CLICK)
	var/right_click = LAZYACCESS(modifiers, RIGHT_CLICK)

	if(right_click)
		toggle_precise_mode(PRECISE_MODE_OFF)
		SStgui.update_uis(src)
		return TRUE

	if(left_click)
		if(istype(target,/atom/movable/screen))
			return FALSE

		var/turf/clicked_turf = get_turf(target)
		if(!clicked_turf)
			return FALSE

		switch(precise_mode)
			if(PRECISE_MODE_TARGET)
				var/list/spawn_params = list(
					"object_list" = selected_atom,
					"object_count" = object_count,
					"offset" = "0,0,0",
					"object_dir" = dir,
					"object_name" = object_name,
					"object_desc" = object_desc,
					"offset_type" = OFFSET_ABSOLUTE,
					"object_where" = where_target_type,
					"object_reference" = target,
					"custom_icon" = custom_icon,
					"custom_icon_state" = custom_icon_state,
					"custom_icon_size" = custom_icon_size
				)

				if(where_target_type == WHERE_TARGETED_LOCATION || where_target_type == WHERE_TARGETED_LOCATION_POD)
					spawn_params["X"] = clicked_turf.x
					spawn_params["Y"] = clicked_turf.y
					spawn_params["Z"] = clicked_turf.z

				spawn_item(spawn_params, user)

			if(PRECISE_MODE_MARK)
				var/client/admin_client = user.client
				admin_client.mark_datum(target)
				to_chat(user, span_notice("Marked object: [icon2html(target, user)] [span_bold("[target]")]"))
				toggle_precise_mode(PRECISE_MODE_OFF)
				SStgui.update_uis(src)

			if(PRECISE_MODE_COPY)
				to_chat(user, span_notice("Picked object: [icon2html(target, user)] [span_bold("[target]")]"))
				selected_atom = target
				toggle_precise_mode(PRECISE_MODE_OFF)
				SStgui.update_uis(src)

		return TRUE

/datum/spawnpanel/ui_data(mob/user)
	var/data = list()
	data["icon"] = selected_atom_icon
	data["iconState"] = selected_atom_icon_state
	data["iconSize"] = custom_icon_size
	var/list/states = list()
	if(available_icon_states)
		for(var/state in available_icon_states)
			states += state
	data["iconStates"] = states
	data["precise_mode"] = precise_mode
	data["selected_object"] = selected_atom.type
	return data

/datum/spawnpanel/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/json/spawnpanel),
	)

#undef WHERE_FLOOR_BELOW_MOB
#undef WHERE_SUPPLY_BELOW_MOB
#undef WHERE_MOB_HAND
#undef WHERE_MARKED_OBJECT
#undef WHERE_IN_MARKED_OBJECT
#undef WHERE_TARGETED_LOCATION
#undef WHERE_TARGETED_LOCATION_POD
#undef WHERE_TARGETED_MOB_HAND
#undef PRECISE_MODE_OFF
#undef PRECISE_MODE_TARGET
#undef PRECISE_MODE_MARK
#undef PRECISE_MODE_COPY
#undef OFFSET_ABSOLUTE
#undef OFFSET_RELATIVE
