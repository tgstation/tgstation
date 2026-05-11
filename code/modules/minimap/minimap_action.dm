/**
 * Action that gives the owner access to the minimap pool
 */
/datum/action/minimap
	name = "Toggle Minimap"
	button_icon = 'icons/hud/implants.dmi'
	button_icon_state = "minimap"
	///Flags to allow the owner to see others of this type
	var/minimap_flags = MINIMAP_FLAG_ALL
	///marker flags this will give the target, mostly used for marine minimaps
	var/marker_flags = MINIMAP_FLAG_ALL
	///boolean as to whether the minimap is currently shown
	var/minimap_displayed = FALSE
	///Minimap object we'll be displaying
	var/atom/movable/screen/minimap/map_object
	///Overrides what the locator tracks aswell what z the map displays as opposed to always tracking the minimap's owner. Default behavior when null.
	var/atom/movable/locator_override
	///Minimap "You are here" indicator for when it's up
	var/atom/movable/screen/minimap_locator/locator
	///button granted when you're on a multiz level that lets you check above and below you
	var/atom/movable/screen/minimap_extras/minimap_z_indicator/z_indicator
	///button granted when you're on a multiz level that lets you check above and below you
	var/atom/movable/screen/minimap_extras/minimap_z_up/z_up
	///button granted when you're on a multiz level that lets you check above and below you
	var/atom/movable/screen/minimap_extras/minimap_z_down/z_down
	///Sets a fixed z level to be tracked by this minimap action instead of being influenced by the owner's / locator override's z level.
	var/default_overwatch_level = 0
	///Reference to the map datum we display
	var/datum/tactical_map/my_map
	/// Current z-level that we are showing on the minimap
	var/current_z_shown
	/// minimap state, if it's open or not
	var/active = FALSE
	/// z-traits where this minimap action cannot be opened and is forced closed.
	var/list/minimap_ztrait_blacklist = list(
		ZTRAIT_CENTCOM,
		ZTRAIT_RESERVED,
	)
	/// list of z-trait overrides to show another z-trait's map
	var/list/minimap_ztrait_overrides = list(
		ZTRAIT_CENTCOM = ZTRAIT_STATION,
		ZTRAIT_RESERVED = ZTRAIT_STATION
	)

/datum/action/minimap/New(Target, new_minimap_flags, new_marker_flags, tactical_map)
	. = ..()
	my_map = tactical_map
	locator = new
	locator.my_map = tactical_map
	z_indicator = new
	z_indicator.minimap_action = src
	z_up = new
	z_up.minimap_action = src
	z_down = new
	z_down.minimap_action = src

	if(new_minimap_flags)
		minimap_flags = new_minimap_flags
	if(new_marker_flags)
		marker_flags = new_marker_flags

/datum/action/minimap/Destroy()
	map_object = null
	locator_override = null
	QDEL_NULL(locator)
	QDEL_NULL(z_indicator)
	QDEL_NULL(z_up)
	QDEL_NULL(z_down)
	return ..()

/datum/action/minimap/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!map_object)
		return FALSE

	return toggle_minimap()

/// Toggles the minimap, has a variable to force on or off (most likely only going to be used to close it)
/datum/action/minimap/proc/toggle_minimap(force_state)
	// No force state? Invert the current state
	if(isnull(force_state))
		force_state = !minimap_displayed
	if(force_state == minimap_displayed)
		return FALSE
	if(!locator_override && ismovable(owner.loc))
		override_locator(owner.loc)
	var/atom/movable/tracking = locator_override ? locator_override : owner
	if(force_state)
		if(is_blacklisted_minimap_z(tracking?.z))
			to_chat(owner, span_warning("The minimap cannot be used on this z-level."))
			return FALSE
		if(locate(/atom/movable/screen/minimap) in owner.client.screen) //This seems like the most effective way to do this without some wacky code
			to_chat(owner, span_warning("You already have a minimap open!"))
			return FALSE
		owner.client.screen += map_object
		if(length(SSmapping.get_connected_levels(map_object.tracked_z)) > 1)
			owner.client.screen += z_indicator
			owner.client.screen += z_up
			owner.client.screen += z_down
		update_locator_visibility(tracking, map_object.tracked_z)
		my_map.process()
		my_map.add_viewer(owner)
	else
		if(owner.client)
			owner.client.screen -= map_object
			owner.client.screen -= locator
			owner.client.screen -= z_indicator
			owner.client.screen -= z_up
			owner.client.screen -= z_down
		map_object.stop_polling -= owner
		locator.UnregisterSignal(tracking, COMSIG_MOVABLE_MOVED)
		my_map.remove_viewer(owner)
	minimap_displayed = force_state
	return TRUE

///Overrides the minimap locator to a given atom
/datum/action/minimap/proc/override_locator(atom/movable/to_track)
	var/atom/movable/tracking = locator_override ? locator_override : owner
	var/atom/movable/new_track = to_track ? to_track : owner
	if(locator_override)
		clear_locator_override()
	if(owner)
		UnregisterSignal(tracking, COMSIG_MOVABLE_Z_CHANGED)
	if(!minimap_displayed)
		locator_override = to_track
		if(to_track)
			RegisterSignal(to_track, COMSIG_QDELETING, TYPE_PROC_REF(/datum/action/minimap, clear_locator_override))
			if(owner && owner.loc == to_track)
				RegisterSignal(to_track, COMSIG_ATOM_EXITED, TYPE_PROC_REF(/datum/action/minimap, on_exit_check))
		if(owner)
			RegisterSignal(new_track, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_owner_z_change))
			var/turf/old_turf = get_turf(tracking)
			if(!old_turf || !old_turf.z || old_turf.z != new_track.z)
				on_owner_z_change(new_track, old_turf?.z, new_track?.z)
		return
	locator.UnregisterSignal(tracking, COMSIG_MOVABLE_MOVED)
	locator_override = to_track
	if(to_track)
		RegisterSignal(to_track, COMSIG_QDELETING, TYPE_PROC_REF(/datum/action/minimap, clear_locator_override))
		if(owner.loc == to_track)
			RegisterSignal(to_track, COMSIG_ATOM_EXITED, TYPE_PROC_REF(/datum/action/minimap, on_exit_check))
	RegisterSignal(new_track, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_owner_z_change))
	var/turf/old_turf = get_turf(tracking)
	if(old_turf.z != new_track.z)
		on_owner_z_change(new_track, old_turf.z, new_track.z)
	locator.RegisterSignal(new_track, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/atom/movable/screen/minimap_locator, update))
	locator.update(new_track)

///checks if we should clear override if the owner exits this atom
/datum/action/minimap/proc/on_exit_check(datum/source, atom/movable/mover)
	SIGNAL_HANDLER
	if(mover && mover != owner)
		return
	clear_locator_override()

///CLears the locator override in case the override target is deleted
/datum/action/minimap/proc/clear_locator_override()
	SIGNAL_HANDLER
	if(!locator_override)
		return
	UnregisterSignal(locator_override, list(COMSIG_QDELETING, COMSIG_ATOM_EXITED))
	if(owner)
		UnregisterSignal(locator_override, COMSIG_MOVABLE_Z_CHANGED)
		RegisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_owner_z_change))
		var/turf/owner_turf = get_turf(owner)
		if(owner_turf.z != locator_override.z)
			on_owner_z_change(owner, locator_override.z, owner_turf.z)
	if(minimap_displayed)
		update_locator_visibility(owner, current_z_shown)
	locator_override = null

/datum/action/minimap/Grant(mob/grant_to)
	. = ..()
	var/atom/movable/tracking = locator_override ? locator_override : grant_to
	RegisterSignal(tracking, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_owner_z_change))
	var/shown_z = default_overwatch_level ? default_overwatch_level : get_overridden_map_z(tracking.z)
	z_indicator.set_indicated_z(shown_z)
	current_z_shown = shown_z
	if(default_overwatch_level)
		if(!my_map.minimaps_by_z["[default_overwatch_level]"] || !my_map.minimaps_by_z["[default_overwatch_level]"].hud_image)
			return
		map_object = my_map.fetch_minimap_object(default_overwatch_level, minimap_flags)
		return
	if(!my_map.minimaps_by_z["[tracking.z]"] || !my_map.minimaps_by_z["[tracking.z]"].hud_image)
		return
	map_object = my_map.fetch_minimap_object(tracking.z, minimap_flags)

/datum/action/minimap/Remove(mob/remove_from)
	toggle_minimap(FALSE)
	UnregisterSignal(locator_override || remove_from, COMSIG_MOVABLE_Z_CHANGED)
	return ..()

/**
 * Updates the map when the owner changes zlevel
 */
/datum/action/minimap/proc/on_owner_z_change(atom/movable/source, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER
	if(is_blacklisted_minimap_z(new_turf?.z))
		if(minimap_displayed)
			toggle_minimap(FALSE)
			to_chat(owner, span_warning("Cannot view this z-level!"))
		return
	change_z_shown(new_turf.z)

/datum/action/minimap/proc/is_blacklisted_minimap_z(z_level)
	if(isnull(z_level))
		return FALSE
	for(var/trait in minimap_ztrait_blacklist)
		if(SSmapping.level_trait(z_level, trait))
			return TRUE
	return FALSE

/// changes the currently to be displayed z. takes the new z as an arg
/datum/action/minimap/proc/change_z_shown(newz)
	var/atom/movable/tracking = locator_override ? locator_override : owner
	if(minimap_displayed)
		owner.client?.screen -= map_object
	var/old_map_z = map_object?.tracked_z
	map_object = null

	var/new_z_shown = get_overridden_map_z(newz)
	if(minimap_displayed)
		var/new_z_is_multiz = length(SSmapping.get_connected_levels(new_z_shown)) > 1
		var/old_z_is_multiz = old_map_z ? length(SSmapping.get_connected_levels(old_map_z)) > 1 : FALSE
		if(old_z_is_multiz != new_z_is_multiz)
			if(new_z_is_multiz)
				owner.client.screen += z_indicator
				owner.client.screen += z_up
				owner.client.screen += z_down
			else
				owner.client.screen -= z_indicator
				owner.client.screen -= z_up
				owner.client.screen -= z_down

	z_indicator.set_indicated_z(new_z_shown)
	current_z_shown = new_z_shown
	if(!my_map.minimaps_by_z["[new_z_shown]"] || !my_map.minimaps_by_z["[new_z_shown]"].hud_image)
		if(minimap_displayed)
			owner.client?.screen -= locator
			locator.UnregisterSignal(tracking, COMSIG_MOVABLE_MOVED)
			minimap_displayed = FALSE
		return
	map_object = my_map.fetch_minimap_object(new_z_shown, minimap_flags)
	if(minimap_displayed)
		if(owner.client)
			owner.client.screen += map_object
			update_locator_visibility(tracking, new_z_shown)
		else
			minimap_displayed = FALSE

/// Returns TRUE when the locator should be displayed for the currently shown map z-level.
/datum/action/minimap/proc/should_show_locator(atom/movable/tracking, shown_z)
	return tracking?.z == shown_z

/// Updates locator visibility and movement signal registration based on the shown z-level.
/datum/action/minimap/proc/update_locator_visibility(atom/movable/tracking, shown_z)
	if(!owner?.client)
		return
	locator.UnregisterSignal(tracking, COMSIG_MOVABLE_MOVED)
	if(!should_show_locator(tracking, shown_z))
		owner.client.screen -= locator
		return
	owner.client.screen += locator
	locator.update(tracking)
	locator.RegisterSignal(tracking, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/atom/movable/screen/minimap_locator, update))

			/// Returns the z-level that should be displayed on minimap after applying trait-based overrides.
/datum/action/minimap/proc/get_overridden_map_z(z_level)
	for(var/source_trait in minimap_ztrait_overrides)
		if(!SSmapping.level_trait(z_level, source_trait))
			continue
		var/target_trait = minimap_ztrait_overrides[source_trait]
		var/list/target_levels = SSmapping.levels_by_trait(target_trait)
		if(!length(target_levels))
			return z_level
		target_levels = sort_list(target_levels, GLOBAL_PROC_REF(cmp_numeric_asc))
		return target_levels[1]
	return z_level
