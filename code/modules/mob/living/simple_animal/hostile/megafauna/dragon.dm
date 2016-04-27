/mob/living/simple_animal/hostile/megafauna/dragon
	name = "ash drake"
	desc = "Guardians of the necropolis."
	health = 2000
	maxHealth = 2000
	attacktext = "chomps"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	icon_state = "dragon"
	icon_living = "dragon"
	friendly = "stares down"
	icon = 'icons/mob/lavaland/dragon.dmi'
	faction = list("mining")
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 1
	move_to_delay = 10
	ranged = 1
	flying = 1
	aggro_vision_range = 18
	idle_vision_range = 5
	del_on_death = 1
	var/anger_modifier = 0
	var/obj/item/device/gps/internal
	var/swooping = 0

/mob/living/simple_animal/hostile/megafauna/dragon/New()
	..()
	internal = new/obj/item/device/gps/internal/dragon(src)

/mob/living/simple_animal/hostile/megafauna/dragon/death(gibbed)
	if(can_die)
		qdel(internal)
	playsound(get_turf(src),'sound/magic/demon_dies.ogg', 200, 1)
	..()

/mob/living/simple_animal/hostile/megafauna/dragon/AttackingTarget()
	if(swooping)
		return
	else
		..()

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
	luminosity = 2

/obj/effect/overlay/temp/target/ex_act()
	return

/obj/effect/overlay/temp/target/New()
	..()
	spawn()
		var/turf/T = get_turf(src)
		playsound(get_turf(src),'sound/magic/Fireball.ogg', 200, 1)
		var/obj/effect/overlay/temp/fireball/F = new(src.loc)
		animate(F, pixel_z = 0, time = 12)
		sleep(12)
		explosion(T, 0, 0, 1, 0, 1, 1)
		qdel(F)
		qdel(src)

/mob/living/simple_animal/hostile/megafauna/dragon/OpenFire()
	anger_modifier = Clamp(((maxHealth - health)/50),0,20)
	ranged_cooldown = world.time + ranged_cooldown_time

	if(prob(15 + anger_modifier))
		if(health > maxHealth/2)
			fire_rain()
		else
			swoop_attack(1)

	else if(prob(10+anger_modifier))
		if(health > maxHealth/2)
			swoop_attack()
		else
			swoop_attack()
			swoop_attack()
			swoop_attack()
	else
		fire_walls()

/mob/living/simple_animal/hostile/megafauna/dragon/proc/fire_rain()
	for(var/turf/turf in range(12,get_turf(src)))
		if(prob(5))
			new /obj/effect/overlay/temp/target(turf)


/mob/living/simple_animal/hostile/megafauna/dragon/proc/fire_walls()
	var/list/attack_dirs = list(NORTH,EAST,SOUTH,WEST)
	if(prob(50))
		attack_dirs = list(NORTH,WEST,SOUTH,EAST)
	playsound(get_turf(src),'sound/magic/Fireball.ogg', 200, 1)

	spawn(0)
		for(var/d in attack_dirs)
			var/turf/E = get_edge_target_turf(src, d)
			var/range = 10
			for(var/turf/open/J in getline(src,E))
				if(!range)
					break
				range--

				PoolOrNew(/obj/effect/hotspot,J)
				J.hotspot_expose(700,50,1)

/mob/living/simple_animal/hostile/megafauna/dragon/proc/swoop_attack(fire_rain = 0)
	if(stat)
		return
	var/mob/living/swoop_target = target
	stop_automated_movement = TRUE
	swooping = 1
	icon_state = "swoop"
	if(prob(50))
		animate(src, pixel_x = 500, pixel_z = 500, time = 10)
	else
		animate(src, pixel_x = -500, pixel_z = 500, time = 10)
	sleep(30)

	var/turf/tturf
	if(fire_rain)
		fire_rain()

	icon_state = "dragon"
	if(swoop_target)
		tturf = get_turf(swoop_target)
	else
		tturf = get_turf(src)
	src.loc = tturf
	animate(src, pixel_x = 0, pixel_z = 0, time = 10)
	sleep(10)
	playsound(src, 'sound/effects/meteorimpact.ogg', 200, 1)
	for(var/mob/living/L in range(1,tturf))
		L.gib()
	for(var/mob/M in range(7,src))
		shake_camera(M, 15, 1)

	stop_automated_movement = FALSE
	swooping = 0

/obj/item/device/gps/internal/dragon
	icon_state = null
	gpstag = "Fiery Signal"
	desc = "Here there be dragons."
	invisibility = 100