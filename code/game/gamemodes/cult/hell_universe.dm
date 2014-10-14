/*

In short:
 * Random area alarms
 * All areas jammed
 * Random gateways spawning hellmonsters (and turn people into cluwnes if ran into)
 * Broken APCs/Fire Alarms
 * Scary music
 * Random tiles changing to culty tiles.

*/
/datum/universal_state/hell
	name = "Hell Rising"
	desc = "OH FUCK OH FUCK OH FUCK"

	decay_rate = 5 // 5% chance of a turf decaying on lighting update/airflow (there's no actual tick for turfs)

/datum/universal_state/hell/OnShuttleCall(var/mob/user)
	return 1
	/*
	if(user)
		user << "<span class='sinister'>All you hear on the frequency is static and panicked screaming. There will be no shuttle call today.</span>"
	return 0
	*/

/datum/universal_state/hell/DecayTurf(var/turf/T)
	if(istype(T,/turf/simulated/wall) && !istype(T,/turf/simulated/wall/cult))
		T.ChangeTurf(/turf/simulated/wall/cult)
		return
	if(istype(T,/turf/simulated/floor) && !istype(T,/turf/simulated/floor/engine/cult))
		T.ChangeTurf(/turf/simulated/floor/engine/cult)
		return


// Apply changes when entering state
/datum/universal_state/hell/OnEnter()
	/*
	if(emergency_shuttle.direction==2)
		captain_announce("The emergency shuttle has returned due to bluespace distortion.")

	emergency_shuttle.force_shutdown()
	*/

	for(var/area/ca in world)
		var/area/A=get_area_master(ca)
		if(!istype(A,/area) || A.name=="Space")
			continue

		// No cheating~
		A.jammed=2

		// Reset all alarms.
		A.fire     = null
		A.atmos    = 1
		A.atmosalm = 0
		A.poweralm = 1
		A.party    = null
		A.radalert = 0

		// Slap random alerts on shit
		if(prob(25))
			switch(rand(1,4))
				if(1)
					A.fire=1
				if(2)
					A.atmosalm=1
				if(3)
					A.radalert=1
				if(4)
					A.party=1

		A.updateicon()

	for(var/turf/T in world)
		if(istype(T,/turf/simulated/floor) && prob(1))
			new /obj/effect/gateway/active/cult(T)

	for (var/obj/machinery/firealarm/alm in world)
		if (!(alm.stat & BROKEN))
			alm.ex_act(2)

	for (var/obj/machinery/power/apc/APC in world)
		if (!(APC.stat & BROKEN) && !istype(APC.areaMaster,/area/turret_protected/ai))
			if(APC.cell)
				APC.cell.charge = 0
			APC.emagged = 1
			APC.queue_icon_update()
			APC.update()

	for(var/mob/living/simple_animal/M in world)
		if(M && !M.client)
			M.stat = DEAD

	ticker.StartThematic("endgame")