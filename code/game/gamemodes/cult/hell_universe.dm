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
		to_chat(user, "<span class='sinister'>All you hear on the frequency is static and panicked screaming. There will be no shuttle call today.</span>")
	return 0
	*/

/datum/universal_state/hell/DecayTurf(var/turf/T)
	if(!T.holy)
		T.cultify()
		for(var/obj/machinery/light/L in T.contents)
			new /obj/structure/cult/pylon(L.loc)
			qdel(L)
	return


/datum/universal_state/hell/OnTurfChange(var/turf/T)
	if(T.name == "space")
		T.overlays += "hell01"
		T.underlays -= "hell01"
	else
		T.overlays -= "hell01"

// Apply changes when entering state
/datum/universal_state/hell/OnEnter()
	set background = 1
	/*
	if(emergency_shuttle.direction==2)
		captain_announce("The emergency shuttle has returned due to bluespace distortion.")

	emergency_shuttle.force_shutdown()
	*/

	escape_list = get_area_turfs(locate(/area/hallway/secondary/exit))
	tcheck(80,1)
	suspend_alert = 1

	//separated into separate procs for profiling
	AreaSet()
	tcheck(80,1)
	MiscSet()
	tcheck(80,1)
	APCSet()
	tcheck(80,1)
	KillMobs()
	tcheck(80,1)
	OverlayAndAmbientSet()
	tcheck(80,1)
	runedec += 9000	//basically removing the rune cap

	ticker.StartThematic("endgame")


/datum/universal_state/hell/proc/AreaSet()
	for(var/area/A in areas)
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

/*
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
*/

		A.updateicon()
		tcheck(80,1)

/datum/universal_state/hell/OverlayAndAmbientSet()
	for(var/turf/T in turfs)
		if(istype(T, /turf/space))
			T.overlays += "hell01"
		else
			T.underlays += "hell01"
		tcheck(85,1)

	for(var/atom/movable/lighting_overlay/L in all_lighting_overlays)
		L.update_lumcount(0.5, 0, 0)
		tcheck(80,1)

/datum/universal_state/hell/proc/MiscSet()
	for(var/turf/simulated/floor/T in turfs)
		if(!T.holy && prob(1))
			new /obj/effect/gateway/active/cult(T)
		tcheck(80,1)

	for (var/obj/machinery/firealarm/alm in machines)
		if (!(alm.stat & BROKEN))
			alm.ex_act(2)
		tcheck(80,1)

/datum/universal_state/hell/proc/APCSet()
	for (var/obj/machinery/power/apc/APC in power_machines)
		if (!(APC.stat & BROKEN) && !istype(APC.areaMaster,/area/turret_protected/ai))
			APC.chargemode = 0
			if(APC.cell)
				APC.cell.charge = 0
			APC.emagged = 1
			APC.queue_icon_update()
		tcheck(85,1)

/datum/universal_state/hell/proc/KillMobs()
	for(var/mob/living/simple_animal/M in mob_list)
		if(M && !M.client)
			M.stat = DEAD
		tcheck(80,1)
