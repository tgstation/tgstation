/datum/round_event_control/borer_infestation
	name = "Borer Infestation"
	typepath = /datum/round_event/borer_infestation
	weight = 5
	max_occurrences = 0  //Not yet, adminspawn only

/datum/round_event/borer_infestation
//	announceWhen	= 400

	var/spawncount = 2
	var/successSpawn = 0	//So we don't make a command report if nothing gets spawned.


/datum/round_event/borer_infestation/setup()
//	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(2, 3)

/datum/round_event/borer_infestation/kill()
	if(!successSpawn && control)
		control.occurrences--
	return ..()

/datum/round_event/borer_infestation/announce()
	/*if(successSpawn)
		priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", 'sound/AI/aliens.ogg')
	*/
	return

/datum/round_event/borer_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in world)
		if(temp_vent.loc.z == ZLEVEL_STATION && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents["p1"]
			if(temp_vent_parent.other_atmosmch.len > 20)	//Stops Borers getting stuck in small networks. See: Security, Virology
				vents += temp_vent

	var/list/candidates = get_candidates(BE_ALIEN, ALIEN_AFK_BRACKET)

	while(spawncount > 0 && vents.len && candidates.len)
		var/obj/vent = pick_n_take(vents)
		var/client/C = pick_n_take(candidates)

		var/mob/living/simple_animal/borer/borer = new(vent.loc)
		borer.key = C.key

		spawncount--
		successSpawn = 1