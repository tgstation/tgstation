/datum/round_event_control/alien_infestation
	name = "Alien Infestation"
	typepath = /datum/round_event/ghost_role/alien_infestation
	weight = 5

	min_players = 10
	max_occurrences = 1

/datum/round_event/ghost_role/alien_infestation
	announceWhen	= 400

	minimum_required = 1
	role_name = "alien larva"

	// 50% chance of being incremented by one
	var/spawncount = 1
	var/successSpawn = 0	//So we don't make a command report if nothing gets spawned.
	fakeable = TRUE


/datum/round_event/ghost_role/alien_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	if(prob(50))
		spawncount++

/datum/round_event/ghost_role/alien_infestation/kill()
	if(!successSpawn && control)
		// This never happened, so let's not deny the future of this round
		// some xenolovin
		control.occurrences--
	return ..()

/datum/round_event/ghost_role/alien_infestation/announce(fake)
	if(successSpawn || fake)
		priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", 'sound/ai/aliens.ogg')


/datum/round_event/ghost_role/alien_infestation/spawn_role()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			//Stops Aliens getting stuck in small networks.
			//See: Security, Virology
			if(temp_vent_parent.other_atmosmch.len > 20)
				vents += temp_vent

	if(!vents.len)
		message_admins("An event attempted to spawn an alien but no suitable vents were found. Shutting down.")
		return MAP_ERROR

	var/list/candidates = get_candidates(ROLE_ALIEN, null, ROLE_ALIEN)

	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	while(spawncount > 0 && vents.len && candidates.len)
		var/obj/vent = pick_n_take(vents)
		var/client/C = pick_n_take(candidates)

		var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
		new_xeno.key = C.key

		spawncount--
		successSpawn = TRUE
		message_admins("[ADMIN_LOOKUPFLW(new_xeno)] has been made into an alien by an event.")
		log_game("[key_name(new_xeno)] was spawned as an alien by an event.")
		spawned_mobs += new_xeno

	if(successSpawn)
		return SUCCESSFUL_SPAWN
	else
		// Like how did we get here?
		return FALSE
