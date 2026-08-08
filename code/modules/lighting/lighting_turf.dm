// Causes any affecting light sources to be queued for a visibility update, for example a door got opened.
/turf/proc/reconsider_lights()
	lighting_corner_NE?.vis_update()
	lighting_corner_SE?.vis_update()
	lighting_corner_SW?.vis_update()
	lighting_corner_NW?.vis_update()

/turf/proc/lighting_clear_overlay()
	if (lighting_object)
		qdel(lighting_object, force=TRUE)

// Builds a lighting object for us, but only if our area is dynamic.
/turf/proc/lighting_build_overlay()
	if (lighting_object)
		qdel(lighting_object, force=TRUE) //Shitty fix for lighting objects persisting after death

	new /atom/movable/lighting_object(null, src)

/// Used to get a scaled lumcount.
/turf/proc/get_lumcount(minlum = 0, maxlum = 1)
	if (!lighting_object)
		return 1

	var/totallums = get_static_lumcount(minlum, maxlum)
	totallums += get_dynamic_lumcount()
	return CLAMP01(totallums)

// Kyler was worried about cost of having these use assoc args, so they're split ~smartkar
// Also easier to use this way
/// Optimized get_lumcount for when you only care if the lumcount is below a certain value, and not what the actual value is
/turf/proc/check_lumcount_below(value)
	if (!lighting_object)
		return FALSE

	var/lums = get_static_lumcount()
	if (lums >= value)
		return FALSE

	for (var/datum/component/overlay_lighting/light as anything in collect_dynamic_lightsources())
		lums += light.lum_power
		if (lums >= value)
			return FALSE
	return TRUE

/// Optimized get_lumcount for when you only care if the lumcount is above a certain value, and not what the actual value is
/turf/proc/check_lumcount_above(value)
	if (!lighting_object)
		return TRUE

	var/lums = get_static_lumcount()
	if (lums > value)
		return TRUE

	for (var/datum/component/overlay_lighting/light as anything in collect_dynamic_lightsources())
		lums += light.lum_power
		if (lums > value)
			return TRUE
	return FALSE

/// Returns lumcount from turf lighting
/turf/proc/get_static_lumcount(minlum = 0, maxlum = 1)
	var/totallums = 0
	var/datum/lighting_corner/L
	L = lighting_corner_NE
	if (L)
		totallums += L.lum_r + L.lum_b + L.lum_g
	L = lighting_corner_SE
	if (L)
		totallums += L.lum_r + L.lum_b + L.lum_g
	L = lighting_corner_SW
	if (L)
		totallums += L.lum_r + L.lum_b + L.lum_g
	L = lighting_corner_NW
	if (L)
		totallums += L.lum_r + L.lum_b + L.lum_g

	totallums /= 12 // 4 corners, each with 3 channels, get the average.
	totallums = (totallums - minlum) / (maxlum - minlum)

/// Fetches dynamic lumcount from lightsources potentially in view of this turf from our spatial grid
/turf/proc/get_dynamic_lumcount()
	. = 0
	for (var/datum/component/overlay_lighting/light as anything in collect_dynamic_lightsources())
		. += light.lum_power

// You've heard of oranges_ear, prepare for oranges_eye
/// Uses the same optimization via viewers() that get_hearers_in_view does by allocating oranges ears to overlay lights
/// And collecting viewers rather than checking view() for each one of them
/turf/proc/collect_dynamic_lightsources()
	. = list()

	var/datum/spatial_grid_cell/grid_cell = SSspatial_grid.get_cell_of(src)
	var/list/light_sources = list()
	var/furthest_range = 0
	for (var/datum/component/overlay_lighting/light as anything in grid_cell.dynamic_light_sources)
		furthest_range = max(furthest_range, light.lumcount_range)
		if (isnull(light_sources[light.current_holder]))
			light_sources[light.current_holder] = light
		else if (islist(light_sources[light.current_holder]))
			light_sources[light.current_holder] |= light
		else
			light_sources[light.current_holder] = list(light_sources[light.current_holder], light)

	var/list/assigned_oranges_ears = SSspatial_grid.assign_oranges_ears(light_sources)
	for(var/mob/oranges_ear/ear in hearers(furthest_range, src))
		for (var/atom/glowie as anything in ear.references)
			. += light_sources[glowie]

	for(var/mob/oranges_ear/remaining_ear as anything in assigned_oranges_ears)
		remaining_ear.unassign()

// Returns a boolean whether the turf is on soft lighting.
// Soft lighting being the threshold at which point the overlay considers
// itself as too dark to allow sight and see_in_dark becomes useful.
// So basically if this returns true the tile is unlit black.
/turf/proc/is_softly_lit()
	if (!lighting_object)
		return FALSE

	return !(luminosity || get_dynamic_lumcount())


///Proc to add movable sources of opacity on the turf and let it handle lighting code.
/turf/proc/add_opacity_source(atom/movable/new_source)
	LAZYADD(opacity_sources, new_source)
	if(opacity)
		return
	recalculate_directional_opacity()


///Proc to remove movable sources of opacity on the turf and let it handle lighting code.
/turf/proc/remove_opacity_source(atom/movable/old_source)
	LAZYREMOVE(opacity_sources, old_source)
	if(opacity) //Still opaque, no need to worry on updating.
		return
	recalculate_directional_opacity()


///Calculate on which directions this turfs block view.
/turf/proc/recalculate_directional_opacity()
	. = directional_opacity
	if(opacity)
		directional_opacity = ALL_CARDINALS
		if(. != directional_opacity)
			reconsider_lights()
		return
	directional_opacity = NONE
	if(opacity_sources)
		for(var/atom/movable/opacity_source as anything in opacity_sources)
			if(opacity_source.flags_1 & ON_BORDER_1)
				directional_opacity |= opacity_source.dir
			else //If fulltile and opaque, then the whole tile blocks view, no need to continue checking.
				directional_opacity = ALL_CARDINALS
				break
	else
		for(var/atom/movable/content as anything in contents)
			SEND_SIGNAL(content, COMSIG_TURF_NO_LONGER_BLOCK_LIGHT)
	if(. != directional_opacity && (. == ALL_CARDINALS || directional_opacity == ALL_CARDINALS))
		reconsider_lights() //The lighting system only cares whether the tile is fully concealed from all directions or not.

///Transfer the lighting of one area to another
/turf/proc/transfer_area_lighting(area/old_area, area/new_area)
	if(SSlighting.initialized && !space_lit)
		if (new_area.static_lighting != old_area.static_lighting)
			if (new_area.static_lighting)
				lighting_build_overlay()
			else
				lighting_clear_overlay()

	// We will only run this logic on turfs off the prime z layer
	// Since on the prime z layer, we use an overlay on the area instead, to save time
	if(SSmapping.z_level_to_plane_offset[z])
		var/index = SSmapping.z_level_to_plane_offset[z] + 1
		//Inherit overlay of new area
		if(old_area.lighting_effects)
			cut_overlay(old_area.lighting_effects[index])
		if(new_area.lighting_effects)
			add_overlay(new_area.lighting_effects[index])

	// Manage removing/adding starlight overlays, we'll inherit from the area so we can drop it if the area has it already
	if(space_lit)
		if(!new_area.lighting_effects && old_area.lighting_effects)
			overlays += GLOB.starlight_overlays[GET_TURF_PLANE_OFFSET(src) + 1]
		else if (new_area.lighting_effects && !old_area.lighting_effects)
			overlays -= GLOB.starlight_overlays[GET_TURF_PLANE_OFFSET(src) + 1]
