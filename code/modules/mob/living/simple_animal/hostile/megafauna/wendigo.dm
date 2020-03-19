/*

Difficulty: Very Hard

*/

/mob/living/simple_animal/hostile/megafauna/wendigo
	name = "wendigo"
	desc = "A mythological man-eating legendary creature, you probably aren't going to survive this."
	health = 2500
	maxHealth = 2500
	icon_state = "wendigo"
	icon_living = "wendigo"
	icon_dead = "wendigo_dead"
	icon = 'icons/mob/icemoon/64x64megafauna.dmi'
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	weather_immunities = list("snow")
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	vision_range = 9
	aggro_vision_range = 18 // man-eating for a reason
	speed = 8
	move_to_delay = 8
	rapid_melee = 16 // every 1/8 second
	melee_queue_distance = 20 // as far as possible really, need this because of charging and teleports
	ranged = TRUE
	pixel_x = -16
	crusher_loot = list()
	loot = list()
	butcher_results = list()
	guaranteed_butcher_results = list()
	wander = FALSE
	del_on_death = FALSE
	blood_volume = BLOOD_VOLUME_NORMAL
	achievement_type = /datum/award/achievement/boss/wendigo_kill
	crusher_achievement_type = /datum/award/achievement/boss/wendigo_crusher
	score_achievement_type = /datum/award/score/wendigo_score
	deathmessage = "falls, shaking the ground around it"
	deathsound = 'sound/effects/gravhit.ogg'
	footstep_type = FOOTSTEP_MOB_HEAVY
	attack_action_types = list(/datum/action/innate/megafauna_attack/heavy_stomp,
							   /datum/action/innate/megafauna_attack/teleport_charge,
							   /datum/action/innate/megafauna_attack/disorienting_scream)
	var/turf/starting
	var/stomp_range = 1
	var/stored_move_dirs = 0
	var/can_move = TRUE

/datum/action/innate/megafauna_attack/heavy_stomp
	name = "Heavy Stomp"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = "<span class='colossus'>You are now stomping the ground around you.</span>"
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/teleport_charge
	name = "Teleport Charge"
	icon_icon = 'icons/effects/bubblegum.dmi'
	button_icon_state = "smack ya one"
	chosen_message = "<span class='colossus'>You are now teleport charging at the target you click on.</span>"
	chosen_attack_num = 2

/datum/action/innate/megafauna_attack/disorienting_scream
	name = "Disorienting Scream"
	icon_icon = 'icons/turf/walls/wall.dmi'
	button_icon_state = "wall"
	chosen_message = "<span class='colossus'>You are now screeching, disorienting targets around you.</span>"
	chosen_attack_num = 3

/mob/living/simple_animal/hostile/megafauna/wendigo/Initialize()
	. = ..()
	starting = get_turf(src)

/mob/living/simple_animal/hostile/megafauna/wendigo/OpenFire()
	SetRecoveryTime(0, 100)

	if(client)
		switch(chosen_attack)
			if(1)
				heavy_stomp()
			if(2)
				teleport_charge()
			if(3)
				disorienting_scream()
		return

	chosen_attack = rand(1, 3)
	if(health >= maxHealth*0.5)
		switch(chosen_attack)
			if(1)
				heavy_stomp()
			if(2)
				teleport_charge()
			if(3)
				disorienting_scream()
	else
		switch(chosen_attack)
			if(1)
				heavy_stomp()
			if(2)
				teleport_charge()
			if(3)
				disorienting_scream()

/mob/living/simple_animal/hostile/megafauna/wendigo/Move(atom/newloc, direct)
	if(!can_move)
		return
	stored_move_dirs |= direct
	. = ..()

/mob/living/simple_animal/hostile/megafauna/wendigo/Moved(atom/oldloc, direct)
	. = ..()
	stored_move_dirs &= ~direct
	if(!stored_move_dirs)
		INVOKE_ASYNC(src, .proc/ground_slam, stomp_range, 1)

/mob/living/simple_animal/hostile/megafauna/wendigo/proc/ground_slam(range, delay)
	var/turf/orgin = get_turf(src)
	var/list/all_turfs = RANGE_TURFS(range, orgin)
	for(var/i = 0 to range)
		for(var/turf/T in all_turfs)
			if(get_dist(orgin, T) > i)
				continue
			playsound(T,'sound/effects/bamf.ogg', 600, 1, 10)
			new /obj/effect/temp_visual/small_smoke/halfsecond(T)
			for(var/mob/living/L in T)
				if(L == src || L.throwing)
					continue
				to_chat(L, "<span class='userdanger'>[src]'s ground slam shockwave sends you flying!</span>")
				var/turf/thrownat = get_ranged_target_turf_direct(src, L, 8, rand(-10, 10))
				L.throw_at(thrownat, 8, 2, src, TRUE, force = MOVE_FORCE_OVERPOWERING, gentle = TRUE)
				L.apply_damage(20, BRUTE)
				shake_camera(L, 2, 1)
			all_turfs -= T
		sleep(delay)
	return

/mob/living/simple_animal/hostile/megafauna/wendigo/proc/heavy_stomp()
	can_move = FALSE
	ground_slam(5, 2)
	SetRecoveryTime(0, 0)
	can_move = TRUE

/mob/living/simple_animal/hostile/megafauna/wendigo/proc/teleport_charge()
	return

/mob/living/simple_animal/hostile/megafauna/wendigo/proc/disorienting_scream()
	return

/mob/living/simple_animal/hostile/megafauna/wendigo/death(gibbed, list/force_grant)
	if(health > 0)
		return
	else
		var/obj/effect/portal/permanent/one_way/exit = new /obj/effect/portal/permanent/one_way(starting)
		exit.id = "wendigo arena exit"
		exit.add_atom_colour(COLOR_RED_LIGHT, ADMIN_COLOUR_PRIORITY)
		exit.set_light(20, 1, LIGHT_COLOR_RED)
		. = ..()
