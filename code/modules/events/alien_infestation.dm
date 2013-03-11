/datum/event_control/alien_infestation
	name = "Alien Infestation"
	typepath = /datum/event/alien_infestation
	weight = 5
	max_occurrences = 1

/datum/event/alien_infestation
	announceWhen	= 400

	var/spawncount = 1
	var/successSpawn = 0	//So we don't make a command report if nothing gets spawned.


/datum/event/alien_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)

/datum/event/alien_infestation/kill()
	if(!successSpawn && control)
		control.occurrences--
	return ..()

/datum/event/alien_infestation/announce()
	if(successSpawn)
		command_alert("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert")
		world << sound('sound/AI/aliens.ogg')


/datum/event/alien_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in world)
		if(temp_vent.loc.z == 1 && !temp_vent.welded && temp_vent.network)
			if(temp_vent.network.normal_members.len > 10)	//Stops Aliens getting stuck in small networks. See: Security, Virology
				vents += temp_vent

	var/list/candidates = get_candidates(BE_ALIEN)

	while(spawncount > 0 && vents.len && candidates.len)
		var/obj/vent = pick_n_take(vents)
		var/client/C = pick_n_take(candidates)

		var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
		new_xeno.key = C.key

		spawncount--
		successSpawn = 1