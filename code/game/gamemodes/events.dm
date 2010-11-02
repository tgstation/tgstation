/proc/start_events()
	if (!event && prob(eventchance))
		event()
		hadevent = 1
		spawn(1300)
			event = 0
	spawn(1200)
		start_events()

/proc/event()
	switch(rand(1,7))
		if(1)
			event = 1
			command_alert("Meteors have been detected on collision course with the station.", "Meteor Alert")
			world << sound('meteors.ogg')
			spawn(100)
				meteor_wave()
				meteor_wave()
			spawn(500)
				meteor_wave()
				meteor_wave()

		if(2)
			event = 1
			command_alert("Gravitational anomalies detected on the station. There is no additional data.", "Anomaly Alert")
			world << sound('granomalies.ogg')
			var/turf/T = pick(blobstart)
			var/obj/bhole/bh = new /obj/bhole( T.loc, 30 )
			spawn(rand(50, 300))
				del(bh)

		if(3)
			event = 1
			command_alert("Space-time anomalies detected on the station. There is no additional data.", "Anomaly Alert")
			world << sound('spanomalies.ogg')
			var/list/turfs = list(	)
			var/turf/picked
			for(var/turf/T in world)
				if(T.z == 1 && istype(T,/turf/simulated/floor) && !istype(T,/turf/space))
					turfs += T
			for(var/turf/T in world)
				if(prob(20) && T.z == 1 && istype(T,/turf/simulated/floor))
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
			event = 1
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
			event = 1
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
		if(6)
			event = 1
			viral_outbreak()
		if(7)
			event = 1
			alien_infestation()

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
	var/mob/dead/observer/newmob
	if (istype(A,/mob/living) && A:client)
		newmob = new/mob/dead/observer(A)
		A:client:mob = newmob
		newmob:client:eye = newmob
		del(A)
	else if (istype(A,/mob/living) && !A:client)
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
		var/mob/dead/observer/newmob
		if (istype(D,/mob/living) && D:client)
			newmob = new/mob/dead/observer(D)
			D:client:mob = newmob
			newmob:client:eye = newmob
			del(D)
		else if (istype(D,/mob/living) && !D:client)
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
		virus_type = pick(/datum/disease/dnaspread,/datum/disease/flu,/datum/disease/cold,/datum/disease/brainrot,/datum/disease/magnitis,/datum/disease/wizarditis)
	else
		switch(virus)
			if("fake gbs")
				virus_type = /datum/disease/fake_gbs
			if("gbs")
				virus_type = /datum/disease/gbs
			if("magnitis")
				virus_type = /datum/disease/magnitis
			if("wizarditis")
				virus_type = /datum/disease/wizarditis
			if("brain rot")
				virus_type = /datum/disease/brainrot
			if("cold")
				virus_type = /datum/disease/cold
			if("rhinovirus")
				virus_type = /datum/disease/dnaspread
			if("flu")
				virus_type = /datum/disease/flu
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