/proc/start_events()
	if(prob(50))//Every 120 seconds and prob 50 2-4 weak spacedusts will hit the station
		spawn(1)
			dust_swarm("weak")
	if (!event && prob(eventchance))
		event()
		hadevent = 1
		spawn(1300)
			event = 0
	spawn(1200)
		start_events()

/proc/event()
	event = 1

	switch(pick(1,2,4,5,6,7,8,9,10,11))
		if(1)
			command_alert("Meteors have been detected on collision course with the station.", "Meteor Alert")
			world << sound('meteors.ogg')
			spawn(100)
				meteor_wave()
				meteor_wave()
			spawn(500)
				meteor_wave()
				meteor_wave()

		if(2)
			command_alert("Gravitational anomalies detected on the station. There is no additional data.", "Anomaly Alert")
			world << sound('granomalies.ogg')
			var/turf/T = pick(blobstart)
			var/obj/bhole/bh = new /obj/bhole( T.loc, 30 )
			spawn(rand(50, 300))
				del(bh)

		if(3) //Leaving the code in so someone can try and delag it, but this event can no longer occur randomly, per SoS's request. --NEO
			command_alert("Space-time anomalies detected on the station. There is no additional data.", "Anomaly Alert")
			world << sound('spanomalies.ogg')
			var/list/turfs = new
			var/turf/picked
			for(var/turf/simulated/floor/T in world)
				if(T.z == 1)
					turfs += T
			for(var/turf/simulated/floor/T in turfs)
				if(prob(20))
					spawn(50+rand(0,3000))
						picked = pick(turfs)
						var/obj/portal/P = new /obj/portal( T )
						P.target = picked
						P.creator = null
						P.icon = 'objects.dmi'
						P.failchance = 0
						P.icon_state = "anom"
						P.name = "wormhole"
						spawn(rand(300,600))
							del(P)
		if(4)
			command_alert("Confirmed anomaly type SPC-MGM-152 aboard [station_name()]. All personnel must destroy the anomaly.", "Anomaly Alert")
			world << sound('outbreak5.ogg')
			var/turf/T = pick(blobstart)
			var/obj/blob/bl = new /obj/blob( T.loc, 30 )
			spawn(0)
				bl.Life()
				bl.Life()
				bl.Life()
				bl.Life()
				bl.Life()
			blobevent = 1
			dotheblobbaby()
			spawn(3000)
				blobevent = 0
			//start loop here

		if(5)
			high_radiation_event()
		if(6)
			viral_outbreak()
		if(7)
			alien_infestation()
		if(8)
			prison_break()
		if(9)
			carp_migration()
		if(10)
			immovablerod()
		if(11)
			lightsout(1,2)

/proc/dotheblobbaby()
	if (blobevent)
		for(var/obj/blob/B in world)
			if (prob (40))
				B.Life()
		spawn(30)
			dotheblobbaby()

/obj/bhole/New()
	src.smoke = new /datum/effects/system/harmless_smoke_spread()
	src.smoke.set_up(5, 0, src)
	src.smoke.attach(src)
	src:life()

/obj/bhole/Bumped(atom/A)
	if (istype(A,/mob/living))
		del(A)
	else
		A:ex_act(1.0)

/obj/bhole/proc/life() //Oh man , this will LAG

	if (prob(10))
		src.anchored = 0
		step(src,pick(alldirs))
		if (prob(30))
			step(src,pick(alldirs))
		src.anchored = 1

	for (var/atom/X in orange(9,src))
		if ((istype(X,/obj) || istype(X,/mob/living)) && prob(7))
			if (!X:anchored)
				step_towards(X,src)

	for (var/atom/B in orange(7,src))
		if (istype(B,/obj))
			if (!B:anchored && prob(50))
				step_towards(B,src)
				if(prob(10)) B:ex_act(3.0)
			else
				B:anchored = 0
				//step_towards(B,src)
				//B:anchored = 1
				if(prob(10)) B:ex_act(3.0)
		else if (istype(B,/turf))
			if (istype(B,/turf/simulated) && (prob(1) && prob(75)))
				src.smoke.start()
				B:ReplaceWithSpace()
		else if (istype(B,/mob/living))
			step_towards(B,src)


	for (var/atom/A in orange(4,src))
		if (istype(A,/obj))
			if (!A:anchored && prob(90))
				step_towards(A,src)
				if(prob(30)) A:ex_act(2.0)
			else
				A:anchored = 0
				//step_towards(A,src)
				//A:anchored = 1
				if(prob(30)) A:ex_act(2.0)
		else if (istype(A,/turf))
			if (istype(A,/turf/simulated) && prob(1))
				src.smoke.start()
				A:ReplaceWithSpace()
		else if (istype(A,/mob/living))
			step_towards(A,src)


	for (var/atom/D in orange(1,src))
		//if (hascall(D,"blackholed"))
		//	call(D,"blackholed")(null)
		//	continue
		if (istype(D,/mob/living))
			del(D)
		else
			D:ex_act(1.0)

	spawn(17)
		life()

/proc/power_failure()
	command_alert("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure")
	world << sound('poweroff.ogg')
	for(var/obj/machinery/power/apc/C in world)
		if(C.cell && C.z == 1)
			C.cell.charge = 0
	for(var/obj/machinery/power/smes/S in world)
		if(istype(get_area(S), /area/turret_protected) || S.z != 1)
			continue
		S.charge = 0
		S.output = 0
		S.online = 0
		S.updateicon()
		S.power_change()
	for(var/area/A in world)
		if(A.name != "Space" && A.name != "Engine Walls" && A.name != "Chemical Lab Test Chamber" && A.name != "Escape Shuttle" && A.name != "Arrival Area" && A.name != "Arrival Shuttle" && A.name != "start area" && A.name != "Engine Combustion Chamber")
			A.power_light = 0
			A.power_equip = 0
			A.power_environ = 0
			A.power_change()

/proc/power_restore()
	command_alert("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal")
	world << sound('poweron.ogg')
	for(var/obj/machinery/power/apc/C in world)
		if(C.cell && C.z == 1)
			C.cell.charge = C.cell.maxcharge
	for(var/obj/machinery/power/smes/S in world)
		if(S.z != 1)
			continue
		S.charge = S.capacity
		S.output = 200000
		S.online = 1
		S.updateicon()
		S.power_change()
	for(var/area/A in world)
		if(A.name != "Space" && A.name != "Engine Walls" && A.name != "Chemical Lab Test Chamber" && A.name != "space" && A.name != "Escape Shuttle" && A.name != "Arrival Area" && A.name != "Arrival Shuttle" && A.name != "start area" && A.name != "Engine Combustion Chamber")
			A.power_light = 1
			A.power_equip = 1
			A.power_environ = 1
			A.power_change()

/proc/viral_outbreak(var/virus = null)
	command_alert("Confirmed outbreak of level 7 viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert")
	world << sound('outbreak7.ogg')
	var/virus_type
	if(!virus)
		virus_type = pick(/datum/disease/dnaspread,/datum/disease/flu,/datum/disease/cold,/datum/disease/brainrot,/datum/disease/magnitis,/datum/disease/pierrot_throat)
	else
		switch(virus)
			if("fake gbs")
				virus_type = /datum/disease/fake_gbs
			if("gbs")
				virus_type = /datum/disease/gbs
			if("magnitis")
				virus_type = /datum/disease/magnitis
			if("rhumba beat")
				virus_type = /datum/disease/rhumba_beat
			if("brain rot")
				virus_type = /datum/disease/brainrot
			if("cold")
				virus_type = /datum/disease/cold
			if("retrovirus")
				virus_type = /datum/disease/dnaspread
			if("flu")
				virus_type = /datum/disease/flu
//			if("t-virus")
//				virus_type = /datum/disease/t_virus
			if("pierrot's throat")
				virus_type = /datum/disease/pierrot_throat
	for(var/mob/living/carbon/human/H in world)
		if((H.virus) || (H.stat == 2))
			continue
		if(virus_type == /datum/disease/dnaspread) //Dnaspread needs strain_data set to work.
			if((!H.dna) || (H.sdisabilities & 1)) //A blindness disease would be the worst.
				continue
			var/datum/disease/dnaspread/D = new
			D.strain_data["name"] = H.real_name
			D.strain_data["UI"] = H.dna.uni_identity
			D.strain_data["SE"] = H.dna.struc_enzymes
			D.carrier = 1
			D.holder = H
			D.affected_mob = H
			H.virus = D
			break
		else
			H.virus = new virus_type
			H.virus.affected_mob = H
			H.virus.holder = H
			H.virus.carrier = 1
			break

/proc/alien_infestation() // -- TLE
	command_alert("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert")
	world << sound('aliens.ogg')
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in world)
		if(temp_vent.loc.z == 1 && !temp_vent.welded)
			vents.Add(temp_vent)
	var/spawncount = rand(2, 6)
	while(spawncount > 1)
		var/obj/vent = pick(vents)
		if(prob(50))
			new /obj/alien/facehugger (vent.loc)
		if(prob(50))
			new /obj/alien/facehugger (vent.loc)
		if(prob(75))
			new /obj/alien/egg (vent.loc)
		vents.Remove(vent)
		spawncount -= 1

/proc/high_radiation_event()
	command_alert("High levels of radiation detected near the station. Please report to the Med-bay if you feel strange.", "Anomaly Alert")
	world << sound('radiation.ogg')
	for(var/mob/living/carbon/human/H in world)
		H.radiation += rand(5,25)
		if (prob(5))
			H.radiation += rand(30,50)
		if (prob(25))
			if (prob(75))
				randmutb(H)
				domutcheck(H,null,1)
			else
				randmutg(H)
				domutcheck(H,null,1)
	for(var/mob/living/carbon/monkey/M in world)
		M.radiation += rand(5,25)

/proc/prison_break() // -- Callagan
	for (var/obj/machinery/power/apc/temp_apc in world)
		if(istype(get_area(temp_apc), /area/prison))
			temp_apc.overload_lighting()
	for (var/obj/machinery/computer/prison_shuttle/temp_shuttle in world)
		temp_shuttle.prison_break()
	for (var/obj/secure_closet/security1/temp_closet in world)
		if(istype(get_area(temp_closet), /area/prison))
			temp_closet.prison_break()
	for (var/obj/machinery/door/airlock/security/temp_airlock in world)
		if(istype(get_area(temp_airlock), /area/prison))
			temp_airlock.prison_open()
	sleep(150)
	command_alert("Prison station VI is not accepting commands. Recommend station AI involvement.", "VI Alert")

/proc/carp_migration() // -- Darem
	for(var/obj/landmark/C in world)
		if(C.name == "carpspawn")
			if(prob(99))
				new /obj/livestock/spesscarp(C.loc)
			else
				new /obj/livestock/spesscarp/elite(C.loc)
	sleep(100)
	command_alert("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")
	world << sound('commandreport.ogg')

/proc/lightsout(isEvent = 0, lightsoutAmount = 1,lightsoutRange = 25) //leave lightsoutAmount as 0 to break ALL lights
	if(isEvent)
		command_alert("An Electrical storm has been detected in your area, please repair potential electronic overloads.","Electrical Storm Alert")

	if(lightsoutAmount)
		var/list/epicentreList = list()

		for(var/i=1,i<=lightsoutAmount,i++)
			var/list/possibleEpicentres = list()
			for(var/obj/landmark/newEpicentre in world)
				if(newEpicentre.name == "lightsout" && !(newEpicentre in epicentreList))
					possibleEpicentres += newEpicentre
			if(possibleEpicentres.len)
				epicentreList += pick(possibleEpicentres)
			else
				break

		if(!epicentreList.len)
			return

		for(var/obj/landmark/epicentre in epicentreList)
			for(var/obj/machinery/power/apc/apc in range(epicentre,lightsoutRange))
				apc.overload_lighting()

	else
		for(var/obj/machinery/power/apc/apc in world)
			apc.overload_lighting()

	return