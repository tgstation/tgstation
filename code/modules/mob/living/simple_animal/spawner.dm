/mob/living/simple_animal/hostile/spawner
	name = "monster nest"
	icon = 'icons/mob/animal.dmi'
	health = 100
	maxHealth = 100
	gender = NEUTER
	var/list/spawned_mobs = list()
	var/max_mobs = 5
	var/spawn_delay = 0
	var/spawn_time = 300 //30 seconds default
	var/mob_type = /mob/living/simple_animal/hostile/carp
	var/spawn_text = "emerges from"
	status_flags = 0
	anchored = 1
	AIStatus = AI_OFF
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	wander = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 350
	layer = BELOW_MOB_LAYER
	sentience_type = SENTIENCE_BOSS


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
	L.admin_spawned = admin_spawned	//If we were admin spawned, lets have our children count as that as well.
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

/mob/living/simple_animal/hostile/spawner/skeleton
	name = "bone pit"
	desc = "A pit full of bones, some still seem to be moving.."
	icon_state = "hole"
	icon_living = "hole"
	icon = 'icons/mob/nest.dmi'
	health = 150
	maxHealth = 150
	max_mobs = 15
	spawn_time = 150
	mob_type = /mob/living/simple_animal/hostile/skeleton
	spawn_text = "climbs out of"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("skeleton")

/mob/living/simple_animal/hostile/spawner/mining
	name = "monster den"
	desc = "A hole dug into the ground, harboring all kinds of monsters found within most caves or mining asteroids."
	icon_state = "hole"
	icon_living = "hole"
	health = 200
	maxHealth = 200
	max_mobs = 3
	icon = 'icons/mob/nest.dmi'
	spawn_text = "crawls out of"
	mob_type = /mob/living/simple_animal/hostile/asteroid/goldgrub
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("mining")

/mob/living/simple_animal/hostile/spawner/mining/goliath
	name = "goliath den"
	desc = "A den housing a nest of goliaths, oh god why?"
	mob_type = /mob/living/simple_animal/hostile/asteroid/goliath

/mob/living/simple_animal/hostile/spawner/mining/hivelord
	name = "hivelord den"
	desc = "A den housing a nest of hivelords."
	mob_type = /mob/living/simple_animal/hostile/asteroid/hivelord

/mob/living/simple_animal/hostile/spawner/mining/basilisk
	name = "basilisk den"
	desc = "A den housing a nest of basilisks, bring a coat."
	mob_type = /mob/living/simple_animal/hostile/asteroid/basilisk

/mob/living/simple_animal/hostile/spawner/mining/wumborian
	name = "wumborian fugu den"
	desc = "A den housing a nest of wumborian fugus, how do they all even fit in there?"
	mob_type = /mob/living/simple_animal/hostile/asteroid/fugu