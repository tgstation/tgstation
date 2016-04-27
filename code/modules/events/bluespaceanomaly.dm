/datum/event_control/bluespace_anomaly


/datum/event/bluespace_anomaly
	announceWhen	= 5

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
	command_alert("Bluespace anomaly detected in the vicinity of [station_name()]. [impact_area.name] has been affected.", "Anomaly Alert")


/datum/event/bluespace_anomaly/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
			// Calculate new position (searches through beacons in world)
		var/obj/item/beacon/chosen
		var/list/possible = list()
		for(var/obj/item/beacon/W in beacons)
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
				// if(M:eyecheck() <= 0) (this is now handled in flash_eyes)
				if(M.flash_eyes(affect_silicon = 1))
					flashers += M

			var/y_distance = TO.y - FROM.y
			var/x_distance = TO.x - FROM.x
			for (var/atom/movable/A in range(12, FROM )) // iterate thru list of mobs in the area
				if(istype(A, /obj/item/beacon)) continue // don't teleport beacons because that's just insanely stupid
				if(A.anchored && (istype(A, /obj/machinery) || istype(A,/obj/structure))) continue
				if(istype(A, /obj/structure/disposalpipe )) continue
				if(istype(A, /obj/structure/cable )) continue
				if(istype(A, /atom/movable/lighting_overlay)) continue

				var/turf/newloc = locate(A.x + x_distance, A.y + y_distance, TO.z) // calculate the new place
				A.forceMove(newloc)

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
