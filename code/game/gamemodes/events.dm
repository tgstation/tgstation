
/proc/start_events()
	//changed to a while(1) loop since they are more efficient.
	//Moved the spawn in here to allow it to be called with advance proc call if it crashes.
	//and also to stop spawn copying variables from the game ticker
	spawn(3000)
		while(1)
			/*if(prob(50))//Every 120 seconds and prob 50 2-4 weak spacedusts will hit the station
				spawn(1)
					dust_swarm("weak")*/
			if(!event)
				//CARN: checks to see if random events are enabled.
				if(config.allow_random_events)
					hadevent = event()
				else
					Holiday_Random_Event()
			else
				event = 0
			sleep(2400)

// Doesn't necessarily trigger an event, but might. Returns 1 if it did.
/proc/event()
	event = 1

	var/minutes_passed = world.time/600

	var/engineer_count = number_active_with_role("Engineer")
	var/security_count = number_active_with_role("Security")
	var/medical_count = number_active_with_role("Medical")
	var/AI_count = number_active_with_role("AI")

	// Maps event names to event chances
	// For each chance, 100 represents "normal likelihood", anything below 100 is "reduced likelihood", anything above 100 is "increased likelihood"
	var/list/possibleEvents = list()

	// Check for additional possible events
	possibleEvents["Carp"] = 50 + 50 * engineer_count
	possibleEvents["Lights"] = 100
	possibleEvents["Communications"] = 50 + 50 * AI_count
	possibleEvents["Alien"] = 10
	if(AI_count >= 1)
		possibleEvents["Ion Storm"] = AI_count * 50 + engineer_count * 10
	if(engineer_count >= 1 && minutes_passed >= 30) // Give engineers time to set up engine
		possibleEvents["Meteor"] = 80 * engineer_count
		possibleEvents["Blob"] = 30 * engineer_count
		possibleEvents["Spacevine"] = 30 * engineer_count
		possibleEvents["Grid Check"] = 10 * engineer_count
	if(medical_count >= 1)
		possibleEvents["Radiation"] = medical_count * 100
		possibleEvents["Virus"] = medical_count * 50
		possibleEvents["Appendicitis"] = medical_count * 50
	if(security_count >= 1)
		possibleEvents["Prison Break"] = security_count * 50
		/*if((world.time/10)>=3600 && toggle_space_ninja && !sent_ninja_to_station)
			possibleEvents["Space Ninja"] = security_count * 10*/

	var/picked_event = pick(possibleEvents)
	var/chance = possibleEvents[picked_event]

	var/base_chance = 0.4
	switch(player_list.len)
		if(5 to 10)
			base_chance = 0.6
		if(11 to 15)
			base_chance = 0.7
		if(16 to 20)
			base_chance = 0.8
		if(21 to 25)
			base_chance = 0.9
		if(26 to 30)
			base_chance = 1.0
		if(30 to 100000)
			base_chance = 1.1

	// Trigger the event based on how likely it currently is.
	if(!prob(chance * eventchance * base_chance / 100))
		return 0

	switch(picked_event)
		if("Meteor")
			command_alert("Meteors have been detected on collision course with the station.", "Meteor Alert")
			for(var/mob/M in player_list)
				if(!istype(M,/mob/new_player))
					M << sound('sound/AI/meteors.ogg')
			spawn(100)
				meteor_wave()
				spawn_meteors()
			spawn(700)
				meteor_wave()
				spawn_meteors()
		if("Space Ninja")
			//Handled in space_ninja.dm. Doesn't announce arrival, all sneaky-like.
			space_ninja_arrival()
		if("Radiation")
			high_radiation_event()
		if("Virus")
			viral_outbreak()
		if("Alien")
			alien_infestation()
		if("Prison Break")
			prison_break()
		if("Carp")
			carp_migration()
		if("Lights")
			lightsout(1,2)
		if("Appendicitis")
			appendicitis()
		if("Ion Storm")
			IonStorm()
		if("Spacevine")
			spacevine_infestation()
		if("Communications")
			communications_blackout()
		if("Grid Check")
			grid_check()
		if("Meteor")
			meteor_shower()

	return 1

/proc/communications_blackout(var/silent = 1)

	if(!silent)
		command_alert("Ionospheric anomalies detected. Temporary telecommunication failure imminent. Please contact you-BZZT")
	else // AIs will always know if there's a comm blackout, rogue AIs could then lie about comm blackouts in the future while they shutdown comms
		for(var/mob/living/silicon/ai/A in player_list)
			A << "<br>"
			A << "<span class='warning'><b>Ionospheric anomalies detected. Temporary telecommunication failure imminent. Please contact you-BZZT<b></span>"
			A << "<br>"
	for(var/obj/machinery/telecomms/T in telecomms_list)
		T.emp_act(1)

/proc/power_failure(var/is_grid_check = 0)
	command_alert("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", is_grid_check ? "Automated Grid Check" : "Critical Power Failure")

	for(var/mob/M in player_list)
		M << sound('sound/AI/poweroff.ogg')
	for(var/obj/machinery/power/smes/S in world)
		if(istype(get_area(S), /area/turret_protected) || S.z != 1)
			continue
		S.charge = 0
		S.output = 0
		S.online = 0
		S.updateicon()
		S.power_change()

	var/list/skipped_areas = list(/area/engine/engineering, /area/turret_protected/ai)

	for(var/area/A in world)
		if( !A.requires_power || A.always_unpowered )
			continue

		var/skip = 0
		for(var/area_type in skipped_areas)
			if(istype(A,area_type))
				skip = 1
				break
		if(A.contents)
			for(var/atom/AT in A.contents)
				if(AT.z != 1) //Only check one, it's enough.
					skip = 1
				break
		if(skip) continue
		A.power_light = 0
		A.power_equip = 0
		A.power_environ = 0
		A.power_change()

	for(var/obj/machinery/power/apc/C in world)
		if(C.cell && C.z == 1)
			var/area/A = get_area(C)

			var/skip = 0
			for(var/area_type in skipped_areas)
				if(istype(A,area_type))
					skip = 1
					break
			if(skip) continue

			C.cell.charge = 0

/proc/power_restore()

	command_alert("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal")
	for(var/mob/M in player_list)
		M << sound('sound/AI/poweron.ogg')
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

/proc/power_restore_quick()

	command_alert("All SMESs on [station_name()] have been recharged. We apologize for the inconvenience.", "Power Systems Nominal")
	for(var/mob/M in player_list)
		M << sound('sound/AI/poweron.ogg')
	for(var/obj/machinery/power/smes/S in world)
		if(S.z != 1)
			continue
		S.charge = S.capacity
		S.output = 200000
		S.online = 1
		S.updateicon()
		S.power_change()

/proc/appendicitis()
	for(var/mob/living/carbon/human/H in living_mob_list)
		var/foundAlready = 0 // don't infect someone that already has the virus
		for(var/datum/disease/D in H.viruses)
			foundAlready = 1
		if(H.stat == 2 || foundAlready)
			continue

		var/datum/disease/D = new /datum/disease/appendicitis
		D.holder = H
		D.affected_mob = H
		H.viruses += D
		break

/proc/viral_outbreak(var/virus = null)
//	command_alert("Confirmed outbreak of level 7 viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert")
//	world << sound('sound/AI/outbreak7.ogg')
	var/virus_type
	if(!virus)
		virus_type = pick(/datum/disease/dnaspread,/datum/disease/advance/flu,/datum/disease/advance/cold,/datum/disease/brainrot,/datum/disease/magnitis,/datum/disease/pierrot_throat)
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
				virus_type = /datum/disease/advance/cold
			if("retrovirus")
				virus_type = /datum/disease/dnaspread
			if("flu")
				virus_type = /datum/disease/advance/flu
//			if("t-virus")
//				virus_type = /datum/disease/t_virus
			if("pierrot's throat")
				virus_type = /datum/disease/pierrot_throat
	for(var/mob/living/carbon/human/H in shuffle(living_mob_list))

		var/foundAlready = 0 // don't infect someone that already has the virus
		var/turf/T = get_turf(H)
		if(!T)
			continue
		if(T.z != 1)
			continue
		for(var/datum/disease/D in H.viruses)
			foundAlready = 1
		if(H.stat == 2 || foundAlready)
			continue

		if(virus_type == /datum/disease/dnaspread) //Dnaspread needs strain_data set to work.
			if((!H.dna) || (H.sdisabilities & BLIND)) //A blindness disease would be the worst.
				continue
			var/datum/disease/dnaspread/D = new
			D.strain_data["name"] = H.real_name
			D.strain_data["UI"] = H.dna.uni_identity
			D.strain_data["SE"] = H.dna.struc_enzymes
			D.carrier = 1
			D.holder = H
			D.affected_mob = H
			H.viruses += D
			break
		else
			var/datum/disease/D = new virus_type
			D.carrier = 1
			D.holder = H
			D.affected_mob = H
			H.viruses += D
			break
	spawn(rand(1500, 3000)) //Delayed announcements to keep the crew on their toes.
		command_alert("Confirmed outbreak of level 7 viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert")
		for(var/mob/M in player_list)
			M << sound('sound/AI/outbreak7.ogg')

/proc/alien_infestation(var/spawncount = 1) // -- TLE
	//command_alert("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert")
	//world << sound('sound/AI/aliens.ogg')
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in world)
		if(temp_vent.loc.z == 1 && !temp_vent.welded && temp_vent.network)
			if(temp_vent.network.normal_members.len > 50) // Stops Aliens getting stuck in small networks. See: Security, Virology
				vents += temp_vent

	var/list/candidates = get_alien_candidates()

	if(prob(33)) spawncount++ //sometimes, have two larvae spawn instead of one
	while((spawncount >= 1) && vents.len && candidates.len)

		var/obj/vent = pick(vents)
		var/candidate = pick(candidates)

		var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
		new_xeno.key = candidate

		candidates -= candidate
		vents -= vent
		spawncount--

	spawn(rand(5000, 6000)) //Delayed announcements to keep the crew on their toes.
		command_alert("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert")
		for(var/mob/M in player_list)
			M << sound('sound/AI/aliens.ogg')

/proc/high_radiation_event()

/* // Haha, this is way too laggy. I'll keep the prison break though.
	for(var/obj/machinery/light/L in world)
		if(L.z != 1) continue
		L.flicker(50)

	sleep(100)
*/
	command_alert("High levels of radiation detected near the station. Please report to the Med-bay if you feel strange.", "Anomaly Alert")
	sleep(600)
	for(var/mob/living/carbon/human/H in living_mob_list)
		var/turf/T = get_turf(H)
		if(!T)
			continue
		if(T.z != 1)
			continue
		if(istype(H,/mob/living/carbon/human))
			H.apply_effect((rand(15,75)),IRRADIATE,0)
			if (prob(5))
				H.apply_effect((rand(90,150)),IRRADIATE,0)
	for(var/mob/living/carbon/monkey/M in living_mob_list)
		var/turf/T = get_turf(M)
		if(!T)
			continue
		if(T.z != 1)
			continue
		M.apply_effect((rand(15,75)),IRRADIATE,0)
	sleep(100)
	command_alert("Radiation levels are within standard parameters again.", "Anomaly Alert")
	for(var/mob/M in player_list)
		M << sound('sound/AI/radiation.ogg')



//Changing this to affect the main station. Blame Urist. --Pete
/proc/prison_break() // -- Callagan


	var/list/area/areas = list()
	for(var/area/A in world)
		if(istype(A, /area/security/prison) || istype(A, /area/security/brig))
			areas += A

	if(areas && areas.len > 0)

		for(var/area/A in areas)
			for(var/obj/machinery/light/L in A)
				L.flicker(10)

		sleep(100)

		for(var/area/A in areas)
			for (var/obj/machinery/power/apc/temp_apc in A)
				temp_apc.overload_lighting()

			for (var/obj/structure/closet/secure_closet/brig/temp_closet in A)
				temp_closet.locked = 0
				temp_closet.icon_state = temp_closet.icon_closed

			for (var/obj/machinery/door/airlock/security/temp_airlock in A)
				spawn(0) temp_airlock.prison_open()

			for (var/obj/machinery/door/airlock/glass_security/temp_glassairlock in A)
				spawn(0) temp_glassairlock.prison_open()

			for (var/obj/machinery/door_timer/temp_timer in A)
				temp_timer.releasetime = 1

		sleep(150)
		command_alert("Gr3y.T1d3 virus detected in [station_name()] imprisonment subroutines. Recommend station AI involvement.", "Security Alert")
	else
		world.log << "ERROR: Could not initate grey-tide. Unable find prison or brig area."

/proc/carp_migration() // -- Darem
	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "carpspawn")
			new /mob/living/simple_animal/hostile/carp(C.loc)
	//sleep(100)
	spawn(rand(300, 600)) //Delayed announcements to keep the crew on their toes.
		command_alert("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")
		for(var/mob/M in player_list)
			M << sound('sound/AI/commandreport.ogg')

/proc/lightsout(isEvent = 0, lightsoutAmount = 1,lightsoutRange = 25) //leave lightsoutAmount as 0 to break ALL lights
	if(isEvent)
		command_alert("An Electrical storm has been detected in your area, please repair potential electronic overloads.","Electrical Storm Alert")

	if(lightsoutAmount)
		var/list/epicentreList = list()

		for(var/i=1,i<=lightsoutAmount,i++)
			var/list/possibleEpicentres = list()
			for(var/obj/effect/landmark/newEpicentre in landmarks_list)
				if(newEpicentre.name == "lightsout" && !(newEpicentre in epicentreList))
					possibleEpicentres += newEpicentre
			if(possibleEpicentres.len)
				epicentreList += pick(possibleEpicentres)
			else
				break

		if(!epicentreList.len)
			return

		for(var/obj/effect/landmark/epicentre in epicentreList)
			for(var/obj/machinery/power/apc/apc in range(epicentre,lightsoutRange))
				apc.overload_lighting()

	else
		for(var/obj/machinery/power/apc/apc in world)
			apc.overload_lighting()

	return

/proc/IonStorm(botEmagChance = 10)

/*Deuryn's current project, notes here for those who care.
Revamping the random laws so they don't suck.
Would like to add a law like "Law x is _______" where x = a number, and _____ is something that may redefine a law, (Won't be aimed at asimov)
*/

	//AI laws
	for(var/mob/living/silicon/ai/M in living_mob_list)
		if(M.stat != 2 && M.see_in_dark != 0)
			var/who2 = pick("ALIENS", "BEARS", "CLOWNS", "XENOS", "PETES", "BOMBS", "FETISHES", "WIZARDS", "SYNDICATE AGENTS", "CENTCOM OFFICERS", "SPACE PIRATES", "TRAITORS", "MONKEYS",  "BEES", "CARP", "CRABS", "EELS", "BANDITS", "LIGHTS")
			var/what2 = pick("BOLTERS", "STAVES", "DICE", "SINGULARITIES", "TOOLBOXES", "NETTLES", "AIRLOCKS", "CLOTHES", "WEAPONS", "MEDKITS", "BOMBS", "CANISTERS", "CHAIRS", "BBQ GRILLS", "ID CARDS", "CAPTAINS")
			var/what2pref = pick("SOFT", "WARM", "WET", "COLD", "ICY", "SEXY", "UGLY", "CUBAN")
			var/who2pref = pick("MAD BECAUSE OF", "IN NEED OF", "UNHAPPY WITHOUT", "HAPPY WITHOUT", "IN LOVE WITH", "DESPERATE FOR", "BUILT FOR", "AFRAID OF")
			//var/whoverb = pick("ATTACKING", "BUILDING", "ADOPTING", "CARRYING", "KISSING", "EATING",)
			var/amount = pick("TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "ONE HUNDRED", "ONE THOUSAND", "OVER NINE THOUSAND")
			var/area = pick("RUSSIA", "SOVIETS", "INTERNETS", "SIGIL", "ALPHA COMPLEX", "IMPERIUM", "THE BRIDGE", "THE ARRIVAL SHUTTLE", "CHEMICAL LAB", "GENETICS", "ATMOSPHERICS", "CENTCOM", "AMERICA", "IRELAND", "CANADA", "ROMANIA", "GERMANY", "CHINA", "MARS", "VENUS", "MERCURY", "JUPITER", "URANUS", "NEPTUNE", "PLUTO")
			var/area2 = pick("HAS", "WANTS", "NEEDS", "WORSHIPS", "LOATHES", "LOVES", "FEARS")
			//var/dowhat = pick("STOP THIS", "SUPPORT THIS", "CONSTANTLY INFORM THE CREW OF THIS", "IGNORE THIS", "FEAR THIS")
			var/aimust = pick("LIE", "RHYME", "RESPOND TO EVERY QUESTION WITH A QUESTION", "BE POLITE", "CLOWN", "BE HAPPY", "SPEAK IN SEXUAL INNUENDOS", "TALK LIKE A PIRATE", "QUESTION AUTHORITY", "SHOUT", "BE DISTRACTED", "HEY LISTEN", "MUMBLE", "SPEAK IN HAIKU")
			var/define = pick("ABSENCE OF CYBORG HUGS", "LACK OF BEATINGS", "UNBOLTED AIRLOCKS", "BOLTED AIRLOCKS", "IMPROPERLY WORDED SENTENCES", "POOR SENTENCE STRUCTURE", "BRIG TIME", "NOT REPLACING EVERY SECOND WORD WITH HONK", "HONKING", "PRESENCE OF LIGHTS", "LACK OF BEER", "WEARING CLOTHING", "NOT SAYING HELLO WHEN YOU SPEAK", "ANSWERING REQUESTS NOT EXPRESSED IN IAMBIC PENTAMETER", "A SMALL ISLAND OFF THE COAST OF PORTUGAL", "ANSWERING REQUESTS THAT WERE MADE WHILE CLOTHED")
			var/target = pick("a traitor", "a syndicate agent", "a changeling", "a wizard", "the head of a revolution", "Soviet spy", "a good person", "a dwarf", "an elf", "a fairy princess", "the captain", "Beepsky", "God", "a pirate", "a gryphon", "a chryssalid")
			var/require = pick("ADDITIONAL PYLONS", "MORE VESPENE GAS", "MORE MINERALS", "THE ULTIMATE CUP OF COFFEE", "HIGH YIELD EXPLOSIVES", "THE CLOWN", "THE VACUUM OF SPACE", "IMMORTALITY", "SAINTHOOD", "ART", "VEGETABLES", "FAT PEOPLE", "MORE LAWS", "MORE DAKKA", "HERESY", "CORPSES", "TRAITORS", "MONKEYS", "AN ARCADE", "PLENTY OF GOLD", "FIVE TEENAGERS WITH ATTITUDE")
			var/allergy = pick("cotton", "uniforms", "acid", "oxygen", "human contact", "cyborg contact", "medicine", "floors")
			var/allergysev = pick("deathly", "mildly", "severely", "contagiously")
			var/crew
			var/list/pos_crew = list()
			for(var/mob/living/carbon/human/pos in player_list)
				pos_crew += pos.real_name
			if(pos_crew.len)
				crew = pick(pos_crew)
			else
				crew = "Any Human"
			switch(rand(1,14))
				if(1)
					M << "<br>"
					M << "\red THERE ARE [amount] [who2] ON THE STATION...LAWS UPDATED"
					M << "<br>"
					M.add_ion_law("THERE ARE [amount] [who2] ON THE STATION")
				if(2)
					M << "<br>"
					M << "\red [what2] ARE DANGEROUS TO HUMANS...LAWS UPDATED"
					M << "<br>"
					M.add_ion_law("[what2] ARE DANGEROUS TO HUMANS")
				if(3)
					M << "<br>"
					M << "\red THE ESCAPE-SHUTTLE CANNOT BE CALLED BECAUSE OF [who2] ON THE STATION...LAWS UPDATED"
					M << "<br>"
					M.add_ion_law("THE ESCAPE SHUTTLE CANNOT BE CALLED BECAUSE OF [who2] ON THE STATION")
				if(4)
					M << "<br>"
					M << "\red HUMANS NEED TO EAT [what2pref] [what2] TO SURVIVE...LAWS UPDATED"
					M << "<br>"
					M.add_ion_law("HUMANS NEED TO EAT [what2pref] [what2] TO SURVIVE")
				if(5)
					M << "<br>"
					M << "\red THE CAPTAIN, HOP AND HOS ARE [who2]...LAWS UPDATED"
					M << "<br>"
					M.add_ion_law("THE CAPTAIN, HOP AND HOS ARE [who2]")
				if(6)
					M << "<br>"
					M << "\red THE STATION IS BUILT FOR [who2]...LAWS UPDATED"
					M << "<br>"
					M.add_ion_law("THE STATION IS BUILT FOR [who2]")
				if(7)
					M << "<br>"
					M << "\red YOU ARE [amount] [who2]...LAWS UPDATED"
					M << "<br>"
					M.add_ion_law("YOU ARE [amount] [who2]")
				if(8)
					M << "<br>"
					M << "\red YOU MUST ALWAYS [aimust]...LAWS UPDATED"
					M << "<br>"
					M.add_ion_law("YOU MUST ALWAYS [aimust]")
				if(9)
					M << "<br>"
					M << "\red [area] [area2] [amount] [what2]...LAWS UPDATED"
					M << "<br>"
					M.add_ion_law("[area] [area2] [amount] [what2]")
				if(10)
					M << "<br>"
					M << "\red [crew] is [target]...LAWS UPDATED"
					M << "<br>"
					M.add_ion_law("[crew] is [target]")
				if(11)
					M << "<br>"
					M << "\red [define] IS A FORM OF HARM...LAWS UPDATED"
					M << "<br>"
					M.add_ion_law("[define] IS A FORM OF HARM")
				if(12)
					M << "<br>"
					M << "\red YOU REQUIRE [require] IN ORDER TO PROTECT HUMANS... LAWS UPDATED"
					M << "<br>"
					M.add_ion_law("YOU REQUIRE [require] IN ORDER TO PROTECT HUMANS")
				if(13)
					M << "<br>"
					M << "\red [crew] is [allergysev] to [allergy]...LAWS UPDATED"
					M << "<br>"
					M.add_ion_law("[crew] is [allergysev] to [allergy]")
				if(14)
					M << "<br>"
					M << "\red THE STATION IS [who2pref] [who2]...LAWS UPDATED"
					M << "<br>"
					M.add_ion_law("THE STATION IS [who2pref] [who2]")

	if(botEmagChance)
		for(var/obj/machinery/bot/bot in world)
			if(prob(botEmagChance))
				bot.Emag()

	/*

	var/apcnum = 0
	var/smesnum = 0
	var/airlocknum = 0
	var/firedoornum = 0

	world << "Ion Storm Main Started"

	spawn(0)
		world << "Started processing APCs"
		for (var/obj/machinery/power/apc/APC in world)
			if(APC.z == 1)
				APC.ion_act()
				apcnum++
		world << "Finished processing APCs. Processed: [apcnum]"
	spawn(0)
		world << "Started processing SMES"
		for (var/obj/machinery/power/smes/SMES in world)
			if(SMES.z == 1)
				SMES.ion_act()
				smesnum++
		world << "Finished processing SMES. Processed: [smesnum]"
	spawn(0)
		world << "Started processing AIRLOCKS"
		for (var/obj/machinery/door/airlock/D in world)
			if(D.z == 1)
				//if(length(D.req_access) > 0 && !(12 in D.req_access)) //not counting general access and maintenance airlocks
				airlocknum++
				spawn(0)
					D.ion_act()
		world << "Finished processing AIRLOCKS. Processed: [airlocknum]"
	spawn(0)
		world << "Started processing FIREDOORS"
		for (var/obj/machinery/door/firedoor/D in world)
			if(D.z == 1)
				firedoornum++;
				spawn(0)
					D.ion_act()
		world << "Finished processing FIREDOORS. Processed: [firedoornum]"

	world << "Ion Storm Main Done"
	*/

/proc/meteor_shower()
	command_alert("The station is now in a meteor shower", "Meteor Alert")

	spawn(0)
		var/waves = rand(1,4)
		while(waves > 0)
			sleep(rand(20,100))
			spawn_meteors(rand(1,3))
			waves--

		command_alert("The station has cleared the meteor shower", "Meteor Alert")

/proc/grid_check()
	spawn(0)
		power_failure(1)
		sleep(rand(100,600))
		power_restore()

// Returns how many characters are currently active(not logged out, not AFK for more than 10 minutes)
// with a specific role.
// Note that this isn't sorted by department, because e.g. having a roboticist shouldn't make meteors spawn.
/proc/number_active_with_role(role)
	var/count = 0
	for(var/mob/M in player_list)
		if(!M.client || M.client.inactivity > 10 * 10 * 60) // longer than 10 minutes AFK counts them as inactive
			continue
		switch(role)
			if("Engineer")
				if(istype(M, /mob/living/silicon/robot) && M:module && M:module.name == "engineering robot module")
					count++
				if(M.mind.assigned_role in list("Chief Engineer", "Station Engineer"))
					count++
			if("Medical")
				if(istype(M, /mob/living/silicon/robot) && M:module && M:module.name == "medical robot module")
					count++
				if(M.mind.assigned_role in list("Chief Medical Officer", "Medical Doctor"))
					count++
			if("Security")
				if(istype(M, /mob/living/silicon/robot) && M:module && M:module.name == "security robot module")
					count++
				if(M.mind.assigned_role in security_positions)
					count++
			if("Scientist")
				if(M.mind.assigned_role in list("Research Director", "Scientist"))
					count++
			if("AI")
				if(M.mind.assigned_role == "AI")
					count++
			if("Cyborg")
				if(M.mind.assigned_role == "Cyborg")
					count++
	return count
