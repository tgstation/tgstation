/// Allows developers to see a breakdown of an atom or a specific target and edit some of the values
/datum/appearance_debugger
	var/datum/admins/owner
	/// Currently debugged atom or mutable appearance, hence /datum
	var/datum/debug_target
	/// A list of copies of the currently debugged appearance and its children for access from the UI
	var/list/mutable_appearance/appearance_copies
	/// Assoc list of ref -> appearance as to prevent refreshing of dynamic appearances
	var/list/mutable_appearance/appearance_cache
	/// Mapview used to display the targeted appearance
	var/atom/movable/screen/map_view/proxy_view

/datum/appearance_debugger/New(datum/admins/owner)
	src.owner = owner
	proxy_view = new()
	proxy_view.generate_view("appearance_debugger_[REF(owner)]_proxy")

/datum/appearance_debugger/Destroy()
	if(owner)
		owner.appearance_debug = null
		owner = null
	QDEL_NULL(proxy_view)
	return ..()

/datum/appearance_debugger/proc/get_appearance_data(atom/appearance_owner)
	var/mutable_appearance/target = appearance_owner
	if (isatom(appearance_owner))
		target = appearance_cache["[REF(appearance_owner)]"] || appearance_owner.appearance
		appearance_cache["[REF(appearance_owner)]"] = target

	var/list/data = list(
		"type" = isatom(appearance_owner) ? "atom" : (isimage(target) ? "image" : "appearance"),
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
	if (ismovable(appearance_owner))
		var/atom/movable/as_movable = appearance_owner
		data["vis_flags"] = as_movable.vis_flags
		// Maybe should be cached but I'm too lazy and don't think this'll matter enough
		var/list/vis_data = list()
		for (var/atom/vis_thing as anything in as_movable.vis_contents)
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

/datum/appearance_debugger/ui_static_data(mob/user)
	var/mutable_appearance/debug_appearance = new(debug_target)
	return list(
		"mainAppearance" = get_appearance_data(debug_appearance),
		"planeToText" = GLOB.admin_readable_planes,
		"layerToText" = GLOB.admin_readable_layers,
		"mapRef" = proxy_view.assigned_map,
	)

/datum/appearance_debugger/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("swapMapView")
			var/appearance_id = text2num(params["id"])
			proxy_view.appearance = appearance_copies[appearance_id]
			// Needs screenloc to be set since we're setting the appearance and carrying over target's screenloc
			proxy_view.set_position(1, 1)

		if("refreshAppearance")
			appearance_copies = list()
			appearance_cache = list()
			update_static_data_for_all_viewers()

/datum/appearance_debugger/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/plane_background))

/datum/appearance_debugger/ui_state(mob/user)
	return ADMIN_STATE(R_DEBUG)

/datum/appearance_debugger/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AppearanceDebug")
		ui.open()
		proxy_view.display_to(user, ui.window)

/datum/appearance_debugger/proc/set_target(mutable_appearance/new_target)
	// Can be an atom!
	debug_target = new_target
	appearance_copies = list()
	appearance_cache = list()
	update_static_data_for_all_viewers()
