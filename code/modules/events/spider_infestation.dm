/datum/event_control/spider_infestation
	name = "Spider Infestation"
	typepath = /datum/event/spider_infestation
	weight = 5
	max_occurrences = 1

/datum/event/spider_infestation
	announceWhen	= 400

	var/spawncount = 1


/datum/event/spider_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(2, 3)

/datum/event/spider_infestation/announce()
	command_alert("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert")
	world << sound('sound/AI/aliens.ogg')


/datum/event/spider_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in world)
		if(temp_vent.loc.z == 1 && !temp_vent.welded && temp_vent.network)
			if(temp_vent.network.normal_members.len > 10)
				vents += temp_vent

	while((spawncount >= 1) && vents.len)
		var/obj/vent = pick(vents)
		var/obj/effect/spider/spiderling/S = new(vent.loc)
		if(prob(66))
			S.grow_as = /mob/living/simple_animal/hostile/giant_spider/nurse
		vents -= vent
		spawncount--