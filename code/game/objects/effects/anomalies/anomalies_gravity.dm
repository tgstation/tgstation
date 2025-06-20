
/atom/movable/warp_effect
	plane = GRAVITY_PULSE_PLANE
	appearance_flags = PIXEL_SCALE|LONG_GLIDE // no tile bound so you can see it around corners and so
	icon = 'icons/effects/light_overlays/light_352.dmi'
	icon_state = "light"
	pixel_x = -176
	pixel_y = -176

/atom/movable/warp_effect/Initialize(mapload)
	. = ..()
	var/turf/new_turf = get_turf(src)
	if(new_turf)
		var/new_offset = GET_TURF_PLANE_OFFSET(new_turf)
		ADD_TRAIT(GLOB, TRAIT_DISTORTION_IN_USE(new_offset), ref(src))

/atom/movable/warp_effect/Destroy(force)
	// Just in case I've forgotten how the movement api works
	var/offset = GET_TURF_PLANE_OFFSET(loc)
	REMOVE_TRAIT(GLOB, TRAIT_DISTORTION_IN_USE(offset), ref(src))
	return ..()

/atom/movable/warp_effect/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	var/turf/new_turf = get_turf(src)
	var/turf/old_turf = get_turf(old_loc)
	if(!new_turf)
		var/old_offset = GET_TURF_PLANE_OFFSET(old_turf)
		REMOVE_TRAIT(GLOB, TRAIT_DISTORTION_IN_USE(old_offset), ref(src))
		return
	else if(get_turf(old_loc))
		return
	// If we're in a thing on a turf we COUNT as a distortion source
	var/new_offset = GET_TURF_PLANE_OFFSET(new_turf)
	ADD_TRAIT(GLOB, TRAIT_DISTORTION_IN_USE(new_offset), ref(src))

/atom/movable/warp_effect/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(same_z_layer)
		return
	if(old_turf)
		var/old_offset = GET_TURF_PLANE_OFFSET(old_turf)
		REMOVE_TRAIT(GLOB, TRAIT_DISTORTION_IN_USE(old_offset), ref(src))
	if(new_turf)
		var/new_offset = GET_TURF_PLANE_OFFSET(new_turf)
		ADD_TRAIT(GLOB, TRAIT_DISTORTION_IN_USE(new_offset), ref(src))

/obj/effect/anomaly/grav
	name = "gravitational anomaly"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield2"
	density = FALSE
	anomaly_core = /obj/item/assembly/signaler/anomaly/grav
	var/boing = 0
	///Warp effect holder for displacement filter to "pulse" the anomaly
	var/atom/movable/warp_effect/warp

/obj/effect/anomaly/grav/Initialize(mapload, new_lifespan)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	apply_wibbly_filters(src)

	warp = new(src)
	vis_contents += warp

/obj/effect/anomaly/grav/Destroy()
	vis_contents -= warp
	warp = null
	return ..()

/obj/effect/anomaly/grav/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(same_z_layer)
		return
	if(warp)
		SET_PLANE(warp, PLANE_TO_TRUE(warp.plane), new_turf)

/obj/effect/anomaly/grav/anomalyEffect(seconds_per_tick)
	..()
	boing = 1
	for(var/obj/O in orange(4, src))
		if(!O.anchored)
			step_towards(O,src)
	for(var/mob/living/M in range(0, src))
		gravShock(M)
	for(var/mob/living/M in orange(4, src))
		if(!M.mob_negates_gravity())
			step_towards(M,src)
	for(var/obj/O in range(0,src))
		if(O.anchored || HAS_TRAIT(O, TRAIT_UNDERFLOOR))
			continue
		var/mob/living/target = locate() in view(4,src)
		if(target && !target.stat)
			O.throw_at(target, 5, 10)

	//anomaly quickly contracts then slowly expands its ring
	animate(warp, time = seconds_per_tick*3, transform = matrix().Scale(0.5,0.5))
	animate(time = seconds_per_tick*7, transform = matrix())

/obj/effect/anomaly/grav/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	gravShock(AM)

/obj/effect/anomaly/grav/Bump(atom/A)
	gravShock(A)

/obj/effect/anomaly/grav/Bumped(atom/movable/AM)
	gravShock(AM)

/obj/effect/anomaly/grav/proc/gravShock(mob/living/A)
	if(boing && isliving(A) && !A.stat)
		A.Paralyze(40)
		var/atom/target = get_edge_target_turf(A, get_dir(src, get_step_away(A, src)))
		A.throw_at(target, 5, 1)
		boing = 0

/obj/effect/anomaly/grav/detonate()
	new /obj/effect/temp_visual/circle_wave/gravity(get_turf(src))
	playsound(src, 'sound/effects/magic/cosmic_energy.ogg', vol = 50)

/obj/effect/anomaly/grav/high
	var/datum/proximity_monitor/advanced/gravity/grav_field

/obj/effect/anomaly/grav/high/Initialize(mapload, new_lifespan)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(setup_grav_field))

/obj/effect/anomaly/grav/high/proc/setup_grav_field()
	grav_field = new(src, 7, TRUE, rand(0, 3))

/obj/effect/anomaly/grav/high/detonate()
	..()
	for(var/obj/machinery/gravity_generator/main/the_generator as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/gravity_generator/main))
		if(is_station_level(the_generator.z))
			the_generator.blackout()

/obj/effect/anomaly/grav/high/Destroy()
	QDEL_NULL(grav_field)
	. = ..()

///Bigger, meaner, immortal gravity anomaly. although this is just the super grav anomaly but bigger and shattering move force
/obj/effect/anomaly/grav/high/big
	immortal = TRUE
	anomaly_core = null
	move_force = MOVE_FORCE_OVERPOWERING

/obj/effect/anomaly/grav/high/big/Initialize(mapload, new_lifespan)
	. = ..()

	transform *= 3

/obj/effect/temp_visual/circle_wave/gravity
	color = COLOR_NAVY
