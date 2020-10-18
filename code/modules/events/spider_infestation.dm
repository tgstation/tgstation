/datum/round_event_control/spider_infestation
	name = "Spider Infestation"
	typepath = /datum/round_event/spider_infestation
	weight = 10
	max_occurrences = 1
	min_players = 20

/datum/round_event/spider_infestation
	announceWhen = 400
	var/spawncount = 2

/datum/round_event/spider_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)

/datum/round_event/spider_infestation/announce(fake)
	priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", 'sound/ai/aliens.ogg')

/datum/round_event/spider_infestation/start()
	var/list/spawn_locs = list()
	for(var/x in GLOB.xeno_spawn)
		var/turf/spawn_turf = x
		var/light_amount = spawn_turf.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			spawn_locs += spawn_turf
	if(spawn_locs.len < spawncount)
		message_admins("Not enough valid spawn locations found in GLOB.xeno_spawn, aborting spider spawning...")
		return MAP_ERROR
	while(spawncount > 0)
		var/obj/structure/spider/eggcluster/midwife/new_eggs = new /obj/structure/spider/eggcluster/midwife(pick_n_take(spawn_locs))
		new_eggs.amount_grown = 98
		spawncount--
	log_game("Midwife spider eggs were spawned via an event.")

