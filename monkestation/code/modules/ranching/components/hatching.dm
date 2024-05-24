/datum/component/hatching
	///current hatch rate
	var/hatch_rate = 0
	///how high our hatch_rate needs to be
	var/max_hatch_rate = 100
	///lowest possible temperature to hatch defaults to null if not set doesn't check
	var/lowest_possible_temp
	/// highest possible temperature to hatch defaults to null if not set doesn't check
	var/highest_possible_temp
	///liquids depth
	var/liquid_depth
	///lowest pressure needed
	var/lowest_pressure
	///highest pressure needed
	var/highest_pressure
	///the turfs we need in the surrounding 3x3 area to hatch, can be any of these
	var/list/needed_turfs
	///mob we need nearby
	var/mob_needed
	///are we hatching?
	var/hatching = FALSE
	var/datum/callback/hatch_callback
	var/list/failures = list()
	COOLDOWN_DECLARE(failed_cooldown)

/datum/component/hatching/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_MOUSE_ENTERED, PROC_REF(check_hatch_fails))

/datum/component/hatching/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_MOUSE_ENTERED)

/datum/component/hatching/Initialize(max_hatch_rate = 100, hatch_callback, lowest_possible_temp, highest_possible_temp, lowest_pressure, highest_pressure, liquid_depth, list/turf_requirements, mob_needed)
	. = ..()
	src.max_hatch_rate = max_hatch_rate
	src.lowest_possible_temp = lowest_possible_temp
	src.highest_possible_temp = highest_possible_temp
	src.lowest_pressure = lowest_pressure
	src.highest_pressure = highest_pressure
	src.liquid_depth = liquid_depth
	src.hatch_callback = hatch_callback
	src.mob_needed = mob_needed
	needed_turfs = turf_requirements

	START_PROCESSING(SSobj, src)

/datum/component/hatching/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, failed_cooldown))
		return

	var/obj/structure/nestbox/nest = locate(/obj/structure/nestbox) in get_turf(parent)
	if(!nest)
		failures |= "nest"
		if(hatching)
			stop_hatching()
		return

	if(!nest.incubator)
		failures |= "nest"
		if(hatching)
			stop_hatching()
		return

	if(!hatching)
		start_hatching()

	if(lowest_possible_temp || highest_possible_temp || lowest_pressure || highest_pressure)
		var/turf/open/turf = get_turf(parent)
		var/datum/gas_mixture/turf_mixture = turf.return_air()

		if(lowest_possible_temp || highest_possible_temp)
			var/temp = turf_mixture.return_temperature()
			if(lowest_possible_temp)
				if(temp < lowest_possible_temp)
					COOLDOWN_START(src, failed_cooldown, 10 SECONDS)
					stop_hatching()
					failures |= "too_cold"

			if(highest_possible_temp)
				if(temp > highest_possible_temp)
					COOLDOWN_START(src, failed_cooldown, 10 SECONDS)
					stop_hatching()
					failures |= "too_hot"

		if(lowest_pressure || highest_pressure)
			var/pressure = turf_mixture.return_pressure()
			if(lowest_pressure)
				if(pressure < lowest_pressure)
					COOLDOWN_START(src, failed_cooldown, 10 SECONDS)
					stop_hatching()
					failures |= "low_pressure"

			if(highest_pressure)
				if(pressure > highest_pressure)
					COOLDOWN_START(src, failed_cooldown, 10 SECONDS)
					stop_hatching()
					failures |= "high_pressure"

	if(length(needed_turfs))
		var/passes = FALSE
		for(var/turf/open/turf in range(2, parent))
			if(turf.type in needed_turfs)
				passes = TRUE
				break
		if(!passes)
			COOLDOWN_START(src, failed_cooldown, 10 SECONDS)
			stop_hatching()
			failures |= "turfs"

	if(mob_needed)
		var/passes = FALSE
		for(var/mob/living/mob in range(3, parent))
			if(mob.type == mob_needed)
				passes = TRUE
				break

		if(!passes)
			COOLDOWN_START(src, failed_cooldown, 10 SECONDS)
			stop_hatching()
			failures |= "mob"

	if(!hatching)
		return

	hatch_rate += rand(2,3)
	if(hatch_rate >= max_hatch_rate)
		hatch()

/datum/component/hatching/proc/stop_hatching()
	animate(parent, transform = matrix()) //stop animation
	hatching = FALSE

/datum/component/hatching/proc/start_hatching()
	flop_animation(parent)
	failures = list()
	hatching = TRUE

/datum/component/hatching/proc/hatch()
	hatch_callback?.Invoke()
	qdel(src)

/datum/component/hatching/proc/check_hatch_fails(atom/movable/source, mob/living/clicker)
	if(!length(failures))
		return

	var/list/offset_to_add = get_icon_dimensions(source.icon)
	var/y_position = offset_to_add["height"] - 10
	var/obj/effect/overlay/hatch_overlays/hatch = new(null, failures, clicker)
	hatch.pixel_y = y_position
	var/image/new_image = new(source)
	new_image.appearance = hatch.appearance
	if(!isturf(source.loc))
		new_image.loc = source.loc
	else
		new_image.loc = source
	SET_PLANE(new_image, new_image.plane, source)
	clicker.client.images += new_image
	hatch.image = new_image


/obj/effect/overlay/hatch_overlays
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE
	layer = ABOVE_HUD_PLANE
	plane = GAME_PLANE_UPPER
	///icon of our heart
	var/mess_ups = 'monkestation/code/modules/ranching/icons/hover_icons.dmi'
	var/client/stored_client
	var/image/image
	var/list/offsets = list(-10, 0, 10, -20, 20, -30, 30)
	var/list/failures = list()


/obj/effect/overlay/hatch_overlays/New(loc, list/failures = list(), mob/living/clicker)
	. = ..()
	if(!clicker)
		return

	src.failures = failures
	RegisterSignal(clicker.client, COMSIG_CLIENT_HOVER_NEW, PROC_REF(clear_view))
	stored_client = clicker.client
	update_appearance()

/obj/effect/overlay/hatch_overlays/Destroy(force)
	. = ..()
	stored_client?.images -= image
	QDEL_NULL(image)
	stored_client = null

/obj/effect/overlay/hatch_overlays/update_overlays()
	. = ..()
	var/index = 1
	for(var/item in failures)
		var/mutable_appearance/new_icon = mutable_appearance(icon = mess_ups, icon_state = item, layer = ABOVE_HUD_PLANE)
		new_icon.pixel_x = offsets[index]
		index++
		. += new_icon

/obj/effect/overlay/hatch_overlays/proc/clear_view()
	qdel(src)

