#define FAKE_FLOOD_EXPAND_TIME 20
#define FAKE_FLOOD_MAX_RADIUS 10

/obj/effect/plasma_image_holder
	icon_state = "nothing"
	anchored = TRUE
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/datum/hallucination/fake_flood
	//Plasma starts flooding from the nearby vent
	var/turf/center
	var/list/flood_images = list()
	var/list/flood_image_holders = list()
	var/list/turf/flood_turfs = list()
	var/image_icon = 'icons/effects/atmospherics.dmi'
	var/image_state = "plasma"
	var/radius = 0
	var/next_expand = 0

/datum/hallucination/fake_flood/New(mob/living/carbon/C, forced = TRUE)
	..()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/U in orange(7,target))
		if(!U.welded)
			center = get_turf(U)
			break
	if(!center)
		qdel(src)
		return
	feedback_details += "Vent Coords: [center.x],[center.y],[center.z]"
	var/obj/effect/plasma_image_holder/pih = new(center)
	var/image/plasma_image = image(image_icon, pih, image_state, FLY_LAYER)
	plasma_image.alpha = 50
	plasma_image.plane = ABOVE_GAME_PLANE
	flood_images += plasma_image
	flood_image_holders += pih
	flood_turfs += center
	if(target.client)
		target.client.images |= flood_images
	next_expand = world.time + FAKE_FLOOD_EXPAND_TIME
	START_PROCESSING(SSobj, src)

/datum/hallucination/fake_flood/process()
	if(next_expand <= world.time)
		radius++
		if(radius > FAKE_FLOOD_MAX_RADIUS)
			qdel(src)
			return
		Expand()
		if((get_turf(target) in flood_turfs) && !target.internal)
			new /datum/hallucination/fake_alert(target, TRUE, ALERT_TOO_MUCH_PLASMA)
		next_expand = world.time + FAKE_FLOOD_EXPAND_TIME

/datum/hallucination/fake_flood/proc/Expand()
	for(var/image/I in flood_images)
		I.alpha = min(I.alpha + 50, 255)
	for(var/turf/FT in flood_turfs)
		for(var/dir in GLOB.cardinals)
			var/turf/T = get_step(FT, dir)
			if((T in flood_turfs) || !TURFS_CAN_SHARE(T, FT) || isspaceturf(T)) //If we've gottem already, or if they're not alright to spread with.
				continue
			var/obj/effect/plasma_image_holder/pih = new(T)
			var/image/new_plasma = image(image_icon, pih, image_state, FLY_LAYER)
			new_plasma.alpha = 50
			new_plasma.plane = ABOVE_GAME_PLANE
			flood_images += new_plasma
			flood_image_holders += pih
			flood_turfs += T
	if(target.client)
		target.client.images |= flood_images

/datum/hallucination/fake_flood/Destroy()
	STOP_PROCESSING(SSobj, src)
	qdel(flood_turfs)
	flood_turfs = list()
	if(target.client)
		target.client.images.Remove(flood_images)
	qdel(flood_images)
	flood_images = list()
	qdel(flood_image_holders)
	flood_image_holders = list()
	return ..()
