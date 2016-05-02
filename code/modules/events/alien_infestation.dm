/datum/round_event_control/alien_infestation
	name = "Alien Infestation"
	typepath = /datum/round_event/alien_infestation
	weight = 5

	min_players = 10
	max_occurrences = 1

/datum/round_event/alien_infestation
	announceWhen	= 400

	var/spawncount = 1
	var/successSpawn = 0	//So we don't make a command report if nothing gets spawned.


/datum/round_event/alien_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(1, 2)

/datum/round_event/alien_infestation/kill()
	if(!successSpawn && control)
		control.occurrences--
	return ..()

/datum/round_event/alien_infestation/announce()
	if(successSpawn)
		priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", 'sound/AI/aliens.ogg')


/datum/round_event/alien_infestation/start()
	get_alien()

/datum/round_event/alien_infestation/proc/get_alien(end_if_fail = 0)
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in machines)
		if(qdeleted(temp_vent))
			continue
		if(temp_vent.loc.z == ZLEVEL_STATION && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.PARENT1
			if(temp_vent_parent.other_atmosmch.len > 20)	//Stops Aliens getting stuck in small networks. See: Security, Virology
				vents += temp_vent

	if(!vents.len)
		message_admins("An event attempted to spawn an alien but no suitable vents were found. Shutting down.")
		return kill()

	var/list/candidates = get_candidates(ROLE_ALIEN, ALIEN_AFK_BRACKET, "alien candidate")
	if(!candidates.len)
		if(end_if_fail)
			return 0
		return find_alien()
	while(spawncount > 0 && vents.len && candidates.len)
		var/obj/vent = pick_n_take(vents)
		var/client/C = pick_n_take(candidates)

		var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
		new_xeno.key = C.key

		spawncount--
		successSpawn = 1
		message_admins("[new_xeno.key] has been made into an alien by an event.")
		log_game("[new_xeno.key] was spawned as an alien by an event.")
	if(successSpawn)
		return 1

/datum/round_event/alien_infestation/proc/find_alien()
	message_admins("Event attempted to spawn an alien but no candidates were available. Will try again momentarily...")
	spawn(50)
		if(get_alien(1))
			message_admins("Situation has been resolved")
			return 0
		message_admins("Unfortunately, no candidates were available for becoming an alien. Shutting down.")
	return kill()
