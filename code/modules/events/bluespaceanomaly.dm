/datum/event_control/bluespace_anomaly


/datum/event/bluespace_anomaly
	announceWhen	= 20

	var/area/impact_area


/datum/event/bluespace_anomaly/setup()
	var/list/safe_areas = list(
	/area/turret_protected/ai,
	/area/turret_protected/ai_upload,
	/area/engineering,
	/area/solar,
	/area/holodeck,
	/area/shuttle/arrival,
	/area/shuttle/escape/station,
	/area/shuttle/escape_pod1/station,
	/area/shuttle/escape_pod2/station,
	/area/shuttle/escape_pod3/station,
	/area/shuttle/escape_pod5/station,
	/area/shuttle/mining/station,
	/area/shuttle/transport1/station,
	/area/shuttle/specops/station)

	//These are needed because /area/engine has to be removed from the list, but we still want these areas to get fucked up.
	var/list/danger_areas = list(
	/area/engineering/break_room,
	/area/engineering/ce)


	impact_area = locate(pick((the_station_areas - safe_areas) + danger_areas))	//need to locate() as it's just a list of paths.


/datum/event/bluespace_anomaly/announce()
	command_alert("Bluespace anomaly detected in the vicinity of [station_name()]. [impact_area.name] has gone missing.", "Anomaly Alert")


/datum/event/bluespace_anomaly/start()
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

			var/list/flashers = list()
			for(var/mob/living/carbon/human/M in viewers(TO, null))
				if(M:eyecheck() <= 0)
					flick("e_flash", M.flash) // flash dose faggots
					flashers += M

			var/y_distance = TO.y - FROM.y
			var/x_distance = TO.x - FROM.x
			for (var/atom/movable/A in range(12, FROM )) // iterate thru list of mobs in the area
				if(istype(A, /obj/item/device/radio/beacon)) continue // don't teleport beacons because that's just insanely stupid
				if(A.anchored && istype(A, /obj/machinery)) continue
				if(istype(A, /obj/structure/disposalpipe )) continue
				if(istype(A, /obj/structure/cable )) continue

				var/turf/newloc = locate(A.x + x_distance, A.y + y_distance, TO.z) // calculate the new place
				if(!A.Move(newloc)) // if the atom, for some reason, can't move, FORCE them to move! :) We try Move() first to invoke any movement-related checks the atom needs to perform after moving
					A.loc = locate(A.x + x_distance, A.y + y_distance, TO.z)

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
							del(blueeffect)