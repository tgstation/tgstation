/datum/component/spawner
	var/mob_types = list(/mob/living/simple_animal/hostile/carp)
	var/spawn_time = 300 //30 seconds default
	var/list/spawned_mobs = list()
	var/spawn_delay = 0
	var/max_mobs = 5
	var/spawn_text = "emerges from"
	var/list/faction = list("mining")
<<<<<<< HEAD

=======
	
>>>>>>> Updated this old code to fork


/datum/component/spawner/Initialize(_mob_types, _spawn_time, _faction, _spawn_text, _max_mobs)
	if(_spawn_time)
		spawn_time=_spawn_time
	if(_mob_types)
		mob_types=_mob_types
	if(_faction)
		faction=_faction
	if(_spawn_text)
		spawn_text=_spawn_text
	if(_max_mobs)
		max_mobs=_max_mobs
<<<<<<< HEAD

	RegisterSignal(parent, list(COMSIG_PARENT_QDELETING), .proc/stop_spawning)
=======
	
	RegisterSignal(parent, list(COMSIG_PARENT_QDELETED), .proc/stop_spawning)
>>>>>>> Updated this old code to fork
	START_PROCESSING(SSprocessing, src)

/datum/component/spawner/process()
	try_spawn_mob()
<<<<<<< HEAD


/datum/component/spawner/proc/stop_spawning(force)
=======
	

/datum/component/spawner/proc/stop_spawning(force, hint)
>>>>>>> Updated this old code to fork
	STOP_PROCESSING(SSprocessing, src)
	for(var/mob/living/simple_animal/L in spawned_mobs)
		if(L.nest == src)
			L.nest = null
	spawned_mobs = null

/datum/component/spawner/proc/try_spawn_mob()
<<<<<<< HEAD
	var/atom/P = parent
=======
	var/atom/P = parent 
>>>>>>> Updated this old code to fork
	if(spawned_mobs.len >= max_mobs)
		return 0
	if(spawn_delay > world.time)
		return 0
	spawn_delay = world.time + spawn_time
	var/chosen_mob_type = pick(mob_types)
	var/mob/living/simple_animal/L = new chosen_mob_type(P.loc)
<<<<<<< HEAD
	L.flags_1 |= (P.flags_1 & ADMIN_SPAWNED_1)
=======
	L.flags_1 |= (P.flags_1 & ADMIN_SPAWNED_1)	
>>>>>>> Updated this old code to fork
	spawned_mobs += L
	L.nest = src
	L.faction = src.faction
	P.visible_message("<span class='danger'>[L] [spawn_text] [P].</span>")
