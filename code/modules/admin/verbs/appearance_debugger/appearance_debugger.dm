/// Allows developers to see a breakdown of an atom or a specific target and edit some of the values
/datum/appearance_debugger
	var/datum/admins/owner
	/// Currently debugged atom or mutable appearance, hence /datum
	var/datum/debug_target
	/// A list of copies of the currently debugged appearance and its children for access from the UI
	var/list/mutable_appearance/appearance_copies
	/// Assoc list of ref -> appearance as to prevent refreshing of dynamic appearances
	var/list/mutable_appearance/appearance_cache
	/// Mapview used to display the hovered over appearance
	var/atom/movable/screen/map_view/proxy_view_hover
	/// Mapview used to display the selected appearance
	var/atom/movable/screen/map_view/proxy_view_selected
	/// Assoc list of ref -> list of atoms to be displayed in said ref atom's vis_contents
	var/list/atom/movable/fake_vis
	/// Should we display a popup that the appearance in-game has updated?
	var/update_warning = FALSE

/datum/appearance_debugger/New(datum/admins/owner)
	src.owner = owner
	proxy_view_hover = new()
	proxy_view_hover.generate_view("appearance_debugger_[REF(owner)]_proxy_hover")
	proxy_view_selected = new()
	proxy_view_selected.generate_view("appearance_debugger_[REF(owner)]_proxy_selected")

/datum/appearance_debugger/Destroy()
	if (owner)
		owner.appearance_debug = null
		owner = null
	if (fake_vis)
		for (var/ref_id in fake_vis)
			var/list/all_fakes = fake_vis[ref_id]
			QDEL_LIST(all_fakes)
		fake_vis.Cut()
	QDEL_NULL(proxy_view_hover)
	QDEL_NULL(proxy_view_selected)
	return ..()

/datum/appearance_debugger/proc/get_appearance_data(atom/appearance_owner)
	var/mutable_appearance/target = appearance_owner
	if (isatom(appearance_owner))
		target = appearance_cache["[REF(appearance_owner)]"] || new /mutable_appearance(appearance_owner.appearance)
		appearance_cache["[REF(appearance_owner)]"] = target
		if (!fake_vis["[REF(appearance_owner)]"] && (ismovable(appearance_owner) || isturf(appearance_owner)))
			var/atom/movable/as_movable = appearance_owner
			var/list/false_vis_contents = list()
			fake_vis["[REF(appearance_owner)]"] = false_vis_contents
			for (var/atom/something in (isturf(as_movable) ? (as_movable.vis_contents + as_movable.contents) : as_movable.vis_contents))
				var/atom/movable/mimic = new()
				mimic.appearance = new /mutable_appearance(something.appearance)
				false_vis_contents += mimic

	var/list/data = list(
		"type" = isatom(appearance_owner) ? "atom" : (isimage(appearance_owner) ? "image" : "appearance"),
		"alpha" = target.alpha,
		"flags" = target.appearance_flags,
		"blend_mode" = target.blend_mode,
		"color" = target.color,
		"dir" = target.dir,
		"icon" = length("[target.icon]") ? "[target.icon]" : null,
		"icon_state" = target.icon_state,
		"invisibility" = target.invisibility,
		"layer" = target.layer,
		"name" = target.name,
		"maptext" = target.maptext,
		"maptext_width" = target.maptext_width,
		"maptext_height" = target.maptext_height,
		"maptext_x" = target.maptext_x,
		"maptext_y" = target.maptext_y,
		"mouse_opacity" = target.mouse_opacity,
		"pixel_x" = target.pixel_x,
		"pixel_y" = target.pixel_y,
		"pixel_w" = target.pixel_w,
		"pixel_z" = target.pixel_z,
		"plane" = target.plane,
		"plane_true" = PLANE_TO_TRUE(target.plane),
		"render_source" = target.render_source,
		"render_target" = target.render_target,
		"screen_loc" = target.screen_loc,
	)

	if (!(target in appearance_copies))
		appearance_copies += target
		data["id"] = length(appearance_copies)
	else
		data["id"] = appearance_copies.Find(target)

	var/list/filter_data = list()
	for (var/list/our_filter as anything in target.filter_data)
		filter_data += list(our_filter)
	data["filters"] = filter_data

	var/list/underlay_data = list()
	for (var/mutable_appearance/underlay as anything in target.underlays)
		underlay_data += list(get_appearance_data(underlay))
	data["underlays"] = underlay_data

	var/list/overlay_data = list()
	for (var/mutable_appearance/overlay as anything in target.overlays)
		overlay_data += list(get_appearance_data(overlay))
	data["overlays"] = overlay_data

	// Display previews if it is either an instance icon or a file and we have icon_state set
	if ((isicon(target.icon) && !isfile(target.icon)) || (target.icon && target.icon_state))
		var/icon/used_icon = icon(target.icon, target.icon_state, (isimage(target) && target.dir) ? target.dir : SOUTH, frame = 1)
		if (istext(target.color))
			used_icon.Blend(target.color, ICON_MULTIPLY)
		data["embed_icon"] = icon2base64(used_icon)

	data["transform"] = list(target.transform.a, target.transform.b, target.transform.c, target.transform.d, target.transform.e, target.transform.f)
	// Turfs aren't movables but they still can have vis_flags/contents so lets just count them as such
	if (ismovable(appearance_owner) || isturf(appearance_owner))
		var/atom/movable/as_movable = appearance_owner
		data["vis_flags"] = as_movable.vis_flags
		// Maybe should be cached but I'm too lazy and don't think this'll matter enough
		var/list/vis_data = list()
		// Turfs also inherit their contents as vis_contents
		for (var/atom/vis_thing as anything in isturf(as_movable) ? (as_movable.vis_contents + as_movable.contents) : as_movable.vis_contents)
			vis_data += list(get_appearance_data(vis_thing))
		data["vis_contents"] = vis_data

	// Handle all dynamically modified layers
	if (target.layer > FLOOR_EMISSIVE_START_LAYER && target.layer < FLOOR_EMISSIVE_END_LAYER)
		data["layer_text_override"] = "FLOOR_EMISSIVE_LAYER (+[target.layer - FLOOR_EMISSIVE_START_LAYER])"
	else if (target.layer > GAS_PIPE_HIDDEN_LAYER && target.layer < GAS_PIPE_HIDDEN_LAYER + 0.006)
		data["layer_text_override"] = "GAS_PIPE_HIDDEN_LAYER (+[target.layer - GAS_PIPE_HIDDEN_LAYER])"
	else if (target.layer > GAS_PIPE_VISIBLE_LAYER && target.layer < GAS_PIPE_VISIBLE_LAYER + 0.006)
		data["layer_text_override"] = "GAS_PIPE_VISIBLE_LAYER (+[target.layer - GAS_PIPE_VISIBLE_LAYER])"
	else if (target.layer > PLUMBING_PIPE_VISIBILE_LAYER && target.layer < PLUMBING_PIPE_VISIBILE_LAYER + (FIFTH_DUCT_LAYER * 2 / 3333))
		data["layer_text_override"] = "PLUMBING_PIPE_VISIBILE_LAYER (+[target.layer - PLUMBING_PIPE_VISIBILE_LAYER])"

	return data

/datum/appearance_debugger/ui_data(mob/user)
	return list(
		"updateWarning" = update_warning,
	)

/datum/appearance_debugger/ui_static_data(mob/user)
	return list(
		"mainAppearance" = get_appearance_data(debug_target),
		"planeToText" = GLOB.admin_readable_planes,
		"layerToText" = GLOB.admin_readable_layers,
		"flagsToText" = get_valid_bitflags("appearance_flags"),
		"visToText" = get_valid_bitflags("vis_flags"),
		"blendToText" = GLOB.blend_names,
		"mapRefHover" = proxy_view_hover.assigned_map,
		"mapRefSelected" = proxy_view_selected.assigned_map,
	)

/datum/appearance_debugger/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("swapMapViewHover")
			var/appearance_id = text2num(params["id"])
			proxy_view_hover.appearance = appearance_copies[appearance_id]

			for (var/atom/movable/something as anything in proxy_view_hover.vis_contents)
				proxy_view_hover.vis_contents -= something
			for (var/ref_id in appearance_cache)
				if (appearance_copies[appearance_id] != appearance_cache[ref_id])
					continue
				if (fake_vis[ref_id])
					proxy_view_hover.vis_contents |= fake_vis[ref_id]

			// Needs screenloc to be set since we're setting the appearance and carrying over target's screenloc
			proxy_view_hover.set_position(1, 1)

		if("swapMapViewSelected")
			var/appearance_id = text2num(params["id"])
			proxy_view_selected.appearance = appearance_copies[appearance_id]

			for (var/atom/movable/something as anything in proxy_view_selected.vis_contents)
				proxy_view_selected.vis_contents -= something
			for (var/ref_id in appearance_cache)
				if (appearance_copies[appearance_id] != appearance_cache[ref_id])
					continue
				if (fake_vis[ref_id])
					proxy_view_selected.vis_contents |= fake_vis[ref_id]

			proxy_view_selected.set_position(1, 1)

		if("refreshAppearance")
			update_warning = FALSE
			appearance_copies = list()
			appearance_cache = list()
			for (var/ref_id in fake_vis)
				var/list/all_fakes = fake_vis[ref_id]
				QDEL_LIST(all_fakes)
			fake_vis = list()
			update_static_data_for_all_viewers()

		if("vvAppearance")
			if (!check_rights(R_VAREDIT))
				return
			var/appearance_id = text2num(params["id"])
			usr.client.debug_variables(appearance_copies[appearance_id])

/datum/appearance_debugger/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/plane_background))

/datum/appearance_debugger/ui_state(mob/user)
	return ADMIN_STATE(R_DEBUG)

/datum/appearance_debugger/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AppearanceDebug")
		ui.open()
		proxy_view_hover.display_to(user, ui.window)
		proxy_view_selected.display_to(user, ui.window)

/datum/appearance_debugger/ui_close(mob/user)
	. = ..()
	// Reset appearances when the UI is closed
	proxy_view_hover.appearance = new /mutable_appearance()
	proxy_view_selected.appearance = new /mutable_appearance()
	proxy_view_hover.vis_contents.Cut()
	proxy_view_selected.vis_contents.Cut()
	if (isatom(debug_target))
		UnregisterSignal(debug_target, COMSIG_ATOM_UPDATE_APPEARANCE)

/datum/appearance_debugger/proc/set_target(mutable_appearance/new_target)
	if (isatom(debug_target))
		UnregisterSignal(debug_target, COMSIG_ATOM_UPDATE_APPEARANCE)
	update_warning = FALSE
	// Can be an atom!
	debug_target = new_target
	if (isatom(debug_target))
		RegisterSignal(debug_target, COMSIG_ATOM_UPDATE_APPEARANCE, PROC_REF(warn_update))
	appearance_copies = list()
	appearance_cache = list()
	for (var/ref_id in fake_vis)
		var/list/all_fakes = fake_vis[ref_id]
		QDEL_LIST(all_fakes)
	fake_vis = list()
	update_static_data_for_all_viewers()

/datum/appearance_debugger/proc/warn_update()
	SIGNAL_HANDLER
	update_warning = TRUE
