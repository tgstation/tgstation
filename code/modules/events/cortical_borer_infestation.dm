/datum/round_event_control/cortical_borer_infestation
	name = "Cortical Borer Infestation"
	typepath = /datum/round_event/cortical_borer_infestation
	weight = 5
	max_occurrences = 1

/datum/round_event/cortical_borer_infestation
	announceWhen	= 400

	var/spawncount = 1
	var/successSpawn = 0	//So we don't make a command report if nothing gets spawned.


/datum/round_event/cortical_borer_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(1, 2)

/datum/round_event/cortical_borer_infestation/kill()
	if(!successSpawn && control)
		control.occurrences--
	return ..()

/datum/round_event/cortical_borer_infestation/announce()
	if(successSpawn)
		command_alert("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert")
		world << sound('sound/AI/aliens.ogg')


/datum/round_event/cortical_borer_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in world)
		if(temp_vent.loc.z == 1 && !temp_vent.welded && temp_vent.network)
			if(temp_vent.network.normal_members.len > 50)	//Stops cortical borers getting stuck in small networks. See: Security, Virology
				vents += temp_vent

	var/list/candidates = get_candidates(BE_ALIEN, ALIEN_AFK_BRACKET)

	while(spawncount > 0 && vents.len && candidates.len)
		var/obj/vent = pick_n_take(vents)
		var/client/C = pick_n_take(candidates)

		var/mob/living/simple_animal/borer/new_borer = new(vent.loc)
		new_borer.key = C.key

		spawncount--
		successSpawn = 1