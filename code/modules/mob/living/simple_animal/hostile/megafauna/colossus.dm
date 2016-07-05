/mob/living/simple_animal/hostile/megafauna/colossus
	name = "colossus"
	desc = "A monstrous creature protected by heavy shielding."
	health = 2500
	maxHealth = 2500
	attacktext = "judges"
	attack_sound = 'sound/magic/clockwork/ratvar_attack.ogg'
	icon_state = "eva"
	icon_living = "eva"
	icon_dead = "dragon_dead"
	friendly = "stares down"
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	faction = list("mining")
	weather_immunities = list("lava","ash")
	speak_emote = list("roars")
	luminosity = 3
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 1
	move_to_delay = 10
	ranged = 1
	flying = 1
	mob_size = MOB_SIZE_LARGE
	pixel_x = -32
	aggro_vision_range = 18
	idle_vision_range = 5
	del_on_death = 1
	loot = list(/obj/machinery/smartfridge/black_box)
	butcher_results = list(/obj/item/weapon/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/animalhide/ashdrake = 10, /obj/item/stack/sheet/bone = 30)

	deathmessage = "disintegrates, leaving a glowing core in its wake."
	death_sound = 'sound/magic/demon_dies.ogg'
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	var/anger_modifier = 0
	var/obj/item/device/gps/internal


/mob/living/simple_animal/hostile/megafauna/colossus/AttackingTarget()
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat == DEAD)
			src.visible_message("<span class='danger'>[src] disintegrates [L]!</span>")
			L.dust()

/mob/living/simple_animal/hostile/megafauna/colossus/OpenFire()
	anger_modifier = Clamp(((maxHealth - health)/50),0,20)
	ranged_cooldown = world.time + 120

	if(prob(20+anger_modifier)) //Major attack
		telegraph()

		if(health < maxHealth/3)
			double_spiral()
		else
			visible_message("<span class='cult'><font size=5>\"<b>Judgement.</b>\"</font></span>")
			if(prob(50))
				spiral_shoot()
			else
				spiral_shoot(1)

	else if(prob(20))
		ranged_cooldown = world.time + 30
		random_shots()
	else
		if(prob(70))
			ranged_cooldown = world.time + 20
			blast()
		else
			ranged_cooldown = world.time + 40
			diagonals()
			sleep(10)
			cardinals()
			sleep(10)
			diagonals()
			sleep(10)
			cardinals()


/mob/living/simple_animal/hostile/megafauna/colossus/New()
	..()
	internal = new/obj/item/device/gps/internal/colossus(src)

/mob/living/simple_animal/hostile/megafauna/colossus/Destroy()
	qdel(internal)
	. = ..()

/obj/effect/overlay/temp/at_shield
	name = "anti-toolbox field"
	desc = "A shimmering forcefield protecting the colossus."
	icon = 'icons/effects/effects.dmi'
	icon_state = "at_shield2"
	layer = FLY_LAYER
	luminosity = 2
	duration = 8
	var/target

/obj/effect/overlay/temp/at_shield/New(new_loc, new_target)
	..()
	target = new_target
	addtimer(src, "orbit", 0, FALSE, target, 0, FALSE, 0, 0, FALSE, TRUE)

/mob/living/simple_animal/hostile/megafauna/colossus/bullet_act(obj/item/projectile/P)
	if(!stat)
		var/obj/effect/overlay/temp/at_shield/AT = PoolOrNew(/obj/effect/overlay/temp/at_shield, src.loc, src)
		var/random_x = rand(-32, 32)
		AT.pixel_x += random_x

		var/random_y = rand(0, 72)
		AT.pixel_y += random_y
	..()


/mob/living/simple_animal/hostile/megafauna/colossus/proc/double_spiral()
	visible_message("<span class='cult'><font size=5>\"<b>Die.</b>\"</font></span>")

	sleep(10)
	addtimer(src, "spiral_shoot", 0)
	addtimer(src, "spiral_shoot", 0, FALSE, 1)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/spiral_shoot(negative = 0)
	var/counter = 1
	var/turf/marker
	for(var/i in 1 to 80)
		switch(counter)
			if(1)
				marker = locate(x,y - 2,z)
			if(2)
				marker = locate(x - 1,y - 2,z)
			if(3)
				marker = locate(x - 2, y - 2,z)
			if(4)
				marker = locate(x - 2,y - 1,z)
			if(5)
				marker = locate (x -2 ,y,z)
			if(6)
				marker = locate(x - 2, y+1,z)
			if(7)
				marker = locate(x - 2, y + 2, z)
			if(8)
				marker = locate(x - 1, y + 2,z)
			if(9)
				marker = locate(x, y + 2,z)
			if(10)
				marker = locate(x + 1, y+2,z)
			if(11)
				marker = locate(x+ 2, y + 2,z)
			if(12)
				marker = locate(x+2,y+1,z)
			if(13)
				marker = locate(x+2,y,z)
			if(14)
				marker = locate(x+2, y - 1, z)
			if(15)
				marker = locate(x+2, y - 2, z)
			if(16)
				marker = locate(x+1, y -2, z)

		if(negative)
			counter--
		else
			counter++
		if(counter > 16)
			counter = 0
		if(counter < 0)
			counter = 16
		shoot_projectile(marker)
		sleep(1)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/shoot_projectile(turf/marker)
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/colossus(startloc)
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 100, 1)
	P.current = startloc
	P.starting = startloc
	P.firer = src
	P.yo = marker.y - startloc.y
	P.xo = marker.x - startloc.x
	P.original = marker
	P.fire()

/mob/living/simple_animal/hostile/megafauna/colossus/proc/random_shots()
	for(var/turf/turf in range(12,get_turf(src)))
		if(prob(5))
			shoot_projectile(turf)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/blast()
	for(var/turf/turf in range(1, target))
		shoot_projectile(turf)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/diagonals()
	var/turf/T = locate(x + 2, y + 2, z)
	shoot_projectile(T)
	T = locate(x + 2, y  -2, z)
	shoot_projectile(T)
	T = locate(x - 2, y + 2, z)
	shoot_projectile(T)
	T = locate(x - 2, y - 2, z)
	shoot_projectile(T)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/cardinals()
	var/list/attack_dirs = list(NORTH,EAST,SOUTH,WEST)
	for(var/d in attack_dirs)
		var/turf/E = get_edge_target_turf(src, d)
		shoot_projectile(E)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/telegraph()
	for(var/mob/M in range(10,src))
		if(M.client)
			flash_color(M.client, rgb(200, 0, 0), 1)
			shake_camera(M, 4, 3)
	playsound(get_turf(src),'sound/magic/clockwork/narsie_attack.ogg', 200, 1)



/obj/item/projectile/colossus
	name ="death bolt"
	icon_state= "chronobolt"
	damage = 25
	armour_penetration = 100
	speed = 2
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE

/obj/item/projectile/colossus/on_hit(atom/target, blocked = 0)
	. = ..()
	if(istype(target,/turf/)||istype(target,/obj/structure/))
		target.ex_act(2)


/obj/item/device/gps/internal/colossus
	icon_state = null
	gpstag = "Angelic Signal"
	desc = "Get in the fucking robot."
	invisibility = 100



//Black Box

/obj/machinery/smartfridge/black_box
	name = "black box"
	desc = "A completely indestructible chunk of crystal, rumoured to predate the start of this universe. It looks like you could store things inside it."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_on = "blackbox"
	icon_off = "blackbox"
	luminosity = 8
	max_n_of_items = 200
	pixel_y = -4
	use_power = 0
	var/duplicate = FALSE
	var/memory_saved = FALSE
	var/list/stored_items = list()
	var/list/blacklist = (/obj/item/weapon/spellbook)

/obj/machinery/smartfridge/black_box/accept_check(obj/item/O)
	if(O.type in blacklist)
		return
	if(istype(O, /obj/item))
		return 1
	return 0

/obj/machinery/smartfridge/black_box/New()
	..()
	for(var/obj/machinery/smartfridge/black_box/B in machines)
		if(B != src)
			duplicate = 1
			qdel(src)
	ReadMemory()

/obj/machinery/smartfridge/black_box/process()
	..()
	if(ticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		WriteMemory()

/obj/machinery/smartfridge/black_box/proc/WriteMemory()
	var/savefile/S = new /savefile("data/npc_saves/Blackbox.sav")
	stored_items = list()
	for(var/obj/I in component_parts)
		qdel(I)
	for(var/obj/O in contents)
		stored_items += O.type
	S["stored_items"]				<< stored_items
	memory_saved = TRUE

/obj/machinery/smartfridge/black_box/proc/ReadMemory()
	var/savefile/S = new /savefile("data/npc_saves/Blackbox.sav")
	S["stored_items"] 		>> stored_items

	if(isnull(stored_items))
		stored_items = list()

	for(var/item in stored_items)
		new item(src)


/obj/machinery/smartfridge/black_box/Destroy()
	if(duplicate)
		return ..()
	else
		return QDEL_HINT_LETMELIVE


//No taking it apart

/obj/machinery/smartfridge/black_box/default_deconstruction_screwdriver()
	return

/obj/machinery/smartfridge/black_box/exchange_parts()
	return


/obj/machinery/smartfridge/black_box/default_pry_open()
	return


/obj/machinery/smartfridge/black_box/default_unfasten_wrench()
	return

/obj/machinery/smartfridge/black_box/default_deconstruction_crowbar()
	return
