/**
 * Space Initialize
 *
 * Doesn't call parent, see [/atom/proc/Initialize].
 * When adding new stuff to /atom/Initialize, /turf/Initialize, etc
 * don't just add it here unless space actually needs it.
 *
 * There is a lot of work that is intentionally not done because it is not currently used.
 * This includes stuff like smoothing, blocking camera visibility, etc.
 * If you are facing some odd bug with specifically space, check if it's something that was
 * intentionally ommitted from this implementation.
 */
/turf/open/space/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	air = space_gas

	if (PERFORM_ALL_TESTS(focus_only/multiple_space_initialization))
		if(flags_1 & INITIALIZED_1)
			stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1

	// We make the assumption that the space plane will never be blacklisted, as an optimization
	if(SSmapping.max_plane_offset)
		plane = PLANE_SPACE - (PLANE_RANGE * SSmapping.z_level_to_plane_offset[z])

	var/area/our_area = loc
	if(!our_area.area_has_base_lighting && space_lit) //Only provide your own lighting if the area doesn't for you
		// Intentionally not add_overlay for performance reasons.
		// add_overlay does a bunch of generic stuff, like creating a new list for overlays,
		// queueing compile, cloning appearance, etc etc etc that is not necessary here.
		overlays += GLOB.starlight_overlays[GET_TURF_PLANE_OFFSET(src) + 1]

	if (!mapload)
		if(requires_activation)
			SSair.add_to_active(src, TRUE)

		if(SSmapping.max_plane_offset)
			var/turf/T = GET_TURF_ABOVE(src)
			if(T)
				T.multiz_turf_new(src, DOWN)
			T = GET_TURF_BELOW(src)
			if(T)
				T.multiz_turf_new(src, UP)

	return INITIALIZE_HINT_NORMAL
