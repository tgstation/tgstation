
#define FAKE_FLOOD_EXPAND_TIME 20
#define FAKE_FLOOD_MAX_RADIUS 10

/// Plasma starts flooding from the nearby vent
/datum/hallucination/fake_flood
	random_hallucination_weight = 7

	var/list/image/flood_images = list()
	var/list/obj/effect/plasma_image_holder/flood_image_holders = list()
	var/list/turf/flood_turfs = list()
	var/image_icon = 'icons/effects/atmospherics.dmi'
	var/image_state = "plasma"
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

	if(get_turf(hallucinator) in flood_turfs)
		var/mob/living/carbon/carbon_hallucinator = hallucinator
		if(istype(carbon_hallucinator) && !carbon_hallucinator.internal)
			hallucinator.cause_hallucination(/datum/hallucination/fake_alert/bad_plasma, "fake plasmaflood hallucination")

	next_expand = world.time + FAKE_FLOOD_EXPAND_TIME

/datum/hallucination/fake_flood/proc/expand_flood()
	for(var/image/flood_image in flood_images)
		flood_image.alpha = min(flood_image.alpha + 50, 255)

	for(var/turf/flooded_turf in flood_turfs)
		for(var/dir in GLOB.cardinals)
			var/turf/nearby_turf = get_step(flooded_turf, dir)
			if((nearby_turf in flood_turfs) || !TURFS_CAN_SHARE(nearby_turf, flooded_turf) || isspaceturf(nearby_turf))
				continue
			create_new_plasma_image(nearby_turf)

	hallucinator.client?.images |= flood_images

/datum/hallucination/fake_flood/proc/create_new_plasma_image(turf/to_flood)
	flood_turfs += to_flood

	var/obj/effect/plasma_image_holder/image_holder = new(to_flood)
	flood_image_holders += image_holder

	var/image/plasma_image = image(image_icon, image_holder, image_state, FLY_LAYER)
	plasma_image.alpha = 50
	SET_PLANE_EXPLICIT(plasma_image, ABOVE_GAME_PLANE, to_flood)
	flood_images += plasma_image

/datum/hallucination/fake_flood/Destroy()
	STOP_PROCESSING(SSobj, src)

	hallucinator.client?.images -= flood_images

	flood_turfs.Cut() // We don't own these
	flood_images.Cut() // We also don't own these, kinda
	QDEL_LIST(flood_image_holders) // But we DO own these

	return ..()

/obj/effect/plasma_image_holder
	icon_state = "nothing"
	anchored = TRUE
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

#undef FAKE_FLOOD_EXPAND_TIME
#undef FAKE_FLOOD_MAX_RADIUS
