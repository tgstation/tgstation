/datum/round_event_control/wizard/lava //THE LEGEND NEVER DIES
	name = "The Floor Is LAVA!"
	weight = 2
	typepath = /datum/round_event/wizard/lava/
	max_occurrences = 3
	earliest_start = 0

/datum/round_event/wizard/lava/

	endWhen = 30 //half a minutes

/datum/round_event/wizard/lava/start()

	for(var/turf/simulated/floor/F in world)
		if(F.z == ZLEVEL_STATION)
			F.name = "lava"
			F.desc = "The floor is LAVA!"
			F.overlays += "lava"
			F.lava = 1

/datum/round_event/wizard/lava/tick()

	for(var/mob/living/carbon/L in living_mob_list)
		if(istype(L.loc, /turf/simulated/floor)) // Are they on LAVA?!
			var/turf/simulated/floor/F = L.loc
			if(F.lava)
				var/safe = 0
				for(var/obj/structure/O in F.contents)
					if(O.level > F.level && !istype(O, /obj/structure/window)) // Something to stand on and it isn't under the floor!
						safe = 1
				if(!safe)
					L.adjustFireLoss(3)

/datum/round_event/wizard/lava/end()

	for(var/turf/simulated/floor/F in world) // Reset everything.
		if(F.z == ZLEVEL_STATION)
			F.name = initial(F.name)
			F.desc = initial(F.desc)
			F.overlays.Cut()
			F.lava = 0
			F.update_icon()