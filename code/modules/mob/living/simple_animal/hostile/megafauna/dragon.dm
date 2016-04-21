/mob/living/simple_animal/hostile/megafauna/dragon
	name = "dragon"
	health = 4000
	maxHealth = 4000
	icon_state = "dragon"
	icon_living = "dragon"
	icon = 'icons/mob/lavaland/dragon.dmi'
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 3
	move_to_delay = 10
	ranged = 1
	flying = 1


/obj/effect/overlay/temp/fireball
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "fireball"
	name = "fireball"
	desc = "Get out of the way!"
	layer = 6
	dir = SOUTH
	pixel_z = 500
	anchored = 1

/obj/effect/overlay/temp/target
	icon = 'icons/mob/actions.dmi'
	icon_state = "sniper_zoom"
	layer = MOB_LAYER - 0.1
	anchored = 1

/obj/effect/overlay/temp/target/ex_act()
	return

/obj/effect/overlay/temp/target/New()
	..()
	spawn()
		var/turf/T = get_turf(src)
		var/obj/effect/overlay/temp/fireball/F = new(src.loc)
		animate(F, pixel_z = 0, time = 12)
		sleep(12)
		explosion(T, 0, 0, 1, 0, 1, 1)
		qdel(F)
		qdel(src)

//mob/living/simple_animal/hostile/megafauna/dragon/OpenFire()
//	fire_rain()

/mob/living/simple_animal/hostile/megafauna/dragon/proc/fire_rain()
	for(var/turf/turf in range(12,get_turf(src)))
		if(prob(5))
			new /obj/effect/overlay/temp/target(turf)


/mob/living/simple_animal/hostile/megafauna/dragon/proc/fire_walls()
	var/list/attack_dirs = list(NORTH,EAST,SOUTH,WEST)
	if(prob(50))
		attack_dirs = list(NORTH,WEST,SOUTH,EAST)

	spawn(0)
		for(var/d in attack_dirs)
			var/turf/E = get_edge_target_turf(src, d)
			var/range = 10
			for(var/turf/J in getline(src,E))
				if(!range)
					break
				range--

				PoolOrNew(/obj/effect/hotspot,J)
				J.hotspot_expose(700,50,1)

/mob/living/simple_animal/hostile/megafauna/dragon/proc/swoop_attack()
	stop_automated_movement = TRUE

	if(prob(50))
		animate(src, pixel_x = 500, pixel_z = 500, time = 10)
	else
		animate(src, pixel_x = -500, pixel_z = 500, time = 10)
	sleep(30)

	var/tturf = get_turf(target)
	src.loc = tturf
	animate(src, pixel_x = 0, pixel_z = 0, time = 10)
	sleep(10)
	for(var/mob/living/L in range(2,tturf))
		L.gib()
	for(var/mob/M in range(7,src))
		shake_camera(M, 15, 1)

	stop_automated_movement = FALSE


/*
/proc/get_random_points_from(atom/A, amount_of_points = 1, range = 5, orange = 0)
	if(!A)
		return list()

	var/list/range_turfs = ultra_range(range,A,orange)
	. = list()

	while(amount_of_points)
		for(var/turf/T in range_turfs-.)
			if(!amount_of_points)
				break
			if(get_dist(A,T) >= range-1) //get edge turfs
				if(prob(3)) //try to space out the turfs
					amount_of_points--
					. += T


#define NOT_ANGRY 0
#define ANNOYED 250
#define ANGRY	500
#define PISSED	750

/mob/living/simple_animal/hostile/lavaboss
	icon = 'icons/mob/LavaBoss.dmi'
	name = "Magma Miscreation"
	desc = "Hotter than the sun in the middle of July"
	icon_state = "lavaboss"
	icon_living = "lavaboss"
	icon_dead = ""
	speak_chance = 0
	turns_per_move = 3
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 1
	maxHealth = 1000
	health = 1000
	harm_intent_damage = 15
	melee_damage_lower = 15
	melee_damage_upper = 35
	attacktext = "claws"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = "harm"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	faction = list("lavaland")
	minbodytemp = 0
	maxbodytemp = INFINITY
	retreat_distance = 0
	minimum_distance = 0
	damage_coeff = list(BRUTE = 0.8, BURN = -1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	pixel_x = -32
	melee_damage_type = BURN
	layer = 5


	//Abilities
	var/next_ability = 0 //the world.time when we can use our next special
	var/groundsmash_trigger_range = 7
	var/anger = NOT_ANGRY

	var/datum/action/lavaboss/groundsmash/groundsmash
	var/datum/action/lavaboss/firewalls/firewalls
	var/datum/action/lavaboss/lavarivers/lavarivers

	var/list/valid_turfs = list(/turf/simulated/floor/plating/asteroid/basalt/lava, /turf/simulated/floor/plating/lava/smooth, /turf/space)


/mob/living/simple_animal/hostile/lavaboss/New()
	..()
	groundsmash = new()
	groundsmash.Grant(src)
	groundsmash.boss = src
	firewalls = new()
	firewalls.Grant(src)
	firewalls.boss = src
	lavarivers = new()
	lavarivers.Grant(src)
	lavarivers.boss = src
	SetLuminosity(10)



/mob/living/simple_animal/hostile/lavaboss/Move(NewLoc,Dir=0,step_x=0,step_y=0)
	..()
	var/turf/T = get_turf(NewLoc)
	if(!is_type_in_list(T,valid_turfs))
		T.ChangeTurf(/turf/simulated/floor/plating/asteroid/basalt/lava) //make the floor beneath it  magma-filled basalt
		for(var/atom/movable/AM in T)
			if(AM == src)
				AM.fire_act()


/mob/living/simple_animal/hostile/lavaboss/fire_act()
	heal_overall_damage(20,20)


/mob/living/simple_animal/hostile/lavaboss/ex_act(severity)
	var/boost = 4-severity //1,2,3
	heal_overall_damage(20*boost,20*boost)


/mob/living/simple_animal/hostile/lavaboss/handle_automated_action()
	. = ..()

	if(target && next_ability < world.time)
		var/groundsmash = 25 //simple damage+stun
		var/firewalls = 20 //temporary area denial
		var/lavarivers = 10 //permanent area denial

		if((get_dir(src,target) in list(SOUTH,EAST,WEST,NORTH)))
			firewalls += anger_modifier()

		if(get_dist(src,target) <= groundsmash_trigger_range)
			groundsmash += anger_modifier()

		lavarivers += anger_modifier()*1.5 //big boost, since it's already p.rare

		if(prob(groundsmash))
			ab_groundsmash()
			next_ability = world.time+50

		else if(prob(firewalls))
			ab_firewalls()
			next_ability = world.time+100

		else if(prob(lavarivers))
			ab_lavarivers()
			next_ability = world.time+200



/mob/living/simple_animal/hostile/lavaboss/adjustBruteLoss(damage)
	..()
	anger += damage


/mob/living/simple_animal/hostile/lavaboss/proc/anger_modifier()
	. = 0
	switch(anger)
		if(ANNOYED)
			. = 10
		if(ANGRY)
			. = 20
		if(PISSED)
			. = 30


/mob/living/simple_animal/hostile/lavaboss/proc/ab_groundsmash()
	notransform = TRUE
	stop_automated_movement = TRUE

	say("GRRRAWWWWWWWR")
	flick("lavaboss_groundsmash",src)

	spawn(12)
		var/list/atoms = ultra_range(5,src,1)

		for(var/turf/T in atoms)
			if(prob(25))
				if(!is_type_in_list(T,valid_turfs)) //dont convert existing turfs
					T.ChangeTurf(/turf/simulated/floor/plating/asteroid/basalt/lava)

				if(!istype(T,/turf/space)) //dont spawn rocks on space, -ever-
					new /obj/structure/flora/rock/lava_attack_rock(T)

		for(var/mob/M in atoms)
			shake_camera(M, 4, 2)


		notransform = FALSE
		stop_automated_movement = FALSE


/mob/living/simple_animal/hostile/lavaboss/proc/ab_firewalls()
	notransform = TRUE
	stop_automated_movement = TRUE

	say("ARRRRRGGGGRRRAARARRA")
	flick("lavaboss_firewalls",src)

	var/list/attack_dirs = list(NORTH,EAST,SOUTH,WEST)
	if(prob(50))
		attack_dirs = list(NORTH,WEST,SOUTH,EAST)

	spawn(0)
		for(var/d in attack_dirs)
			var/turf/E = get_edge_target_turf(src, d)
			var/range = 10
			for(var/turf/J in getline(src,E))
				if(!range)
					break
				range--

				PoolOrNew(/obj/effect/hotspot,J)
				J.hotspot_expose(700,50,1)

				sleep(0.5)

	sleep(7) //7 tick anim

	notransform = FALSE
	stop_automated_movement = FALSE


/mob/living/simple_animal/hostile/lavaboss/proc/ab_lavarivers()
	notransform = TRUE
	stop_automated_movement = TRUE

	say("BLURBUBLUBURRLRLRUBRL")
	flick("lavaboss_lavarivers",src)

	var/list/flow_ends = get_random_points_from(src,3,5,1)
	for(var/turf/T in flow_ends)
		for(var/turf/J in getline(src,T))
			if(!is_type_in_list(J,valid_turfs))
				J.ChangeTurf(/turf/simulated/floor/plating/lava/smooth)
			sleep(0.5)

	sleep(8.5) //10 tick anim, -3*0.5 sleep in creation

	notransform = FALSE
	stop_automated_movement = FALSE




/datum/action/lavaboss
	check_flags = AB_CHECK_ALIVE
	background_icon_state = "bg_lavaboss"
	var/mob/living/simple_animal/hostile/lavaboss/boss


/datum/action/lavaboss/Trigger()
	if(..())
		if(boss)
			if(boss.next_ability < world.time)
				return 1
		return 0

/datum/action/avaboss/groundsmash
	name = "Groundsmash"
	button_icon_state = "groundsmash"

/datum/action/lavaboss/groundsmash/Trigger()
	boss.ab_groundsmash()
	boss.next_ability = world.time+50


/datum/action/lavaboss/firewalls
	name = "Firewalls"
	button_icon_state = "firewalls"

/datum/action/lavaboss/firewalls/Trigger()
	boss.ab_firewalls()
	boss.next_ability = world.time+100


/datum/action/lavaboss/lavarivers
	name = "Lava rivers"
	button_icon_state = "lavarivers"

/datum/action/lavaboss/lavarivers/Trigger()
	boss.ab_lavarivers()
	boss.next_ability = world.time+200




/obj/structure/flora/rock/lava_attack_rock/New()
	..()
	spawn(10)
		var/turf/T = get_turf(src)
		for(var/atom/movable/AM in T.contents)
			AM.ex_act(1)

/obj/structure/flora/rock/lava_attack_rock/ex_act()
	return

*/