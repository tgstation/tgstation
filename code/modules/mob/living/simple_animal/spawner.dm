/mob/living/simple_animal/hostile/spawner
	name = "monster nest"
	icon = 'icons/mob/animal.dmi'
	health = 100
	maxHealth = 100
	var/list/spawned_mobs = list()
	var/max_mobs = 5
	var/spawn_delay = 0
	var/spawn_time = 300 //30 seconds default
	var/mob_type = /mob/living/simple_animal/hostile/carp
	var/spawn_text = "emerges from"
	status_flags = 0
	anchored = 1
	AIStatus = AI_OFF
	a_intent = "harm"
	stop_automated_movement = 1
	wander = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 350


/mob/living/simple_animal/hostile/spawner/Destroy()
	for(var/mob/living/simple_animal/L in spawned_mobs)
		if(L.nest == src)
			L.nest = null
	spawned_mobs = null
	return ..()

/mob/living/simple_animal/hostile/spawner/Life()
	..()
	if(!stat)
		spawn_mob()

/mob/living/simple_animal/hostile/spawner/proc/spawn_mob()
	if(spawned_mobs.len >= max_mobs)
		return 0
	if(spawn_delay > world.time)
		return 0
	spawn_delay = world.time + spawn_time
	var/mob/living/simple_animal/L = new mob_type(src.loc)
	spawned_mobs += L
	L.nest = src
	L.faction = src.faction
	visible_message("<span class='danger'>[L] [spawn_text] [src].</span>")



/mob/living/simple_animal/hostile/spawner/syndicate
	name = "warp beacon"
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	spawn_text = "warps in from"
	mob_type = /mob/living/simple_animal/hostile/syndicate/ranged
	faction = list("syndicate")


