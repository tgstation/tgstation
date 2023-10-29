/atom/movable/screen/plane_master/parallax_white
	name = "Parallax whitifier"
	documentation = "Essentially a backdrop for the parallax plane. We're rendered just below it, so we'll be multiplied by its well, parallax.\
		<br>If you want something to look as if it has parallax on it, draw it to this plane."
	plane = PLANE_SPACE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_GAME, LIGHT_MASK_PLANE)
	critical = PLANE_CRITICAL_FUCKO_PARALLAX // goes funny when touched. no idea why I don't trust byond

/atom/movable/screen/plane_master/parallax_white/Initialize(mapload, datum/hud/hud_owner, datum/plane_master_group/home, offset)
	. = ..()
	add_relay_to(GET_NEW_PLANE(EMISSIVE_RENDER_PLATE, offset), relay_layer = EMISSIVE_SPACE_LAYER)

///Contains space parallax
/atom/movable/screen/plane_master/parallax
	name = "Parallax"
	documentation = "Contains parallax, or to be more exact the screen objects that hold parallax.\
		<br>Note the BLEND_MULTIPLY. The trick here is how low our plane value is. Because of that, we draw below almost everything in the game.\
		<br>We abuse this to ensure we multiply against the Parallax whitifier plane, or space's plane. It's set to full white, so when you do the multiply you just get parallax out where it well, makes sense to be.\
		<br>Also notice that the parent parallax plane is mirrored down to all children. We want to support viewing parallax across all z levels at once."
	plane = PLANE_SPACE_PARALLAX
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	multiz_scaled = FALSE

/atom/movable/screen/plane_master/parallax/Initialize(mapload, datum/hud/hud_owner, datum/plane_master_group/home, offset)
	. = ..()
	if(offset != 0)
		// You aren't the source? don't change yourself
		return
	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(on_offset_increase))
	RegisterSignal(SSdcs, COMSIG_NARSIE_SUMMON_UPDATE, PROC_REF(narsie_modified))
	if(GLOB.narsie_summon_count >= 1)
		narsie_start_midway(GLOB.narsie_effect_last_modified) // We assume we're on the start, so we can use this number
	offset_increase(0, SSmapping.max_plane_offset)

/atom/movable/screen/plane_master/parallax/proc/on_offset_increase(datum/source, old_offset, new_offset)
	SIGNAL_HANDLER
	offset_increase(old_offset, new_offset)

/atom/movable/screen/plane_master/parallax/proc/offset_increase(old_offset, new_offset)
	// Parallax will be mirrored down to any new planes that are added, so it will properly render across mirage borders
	for(var/offset in old_offset to new_offset)
		if(offset != 0)
			// Overlay so we don't multiply twice, and thus fuck up our rendering
			add_relay_to(GET_NEW_PLANE(plane, offset), BLEND_OVERLAY)

// Hacky shit to ensure parallax works in perf mode
/atom/movable/screen/plane_master/parallax/outside_bounds(mob/relevant)
	if(offset == 0)
		remove_relay_from(GET_NEW_PLANE(RENDER_PLANE_GAME, 0))
		is_outside_bounds = TRUE // I'm sorry :(
		return
	// If we can't render, and we aren't the bottom layer, don't render us
	// This way we only multiply against stuff that's not fullwhite space
	var/atom/movable/screen/plane_master/parent_parallax = home.our_hud.get_plane_master(PLANE_SPACE_PARALLAX)
	var/turf/viewing_turf = get_turf(relevant)
	if(!viewing_turf || offset != GET_LOWEST_STACK_OFFSET(viewing_turf.z))
		parent_parallax.remove_relay_from(plane)
	else
		parent_parallax.add_relay_to(plane, BLEND_OVERLAY)
	return ..()

/atom/movable/screen/plane_master/parallax/inside_bounds(mob/relevant)
	if(offset == 0)
		add_relay_to(GET_NEW_PLANE(RENDER_PLANE_GAME, 0))
		is_outside_bounds = FALSE
		return
	// Always readd, just in case we lost it
	var/atom/movable/screen/plane_master/parent_parallax = home.our_hud.get_plane_master(PLANE_SPACE_PARALLAX)
	parent_parallax.add_relay_to(plane, BLEND_OVERLAY)
	return ..()

// Needs to handle rejoining on a lower z level, so we NEED to readd old planes
/atom/movable/screen/plane_master/parallax/check_outside_bounds()
	// If we're outside bounds AND we're the 0th plane, we need to show cause parallax is hacked to hell
	return offset != 0 && is_outside_bounds

/// Starts the narsie animation midway, so we can catch up to everyone else quickly
/atom/movable/screen/plane_master/parallax/proc/narsie_start_midway(start_time)
	var/time_elapsed = world.time - start_time
	narsie_summoned_effect(max(16 SECONDS - time_elapsed, 0))

/// Starts the narsie animation, make us grey, then red
/atom/movable/screen/plane_master/parallax/proc/narsie_modified(datum/source, new_count)
	SIGNAL_HANDLER
	if(new_count >= 1)
		narsie_summoned_effect(16 SECONDS)
	else
		narsie_unsummoned()

/atom/movable/screen/plane_master/parallax/proc/narsie_summoned_effect(animate_time)
	if(GLOB.narsie_summon_count >= 2)
		var/static/list/nightmare_parallax = list(255,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, -130,0,0,0)
		animate(src, color = nightmare_parallax, time = animate_time)
		return

	var/static/list/grey_parallax = list(0.4,0.4,0.4,0, 0.4,0.4,0.4,0, 0.4,0.4,0.4,0, 0,0,0,1, -0.1,-0.1,-0.1,0)
	// We're gonna animate ourselves grey
	// Then, once it's done, about 40 seconds into the event itself, we're gonna start doin some shit. see below
	animate(src, color = grey_parallax, time = animate_time)

/atom/movable/screen/plane_master/parallax/proc/narsie_unsummoned()
	animate(src, color = null, time = 8 SECONDS)
