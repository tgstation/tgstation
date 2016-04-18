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
	var/track_cooldown = 0
	var/track_delay = 10 //How often it checks for proximity
	var/detect_state = 0 //1 = yellow, 2 = red
	var/turf/our_turf
	var/rangealert = 8	//Glows red when inside
	var/rangewarning = 20 //Glows yellow when inside

/obj/item/device/multitool/ai_detect/New()
	..()
	SSobj.processing += src

/obj/item/device/multitool/ai_detect/Destroy()
	SSobj.processing -= src
	return ..()

/obj/item/device/multitool/ai_detect/process()
	if(track_cooldown > world.time)
		return

	detect_state = 0
	our_turf = get_turf(src)
	multitool_detect()

	if(detect_state == 1)
		icon_state = "[initial(icon_state)]_yellow"
	else if(detect_state == 2)
		icon_state = "[initial(icon_state)]_red"
	else
		icon_state = initial(icon_state)

	track_cooldown = world.time + track_delay // 1 second
	return

/obj/item/device/multitool/ai_detect/proc/multitool_detect()
	for(var/mob/living/silicon/ai/AI in ai_list)
		if(AI.cameraFollow == src)
			detect_state = 2
			break

	if(!detect_state && cameranet.chunkGenerated(our_turf.x, our_turf.y, our_turf.z))
		var/datum/camerachunk/chunk = cameranet.getCameraChunk(our_turf.x, our_turf.y, our_turf.z)
		if(chunk)
			if(chunk.seenby.len)
				for(var/mob/camera/aiEye/A in chunk.seenby)
					var/turf/detect_turf = get_turf(A)
					if(get_dist(our_turf, detect_turf) < rangealert)
						detect_state = 2
						break
					if(get_dist(our_turf, detect_turf) < rangewarning)
						detect_state = 1
						break

/obj/item/device/multitool/ai_detect/admin
	desc = "Used for pulsing wires to test which to cut. Not recommended by doctors. Has a strange tag that says 'Grief in Safety'" //What else should I say for a meme item?
	track_delay = 5

/obj/item/device/multitool/ai_detect/admin/multitool_detect()
	for(var/mob/J in range(rangewarning,src))
		if(admin_datums[J.ckey])
			detect_state = 1
			var/turf/detect_turf = get_turf(J)
			if(get_dist(our_turf, detect_turf) < rangealert)
				detect_state = 2
				break

/obj/item/device/multitool/cyborg
	name = "multitool"
	desc = "Optimised and stripped-down version of a regular multitool."
	icon = 'icons/obj/items_cyborg.dmi'
	toolspeed = 2