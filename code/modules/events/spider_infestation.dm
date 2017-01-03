/datum/round_event_control/spider_infestation
	name = "Spider Infestation"
	typepath = /datum/round_event/spider_infestation
	weight = 5
	max_occurrences = 1
	min_players = 15

/datum/round_event/spider_infestation
	announceWhen	= 400

	var/spawncount = 1


/datum/round_event/spider_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(5, 8)

/datum/round_event/spider_infestation/announce()
	priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", 'sound/AI/aliens.ogg')


/datum/round_event/spider_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in world)
		if(temp_vent.loc.z == ZLEVEL_STATION && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.PARENT1
			if(temp_vent_parent.other_atmosmch.len > 20)
				vents += temp_vent

	while((spawncount >= 1) && vents.len)
		var/obj/vent = pick(vents)
		var/spawn_type = /obj/structure/spider/spiderling
		if(prob(66))
			spawn_type = /obj/structure/spider/spiderling/nurse
		spawn_atom_to_turf(spawn_type, vent, 1, FALSE)
		vents -= vent
		spawncount--
