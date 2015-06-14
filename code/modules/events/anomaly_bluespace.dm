/datum/round_event_control/anomaly/anomaly_bluespace
	name = "Anomaly: Bluespace"
	typepath = /datum/round_event/anomaly/anomaly_bluespace
	max_occurrences = 1
	weight = 5

/datum/round_event/anomaly/anomaly_bluespace
	startWhen = 3
	announceWhen = 10
	endWhen = 95


/datum/round_event/anomaly/anomaly_bluespace/announce()
	priority_announce("Unstable bluespace anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")


/datum/round_event/anomaly/anomaly_bluespace/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/bluespace(T.loc)


/datum/round_event/anomaly/anomaly_bluespace/end()
	if(newAnomaly.loc)//If it hasn't been neutralized, it's time to warp half the station away jeez
		var/turf/T = pick(get_area_turfs(impact_area))
		if(T)
				// Calculate new position (searches through beacons in world)
			var/obj/item/device/radio/beacon/chosen
			var/list/possible = list()
			for(var/obj/item/device/radio/beacon/W in world)
				possible += W

			if(possible.len > 0)
				chosen = pick(possible)

			if(chosen)
					// Calculate previous position for transition

				var/turf/FROM = T // the turf of origin we're travelling FROM
				var/turf/TO = get_turf(chosen)			 // the turf of origin we're travelling TO

				playsound(TO, 'sound/effects/phasein.ogg', 100, 1)
				priority_announce("Massive bluespace translocation detected.", "Anomaly Alert")

				var/list/flashers = list()
				for(var/mob/living/carbon/human/M in viewers(TO, null))
					if(M.flash_eyes())
						flashers += M

				var/y_distance = TO.y - FROM.y
				var/x_distance = TO.x - FROM.x
				for (var/atom/movable/A in range(12, FROM )) // iterate thru list of mobs in the area
					if(istype(A, /obj/item/device/radio/beacon)) continue // don't teleport beacons because that's just insanely stupid
					if(A.anchored) continue

					var/turf/newloc = locate(A.x + x_distance, A.y + y_distance, TO.z) // calculate the new place
					if(!A.Move(newloc) && newloc) // if the atom, for some reason, can't move, FORCE them to move! :) We try Move() first to invoke any movement-related checks the atom needs to perform after moving
						A.loc = newloc

					spawn()
						if(ismob(A) && !(A in flashers)) // don't flash if we're already doing an effect
							var/mob/M = A
							if(M.client)
								var/obj/blueeffect = new /obj(src)
								blueeffect.screen_loc = "WEST,SOUTH to EAST,NORTH"
								blueeffect.icon = 'icons/effects/effects.dmi'
								blueeffect.icon_state = "shieldsparkles"
								blueeffect.layer = 17
								blueeffect.mouse_opacity = 0
								M.client.screen += blueeffect
								sleep(20)
								M.client.screen -= blueeffect
								qdel(blueeffect)
			qdel(newAnomaly)