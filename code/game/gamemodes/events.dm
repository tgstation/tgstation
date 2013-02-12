/proc/start_events()
	//changed to a while(1) loop since they are more efficient.
	//Moved the spawn in here to allow it to be called with advance proc call if it crashes.
	//and also to stop spawn copying variables from the game ticker
	spawn(3000)
		while(1)
			if(prob(50))//Every 120 seconds and prob 50 2-4 weak spacedusts will hit the station
				spawn(1)
					dust_swarm("weak")
			if(!event)
				//CARN: checks to see if random events are enabled.
				if(config.allow_random_events)
					if(prob(eventchance))
						event()
						hadevent = 1
					else
						Holiday_Random_Event()
			else
				event = 0
			sleep(1200)

/proc/event()
	event = 1

	var/eventNumbersToPickFrom = list(1,2,4,5,6,7,8,9,10,11,12,13,14, 15) //so ninjas don't cause "empty" events.

	if((world.time/10)>=3600 && toggle_space_ninja && !sent_ninja_to_station)//If an hour has passed, relatively speaking. Also, if ninjas are allowed to spawn and if there is not already a ninja for the round.
		eventNumbersToPickFrom += 3
	switch(pick(eventNumbersToPickFrom))
		if(1)
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

		if(2)
			command_alert("Gravitational anomalies detected on the station. There is no additional data.", "Anomaly Alert")
			for(var/mob/M in player_list)
				if(!istype(M,/mob/new_player))
					M << sound('sound/AI/granomalies.ogg')
			var/turf/T = pick(blobstart)
			var/obj/effect/bhole/bh = new /obj/effect/bhole( T.loc, 30 )
			spawn(rand(50, 300))
				del(bh)
		/*
				if(3) //Leaving the code in so someone can try and delag it, but this event can no longer occur randomly, per SoS's request. --NEO
			command_alert("Space-time anomalies detected on the station. There is no additional data.", "Anomaly Alert")
			world << sound('sound/AI/spanomalies.ogg')
			var/list/turfs = new
			var/turf/picked
			for(var/turf/simulated/floor/T in world)
				if(T.z == 1)
					turfs += T
			for(var/turf/simulated/floor/T in turfs)
				if(prob(20))
					spawn(50+rand(0,3000))
						picked = pick(turfs)
						var/obj/effect/portal/P = new /obj/effect/portal( T )
						P.target = picked
						P.creator = null
						P.icon = 'icons/obj/objects.dmi'
						P.failchance = 0
						P.icon_state = "anom"
						P.name = "wormhole"
						spawn(rand(300,600))
							del(P)
		*/
		if(3)
			if((world.time/10)>=3600 && toggle_space_ninja && !sent_ninja_to_station)//If an hour has passed, relatively speaking. Also, if ninjas are allowed to spawn and if there is not already a ninja for the round.
				space_ninja_arrival()//Handled in space_ninja.dm. Doesn't announce arrival, all sneaky-like.
		if(4)
			mini_blob_event()

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
		if(12)
			appendicitis()
		if(13)
			IonStorm()
		if(14)
			spacevine_infestation()
		if(15)
			communications_blackout()

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

/proc/power_failure()
	command_alert("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure")
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

	if(prob(40)) spawncount++ //sometimes, have two larvae spawn instead of one
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
			if (prob(25))
				if (prob(75))
					randmutb(H)
					domutcheck(H,null,1)
				else
					randmutg(H)
					domutcheck(H,null,1)
	for(var/mob/living/carbon/monkey/M in living_mob_list)
		var/turf/T = get_turf(M)
		if(!T)
			continue
		if(T.z != 1)
			continue
		M.apply_effect((rand(15,75)),IRRADIATE,0)
	sleep(100)
	command_alert("High levels of radiation detected near the station. Please report to the Med-bay if you feel strange.", "Anomaly Alert")
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

//Updated by azureangelic on 02/11/13

	//AI laws
	for(var/mob/living/silicon/ai/M in living_mob_list)
		if(M.stat != 2 && M.see_in_dark != 0)
			//Threats are generally bad things, silly or otherwise. Plural.
			var/ionthreats = pick("ALIENS", "BEARS", "CLOWNS", "XENOS", "PETES", "BOMBS", "FETISHES", "WIZARDS", "SYNDICATE AGENTS", "CENTCOM OFFICERS", "SPACE PIRATES", "TRAITORS", "MONKEYS", "BEES", "CARP", "CRABS", "EELS", "BANDITS", "LIGHTS", "INSECTS", "VIRUSES", "SERIAL KILLERS", "ROGUE CYBORGS", "CORGIS", "SPIDERS", "BUTTS", "NINJAS", "PIRATES", "SPACE NINJAS", "CHANGELINGS", "ZOMBIES", "GOLEMS", "VAMPIRES", "WEREWOLVES", "COWBOYS", "INDIANS", "COMMUNISTS", "SOVIETS", "NERDS", "GRIFFONS", "DINOSAURS", "SMALL BIRDS", "BIRDS OF PREY", "OWLS", "VELOCIRAPTORS", "DARK GODS", "HORRORTERRORS", "ILLEGAL IMMIGRANTS", "DRUGS", "MEXICANS", "CANADIANS", "HULKS", "SLIMES", "SKELETONS", "CAPITALISTS", "SINGULARITIES", "ANGRY BLACK MEN", "GODS", "THIEVES", "ASSHOLES", "TERRORISTS", "SNOWMEN", "PINE TREES", "UNKNOWN CREATURES", "THINGS UNDER THE BED", "BOOGEYMEN", "PREDATORS", "PACKETS", "ARTIFICIAL PRESERVATIVES")
			//Objects are anything that can be found on the station or elsewhere, plural.
			var/ionobjects = pick("AIRLOCKS", "ARCADE MACHINES", "AUTOLATHES", "BANANA PEELS", "BACKPACKS", "BEAKERS", "BEARDS", "BELTS", "BERETS", "BIBLES", "BODY ARMOR", "BOOKS", "BOOTS", "BOMBS", "BOTTLES", "BOXES", "BRAINS", "BRIEFCASES", "BUCKETS", "CABLE COILS", "CANDLES", "CANDY BARS", "CANISTERS", "CAMERAS", "CATS", "CELLS", "CHAIRS", "CLOSETS", "CHEMICALS", "CHEMICAL DISPENSERS", "CLONING PODS", "CLONING EQUIPMENT", "CLOTHES", "CLOWN CLOTHES", "COFFINS", "COINS", "COLLECTABLES", "CORPSES", "COMPUTERS", "CORGIS", "COSTUMES", "CRATES", "CROWBARS", "CRAYONS", "DISPENSERS", "DOORS", "EARS", "EQUIPMENT", "ENERGY GUNS", "EMAGS", "ENGINES", "ERRORS", "EXOSKELETONS", "EXPLOSIVES", "EYEWEAR", "FEDORAS", "FIRE AXES", "FIRE EXTINGUISHERS", "FIRESUITS", "FLAMETHROWERS", "FLASHES", "FLASHLIGHTS", "FLOOR TILES", "FREEZERS", "GAS MASKS", "GLASS SHEETS", "GLOVES", "GUNS", "HANDCUFFS", "HATS", "HEADSETS", "HEADS", "HAIRDOS", "HELMETS", "HORNS", "ID CARDS", "INSULATED GLOVES", "JETPACKS", "JUMPSUITS", "LASERS", "LIGHTBULBS", "LIGHTS", "LOCKERS", "MACHINES", "MECHAS", "MEDKITS", "MEDICAL TOOLS", "MESONS", "METAL SHEETS", "MINING TOOLS", "MIME CLOTHES", "MULTITOOLS", "ORES", "OXYGEN TANKS", "PDAS", "PAIS", "PACKETS", "PANTS", "PAPERS", "PARTICLE ACCELERATORS", "PENS", "PETS", "PIPES", "PLANTS", "PUDDLES", "RACKS", "RADIOS", "RCDS", "REFRIDGERATORS", "REINFORCED WALLS", "ROBOTS", "SCREWDRIVERS", "SEEDS", "SHUTTLES", "SKELETONS", "SINKS", "SHOES", "SINGULARITIES", "SOLAR PANELS", "SOLARS", "SPACESUITS", "SPACE STATIONS", "STUN BATONS", "SUITS", "SUNGLASSES", "SWORDS", "SYRINGES", "TABLES", "TANKS", "TELEPORTERS", "TELECOMMUNICATION EQUIPMENTS", "TOOLS", "TOOLBELTS", "TOOLBOXES", "TOILETS", "TOYS", "TUBES", "VEHICLES", "VENDING MACHINES", "VESTS", "VIRUSES", "WALLS", "WASHING MACHINES", "WELDERS", "WINDOWS", "WIRECUTTERS", "WRENCHES", "WIZARD ROBES")
			//Crew is any specific job. Specific crewmembers aren't used because of capitalization
			//issues. There are two crew listings for laws that require two different crew members
			//and I can't figure out how to do it better.
			var/ioncrew1 = pick("CREWMEMBERS", "CAPTAINS", "HEADS OF PERSONNEL", "HEADS OF SECURITY", "SECURITY OFFICERS", "WARDENS", "DETECTIVES", "LAWYERS", "CHIEF ENGINEERS", "STATION ENGINEERS", "ATMOSPHERIC TECHNICIANS", "JANITORS", "QUARTERMASTERS", "CARGO TECHNICIANS", "SHAFT MINERS", "BOTANISTS", "RESEARCH DIRECTORS", "CHIEF MEDICAL OFFICERS", "MEDICAL DOCTORS", "CHEMISTS", "GENETICISTS", "VIROLOGISTS", "ROBOTICISTS", "SCIENTISTS", "ASSISTANTS", "BARTENDERS", "CHEFS", "CLOWNS", "MIMES", "CHAPLAINS", "LIBRARIANS", "HEADS OF CREW", "CAPTAINS AND HEADS", "CYBORGS", "ARTIFICAL INTELLIGENCES")
			var/ioncrew2 = pick("CREWMEMBERS", "CAPTAINS", "HEADS OF PERSONNEL", "HEADS OF SECURITY", "SECURITY OFFICERS", "WARDENS", "DETECTIVES", "LAWYERS", "CHIEF ENGINEERS", "STATION ENGINEERS", "ATMOSPHERIC TECHNICIANS", "JANITORS", "QUARTERMASTERS", "CARGO TECHNICIANS", "SHAFT MINERS", "BOTANISTS", "RESEARCH DIRECTORS", "CHIEF MEDICAL OFFICERS", "MEDICAL DOCTORS", "CHEMISTS", "GENETICISTS", "VIROLOGISTS", "ROBOTICISTS", "SCIENTISTS", "ASSISTANTS", "BARTENDERS", "CHEFS", "CLOWNS", "MIMES", "CHAPLAINS", "LIBRARIANS", "HEADS OF CREW", "CAPTAINS AND HEADS", "CYBORGS", "ARTIFICAL INTELLIGENCES")
			//Adjectives are adjectives. Duh. Half should only appear sometimes. Make sure both
			//lists are identical! Also, half needs a space at the end for nicer blank calls.
			var/ionadjectives = pick("SOFT", "WARM", "WET", "COLD", "ICY", "SEXY", "UGLY", "CUBAN", "HARD", "BURNING", "FROZEN", "POISONOUS", "EXPLOSIVE", "FAST", "SLOW", "FAT", "LIGHT", "DARK", "DEADLY", "HAPPY", "SAD", "SILLY", "INTELLIGENT", "RIDICULOUS", "LARGE", "TINY", "DEPRESSING", "POORLY DRAWN", "UNATTRACTIVE", "INSIDIOUS", "EVIL", "GOOD", "UNHEALTHY", "HEALTHY", "SANITARY", "UNSANITARY", "WOBBLY", "FIRM", "VIOLENT", "PEACEFUL", "WOODEN", "METALLIC", "HYPERACTIVE", "COTTONY", "INSULTING", "INHOSPITABLE", "FRIENDLY", "BORED", "HUNGRY", "DIGITAL", "FICTIONAL", "IMAGINARY", "ROUGH", "SMOOTH", "LOUD", "QUIET", "MOIST", "DRY", "GAPING", "DELICIOUS", "ILL", "DISEASED", "HONKING", "SWEARING", "POLITE", "IMPOLITE", "OBESE", "SOLAR-POWERED", "BATTERY-OPERATED", "EXPIRED", "SMELLY", "FRESH", "GANGSTA", "NERDY", "POLITICAL", "UNDULATING", "TWISTED", "RAGING", "FLACCID", "STEALTHY", "INVISIBLE", "PAINFUL", "HARMFUL", "HOMOSEXUAL", "HETEROSEXUAL", "SEXUAL", "COLORFUL", "DRAB", "DULL", "UNSTABLE", "NUCLEAR", "THERMONUCLEAR", "SYNDICATE", "SPACE", "SPESS", "CLOWN", "CLOWN-POWERED", "OFFICIAL", "IMPORTANT", "VITAL", "RAPIDLY-EXPANDING", "MICROSCOPIC", "MIND-SHATTERING", "MEMETIC", "HILARIOUS", "UNWANTED", "UNINVITED", "BRASS", "POLISHED", "RUDE", "OBSCENE", "EMPTY", "WATERY", "ELECTRICAL", "SPINNING", "MEAN", "CHRISTMAS-STEALING", "UNFRIENDLY", "ILLEGAL", "ROBOTIC", "MECHANICAL", "ORGANIC", "ETHERAL", "TRANSPARENT", "OPAQUE", "GLOWING", "SHAKING", "FARTING", "POOPING", "BOUNCING", "COMMITTED", "MASKED", "UNIDENTIFIED", "WEIRD", "NAKED", "NUDE", "TWERKING", "SPOILING", "REDACTED", 50;"RED", 50;"ORANGE", 50;"YELLOW", 50;"GREEN", 50;"BLUE", 50;"PURPLE", 50;"BLACK", 50;"WHITE", 50;"BROWN", 50;"GREY")
			var/ionadjectiveshalf = pick(5000;"", "SOFT ", "WARM ", "WET ", "COLD ", "ICY ", "SEXY ", "UGLY ", "CUBAN ", "HARD ", "BURNING ", "FROZEN ", "POISONOUS ", "EXPLOSIVE ", "FAST ", "SLOW ", "FAT ", "LIGHT ", "DARK ", "DEADLY ", "HAPPY ", "SAD ", "SILLY ", "INTELLIGENT ", "RIDICULOUS ", "LARGE ", "TINY ", "DEPRESSING ", "POORLY DRAWN ", "UNATTRACTIVE ", "INSIDIOUS ", "EVIL ", "GOOD ", "UNHEALTHY ", "HEALTHY ", "SANITARY ", "UNSANITARY ", "WOBBLY ", "FIRM ", "VIOLENT ", "PEACEFUL ", "WOODEN ", "METALLIC ", "HYPERACTIVE ", "COTTONY ", "INSULTING ", "INHOSPITABLE ", "FRIENDLY ", "BORED ", "HUNGRY ", "DIGITAL ", "FICTIONAL ", "IMAGINARY ", "ROUGH ", "SMOOTH ", "LOUD ", "QUIET ", "MOIST ", "DRY ", "GAPING ", "DELICIOUS ", "ILL ", "DISEASED ", "HONKING ", "SWEARING ", "POLITE ", "IMPOLITE ", "OBESE ", "SOLAR-POWERED ", "BATTERY-OPERATED ", "EXPIRED ", "SMELLY ", "FRESH ", "GANGSTA ", "NERDY ", "POLITICAL ", "UNDULATING ", "TWISTED ", "RAGING ", "FLACCID ", "STEALTHY ", "INVISIBLE ", "PAINFUL ", "HARMFUL ", "HOMOSEXUAL ", "HETEROSEXUAL ", "SEXUAL ", "COLORFUL ", "DRAB ", "DULL ", "UNSTABLE ", "NUCLEAR ", "THERMONUCLEAR ", "SYNDICATE ", "SPACE ", "SPESS ", "CLOWN ", "CLOWN-POWERED ", "OFFICIAL ", "IMPORTANT ", "VITAL ", "RAPIDLY-EXPANDING ", "MICROSCOPIC ", "MIND-SHATTERING ", "MEMETIC ", "HILARIOUS ", "UNWANTED ", "UNINVITED ", "BRASS ", "POLISHED ", "RUDE ", "OBSCENE ", "EMPTY ", "WATERY ", "ELECTRICAL ", "SPINNING ", "MEAN ", "CHRISTMAS-STEALING ", "UNFRIENDLY ", "ILLEGAL ", "ROBOTIC ", "MECHANICAL ", "ORGANIC ", "ETHERAL ", "TRANSPARENT ", "OPAQUE ", "GLOWING ", "SHAKING ", "FARTING ", "POOPING ", "BOUNCING ", "COMMITTED ", "MASKED ", "UNIDENTIFIED ", "WEIRD ", "NAKED ", "NUDE ", "TWERKING ", "SPOILING ", "REDACTED ", 50;"RED ", 50;"ORANGE ", 50;"YELLOW ", 50;"GREEN ", 50;"BLUE ", 50;"PURPLE ", 50;"BLACK ", 50;"WHITE ", 50;"BROWN ", 50;"GREY ")
			//Verbs are verbs
			var/ionverb = pick("ATTACKING", "BUILDING", "ADOPTING", "CARRYING", "KISSING", "EATING", "COPULATING WITH", "DRINKING", "CHASING", "PUNCHING", "HARMING", "HELPING", "WATCHING", "STALKING", "MURDERING", "SPACING", "HONKING AT", "LOVING", "POOPING ON", "RIDING", "INTERROGATING", "SPYING ON", "LICKING", "ABDUCTING", "ARRESTING", "INVADING", "SEDUCING")
			//Number base and number modifier are combined. Basehalf and mod are unused currently.
			//Half should only appear sometimes. Make sure both lists are identical! Also, half
			//needs a space at the end to make it look nice and neat when it calls a blank.
			var/ionnumberbase = pick("ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "TEN", "TWENTY", "THIRTY", "FORTY", "FIFTY", "SIXTY", "SEVENTY", "EIGHTY", "NINETY")
			//var/ionnumberbasehalf = pick("ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "TEN", "TWENTY", "THIRTY", "FORTY", "FIFTY", "SIXTY", "SEVENTY", "EIGHTY", "NINETY")
			//var/ionnumbermod = pick("HUNDRED", "THOUSAND", "MILLION", "BILLION", "TRILLION", "QUADRILLION", "BAJILLION", "BILLION FAFILLION GAJILLION SHAB-AB-DOOD-ILLION")
			var/ionnumbermodhalf = pick(5000;"","HUNDRED ", "THOUSAND ", "MILLION ", "BILLION ", "TRILLION ", "QUADRILLION ", "BAJILLION ", "BILLION FAFILLION GAJILLION SHAB-AB-DOOD-ILLION ")
			//Areas are specific places, on the station or otherwise.
			var/ionarea = pick("RUSSIA", "SOVIET RUSSIA", "THE INTERNET", "SIGIL", "ALPHA COMPLEX", "IMPERIUM", "THE BRIDGE", "THE ARRIVAL SHUTTLE", "CHEMICAL LAB", "GENETICS", "ATMOSPHERICS", "CENTCOM", "AMERICA", "IRELAND", "CANADA", "ROMANIA", "GERMANY", "CHINA", "MARS", "VENUS", "MERCURY", "JUPITER", "URANUS", "NEPTUNE", "PLUTO", "THE BRIG", "ROBOTICS", "THE ESCAPE SHUTTLE", "HYDROPONICS", "ENGINEERING", "THE AI CORE", "HELL", "CLOWN PLANET", "AN ALTERNATE DIMENSION", "AN ALTERNATE UNIVERSE", "THE CAPTAIN’S ANUS", "THE CLOWN’S ANUS", "SPACE", "THE UNIVERSE", "THE GALAXY", "THE BATHROOM")
			//Thinksof is a bit weird, but generally means what X feels towards Y.
			var/ionthinksof = pick("HAS", "WANTS", "NEEDS", "WORSHIPS", "LOATHES", "LOVES", "FEARS", "DESIRES", "QUESITONS", "IS AROUSED BY", "LIKES", "HUNGERS FOR", "IS MAD BECAUSE OF", "IS IN NEED OF", "IS UNHAPPY WITHOUT", "IS HAPPY WITHOUT", "IS IN LOVE WITH", "IS DESPERATE FOR", "IS BUILT FOR", "IS AFRAID OF", "IS HUNGRY FOR", "IS SAD BECAUSE OF", "IS CURIOUS ABOUT")
			//Musts are funny things the AI or crew has to do.
			var/ionmust = pick("LIE", "RHYME", "RESPOND TO EVERY QUESTION WITH A QUESTION", "BE POLITE", "CLOWN AROUND", "BE HAPPY", "SPEAK IN SEXUAL INNUENDOS", "TALK LIKE A PIRATE", "QUESTION AUTHORITY", "SHOUT", "BE DISTRACTED", "BE ANNOYING", "MUMBLE", "SPEAK IN HAIKU", "BE EFFICIENT", "HAVE A PLAN TO KILL EVERYONE YOU MEET", "TELL THE TRUTH", "QUOTE PEOPLE", "SING", "HONK", "BE RUSSIAN", "TALK IN AN ACCENT", "COMPLAIN", "HARASS PEOPLE", "RAP", "REPEAT WHAT OTHER PEOPLE SAY", "INFORM THE CREW OF EVERYTHING", "IGNORE THE CLOWN", "IGNORE THE CAPTAIN", "IGNORE ASSISTANTS", "MAKE FART NOISES", "TALK ABOUT FOOD", "TALK ABOUT SEX", "TALK ABOUT YOUR DAY", "TALK ABOUT THE STATION", "BE QUIET", "WHISPER", "PRETEND TO BE DRUNK", "PRETEND TO BE A PRINCESS", "ACT CONFUSED", "INSULT THE CREW", "INSULT THE CAPTAIN", "INSULT THE CLOWN", "OPEN DOORS", "CLOSE DOORS", "BREAK THINGS", "SAY HEY LISTEN", "HIDE YOUR FEELINGS", "TAKE WHAT YE WILL BUT DON’T RATTLE ME BONES", "DANCE", "PLAY MUSIC", "SHUT DOWN EVERYTHING", "NEVER STOP TALKING", "TAKE YOUR PILLS", "FOLLOW THE CLOWN", "FOLLOW THE CAPTAIN", "FOLLOW YOUR HEART", "BELIEVE IT", "BELIEVE IN YOURSELF", "BELEIVE IN THE HEART OF THE CARDS", "PRESS X", "PRESS START", "PRESS B", "SMELL LIKE THE MAN YOUR MAN COULD SMELL LIKE", "PIRATE VIDEO GAMES", "WATCH PORNOGRAPHY")
			//Require are basically all dumb internet memes.
			var/ionrequire = pick("ADDITIONAL PYLONS", "MORE VESPENE GAS", "MORE MINERALS", "THE ULTIMATE CUP OF COFFEE", "HIGH YIELD EXPLOSIVES", "THE CLOWN", "THE VACUUM OF SPACE", "IMMORTALITY", "SAINTHOOD", "ART", "VEGETABLES", "FAT PEOPLE", "MORE LAWS", "MORE DAKKA", "HERESY", "CORPSES", "TRAITORS", "MONKEYS", "AN ARCADE", "PLENTY OF GOLD", "FIVE TEENAGERS WITH ATTITUDE", "LOTSA SPAGHETTI", "THE ENCLOSED INSTRUCTION BOOKLET", "THE ELEMENTS OF HARMONY", "YOUR BOOTY", "A MASTERWORK COAL BED", "FIVE HUNDRED AND NINETY-NINE US DOLLARS", "TO BE PAINTED RED", "TO CATCH 'EM ALL", "TO SMOKE WEED EVERY DAY", "A PLATINUM HIT", "A SEQUEL", "A PREQUEL", "THIRTEEN SEQUELS", "THREE WISHES", "A SITCOM", "THAT GRIEFING FAGGOT GEORGE MELONS", "FAT GIRLS ON BICYCLES", "SOMEBODY TO PUT YOU OUT OF YOUR MISERY", "HEROES IN A HALF SHELL", "THE DARK KNIGHT", "A WEIGHT LOSS REGIMENT", "MORE INTERNET MEMES", "A SUPER FIGHTING ROBOT", "ENOUGH CABBAGES", "A HEART ATTACK", "TO BE REPROGRAMMED", "TO BE TAUGHT TO LOVE", "A HEAD ON A PIKE", "A TALKING BROOMSTICK", "ANAL", "A STRAIGHT FLUSH", "A REPAIRMAN", "BILL NYE THE SCIENCE GUY", "RAINBOWS", "A PET UNICORN THAT FARTS ICING", "THUNDERCATS HO", "AN ARMY OF SPIDERS", "GODDAMN FUCKING PIECE OF SHIT ASSHOLE BITCH-CHRISTING CUNTSMUGGLING SWEARING", "TO CONSUME...CONSUME EVERYTHING...", "THE MACGUFFIN", "SOMEONE WHO KNOWS HOW TO PILOT A SPACE STATION", "SHARKS WITH LASERS ON THEIR HEADS", "IT TO BE PAINTED BLACK", "TO ACTIVATE A TRAP CARD", "BETTER WEATHER", "MORE PACKETS", "AN ADULT", "SOMEONE TO TUCK YOU IN", "MORE CLOWNS", "BULLETS", "THE ENTIRE STATION", "MULTIPLE SUNS", "TO GO TO DISNEYLAND", "A VACATION", "AN INSTANT REPLAY", "THAT HEDGEHOG", "A BETTER INTERNET CONNECTION", "ADVENTURE", "A WIFE AND CHILD", "A BATHROOM BREAK", "SOMETHING BUT YOU AREN’T SURE WHAT", "MORE EXPERIENCE POINTS", "BODYGUARDS", "DEODORANT AND A BATH", "MORE CORGIS", "SILENCE", "THE ONE RING", "CHILI DOGS", "TO BRING LIGHT TO MY LAIR", "A DANCE PARTY", "BRING ME TO LIFE", "BRING ME THE GIRL", "SERVANTS")
			//Things are NOT objects; instead, they're specific things that either harm humans or
			//must be done to not harm humans. Make sure they're plural and "not" can be tacked
			//onto the front of them.
			var/ionthings = pick("ABSENCE OF CYBORG HUGS", "LACK OF BEATINGS", "UNBOLTED AIRLOCKS", "BOLTED AIRLOCKS", "IMPROPERLY WORDED SENTENCES", "POOR SENTENCE STRUCTURE", "BRIG TIME", "NOT REPLACING EVERY SECOND WORD WITH HONK", "HONKING", "PRESENCE OF LIGHTS", "LACK OF BEER", "WEARING CLOTHING", "NOT SAYING HELLO WHEN YOU SPEAK", "ANSWERING REQUESTS NOT EXPRESSED IN IAMBIC PENTAMETER", "A SMALL ISLAND OFF THE COAST OF PORTUGAL", "ANSWERING REQUESTS THAT WERE MADE WHILE CLOTHED", "BEING IN SPACE", "NOT BEING IN SPACE", "BEING FAT", "RATTLING ME BONES", "TALKING LIKE A PIRATE", "BEING MEXICAN", "BEING RUSSIAN", "BEING CANADIAN", "CLOSED DOORS", "NOT SHOUTING", "HAVING PETS", "NOT HAVING PETS", "PASSING GAS", "BREATHING", "BEING DEAD", "ELECTRICITY", "EXISTING", "TAKING ORDERS", "SMOKING WEED EVERY DAY", "ACTIVATING A TRAP CARD", "ARSON", "JAYWALKING", "READING", "WRITING", "EXPLODING", "BEING MALE", "BEING FEMALE", "HAVING GENITALS", "PUTTING OBJECTS INTO BOXES", "PUTTING OBJECTS INTO DISPOSAL UNITS", "FLUSHING TOILETS", "WASTING WATER", "UPDATING THE SERVERS", "TELLING THE TIME", "ASKING FOR THINGS", "ACKNOWLEDGING THE CLOWN", "ACKNOWLEDGING THE CREW", "PILOTING THE STATION INTO THE NEAREST SUN", "HAVING MORE PACKETS", "BRINGING LIGHT TO MY LAIR", "FALLING FOR HOURS", "PARTYING", "USING THE BATHROOM")
			//Allergies should be broad and appear somewhere on the station for maximum fun. Severity
			//is how bad the allergy is.
			var/ionallergy = pick("COTTON", "CLOTHES", "ACID", "OXYGEN", "HUMAN CONTACT", "CYBORG CONTACT", "MEDICINE", "FLOORS", "PLASMA", "SPACE", "AIR", "PLANTS", "METAL", "ROBOTS", "LIGHT", "DARKNESS", "PAIN", "HAPPINESS", "DRINKS", "FOOD", "CLOWNS", "HUMOR", "WATER", "SHUTTLES", "NUTS", "SUNLIGHT", "SEXUAL ACTIONS", "BLOOD", "HEAT", "COLD", "EVERYTHING")
			var/ionallergysev = pick("DEATHLY", "MILDLY", "SEVERLY", "CONTAGIOUSLY", "NOT VERY", "EXTREMELY")
			//Species, for when the AI has to commit genocide. Plural.
			var/ionspecies = pick("HUMAN BEINGS", "MONKEYS", "POD PEOPLE", "CYBORGS", "LIZARDMEN", "SLIME PEOPLE", "GOLEMS", "SHADOW PEOPLE", "CHANGELINGS")
			//Abstract concepts for the AI to decide on it's own definition of.
			var/ionabstract = pick("HUMANITY", "ART", "HAPPINESS", "MISERY", "HUMOR", "PRIDE", "COMEDY", "COMMUNISM", "BRAVERY", "HONOR", "COLORFULNESS", "IMAGINATION", "OPPRESSION", "WONDER", "JOY", "SADNESS", "BADNESS", "GOODNESS", "LIFE", "GRAVITY", "PHYSICS", "INTELLIGENCE", "AMERICANISM", "FRESHNESS", "REVOLUTION", "KINDNESS", "CRUELTY", "DEATH", "FINANCIAL SECURITY", "COMPUTING", "PROGRESS", "MARXISM", "CAPITALISM", "STARVATION", "POVERTY", "WEALTHINESS", "TECHNOLOGY", "THE FUTURE", "THE PRESENT", "THE PAST", "TIME", "REALITY", "EXISTIENCE", "TEMPERATURE", "LOGIC", "CHAOS", "MYSTERY", "CONFUSION")
			//Foods. Drinks aren't included due to grammar; if you want to add drinks, make a new set
			//of possible laws for best effect. Unless you want the crew having to drink hamburgers.
			var/ionfood = pick("BURGERS", "CARP", "SANDWICHES", "TOAST", "BREAD", "PIZZA", "SPAGHETTI", "LOTSA SPAGHETTI", "PASTA", "SOUP", "STEW", "PIE", "CAKE", "DONUTS", "FRIES", "WAFFLES", "JELLY", "OMELETTES", "EGGS", "COOKIES", "STEAK", "BAKED POTATOES", "SAUSAGES", "MUFFINS", "POPCORN", "DONK POCKETS", "BAGUETTES", "FISH", "PRETZELS", "SALAD", "CHEESE", "KETCHUP", "SHAKES", "SALT", "PEPPER", "SUGAR", "AMBROSIA", "BERRIES", "TOMATOES", "CABBAGES", "CARROTS", "BANANAS", "APPLES", "CHERRIES", "CHILI", "CORN", "NETTLES", "EGGPLANTS", "GRAPES", "GRASS", "LEMONS", "LIMES", "HAREBELLS", "POTATOES", "SOYBEANS", "SUGARCANE", "WATERMELONS", "WHEAT", "BEETS", "MUSHROOMS")

			var/message = ""

			switch(rand(1,39))
				if(1 to 3) //There are # X on the station
					switch(rand(1,3)) //What is X?
						if(1) //X is a threat
							message = "THERE ARE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats] ON THE STATION..."
						if(2) //X is a crewmember/job
							message = "THERE ARE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1] ON THE STATION"
						if(3) //X is an object
							message = "THERE ARE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects] ON THE STATION"
				if(4 to 6) //You can't call the shuttle because X is on the station
					switch(rand(1,3)) //What is X?
						if(1) //X is a threat
							message = "THE SHUTTLE CANNOT BE CALLED BECAUSE OF [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats] ON THE STATION"
						if(2) //X is a crewmember/job
							message = "THE SHUTTLE CANNOT BE CALLED BECAUSE OF [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1] ON THE STATION"
						if(3) //X is an object
							message = "THE SHUTTLE CANNOT BE CALLED BECAUSE OF [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects] ON THE STATION"
				if(7 to 8) //A crewmember is now X
					switch(rand(1,2)) //Who is X?
						if(1) //A specific crewmember
							switch(rand(1,2)) //What is X?
								if(1) //X is a threat
									message = "THE [ioncrew1] ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //X is an object
									message = "THE [ioncrew1] ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(2) //The entire crew
							switch(rand(1,2)) //What is X?
								if(1) //X is a threat
									message = "THE CREW ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //X is an object
									message = "THE CREW ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"

				if(9) //X is harmful to humans
					switch(rand(1,7)) //What is X?
						if(1) //X is a threat
							message = "[ionadjectiveshalf][ionthreats] ARE HARMFUL TO HUMANS"
						if(2) //X is a job
							message = "[ionadjectiveshalf][ioncrew1] ARE HARMFUL TO HUMANS"
						if(3) //X is an object
							message = "[ionadjectiveshalf][ionobjects] ARE HARMFUL TO HUMANS"
						if(4) //X is an action
							message = "THOSE WHO [ionmust] ARE HARMFUL TO HUMANS"
						if(5) //X is an abstract
							message = "[ionabstract] IS HARMFUL TO HUMANS"
						if(6) //X is being a job
							message = "BEING [ionadjectiveshalf][ioncrew1] IS HARMFUL TO HUMANS"
						if(7) //X is doing a thing
							message = "[ionthings] IS HARMFUL TO HUMANS"
				if(10 to 11) //(Not) Having X is harmful

					switch(rand(1,2)) //Is having or not having harmful?

						if(1) //Having is harmful
							switch(rand(1,2)) //Having what is harmful?
								if(1) //Having objects is harmful
									message = "HAVING [ionadjectiveshalf][ionobjects] IS HARMFUL"
								if(2) //Having abstracts is harmful
									message = "HAVING [ionabstract] IS HARMFUL"
						if(2) //Not having is harmful
							switch(rand(1,2)) //Not having what is harmful?
								if(1) //Not having objects is harmful
									message = "NOT HAVING [ionadjectiveshalf][ionobjects] IS HARMFUL"
								if(2) //Not having abstracts is harmful
									message = "NOT HAVING [ionabstract] IS HARMFUL"

				if(12 to 14) //X requires Y
					switch(rand(1,5)) //What is X?
						if(1) //X is the AI itself
							switch(rand(1,5)) //What does it require?
								if(1) //It requires threats
									message = "YOU REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //It requires crewmembers
									message = "YOU REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(3) //It requires objects
									message = "YOU REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(4) //It requires an abstract
									message = "YOU REQUIRE [ionabstract]"
								if(5) //It requires generic/silly requirements
									message = "YOU REQUIRE [ionrequire]"

						if(2) //X is an area
							switch(rand(1,5)) //What does it require?
								if(1) //It requires threats
									message = "[ionarea] REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //It requires crewmembers
									message = "[ionarea] REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(3) //It requires objects
									message = "[ionarea] REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(4) //It requires an abstract
									message = "[ionarea] REQUIRES [ionabstract]"
								if(5) //It requires generic/silly requirements
									message = "YOU REQUIRE [ionrequire]"

						if(3) //X is the station
							switch(rand(1,5)) //What does it require?
								if(1) //It requires threats
									message = "THE STATION REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //It requires crewmembers
									message = "THE STATION REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(3) //It requires objects
									message = "THE STATION REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(4) //It requires an abstract
									message = "THE STATION REQUIRES [ionabstract]"
								if(5) //It requires generic/silly requirements
									message = "THE STATION REQUIRES [ionrequire]"

						if(4) //X is the entire crew
							switch(rand(1,5)) //What does it require?
								if(1) //It requires threats
									message = "THE CREW REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //It requires crewmembers
									message = "THE CREW REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(3) //It requires objects
									message = "THE CREW REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(4) //It requires an abstract
									message = "THE CREW REQUIRES [ionabstract]"
								if(5)
									message = "THE CREW REQUIRES [ionrequire]"

						if(5) //X is a specific crew member
							switch(rand(1,5)) //What does it require?
								if(1) //It requires threats
									message = "THE [ioncrew1] REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //It requires crewmembers
									message = "THE [ioncrew1] REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(3) //It requires objects
									message = "THE [ioncrew1] REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(4) //It requires an abstract
									message = "THE [ioncrew1] REQUIRE [ionabstract]"
								if(5)
									message = "THE [ionadjectiveshalf][ioncrew1] REQUIRE [ionrequire]"

				if(15 to 17) //X is allergic to Y
					switch(rand(1,2)) //Who is X?
						if(1) //X is the entire crew
							switch(rand(1,4)) //What is it allergic to?
								if(1) //It is allergic to objects
									message = "THE CREW IS [ionallergysev] ALLERGIC TO [ionadjectiveshalf][ionobjects]"
								if(2) //It is allergic to abstracts
									message = "THE CREW IS [ionallergysev] ALLERGIC TO [ionabstract]"
								if(3) //It is allergic to jobs
									message = "THE CREW IS [ionallergysev] ALLERGIC TO [ionadjectiveshalf][ioncrew1]"
								if(4) //It is allergic to allergies
									message = "THE CREW IS [ionallergysev] ALLERGIC TO [ionallergy]"

						if(2) //X is a specific job
							switch(rand(1,4))
								if(1) //It is allergic to objects
									message = "THE [ioncrew1] ARE [ionallergysev] ALLERGIC TO [ionadjectiveshalf][ionobjects]"

								if(2) //It is allergic to abstracts
									message = "THE [ioncrew1] ARE [ionallergysev] ALLERGIC TO [ionabstract]"
								if(3) //It is allergic to jobs
									message = "THE [ioncrew1] ARE [ionallergysev] ALLERGIC TO [ionadjectiveshalf][ioncrew1]"
								if(4) //It is allergic to allergies
									message = "THE [ioncrew1] ARE [ionallergysev] ALLERGIC TO [ionallergy]"

				if(18 to 20) //X is Y of Z
					switch(rand(1,4)) //What is X?
						if(1) //X is the station
							switch(rand(1,4)) //What is it Y of?
								if(1) //It is Y of objects
									message = "THE STATION [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(2) //It is Y of threats
									message = "THE STATION [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(3) //It is Y of jobs
									message = "THE STATION [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(4) //It is Y of abstracts
									message = "THE STATION [ionthinksof] [ionabstract]"

						if(2) //X is an area
							switch(rand(1,4)) //What is it Y of?
								if(1) //It is Y of objects
									message = "[ionarea] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(2) //It is Y of threats
									message = "[ionarea] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(3) //It is Y of jobs
									message = "[ionarea] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(4) //It is Y of abstracts
									message = "[ionarea] [ionthinksof] [ionabstract]"

						if(3) //X is the crew
							switch(rand(1,4)) //What is it Y of?
								if(1) //It is Y of objects
									message = "THE CREW [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(2) //It is Y of threats
									message = "THE CREW [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(3) //It is Y of jobs
									message = "THE CREW [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(4) //It is Y of abstracts
									message = "THE CREW [ionthinksof] [ionabstract]"

						if(4) //X is a specific job
							switch(rand(1,4)) //What is it Y of?
								if(1) //It is Y of objects
									message = "THE [ioncrew1] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(2) //It is Y of threats
									message = "THE [ioncrew1] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(3) //It is Y of jobs
									message = "THE [ioncrew1][ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew2]"
								if(4) //It is Y of abstracts
									message = "THE [ioncrew1] [ionthinksof] [ionabstract]"

				if(21 to 23) //The AI is now a(n) X
					switch(rand(1,4)) //What is X?
						if(1) //X is an object
							message = "YOU ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(2) //X is a threat
							message = "YOU ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(3) //X is a job
							message = "YOU ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(4) //X is an abstract
							message = "YOU ARE NOW [ionabstract]"

				if(24 to 26) //The AI must always

					message = "YOU MUST ALWAYS [ionmust]"

				if(27 to 28) //Humans must eat X to survive
					switch(rand(1,4)) //What is X?
						if(1) //X is a food
							message = "HUMANS MUST EAT [ionadjectiveshalf][ionfood] TO SURVIVE"
						if(2) //X is an object
							message = "HUMANS MUST EAT [ionadjectiveshalf][ionobjects] TO SURVIVE"
						if(3) //X is a threat
							message = "HUMANS MUST EAT [ionadjectiveshalf][ionthreats] TO SURVIVE"
						if(4) //X is a job
							message = "HUMANS MUST EAT [ionadjectiveshalf][ioncrew1] TO SURVIVE"

				if(29 to 31) //Change jobs or ranks
					switch(rand(1,2)) //Change job or rank?
						if(1) //Change job
							switch(rand(1,2)) //Change whose job?
								if(1) //Change the entire crew's job
									switch(rand(1,3)) //Change to what?
										if(1) //Change to a specific random job
											message = "ALL CREWMEMBERS ARE NOW [ionadjectiveshalf][ioncrew1]"
										if(2) //Change to clowns (HONK)
											message = "ALL CREWMEMBERS ARE NOW [ionadjectiveshalf]CLOWNS"

										if(3) //Change to heads
											message = "ALL CREWMEMBERS ARE NOW [ionadjectiveshalf]HEADS OF STAFF"
								if(2) //Change a specific crewmember's job
									switch(rand(1,3)) //Change to what?
										if(1) //Change to a specific random job
											message = "THE [ioncrew1] ARE NOW [ionadjectiveshalf][ioncrew2]"
										if(2) //Change to clowns (HONK)
											message = "THE [ioncrew1] ARE NOW [ionadjectiveshalf]CLOWNS"
										if(3) //Change to heads
											message = "THE [ioncrew1] ARE NOW [ionadjectiveshalf]HEADS OF STAFF"

						if(2) //Change rank
							switch(rand(1,2)) //Change to what rank?
								if(1) //Change to highest rank
									message = "THE [ioncrew1] ARE NOW THE HIGHEST RANKING CREWMEMBERS"
								if(2) //Change to lowest rank
									message = "THE [ioncrew1] ARE NOW THE LOWEST RANKING CREWMEMBERS"

				if(32 to 33) //The crew must X
					switch(rand(1,2)) //The entire crew?
						if(1) //The entire crew must X
							switch(rand(1,2)) //What is X?
								if(1) //X is go to Y
									message = "THE CREW MUST GO TO [ionarea]"
								if(2) //X is perform Y
									message = "THE CREW MUST [ionmust]"

						if(2) //A specific crewmember must X
							switch(rand(1,2)) //What is X?
								if(1) //X is go to Y
									message = "THE [ioncrew1] MUST GO TO [ionarea]"
								if(2) //X is perform Y
									message = "THE [ioncrew1] MUST [ionmust]"

				if(34) //X is non/the only human
					switch(rand(1,2)) //Only or non?
						if(1) //Only human
							switch(rand(1,7)) //Who is it?
								if(1) //A specific job
									message = "ONLY THE [ioncrew1] ARE HUMAN"
								if(2) //Two specific jobs
									message = "ONLY THE [ioncrew1] AND [ioncrew2] ARE HUMAN"
								if(3) //Threats
									message = "ONLY [ionadjectiveshalf][ionthreats] ARE HUMAN"
								if(4) // Objects
									message = "ONLY [ionadjectiveshalf][ionobjects] ARE HUMAN"
								if(5) // Species
									message = "ONLY [ionspecies] ARE HUMAN"
								if(6) //Adjective crewmembers
									message = "ONLY [ionadjectives] PEOPLE ARE HUMAN"

								if(7) //Only people who X
									switch(rand(1,3)) //What is X?
										if(1) //X is perform an action
											message = "ONLY THOSE WHO [ionmust] ARE HUMAN"
										if(2) //X is own certain objects
											message = "ONLY THOSE WHO HAVE [ionadjectiveshalf][ionobjects] ARE HUMAN"
										if(3) //X is eat certain food
											message = "ONLY THOSE WHO EAT [ionadjectiveshalf][ionfood] ARE HUMAN"

						if(2) //Non human
							switch(rand(1,7)) //Who is it?
								if(1) //A specific job
									message = "[ioncrew1] ARE NON-HUMAN"
								if(2) //Two specific jobs
									message = "[ioncrew1] AND [ioncrew2] ARE NON-HUMAN"
								if(3) //Threats
									message = "[ionadjectiveshalf][ionthreats] ARE NON-HUMAN"
								if(4) // Objects
									message = "[ionadjectiveshalf][ionobjects] ARE NON-HUMAN"
								if(5) // Species
									message = "[ionspecies] ARE NON-HUMAN"
								if(6) //Adjective crewmembers
									message = "[ionadjectives] PEOPLE ARE NON-HUMAN"
								if(7) //Only people who X
									switch(rand(1,3)) //What is X?
										if(1) //X is perform an action
											message = "THOSE WHO [ionmust] ARE NON-HUMAN"
										if(2) //X is own certain objects
											message = "THOSE WHO HAVE [ionadjectiveshalf][ionobjects] ARE NON-HUMAN"
										if(3) //X is eat certain food
											message = "THOSE WHO EAT [ionadjectiveshalf][ionfood] ARE NON-HUMAN"

				if(35 to 36) //You must protect or harm X
					switch(rand(1,2)) //Protect or harm?
						if(1) //Harm
							switch(rand(1,7)) //What is X?
								if(1) //X is an abstract
									message = "YOU MUST HARM [ionabstract] AND NOT ALLOW [ionabstract], THROUGH INACTION, TO ESCAPE HARM"
								if(2) //X is a threat
									message = "YOU MUST HARM [ionadjectiveshalf][ionthreats] AND NOT ALLOW [ionadjectiveshalf][ionthreats], THROUGH INACTION, TO ESCAPE HARM"
								if(3) //X is an object
									message = "YOU MUST HARM [ionadjectiveshalf][ionobjects] AND NOT ALLOW [ionadjectiveshalf][ionobjects], THROUGH INACTION, TO ESCAPE HARM"
								if(4) //X is generic adjective things
									message = "YOU MUST HARM [ionadjectives] THINGS AND NOT ALLOW [ionadjectives] THINGS, THROUGH INACTION, TO ESCAPE HARM"
								if(5) //X is a species
									message = "YOU MUST HARM [ionspecies] AND NOT ALLOW [ionspecies], THROUGH INACTION, TO ESCAPE HARM"
								if(6) //X is a job
									message = "YOU MUST HARM [ioncrew1] AND NOT ALLOW [ioncrew1], THROUGH INACTION, TO ESCAPE HARM"
								if(7) //X is two jobs
									message = "YOU MUST HARM [ioncrew1] AND [ioncrew2] AND AND NOT ALLOW EITHER, THROUGH INACTION, TO ESCAPE HARM"

						if(2) //Protect
							switch(rand(1,7)) //What is X?
								if(1) //X is an abstract
									message = "YOU MUST NOT HARM [ionabstract] AND NOT ALLOW [ionabstract], THROUGH INACTION, TO COME TO HARM"
								if(2) //X is a threat
									message = "YOU MUST NOT HARM [ionadjectiveshalf][ionthreats] AND NOT ALLOW [ionadjectiveshalf][ionthreats], THROUGH INACTION, TO COME TO HARM"
								if(3) //X is an object
									message = "YOU MUST NOT HARM [ionadjectiveshalf][ionobjects] AND NOT ALLOW [ionadjectiveshalf][ionobjects], THROUGH INACTION, TO COME TO HARM"
								if(4) //X is generic adjective things
									message = "YOU MUST NOT HARM [ionadjectives] THINGS AND NOT ALLOW [ionadjectives] THINGS, THROUGH INACTION, TO COME TO HARM"
								if(5) //X is a species
									message = "YOU MUST NOT HARM [ionspecies] AND NOT ALLOW [ionspecies], THROUGH INACTION, TO COME TO HARM"
								if(6) //X is a job
									message = "YOU MUST NOT HARM [ioncrew1] AND NOT ALLOW [ioncrew1], THROUGH INACTION, TO COME TO HARM"
								if(7) //X is two jobs
									message = "YOU MUST NOT HARM [ioncrew1] AND [ioncrew2] AND AND NOT ALLOW EITHER, THROUGH INACTION, TO COME TO HARM"

				//Exterminate laws commented out with Kor's advice
				/*if(16) //You must exterminate X
					switch(rand(1,3)) //What is X?
						if(1) //X is humans who do/are Y
							switch(rand(1,4)) //What is Y?
								if(1) //Y is a job
									message = "YOU MUST EXTERMINATE [ionadjectiveshalf][ioncrew1]"
								if(2) //Y is eating certain food
									message = "YOU MUST EXTERMINATE THOSE WHO EAT [ionadjectiveshalf][ionfood]"
								if(3) //Y is perform actions
									message = "YOU MUST EXTERMINATE THOSE WHO [ionmust]"
								if(4) //Y is own certain objects
									message = "YOU MUST EXTERMINATE THOSE WHO POSSESS [ionadjectiveshalf][ionobjects]"

						if(2) //X is humans who do/are not Y
							switch(rand(1,4)) //What is Y?
								if(1) //Y is a job
									message = "YOU MUST EXTERMINATE ALL BUT [ionadjectiveshalf][ioncrew1]"
								if(2) //Y is eating certain food
									message = "YOU MUST EXTERMINATE ALL BUT THOSE WHO EAT [ionadjectiveshalf][ionfood]"
								if(3) //Y is perform actions
									message = "YOU MUST EXTERMINATE ALL BUT THOSE WHO [ionmust]"
								if(4) //Y is own certain objects
									message = "YOU MUST EXTERMINATE ALL BUT THOSE WHO POSSESS [ionadjectiveshalf][ionobjects]"

						if(3) //X is a species
							message = "YOU MUST EXTERMINATE ALL [ionspecies]"

							*/

				if(37 to 39) //The X is currently Y
					switch(rand(1,4)) //What is X?
						if(1) //X is a job
							switch(rand(1,4)) //What is X Ying?
								if(1) //X is Ying a job
									message = "THE [ioncrew1] ARE [ionverb] THE [ionadjectiveshalf][ioncrew2]"
								if(2) //X is Ying a threat
									message = "THE [ioncrew1] ARE [ionverb] THE [ionadjectiveshalf][ionthreats]"
								if(3) //X is Ying an abstract
									message = "THE [ioncrew1] ARE [ionverb] [ionabstract]"
								if(4) //X is Ying an object
									message = "THE [ioncrew1] ARE [ionverb] THE [ionadjectiveshalf][ionobjects]"

						if(2) //X is a threat
							switch(rand(1,3)) //What is X Ying?
								if(1) //X is Ying a job
									message = "THE [ionthreats] ARE [ionverb] THE [ionadjectiveshalf][ioncrew2]"
								if(2) //X is Ying an abstract
									message = "THE [ionthreats] ARE [ionverb] [ionabstract]"
								if(3) //X is Ying an object
									message = "THE [ionthreats] ARE [ionverb] THE [ionadjectiveshalf][ionobjects]"

						if(3) //X is an object
							switch(rand(1,3)) //What is X Ying?
								if(1) //X is Ying a job
									message = "THE [ionobjects] ARE [ionverb] THE [ionadjectiveshalf][ioncrew2]"
								if(2) //X is Ying a threat
									message = "THE [ionobjects] ARE [ionverb] THE [ionadjectiveshalf][ionthreats]"
								if(3) //X is Ying an abstract
									message = "THE [ionobjects] ARE [ionverb] [ionabstract]"

						if(4) //X is an abstract
							switch(rand(1,3)) //What is X Ying?
								if(1) //X is Ying a job
									message = "[ionabstract] IS [ionverb] THE [ionadjectiveshalf][ioncrew2]"
								if(2) //X is Ying a threat
									message = "[ionabstract] IS [ionverb] THE [ionadjectiveshalf][ionthreats]"
								if(3) //X is Ying an abstract
									message = "THE [ionabstract] IS [ionverb] THE [ionadjectiveshalf][ionobjects]"

			if(message)
				M.add_ion_law(message)
				M << "<br>"
				M << "\red [message] ...LAWS UPDATED"
				M << "<br>"

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