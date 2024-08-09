
#define FAKE_FLOOD_EXPAND_TIME 20
#define FAKE_FLOOD_MAX_RADIUS 10

/// Plasma starts flooding from the nearby vent
/datum/hallucination/fake_flood
	random_hallucination_weight = 7

	var/list/image/flood_images = list()
	// Assoc list of turfs we have flooded -> the /obj/effect/plasma_image_holder living on them
	var/list/turf_to_flood = list()
	// List of turfs that have not yet been completely flooded out
	var/list/half_baked_turfs = list()
	var/image_icon = 'icons/effects/atmos/plasma.dmi'
	var/base_image_state = ""
	var/radius = 0
	var/next_expand = 0

/datum/hallucination/fake_flood/start()
	// This hallucination is purely visual, so we don't need to bother for clientless mobs
	if(!hallucinator.client)
		return FALSE

	var/turf/center

	for(var/obj/machinery/atmospherics/components/unary/vent_pump/nearby_pump in orange(7, hallucinator))
		if(nearby_pump.welded)
			continue

		center = get_turf(nearby_pump)
		break

	if(!center)
		return FALSE

	feedback_details += "Vent Coords: ([center.x], [center.y], [center.z])"
	create_new_plasma_image(center)
	hallucinator.client?.images |= flood_images

	next_expand = world.time + FAKE_FLOOD_EXPAND_TIME
	START_PROCESSING(SSobj, src)
	return TRUE

/datum/hallucination/fake_flood/process()
	if(next_expand > world.time)
		return

	radius++
	if(radius > FAKE_FLOOD_MAX_RADIUS)
		qdel(src)
		return

	expand_flood()

	if(turf_to_flood[get_turf(hallucinator)])
		var/mob/living/carbon/carbon_hallucinator = hallucinator
		if(istype(carbon_hallucinator) && !carbon_hallucinator.internal)
			hallucinator.cause_hallucination(/datum/hallucination/fake_alert/bad_plasma, "fake plasmaflood hallucination")

	next_expand = world.time + FAKE_FLOOD_EXPAND_TIME

/datum/hallucination/fake_flood/proc/expand_flood()
	for(var/image/flood_image in flood_images)
		flood_image.alpha = min(flood_image.alpha + 50, 255)

	for(var/turf/flooded_turf in half_baked_turfs)
		var/potential_hole = FALSE
		for(var/dir in GLOB.cardinals)
			var/turf/nearby_turf = get_step(flooded_turf, dir)
			if(turf_to_flood[nearby_turf])
				continue
			if(!TURFS_CAN_SHARE(nearby_turf, flooded_turf) || isspaceturf(nearby_turf))
				potential_hole = TRUE
				continue
			create_new_plasma_image(nearby_turf)
		if(!potential_hole)
			half_baked_turfs -= flooded_turf

	hallucinator.client?.images |= flood_images

/datum/hallucination/fake_flood/proc/create_new_plasma_image(turf/to_flood)
	half_baked_turfs += to_flood
	var/obj/effect/plasma_image_holder/image_holder = new(to_flood)
	turf_to_flood[to_flood] = image_holder

	var/image/plasma_image = image(image_icon, image_holder, "[base_image_state]-0", FLY_LAYER)
	plasma_image.alpha = 50
	SET_PLANE_EXPLICIT(plasma_image, GAME_PLANE, to_flood)
	image_holder.overriding_image = plasma_image
	flood_images += plasma_image

	var/connected_dirs = NONE
	for(var/dir in GLOB.cardinals)
		var/turf/adjacent_turf = get_step(to_flood, dir)
		var/obj/effect/plasma_image_holder/adjacent_holder = turf_to_flood[adjacent_turf]
		if(!adjacent_holder)
			continue
		connected_dirs |= dir
		adjacent_holder.smooth_directions |= REVERSE_DIR(dir)
		adjacent_holder.overriding_image.icon_state = "[base_image_state]-[adjacent_holder.smooth_directions]"
	image_holder.smooth_directions = connected_dirs
	plasma_image.icon_state = "[base_image_state]-[image_holder.smooth_directions]"

/datum/hallucination/fake_flood/Destroy()
	STOP_PROCESSING(SSobj, src)

	hallucinator.client?.images -= flood_images

	flood_images.Cut() // We don't own these, kinda
	half_baked_turfs.Cut() // We REALLY don't own these
	QDEL_LIST_ASSOC_VAL(turf_to_flood) // But we DO own these (sorta)

	return ..()

/obj/effect/plasma_image_holder
	icon_state = "nothing"
	anchored = TRUE
	layer = FLY_LAYER
	plane = GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/datum/hallucination/fake_flood/owning_hallucination
	var/image/overriding_image
	var/smooth_directions = NONE

/obj/effect/plasma_image_holder/Destroy(force)
	. = ..()
	owning_hallucination = null
	overriding_image = null

#undef FAKE_FLOOD_EXPAND_TIME
#undef FAKE_FLOOD_MAX_RADIUS
