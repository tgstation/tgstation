var/list/event_last_fired = list()

//Always triggers an event when called, dynamically chooses events based on job population
/proc/spawn_dynamic_event()
	if(!config.allow_random_events)
		return

	var/minutes_passed = world.time/600

	var/list/active_with_role = number_active_with_role()

	// Maps event names to event chances
	// For each chance, 100 represents "normal likelihood", anything below 100 is "reduced likelihood", anything above 100 is "increased likelihood"
	// Events have to be manually added to this proc to happen
	var/list/possibleEvents = list()

	//see:
	// Code/WorkInProgress/Cael_Aislinn/Economy/Economy_Events.dm
	// Code/WorkInProgress/Cael_Aislinn/Economy/Economy_Events_Mundane.dm
	//Commented out for now. Let's be honest, a string of text on PDA is not worth a meteor shower or ion storm
	//possibleEvents[/datum/event/economic_event] = 100
	//possibleEvents[/datum/event/trivial_news] = 150
	//possibleEvents[/datum/event/mundane_news] = 100

	//It is this coder's thought that weighting events on job counts is dumb and predictable as hell. 10 Engies ? Hope you like Meteors
	//Instead, weighting goes from 100 (boring and common) to 10 (exceptional)

	possibleEvents[/datum/event/pda_spam] = 75
	possibleEvents[/datum/event/money_lotto] = 20
	if(account_hack_attempted)
		possibleEvents[/datum/event/money_hacker] = 30

	possibleEvents[/datum/event/carp_migration] = 40
	possibleEvents[/datum/event/brand_intelligence] = 30
	possibleEvents[/datum/event/rogue_drone] = 25
	possibleEvents[/datum/event/infestation] = 60
	possibleEvents[/datum/event/communications_blackout] = 25

	if(active_with_role["AI"] > 0 || active_with_role["Cyborg"] > 0)
		possibleEvents[/datum/event/ionstorm] = 30
	possibleEvents[/datum/event/grid_check] = 20 //May cause lag
	possibleEvents[/datum/event/electrical_storm] = 10
	possibleEvents[/datum/event/wallrot] = 30

	if(!spacevines_spawned)
		possibleEvents[/datum/event/spacevine] = 15
	if(minutes_passed >= 30 && active_with_role["Engineer"] > 1) // Give engineers time to not set up the engine
		possibleEvents[/datum/event/meteor_wave] = 15
		possibleEvents[/datum/event/meteor_shower] = 40
		possibleEvents[/datum/event/blob] = 10

	possibleEvents[/datum/event/viral_infection] = 40
	if(active_with_role["Medical"] > 1)
		possibleEvents[/datum/event/radiation_storm] = 50
		possibleEvents[/datum/event/spontaneous_appendicitis] = 75
		possibleEvents[/datum/event/viral_outbreak] = 25
		possibleEvents[/datum/event/organ_failure] = 30

	possibleEvents[/datum/event/prison_break] = 25
	if(active_with_role["Security"] > 1)
		if(!sent_spiders_to_station)
			possibleEvents[/datum/event/spider_infestation] = 15
		if(aliens_allowed && !sent_aliens_to_station)
			possibleEvents[/datum/event/alien_infestation] = 10
		if(!sent_ninja_to_station && toggle_space_ninja)
			possibleEvents[/datum/event/space_ninja] = 0 //Fix the ninja code first

	for(var/event_type in event_last_fired) if(possibleEvents[event_type])
		var/time_passed = world.time - event_last_fired[event_type]
		var/full_recharge_after = 60 * 60 * 10 // Was 3 hours, changed to 1 hour since rounds rarely last that long anyways
		var/weight_modifier = max(0, (full_recharge_after - time_passed) / 300)

		possibleEvents[event_type] = max(possibleEvents[event_type] - weight_modifier, 0)

	var/picked_event = pickweight(possibleEvents)
	event_last_fired[picked_event] = world.time

	// Debug code below here, very useful for testing so don't delete please.
	var/debug_message = "Firing random event. "
	for(var/V in active_with_role)
		debug_message += "#[V]:[active_with_role[V]] "
	debug_message += "||| "
	for(var/V in possibleEvents)
		debug_message += "[V]:[possibleEvents[V]]"
	debug_message += "|||Picked:[picked_event]"
	log_debug(debug_message)

	if(!picked_event)
		return

	//The event will add itself to the MC's event list
	//and start working via the constructor.
	new picked_event

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
	active_with_role["Botanist"] = 0

	for(var/mob/M in player_list)
		if(!M.mind || !M.client || M.client.inactivity > 10 * 10 * 60) // longer than 10 minutes AFK counts them as inactive
			continue

		if(istype(M, /mob/living/silicon/robot) && M:module && M:module.name == "engineering robot module")
			active_with_role["Engineer"]++
		if(M.mind.assigned_role in list("Chief Engineer", "Station Engineer"))
			active_with_role["Engineer"]++

		if(istype(M, /mob/living/silicon/robot) && M:module && M:module.name == "medical robot module")
			active_with_role["Medical"]++
		if(M.mind.assigned_role in list("Chief Medical Officer", "Medical Doctor"))
			active_with_role["Medical"]++

		if(istype(M, /mob/living/silicon/robot) && M:module && M:module.name == "security robot module")
			active_with_role["Security"]++
		if(M.mind.assigned_role in security_positions)
			active_with_role["Security"]++

		if(M.mind.assigned_role in list("Research Director", "Scientist"))
			active_with_role["Scientist"]++

		if(M.mind.assigned_role == "AI")
			active_with_role["AI"]++

		if(M.mind.assigned_role == "Cyborg")
			active_with_role["Cyborg"]++

		if(M.mind.assigned_role == "Janitor")
			active_with_role["Janitor"]++

		if(M.mind.assigned_role == "Botanist")
			active_with_role["Botanist"]++

	return active_with_role
