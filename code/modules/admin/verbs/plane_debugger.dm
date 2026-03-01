/// Used for testing/debugger plane masters and their associated rendering plates
/datum/plane_master_debug
	var/datum/admins/owner
	/// Assoc list of plane master group key -> its depth stack
	var/list/depth_stack = list()
	/// The current plane master group we're viewing
	var/current_group = PLANE_GROUP_MAIN
	/// Weakref to the mob to edit
	var/datum/weakref/mob_ref
	/// Has the target been set explicitly (via VV) or implicitly (via orbit)
	/// Orbit targets will get unset whenever you stop orbiting them
	var/explicit_mirror = FALSE

	var/datum/visual_data/tracking/stored
	var/datum/visual_data/mirroring/mirror
	/// If we are actively mirroring the target of our current ui
	var/mirror_target = FALSE

/datum/plane_master_debug/New(datum/admins/owner)
	src.owner = owner

/datum/plane_master_debug/Destroy()
	if(owner)
		owner.plane_debug = null
		owner = null
	return ..()

/datum/plane_master_debug/proc/set_target(mob/new_mob, explicit = TRUE)
	QDEL_NULL(mirror)
	QDEL_NULL(stored)

	depth_stack = list()
	if(!new_mob?.hud_used)
		new_mob = owner.owner?.mob

	mob_ref = WEAKREF(new_mob)

	if(!mirror_target)
		UnregisterSignal(owner.owner.mob, COMSIG_MOB_LOGOUT)
		return

	RegisterSignal(owner.owner.mob, COMSIG_MOB_LOGOUT, PROC_REF(on_our_logout), override = TRUE)
	mirror = new()
	mirror.shadow(new_mob)
	SStgui.update_uis(owner.owner.mob)

	if(new_mob == owner.owner.mob)
		explicit_mirror = FALSE
		return

	explicit_mirror = explicit
	create_store()

/datum/plane_master_debug/proc/on_our_logout(mob/source)
	SIGNAL_HANDLER
	// Recreate our stored view, since we've changed mobs now
	create_store()
	UnregisterSignal(source, COMSIG_MOB_LOGOUT)
	RegisterSignal(owner.owner.mob, COMSIG_MOB_LOGOUT, PROC_REF(on_our_logout), override = TRUE)

/// Create or refresh our stored visual data, represeting the viewing mob
/datum/plane_master_debug/proc/create_store()
	if(stored)
		QDEL_NULL(stored)
	stored = new()
	stored.shadow(owner.owner.mob)
	stored.set_truth(mirror)
	mirror.set_mirror_target(owner.owner.mob)

/datum/plane_master_debug/proc/get_target()
	var/mob/cur_target = mob_ref?.resolve()
	var/mob/target = cur_target
	if(!target?.hud_used || !explicit_mirror)
		target = owner.owner.mob
		if (ismob(target.orbit_target)) // If we're orbiting someone, swap to them if possible
			var/mob/as_mob = target.orbit_target
			if (as_mob.hud_used)
				target = target.orbit_target
		if (cur_target != target)
			set_target(target, FALSE)
	return target

/// Setter for mirror_target, basically allows for enabling/disabiling viewing through mob's sight
/datum/plane_master_debug/proc/set_mirroring(value)
	if(value == mirror_target)
		return
	mirror_target = value
	// Refresh our target and mirrors and such, but keep explicit/implicit mirroring
	set_target(get_target(), explicit_mirror)

/datum/plane_master_debug/ui_state(mob/user)
	return ADMIN_STATE(R_DEBUG)

/datum/plane_master_debug/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlaneMasterDebug")
		ui.open()

/datum/plane_master_debug/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/plane_background))

/datum/plane_master_debug/ui_data()
	var/list/data = list()

	var/mob/reference_frame = get_target()
	data["mob_name"] = reference_frame.name
	data["mob_ref"] = ref(reference_frame)
	data["our_ref"] = ref(owner.owner.mob)
	data["tracking_active"] = mirror_target

	var/datum/hud/our_hud = reference_frame.hud_used
	var/list/our_groups = our_hud.master_groups
	if (!our_groups[current_group])
		// We assume we'll always have at least one group
		current_group = our_groups[length(our_hud.master_groups)]

	var/list/groups = list()
	for (var/key in our_groups)
		groups += key

	data["enable_group_view"] = length(groups) > 1
	data["our_group"] = current_group
	data["present_groups"] = groups

	var/list/plane_info = list()

	var/list/our_planes = our_hud?.get_planes_from(current_group)
	for (var/plane_string in our_planes)
		var/list/this_plane = list()
		var/atom/movable/screen/plane_master/plane = our_planes[plane_string]
		this_plane["name"] = plane.name
		this_plane["documentation"] = plane.documentation
		this_plane["plane"] = plane.plane
		this_plane["offset"] = plane.offset
		this_plane["real_plane"] = plane.real_plane
		this_plane["renders_onto"] = plane.render_relay_planes
		this_plane["blend_mode"] = GLOB.blend_names["[plane.blend_mode_override || initial(plane.blend_mode)]"]
		this_plane["color"] = plane.color
		this_plane["alpha"] = plane.alpha
		this_plane["render_target"] = plane.render_target
		this_plane["force_hidden"] = plane.force_hidden

		var/list/relays = list()
		var/list/filters = list()

		for (var/atom/movable/render_plane_relay/relay as anything in plane.relays)
			var/list/this_relay = list()
			this_relay["name"] = relay.name
			this_relay["source"] = plane.plane
			this_relay["target"] = relay.plane
			this_relay["layer"] = relay.layer
			this_relay["our_ref"] = "[plane.plane]-[relay.plane]"
			this_relay["blend_mode"] = GLOB.blend_names["[relay.blend_mode]"]
			relays += list(this_relay)

		for (var/list/filter in plane.filter_data)
			if(!filter["render_source"])
				continue

			var/list/filter_info = filter.Copy()
			filter_info["our_ref"] = "[plane.plane]-[filter_info["name"]]"
			filters += list(filter_info)

		this_plane["relays"] = relays
		this_plane["filters"] = filters

		plane_info += list(this_plane)

	data["planes"] += plane_info
	return data

/datum/plane_master_debug/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/reference_frame = get_target()
	var/datum/hud/our_hud = reference_frame.hud_used
	var/datum/plane_master_group/group = our_hud?.master_groups[current_group]
	if(!group) // Nothing to act on
		return
	var/list/our_planes = group.plane_masters

	switch(action)
		if("rebuild")
			group.rebuild_hud()

		if("reset_mob")
			set_target(null)

		if("toggle_mirroring")
			set_mirroring(!mirror_target)

		if("vv_mob")
			owner.owner.debug_variables(reference_frame)

		if("set_group")
			current_group = params["target_group"]

		if("connect_relay")
			var/source_plane = params["source"]
			var/target_plane = params["target"]
			var/blend_mode = text2num(params["mode"])
			var/atom/movable/screen/plane_master/source = our_planes["[source_plane]"]
			if(source.get_relay_to(target_plane)) // Fuck off
				return
			source.add_relay_to(target_plane, blend_mode != BLEND_DEFAULT ? blend_mode : null)
			return TRUE

		if("disconnect_relay")
			var/source_plane = params["source"]
			var/target_plane = params["target"]
			var/atom/movable/screen/plane_master/source = our_planes["[source_plane]"]
			source.remove_relay_from(text2num(target_plane))
			return TRUE

		if("disconnect_filter")
			var/target_plane = params["target"]
			var/atom/movable/screen/plane_master/filtered_plane = our_planes["[target_plane]"]
			filtered_plane.remove_filter(params["name"])
			return TRUE

		if("vv_plane")
			var/plane_edit = params["edit"]
			var/atom/movable/screen/plane_master/edit = our_planes["[plane_edit]"]
			var/mob/user = ui.user
			user?.client?.debug_variables(edit)
			return TRUE

		if("set_alpha")
			var/plane_edit = params["edit"]
			var/atom/movable/screen/plane_master/edit = our_planes["[plane_edit]"]
			var/newalpha = params["alpha"]
			animate(edit, 0.4 SECONDS, alpha = newalpha)
			return TRUE

		if("edit_color_matrix")
			var/plane_edit = params["edit"]
			var/atom/movable/screen/plane_master/edit = our_planes["[plane_edit]"]
			var/mob/user = ui.user
			user?.client?.open_color_matrix_editor(edit)
			return TRUE

		if("edit_filters")
			var/plane_edit = params["edit"]
			var/atom/movable/screen/plane_master/edit = our_planes["[plane_edit]"]
			var/mob/user = ui.user
			user?.client?.open_filter_editor(edit)
			return TRUE

/datum/plane_master_debug/ui_close(mob/user)
	. = ..()
	set_mirroring(FALSE)
