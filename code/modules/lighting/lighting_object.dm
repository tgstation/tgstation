/datum/lighting_object
	///the underlay we are currently applying to our turf to apply light
	var/mutable_appearance/current_underlay

	///whether we are already in the SSlighting.objects_queue list
	var/needs_update = FALSE

	///the turf that our light is applied to
	var/turf/affected_turf

// Global list of lighting underlays, indexed by z level
GLOBAL_LIST_EMPTY(default_lighting_underlays_by_z)

/datum/lighting_object/New(turf/source)
	if(!isturf(source))
		qdel(src, force=TRUE)
		stack_trace("a lighting object was assigned to [source], a non turf! ")
		return

	. = ..()

	current_underlay = new(GLOB.default_lighting_underlays_by_z[source.z])

	affected_turf = source
	if (affected_turf.lighting_object)
		qdel(affected_turf.lighting_object, force = TRUE)
		stack_trace("a lighting object was assigned to a turf that already had a lighting object!")

	affected_turf.lighting_object = src
	// Default to fullbright, so things can "see" if they use view() before we update
	affected_turf.luminosity = 1

	// This path is really hot. this is faster
	// Really this should be a global var or something, but lets not think about that yes?
	for(var/turf/open/space/space_tile in RANGE_TURFS(1, affected_turf))
		space_tile.enable_starlight()

	needs_update = TRUE
	SSlighting.objects_queue += src

/datum/lighting_object/Destroy(force)
	if (!force)
		return QDEL_HINT_LETMELIVE
	SSlighting.objects_queue -= src
	if (isturf(affected_turf))
		affected_turf.lighting_object = null
		affected_turf.luminosity = 1
		affected_turf.underlays -= current_underlay
	affected_turf = null
	return ..()

/datum/lighting_object/proc/update()
	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

	var/turf/affected_turf = src.affected_turf

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

	var/mutable_appearance/current_underlay = src.current_underlay
	affected_turf.underlays -= current_underlay
	if(red_corner.cache_r & green_corner.cache_r & blue_corner.cache_r & alpha_corner.cache_r && \
		(red_corner.cache_g + green_corner.cache_g + blue_corner.cache_g + alpha_corner.cache_g + \
		red_corner.cache_b + green_corner.cache_b + blue_corner.cache_b + alpha_corner.cache_b == 8))
		//anything that passes the first case is very likely to pass the second, and addition is a little faster in this case
		current_underlay.icon_state = "lighting_transparent"
		current_underlay.color = null
	else if(!set_luminosity)
		current_underlay.icon_state = "lighting_dark"
		current_underlay.color = null
	else
		current_underlay.icon_state = null
		current_underlay.color = list(
			red_corner.cache_r, red_corner.cache_g, red_corner.cache_b, 00,
			green_corner.cache_r, green_corner.cache_g, green_corner.cache_b, 00,
			blue_corner.cache_r, blue_corner.cache_g, blue_corner.cache_b, 00,
			alpha_corner.cache_r, alpha_corner.cache_g, alpha_corner.cache_b, 00,
			00, 00, 00, 01
		)

	// Of note. Most of the cost in this proc is here, I think because color matrix'd underlays DO NOT cache well, which is what adding to underlays does
	// We use underlays because objects on each tile would fuck with maptick. if that ever changes, use an object for this instead
	affected_turf.underlays += current_underlay
	affected_turf.luminosity = set_luminosity
