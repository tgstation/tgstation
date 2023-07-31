/atom/movable/lighting_object
	name = ""
	anchored = TRUE
	icon = LIGHTING_ICON
	icon_state = null
	plane = LIGHTING_PLANE
	color = null //we manually set color in init instead
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING
	vis_flags = VIS_HIDE
	///whether we are already in the SSlighting.objects_queue list
	var/needs_update = FALSE

	///the turf that our light is applied to
	var/turf/affected_turf

/atom/movable/lighting_object/Initialize(mapload)
	if(!isturf(loc))
		qdel(src, force=TRUE)
		stack_trace("a lighting object was assigned to [loc], a non turf! ")
		return

	. = ..()

	verbs.Cut()

	affected_turf = loc
	if (affected_turf.lighting_object)
		qdel(affected_turf.lighting_object, force = TRUE)
		stack_trace("a lighting object was assigned to a turf that already had a lighting object!")

	affected_turf.lighting_object = src
	// Default to fullbright, so things can "see" if they use view() before we update
	affected_turf.luminosity = 0
	luminosity = 1

	// This path is really hot. this is faster
	// Really this should be a global var or something, but lets not think about that yes?
	for(var/turf/open/space/space_tile in RANGE_TURFS(1, affected_turf))
		space_tile.enable_starlight()

	needs_update = TRUE
	SSlighting.objects_queue += src

/atom/movable/lighting_object/Destroy(force)
	if (!force)
		return QDEL_HINT_LETMELIVE
	SSlighting.objects_queue -= src
	if (loc != affected_turf)
		var/turf/oldturf = get_turf(affected_turf)
		var/turf/newturf = get_turf(loc)
		stack_trace("A lighting object was qdeleted with a different loc then it is suppose to have ([COORD(oldturf)] -> [COORD(newturf)])")
	if (isturf(affected_turf))
		affected_turf.lighting_object = null
		affected_turf.luminosity = 1
	affected_turf = null
	return ..()

/atom/movable/lighting_object/proc/update()
	var/turf/affected_turf = src.affected_turf

	if (loc != affected_turf)
		if (loc)
			var/turf/oldturf = get_turf(affected_turf)
			var/turf/newturf = get_turf(loc)
			warning("A lighting object realised it's loc had changed in update() ([affected_turf]\[[affected_turf ? affected_turf.type : "null"]]([COORD(oldturf)]) -> [loc]\[[ loc ? loc.type : "null"]]([COORD(newturf)]))!")

		qdel(src, TRUE)
		return

	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

#ifdef VISUALIZE_LIGHT_UPDATES
	affected_turf.add_atom_colour(COLOR_BLUE_LIGHT, ADMIN_COLOUR_PRIORITY)
	animate(affected_turf, 10, color = null)
	addtimer(CALLBACK(affected_turf, TYPE_PROC_REF(/atom, remove_atom_colour), ADMIN_COLOUR_PRIORITY, COLOR_BLUE_LIGHT), 10, TIMER_UNIQUE|TIMER_OVERRIDE)
#endif

	var/datum/lighting_corner/red_corner = affected_turf.lighting_corner_SW || dummy_lighting_corner
	var/datum/lighting_corner/green_corner = affected_turf.lighting_corner_SE || dummy_lighting_corner
	var/datum/lighting_corner/blue_corner = affected_turf.lighting_corner_NW || dummy_lighting_corner
	var/datum/lighting_corner/alpha_corner = affected_turf.lighting_corner_NE || dummy_lighting_corner

	var/max = max(red_corner.largest_color_luminosity, green_corner.largest_color_luminosity, blue_corner.largest_color_luminosity, alpha_corner.largest_color_luminosity)


	#if LIGHTING_SOFT_THRESHOLD != 0
	var/set_luminosity = max > LIGHTING_SOFT_THRESHOLD
	#else
	// Because of floating points™?, it won't even be a flat 0.
	// This number is mostly arbitrary.
	var/set_luminosity = max > 1e-6
	#endif

	if(!set_luminosity)
		icon_state = "lighting_dark"
		color = null
	else
		icon_state = null
		color = list(
			red_corner.cache_r, red_corner.cache_g, red_corner.cache_b, 00,
			green_corner.cache_r, green_corner.cache_g, green_corner.cache_b, 00,
			blue_corner.cache_r, blue_corner.cache_g, blue_corner.cache_b, 00,
			alpha_corner.cache_r, alpha_corner.cache_g, alpha_corner.cache_b, 00,
			00, 00, 00, 01
		)

	luminosity = set_luminosity

// Variety of overrides so the overlays don't get affected by weird things.

/atom/movable/lighting_object/ex_act(severity)
	return FALSE

/atom/movable/lighting_object/singularity_act()
	return

/atom/movable/lighting_object/singularity_pull()
	return

/atom/movable/lighting_object/blob_act()
	return

/atom/movable/lighting_object/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents = TRUE)
	SHOULD_CALL_PARENT(FALSE)
	return

/atom/movable/lighting_object/wash(clean_types)
	SHOULD_CALL_PARENT(FALSE) // lighting objects are dirty, confirmed
	return

// Override here to prevent things accidentally moving around overlays.
/atom/movable/lighting_object/forceMove(atom/destination, no_tp = FALSE, harderforce = FALSE)
	if(harderforce)
		return ..()
