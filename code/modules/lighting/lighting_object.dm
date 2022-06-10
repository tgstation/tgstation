/datum/lighting_object
	///the underlay we are currently applying to our turf to apply light
	var/mutable_appearance/current_underlay

	///whether we are already in the SSlighting.objects_queue list
	var/needs_update = FALSE

	///the turf that our light is applied to
	var/turf/affected_turf

/datum/lighting_object/New(turf/source)
	if(!isturf(source))
		qdel(src, force=TRUE)
		stack_trace("a lighting object was assigned to [source], a non turf! ")
		return
	. = ..()

	current_underlay = mutable_appearance(LIGHTING_ICON, "transparent", source.z, LIGHTING_PLANE, 255, RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM)

	affected_turf = source
	if (affected_turf.lighting_object)
		qdel(affected_turf.lighting_object, force = TRUE)
		stack_trace("a lighting object was assigned to a turf that already had a lighting object!")

	affected_turf.lighting_object = src
	affected_turf.luminosity = 0

	for(var/turf/open/space/space_tile in RANGE_TURFS(1, affected_turf))
		space_tile.update_starlight()

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

// Look at how much we gain by moving this from the lighting object to the turf
// If that's not enough, try using listmos, see if it helps
// Maybe store all 4 corners as one unrolled list, would take more memory but potentially save time (not worth it, since corners are shared between turfs)
// As an upside, this means any work we do that's the same for each lighting object can be safely cached
// Consider precaching the max, for similar reasons (may or may not be possible, think about it (basically decreasing would be expensive potentially))
/datum/lighting_object/proc/update()
	switch(rand(1, 9))
		if(1)
			old_update()
		if(2)
			max_first_update()
		if(3)
			update_lighting_turf()
		if(4)
			moved_underlays_update()
		if(5)
			w_min_update()
		if(6)
			full_turf_update()
		if(7)
			full_list_turf_update()
		if(8)
			full_turf_if_update()
		if(9)
			full_turf_extended_if_update()

GLOBAL_VAR_INIT(color_updated_matrix, 0)
GLOBAL_VAR_INIT(color_updated_fulldark, 0)
GLOBAL_VAR_INIT(color_updated_fullbright, 0)

/datum/lighting_object/proc/update_lighting_turf()
	affected_turf.update_lighting_object()

/turf/proc/update_lighting_object()
	var/mutable_appearance/underlayd_light = lighting_object.current_underlay

	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

	var/datum/lighting_corner/red_corner = lighting_corner_SW || dummy_lighting_corner
	var/datum/lighting_corner/green_corner = lighting_corner_SE || dummy_lighting_corner
	var/datum/lighting_corner/blue_corner = lighting_corner_NW || dummy_lighting_corner
	var/datum/lighting_corner/alpha_corner = lighting_corner_NE || dummy_lighting_corner

	var/max = max(red_corner.largest_color_luminosity, green_corner.largest_color_luminosity, blue_corner.largest_color_luminosity, alpha_corner.largest_color_luminosity)

	var/rr = red_corner.cache_r
	var/rg = red_corner.cache_g
	var/rb = red_corner.cache_b

	var/gr = green_corner.cache_r
	var/gg = green_corner.cache_g
	var/gb = green_corner.cache_b

	var/br = blue_corner.cache_r
	var/bg = blue_corner.cache_g
	var/bb = blue_corner.cache_b

	var/ar = alpha_corner.cache_r
	var/ag = alpha_corner.cache_g
	var/ab = alpha_corner.cache_b

	#if LIGHTING_SOFT_THRESHOLD != 0
	var/set_luminosity = max > LIGHTING_SOFT_THRESHOLD
	#else
	// Because of floating points™?, it won't even be a flat 0.
	// This number is mostly arbitrary.
	var/set_luminosity = max > 1e-6
	#endif

	// There's no reason to check this first, if max is too low we're doomed anyway
	if((rr & gr & br & ar) && (rg + gg + bg + ag + rb + gb + bb + ab == 8))
		//anything that passes the first case is very likely to pass the second, and addition is a little faster in this case
		underlays -= underlayd_light
		underlayd_light.icon_state = "lighting_transparent"
		underlayd_light.color = null
		underlays += underlayd_light
		GLOB.color_updated_fullbright += 1
	else if(!set_luminosity)
		underlays -= underlayd_light
		underlayd_light.icon_state = "lighting_dark"
		underlayd_light.color = null
		underlays += underlayd_light
		GLOB.color_updated_fulldark += 1
	else
		underlays -= underlayd_light
		underlayd_light.icon_state = null
		underlayd_light.color = list(
			rr, rg, rb, 00,
			gr, gg, gb, 00,
			br, bg, bb, 00,
			ar, ag, ab, 00,
			00, 00, 00, 01
		)
		underlays += underlayd_light
		GLOB.color_updated_matrix += 1

	luminosity = set_luminosity

/datum/lighting_object/proc/old_update()

	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

	var/datum/lighting_corner/red_corner = affected_turf.lighting_corner_SW || dummy_lighting_corner
	var/datum/lighting_corner/green_corner = affected_turf.lighting_corner_SE || dummy_lighting_corner
	var/datum/lighting_corner/blue_corner = affected_turf.lighting_corner_NW || dummy_lighting_corner
	var/datum/lighting_corner/alpha_corner = affected_turf.lighting_corner_NE || dummy_lighting_corner

	var/max = max(red_corner.largest_color_luminosity, green_corner.largest_color_luminosity, blue_corner.largest_color_luminosity, alpha_corner.largest_color_luminosity)

	var/rr = red_corner.cache_r
	var/rg = red_corner.cache_g
	var/rb = red_corner.cache_b

	var/gr = green_corner.cache_r
	var/gg = green_corner.cache_g
	var/gb = green_corner.cache_b

	var/br = blue_corner.cache_r
	var/bg = blue_corner.cache_g
	var/bb = blue_corner.cache_b

	var/ar = alpha_corner.cache_r
	var/ag = alpha_corner.cache_g
	var/ab = alpha_corner.cache_b

	#if LIGHTING_SOFT_THRESHOLD != 0
	var/set_luminosity = max > LIGHTING_SOFT_THRESHOLD
	#else
	// Because of floating points™?, it won't even be a flat 0.
	// This number is mostly arbitrary.
	var/set_luminosity = max > 1e-6
	#endif

	// There's no reason to check this first, if max is too low we're doomed anyway
	if((rr & gr & br & ar) && (rg + gg + bg + ag + rb + gb + bb + ab == 8))
		//anything that passes the first case is very likely to pass the second, and addition is a little faster in this case
		affected_turf.underlays -= current_underlay
		current_underlay.icon_state = "lighting_transparent"
		current_underlay.color = null
		affected_turf.underlays += current_underlay
		GLOB.color_updated_fullbright += 1
	else if(!set_luminosity)
		affected_turf.underlays -= current_underlay
		current_underlay.icon_state = "lighting_dark"
		current_underlay.color = null
		affected_turf.underlays += current_underlay
		GLOB.color_updated_fulldark += 1
	else
		affected_turf.underlays -= current_underlay
		current_underlay.icon_state = null
		current_underlay.color = list(
			rr, rg, rb, 00,
			gr, gg, gb, 00,
			br, bg, bb, 00,
			ar, ag, ab, 00,
			00, 00, 00, 01
		)

		affected_turf.underlays += current_underlay
		GLOB.color_updated_matrix += 1

	affected_turf.luminosity = set_luminosity

/datum/lighting_object/proc/max_first_update()

	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

	var/datum/lighting_corner/red_corner = affected_turf.lighting_corner_SW || dummy_lighting_corner
	var/datum/lighting_corner/green_corner = affected_turf.lighting_corner_SE || dummy_lighting_corner
	var/datum/lighting_corner/blue_corner = affected_turf.lighting_corner_NW || dummy_lighting_corner
	var/datum/lighting_corner/alpha_corner = affected_turf.lighting_corner_NE || dummy_lighting_corner

	var/max = max(red_corner.largest_color_luminosity, green_corner.largest_color_luminosity, blue_corner.largest_color_luminosity, alpha_corner.largest_color_luminosity)

	var/rr = red_corner.cache_r
	var/rg = red_corner.cache_g
	var/rb = red_corner.cache_b

	var/gr = green_corner.cache_r
	var/gg = green_corner.cache_g
	var/gb = green_corner.cache_b

	var/br = blue_corner.cache_r
	var/bg = blue_corner.cache_g
	var/bb = blue_corner.cache_b

	var/ar = alpha_corner.cache_r
	var/ag = alpha_corner.cache_g
	var/ab = alpha_corner.cache_b

	#if LIGHTING_SOFT_THRESHOLD != 0
	var/set_luminosity = max > LIGHTING_SOFT_THRESHOLD
	#else
	// Because of floating points™?, it won't even be a flat 0.
	// This number is mostly arbitrary.
	var/set_luminosity = max > 1e-6
	#endif

	// There's no reason to check this first, if max is too low we're doomed anyway
	if(!set_luminosity)
		affected_turf.underlays -= current_underlay
		current_underlay.icon_state = "lighting_dark"
		current_underlay.color = null
		affected_turf.underlays += current_underlay
		GLOB.color_updated_fulldark += 1
	else if((rr & gr & br & ar) && (rg + gg + bg + ag + rb + gb + bb + ab == 8))
		//anything that passes the first case is very likely to pass the second, and addition is a little faster in this case
		affected_turf.underlays -= current_underlay
		current_underlay.icon_state = "lighting_transparent"
		current_underlay.color = null
		affected_turf.underlays += current_underlay
		GLOB.color_updated_fullbright += 1
	else
		affected_turf.underlays -= current_underlay
		current_underlay.icon_state = null
		current_underlay.color = list(
			rr, rg, rb, 00,
			gr, gg, gb, 00,
			br, bg, bb, 00,
			ar, ag, ab, 00,
			00, 00, 00, 01
		)

		affected_turf.underlays += current_underlay
		GLOB.color_updated_matrix += 1

	affected_turf.luminosity = set_luminosity

/datum/lighting_object/proc/moved_underlays_update()

	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

	var/datum/lighting_corner/red_corner = affected_turf.lighting_corner_SW || dummy_lighting_corner
	var/datum/lighting_corner/green_corner = affected_turf.lighting_corner_SE || dummy_lighting_corner
	var/datum/lighting_corner/blue_corner = affected_turf.lighting_corner_NW || dummy_lighting_corner
	var/datum/lighting_corner/alpha_corner = affected_turf.lighting_corner_NE || dummy_lighting_corner

	var/max = max(red_corner.largest_color_luminosity, green_corner.largest_color_luminosity, blue_corner.largest_color_luminosity, alpha_corner.largest_color_luminosity)

	var/rr = red_corner.cache_r
	var/rg = red_corner.cache_g
	var/rb = red_corner.cache_b

	var/gr = green_corner.cache_r
	var/gg = green_corner.cache_g
	var/gb = green_corner.cache_b

	var/br = blue_corner.cache_r
	var/bg = blue_corner.cache_g
	var/bb = blue_corner.cache_b

	var/ar = alpha_corner.cache_r
	var/ag = alpha_corner.cache_g
	var/ab = alpha_corner.cache_b

	#if LIGHTING_SOFT_THRESHOLD != 0
	var/set_luminosity = max > LIGHTING_SOFT_THRESHOLD
	#else
	// Because of floating points™?, it won't even be a flat 0.
	// This number is mostly arbitrary.
	var/set_luminosity = max > 1e-6
	#endif

	affected_turf.underlays -= current_underlay
	// There's no reason to check this first, if max is too low we're doomed anyway
	if((rr & gr & br & ar) && (rg + gg + bg + ag + rb + gb + bb + ab == 8))
		//anything that passes the first case is very likely to pass the second, and addition is a little faster in this case
		current_underlay.icon_state = "lighting_transparent"
		current_underlay.color = null
		GLOB.color_updated_fullbright += 1
	else if(!set_luminosity)
		current_underlay.icon_state = "lighting_dark"
		current_underlay.color = null
		GLOB.color_updated_fulldark += 1
	else
		current_underlay.icon_state = null
		current_underlay.color = list(
			rr, rg, rb, 00,
			gr, gg, gb, 00,
			br, bg, bb, 00,
			ar, ag, ab, 00,
			00, 00, 00, 01
		)
		GLOB.color_updated_matrix += 1

	affected_turf.underlays += current_underlay
	affected_turf.luminosity = set_luminosity

/datum/lighting_object/proc/w_min_update()

	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

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

	// There's no reason to check this first, if max is too low we're doomed anyway
	if(red_corner.smallest_cache + green_corner.smallest_cache + blue_corner.smallest_cache + alpha_corner.smallest_cache == 4)
		//anything that passes the first case is very likely to pass the second, and addition is a little faster in this case
		affected_turf.underlays -= current_underlay
		current_underlay.icon_state = "lighting_transparent"
		current_underlay.color = null
		affected_turf.underlays += current_underlay
		GLOB.color_updated_fullbright += 1
	else if(!set_luminosity)
		affected_turf.underlays -= current_underlay
		current_underlay.icon_state = "lighting_dark"
		current_underlay.color = null
		affected_turf.underlays += current_underlay
		GLOB.color_updated_fulldark += 1
	else
		affected_turf.underlays -= current_underlay
		current_underlay.icon_state = null
		current_underlay.color = list(
			red_corner.cache_r, red_corner.cache_g, red_corner.cache_b, 00,
			green_corner.cache_r, green_corner.cache_g, green_corner.cache_b, 00,
			blue_corner.cache_r, blue_corner.cache_g, blue_corner.cache_b, 00,
			alpha_corner.cache_r, alpha_corner.cache_g, alpha_corner.cache_b, 00,
			00, 00, 00, 01
		)
		GLOB.color_updated_matrix += 1

		affected_turf.underlays += current_underlay

	affected_turf.luminosity = set_luminosity

/datum/lighting_object/proc/full_turf_update()
	affected_turf.optimized_light_update()

/turf/proc/optimized_light_update()
	var/mutable_appearance/underlayd_light = lighting_object.current_underlay
	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

	var/datum/lighting_corner/red_corner = lighting_corner_SW || dummy_lighting_corner
	var/datum/lighting_corner/green_corner = lighting_corner_SE || dummy_lighting_corner
	var/datum/lighting_corner/blue_corner = lighting_corner_NW || dummy_lighting_corner
	var/datum/lighting_corner/alpha_corner = lighting_corner_NE || dummy_lighting_corner

	var/max = max(red_corner.largest_color_luminosity, green_corner.largest_color_luminosity, blue_corner.largest_color_luminosity, alpha_corner.largest_color_luminosity)

	#if LIGHTING_SOFT_THRESHOLD != 0
	var/set_luminosity = max > LIGHTING_SOFT_THRESHOLD
	#else
	// Because of floating points™?, it won't even be a flat 0.
	// This number is mostly arbitrary.
	var/set_luminosity = max > 1e-6
	#endif

	underlays -= underlayd_light
	// There's no reason to check this first, if max is too low we're doomed anyway
	if(red_corner.smallest_cache + green_corner.smallest_cache + blue_corner.smallest_cache + alpha_corner.smallest_cache == 4)
		//anything that passes the first case is very likely to pass the second, and addition is a little faster in this case
		underlayd_light.icon_state = "lighting_transparent"
		underlayd_light.color = null
		GLOB.color_updated_fullbright += 1
	else if(!set_luminosity)
		underlayd_light.icon_state = "lighting_dark"
		underlayd_light.color = null
		GLOB.color_updated_fulldark += 1
	else
		underlayd_light.icon_state = null
		underlayd_light.color = list(
			red_corner.cache_r, red_corner.cache_g, red_corner.cache_b, 00,
			green_corner.cache_r, green_corner.cache_g, green_corner.cache_b, 00,
			blue_corner.cache_r, blue_corner.cache_g, blue_corner.cache_b, 00,
			alpha_corner.cache_r, alpha_corner.cache_g, alpha_corner.cache_b, 00,
			00, 00, 00, 01
		)
		GLOB.color_updated_matrix += 1

	underlays += underlayd_light
	luminosity = set_luminosity

/datum/lighting_object/proc/full_list_turf_update()
	affected_turf.list_optimized_light_update()

/turf/proc/list_optimized_light_update()
	var/mutable_appearance/underlayd_light = lighting_object.current_underlay
	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

	var/list/red_struct = (lighting_corner_SW || dummy_lighting_corner).light_struct
	var/list/green_struct = (lighting_corner_SE || dummy_lighting_corner).light_struct
	var/list/blue_struct = (lighting_corner_NW || dummy_lighting_corner).light_struct
	var/list/alpha_struct = (lighting_corner_NE || dummy_lighting_corner).light_struct

	var/max = max(red_struct[4], green_struct[4], blue_struct[4], alpha_struct[4])

	#if LIGHTING_SOFT_THRESHOLD != 0
	var/set_luminosity = max > LIGHTING_SOFT_THRESHOLD
	#else
	// Because of floating points™?, it won't even be a flat 0.
	// This number is mostly arbitrary.
	var/set_luminosity = max > 1e-6
	#endif

	underlays -= underlayd_light
	// There's no reason to check this first, if max is too low we're doomed anyway
	if(red_struct[5] + green_struct[5] + blue_struct[5] + alpha_struct[5] == 4)
		//anything that passes the first case is very likely to pass the second, and addition is a little faster in this case
		underlayd_light.icon_state = "lighting_transparent"
		underlayd_light.color = null
		GLOB.color_updated_fullbright += 1
	else if(!set_luminosity)
		underlayd_light.icon_state = "lighting_dark"
		underlayd_light.color = null
		GLOB.color_updated_fulldark += 1
	else
		underlayd_light.icon_state = null
		underlayd_light.color = list(
			red_struct[1], red_struct[2], red_struct[3], 00,
			green_struct[1], green_struct[2], green_struct[3], 00,
			blue_struct[1], blue_struct[2], blue_struct[3], 00,
			alpha_struct[1], alpha_struct[2], alpha_struct[3], 00,
			00, 00, 00, 01
		)
		GLOB.color_updated_matrix += 1

	underlays += underlayd_light
	luminosity = set_luminosity

/datum/lighting_object/proc/full_turf_if_update()
	affected_turf.if_optimized_light_update()

/turf/proc/if_optimized_light_update()
	var/mutable_appearance/underlayd_light = lighting_object.current_underlay
	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

	var/datum/lighting_corner/red_corner = lighting_corner_SW || dummy_lighting_corner
	var/datum/lighting_corner/green_corner = lighting_corner_SE || dummy_lighting_corner
	var/datum/lighting_corner/blue_corner = lighting_corner_NW || dummy_lighting_corner
	var/datum/lighting_corner/alpha_corner = lighting_corner_NE || dummy_lighting_corner

	var/set_luminosity = red_corner.has_real_lum || green_corner.has_real_lum || blue_corner.has_real_lum || alpha_corner.has_real_lum

	underlays -= underlayd_light
	// There's no reason to check this first, if max is too low we're doomed anyway
	if(red_corner.smallest_cache + green_corner.smallest_cache + blue_corner.smallest_cache + alpha_corner.smallest_cache == 4)
		//anything that passes the first case is very likely to pass the second, and addition is a little faster in this case
		underlayd_light.icon_state = "lighting_transparent"
		underlayd_light.color = null
		GLOB.color_updated_fullbright += 1
	else if(!set_luminosity)
		underlayd_light.icon_state = "lighting_dark"
		underlayd_light.color = null
		GLOB.color_updated_fulldark += 1
	else
		underlayd_light.icon_state = null
		underlayd_light.color = list(
			red_corner.cache_r, red_corner.cache_g, red_corner.cache_b, 00,
			green_corner.cache_r, green_corner.cache_g, green_corner.cache_b, 00,
			blue_corner.cache_r, blue_corner.cache_g, blue_corner.cache_b, 00,
			alpha_corner.cache_r, alpha_corner.cache_g, alpha_corner.cache_b, 00,
			00, 00, 00, 01
		)
		GLOB.color_updated_matrix += 1

	underlays += underlayd_light
	luminosity = set_luminosity

/datum/lighting_object/proc/full_turf_extended_if_update()
	affected_turf.extended_if_optimized_light_update()

/turf/proc/extended_if_optimized_light_update()
	var/mutable_appearance/underlayd_light = lighting_object.current_underlay
	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

	var/datum/lighting_corner/red_corner = lighting_corner_SW || dummy_lighting_corner
	var/datum/lighting_corner/green_corner = lighting_corner_SE || dummy_lighting_corner
	var/datum/lighting_corner/blue_corner = lighting_corner_NW || dummy_lighting_corner
	var/datum/lighting_corner/alpha_corner = lighting_corner_NE || dummy_lighting_corner

	var/set_luminosity = red_corner.has_real_lum || green_corner.has_real_lum || blue_corner.has_real_lum || alpha_corner.has_real_lum

	underlays -= underlayd_light
	// There's no reason to check this first, if max is too low we're doomed anyway
	if(red_corner.all_max_lum && green_corner.all_max_lum && blue_corner.all_max_lum && alpha_corner.all_max_lum)
		//anything that passes the first case is very likely to pass the second, and addition is a little faster in this case
		underlayd_light.icon_state = "lighting_transparent"
		underlayd_light.color = null
		GLOB.color_updated_fullbright += 1
	else if(!set_luminosity)
		underlayd_light.icon_state = "lighting_dark"
		underlayd_light.color = null
		GLOB.color_updated_fulldark += 1
	else
		underlayd_light.icon_state = null
		underlayd_light.color = list(
			red_corner.cache_r, red_corner.cache_g, red_corner.cache_b, 00,
			green_corner.cache_r, green_corner.cache_g, green_corner.cache_b, 00,
			blue_corner.cache_r, blue_corner.cache_g, blue_corner.cache_b, 00,
			alpha_corner.cache_r, alpha_corner.cache_g, alpha_corner.cache_b, 00,
			00, 00, 00, 01
		)
		GLOB.color_updated_matrix += 1

	underlays += underlayd_light
	luminosity = set_luminosity
