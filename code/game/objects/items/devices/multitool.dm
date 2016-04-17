/**
 * Multitool -- A multitool is used for hacking electronic devices.
 * TO-DO -- Using it as a power measurement tool for cables etc. Nannek.
 *
 */

/obj/item/device/multitool
	name = "multitool"
	desc = "Used for pulsing wires to test which to cut. Not recommended by doctors."
	icon_state = "multitool"
	force = 5
	w_class = 2
	throwforce = 0
	throw_range = 7
	throw_speed = 3
	materials = list(MAT_METAL=50, MAT_GLASS=20)
	origin_tech = "magnets=1;engineering=1"
	var/obj/machinery/buffer // simple machine buffer for device linkage
	hitsound = 'sound/weapons/tap.ogg'
	toolspeed = 1


// Syndicate device disguised as a multitool; it will turn red when an AI camera is nearby.


/obj/item/device/multitool/ai_detect
	var/track_delay = 0

/obj/item/device/multitool/ai_detect/New()
	..()
	SSobj.processing += src

/obj/item/device/multitool/ai_detect/Destroy()
	SSobj.processing -= src
	return ..()

/obj/item/device/multitool/ai_detect/process()
	if(track_delay > world.time)
		return

	var/found_eye = 0
	var/turf/our_turf = get_turf(src)

	for(var/mob/living/silicon/ai/AI in ai_list)
		if(AI.cameraFollow == src)
			found_eye = 1
			break

	if(!found_eye && cameranet.chunkGenerated(our_turf.x, our_turf.y, our_turf.z))
		var/datum/camerachunk/chunk = cameranet.getCameraChunk(our_turf.x, our_turf.y, our_turf.z)
		if(chunk)
			if(chunk.seenby.len)
				for(var/mob/camera/aiEye/A in chunk.seenby)
					var/turf/eye_turf = get_turf(A)
					if(get_dist(our_turf, eye_turf) < 8)
						found_eye = 1
						break

	if(found_eye)
		icon_state = "[initial(icon_state)]_red"
	else
		icon_state = initial(icon_state)

	track_delay = world.time + 10 // 1 second
	return



/obj/item/device/multitool/cyborg
	name = "multitool"
	desc = "Optimised and stripped-down version of a regular multitool."
	icon = 'icons/obj/items_cyborg.dmi'
	toolspeed = 2