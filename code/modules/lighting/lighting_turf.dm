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

	new /datum/lighting_object(src)

/// Returns TRUE if lumcount is below the passed in threshold, FALSE otherwise
/turf/proc/lumcount_below(threshold)
	if(threshold > 1)
		return TRUE
	if (!lighting_object)
		return TRUE

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
	if(totallums >= threshold)
		return FALSE

	for(var/datum/component/overlay_lighting/in_range as anything in SSspatial_grid.orthogonal_range_search(src, SPATIAL_GRID_CONTENTS_TYPE_OVERLAY_LIGHTS, 0))
		if(!in_range.turf_impacted(src))
			continue
		totallums += in_range.lum_power
		if(totallums >= threshold)
			return FALSE

	return TRUE

// Used to get a scaled lumcount.
/turf/proc/get_lumcount(minlum = 0, maxlum = 1)
	if (!lighting_object)
		return 1

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

	totallums += get_dynamic_lumcount()

	return CLAMP01(totallums)

// Returns a boolean whether the turf is on soft lighting.
// Soft lighting being the threshold at which point the overlay considers
// itself as too dark to allow sight and see_in_dark becomes useful.
// So basically if this returns true the tile is unlit black.
/turf/proc/is_softly_lit()
	if (!lighting_object)
		return FALSE

	return !(luminosity || get_dynamic_lumcount())

/// Returns the lumcount from dynamic sources impacting this turf
/turf/proc/get_dynamic_lumcount()
	var/dynamic_lumcount = 0
	// Alright, let's pull from overlay lighting
	// Gonna do this by extracting from overlay lights both near us and that want us
	for(var/obj/effect/abstract/dummy_grid_source/in_range as anything in SSspatial_grid.orthogonal_range_search(src, SPATIAL_GRID_CONTENTS_TYPE_OVERLAY_LIGHTS, 0))
		for(var/datum/component/overlay_lighting/light_in_range as anything in in_range.get_grid_contents(SPATIAL_GRID_CONTENTS_TYPE_OVERLAY_LIGHTS))
			if(!light_in_range.turf_impacted(src))
				continue
			dynamic_lumcount += light_in_range.lum_power
	return dynamic_lumcount


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
