
/*
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
			*/

//Always triggers an event when called, dynamically chooses events based on job population
/proc/spawn_dynamic_event()
	if(!config.allow_random_events)
		return

	var/minutes_passed = world.time/600

	var/list/active_with_role = number_active_with_role()
	//var/engineer_count = number_active_with_role("Engineer")
	//var/security_count = number_active_with_role("Security")
	//var/medical_count = number_active_with_role("Medical")
	//var/AI_count = number_active_with_role("AI")
	//var/janitor_count = number_active_with_role("Janitor")

	// Maps event names to event chances
	// For each chance, 100 represents "normal likelihood", anything below 100 is "reduced likelihood", anything above 100 is "increased likelihood"
	var/list/possibleEvents = list()

	// Check for additional possible events
	possibleEvents[/datum/event/economic_event] = 100	//see Code/WorkInProgress/Cael_Aislinn/Economy/Economy_Events.dm
	possibleEvents[/datum/event/carp_migration] = 50 + 50 * active_with_role["Engineer"]
	possibleEvents[/datum/event/brand_intelligence] = 50 + 25 * active_with_role["Janitor"]

	possibleEvents[/datum/event/rogue_drone] = 25 + 25 * active_with_role["Engineer"] + 25 * active_with_role["Security"]
	possibleEvents[/datum/event/infestation] = 50 + 25 * active_with_role["Janitor"]

	possibleEvents[/datum/event/communications_blackout] = 50 + 25 * active_with_role["AI"] + active_with_role["Scientist"] * 25
	possibleEvents[/datum/event/ionstorm] = active_with_role["AI"] * 25 + active_with_role["Cyborg"] * 25 + active_with_role["Engineer"] * 10 + active_with_role["Scientist"] * 5
	possibleEvents[/datum/event/grid_check] = 10 * active_with_role["Engineer"]
	possibleEvents[/datum/event/electrical_storm] = 75 + 25 * active_with_role["Janitor"] + 5 * active_with_role["Engineer"]

	if(!spacevines_spawned)
		possibleEvents[/datum/event/spacevine] = 5 + 10 * active_with_role["Engineer"]
	if(active_with_role["Engineer"] > 0 && minutes_passed >= 30) // Give engineers time to set up engine
		possibleEvents[/datum/event/meteor_wave] = 20 * active_with_role["Engineer"]
		possibleEvents[/datum/event/meteor_shower] = 80 * active_with_role["Engineer"]
		possibleEvents[/datum/event/blob] = 30 * active_with_role["Engineer"]

	possibleEvents[/datum/event/viral_infection] = 25 + active_with_role["Medical"] * 25
	if(active_with_role["Medical"] > 0)
		possibleEvents[/datum/event/radiation_storm] = active_with_role["Medical"] * 100
		possibleEvents[/datum/event/spontaneous_appendicitis] = active_with_role["Medical"] * 75
		possibleEvents[/datum/event/viral_outbreak] = active_with_role["Medical"] * 5

	if(active_with_role["Security"] > 0)
		possibleEvents[/datum/event/prison_break] = active_with_role["Security"] * 50
		if(!sent_spiders_to_station)
			possibleEvents[/datum/event/spider_infestation] = max(active_with_role["Security"], 5) + 5
		if(aliens_allowed && !sent_aliens_to_station)
			possibleEvents[/datum/event/alien_infestation] = max(active_with_role["Security"], 5) + 2.5
		if(!sent_ninja_to_station && toggle_space_ninja)
			possibleEvents[/datum/event/space_ninja] = max(active_with_role["Security"], 5)

	var/picked_event = pickweight(possibleEvents)
	if(!picked_event)
		return

	//The event will add itself to the MC's event list
	//and start working via the constructor.
	new picked_event

	//moved this to proc/check_event()
	/*var/chance = possibleEvents[picked_event]
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
		return 0*/

	/*switch(picked_event)
		if("Meteor")
			command_alert("Meteors have been detected on collision course with the station.", "Meteor Alert")
			for(var/mob/M in player_list)
				if(!istype(M,/mob/new_player))
					M << sound('sound/AI/meteors.ogg')
			spawn(100)
				meteor_wave(10)
				spawn_meteors()
			spawn(700)
				meteor_wave(10)
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
			meteor_shower()*/

	return 1

// Returns how many characters are currently active(not logged out, not AFK for more than 10 minutes)
// with a specific role.
// Note that this isn't sorted by department, because e.g. having a roboticist shouldn't make meteors spawn.
/proc/number_active_with_role(role)
	var/list/active_with_role = list()
	active_with_role["Engineer"] = 0
	active_with_role["Medical"] = 0
	active_with_role["Security"] = 0
	active_with_role["Scientist"] = 0
	active_with_role["AI"] = 0
	active_with_role["Cyborg"] = 0
	active_with_role["Janitor"] = 0

	for(var/mob/M in player_list)
		if(!M.client || M.client.inactivity > 10 * 10 * 60) // longer than 10 minutes AFK counts them as inactive
			continue
		switch(role)
			if("Engineer")
				if(istype(M, /mob/living/silicon/robot) && M:module && M:module.name == "engineering robot module")
					active_with_role["Engineer"]++
				if(M.mind.assigned_role in list("Chief Engineer", "Station Engineer"))
					active_with_role["Engineer"]++
			if("Medical")
				if(istype(M, /mob/living/silicon/robot) && M:module && M:module.name == "medical robot module")
					active_with_role["Medical"]++
				if(M.mind.assigned_role in list("Chief Medical Officer", "Medical Doctor"))
					active_with_role["Medical"]++
			if("Security")
				if(istype(M, /mob/living/silicon/robot) && M:module && M:module.name == "security robot module")
					active_with_role["Security"]++
				if(M.mind.assigned_role in security_positions)
					active_with_role["Security"]++
			if("Scientist")
				if(M.mind.assigned_role in list("Research Director", "Scientist"))
					active_with_role["Scientist"]++
			if("AI")
				if(M.mind.assigned_role == "AI")
					active_with_role["AI"]++
			if("Cyborg")
				if(M.mind.assigned_role == "Cyborg")
					active_with_role["Cyborg"]++
			if("Janitor")
				if(M.mind.assigned_role == "Janitor")
					active_with_role["Janitor"]++
	return active_with_role
