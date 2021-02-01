/mob/living/simple_animal/hostile/megafauna/lucift
	name = "Luciftvian"
	desc = "It's looking for beautiful things. And you fit the bill."
	icon = 'icons/mob/lucift.dmi'
	icon_state = "lucift"
	icon_living = "lucift"
	var/icon_battle = "luciftattackprep"
	var/icon_enraged = "luciftrage"
	var/icon_defeat = "luciftabouttodie"
	icon_dead = "luciftdead"
	AIStatus = AI_OFF
	maxHealth = 30000
	health = 30000
	gender = MALE
	armour_penetration = 10
	melee_damage_lower = 10
	melee_damage_upper = 10
	pixel_y = 0
	pixel_x= -80
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	speak_emote = list("states")
	movement_type = GROUND
	light_color = COLOR_WHITE
	light_range = 10
	weather_immunities = list("lava","ash")
	possible_a_intents = list(INTENT_HELP, INTENT_GRAB, INTENT_DISARM, INTENT_HARM)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 8
	move_to_delay = 8
	maxbodytemp = INFINITY
	del_on_death = FALSE
	rapid_melee = 16 // every 1/8 second
	melee_queue_distance = 20 // as far as possible really, need this because of charging and teleports
	ranged = TRUE
	blood_volume = BLOOD_VOLUME_NORMAL
	deathmessage = "slumps, finally peaceful."
	deathsound = 'sound/effects/gravhit.ogg'
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER
	light_power = 1
	light_range = 15
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	mouse_opacity = MOUSE_OPACITY_ICON
	footstep_type = FOOTSTEP_MOB_HEAVY
	attack_action_types = list(/datum/action/innate/megafauna_attack/heavy_stomp,
							   /datum/action/innate/megafauna_attack/teleport,
							   /datum/action/innate/megafauna_attack/lucift_summon)
	faction = list("boss", "lucift")
	var/BATTLESTART = FALSE
	var/ENRAGED = FALSE
	var/ABOUTTODIE = FALSE
	/// Saves the turf the megafauna was created at (spawns exit portal here)
	var/turf/starting
	/// Range for wendigo stomping when it moves
	var/stomp_range = 1
	/// Stores directions the mob is moving, then calls that a move has fully ended when these directions are removed in moved
	var/stored_move_dirs = 0
	/// If the wendigo is allowed to move
	var/can_move = TRUE
	/// Stores the last scream time so it doesn't spam it
	var/last_scream = 0

/datum/action/innate/megafauna_attack/heavy_stomp
	name = "Heavy Stomp"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = "<span class='colossus'>You are now stomping the ground around you.</span>"
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/teleport
	name = "Teleport"
	icon_icon = 'icons/effects/bubblegum.dmi'
	button_icon_state = "smack ya one"
	chosen_message = "<span class='colossus'>You are now teleporting at the target you click on.</span>"
	chosen_attack_num = 2


/datum/action/innate/megafauna_attack/lucift_summon
	name = "Summon"
	icon_icon = 'icons/turf/walls/wall.dmi'
	button_icon_state = "wall"
	chosen_message = "<span class='colossus'>You are now summoning your minions when you click.</span>"
	chosen_attack_num = 3

/mob/living/simple_animal/hostile/megafauna/lucift/Initialize()
	. = ..()
	starting = get_turf(src)

/mob/living/simple_animal/hostile/megafauna/lucift/Life()
	if(health < 29600)
		if(BATTLESTART == FALSE)
			icon_state = icon_battle
			armour_penetration = 30
			melee_damage_lower = 30
			melee_damage_upper = 40
			BATTLESTART = TRUE
		else if(health < 15000)
			if(ENRAGED == FALSE)
				icon_state = icon_enraged
				ENRAGED = TRUE
				armour_penetration = 30
				melee_damage_lower = 50
				melee_damage_upper = 70
			else if(health < 6000)
				if(ABOUTTODIE == FALSE)
					icon_state = icon_defeat
					ABOUTTODIE = TRUE
	if(!.)
		return
	if(target || get_dist(src, starting) < 12)
		return
	do_teleport(src, starting, 0,  channel=TELEPORT_CHANNEL_BLUESPACE, forced = TRUE)

/mob/living/simple_animal/hostile/megafauna/lucift/OpenFire()
	SetRecoveryTime(0, 100)
	if(health <= maxHealth*0.5)
		stomp_range = 2
		speed = 6
		move_to_delay = 6
	else
		stomp_range = initial(stomp_range)
		speed = initial(speed)
		move_to_delay = initial(move_to_delay)

	if(client)
		switch(chosen_attack)
			if(1)
				heavy_stomp()
			if(2)
				teleport()
			if(3)
				summon_synth1()
				summon_synth1()
				summon_synth1()
				summon_synth2()
				summon_synth2()
				summon_synth2()
				summon_synth3()

//mob/living/simple_animal/hostile/megafauna/lucift/Life()
//	. = ..()
//	if(!.)
//		return
//	if(target || get_dist(src, starting) < 12)
//		return
//	do_teleport(src, starting, 0,  channel=TELEPORT_CHANNEL_BLUESPACE, forced = TRUE)

/mob/living/simple_animal/hostile/megafauna/lucift/Move(atom/newloc, direct)
	if(!can_move)
		return
	stored_move_dirs |= direct
	return ..()

/mob/living/simple_animal/hostile/megafauna/lucift/Moved(atom/OldLoc, direct, Dir, Forced = FALSE)
	. = ..()
	stored_move_dirs &= ~direct
	if(!stored_move_dirs)
		INVOKE_ASYNC(src, .proc/ground_slam, stomp_range, 1)
	if(Dir)
		new /obj/effect/decal/cleanable/oil(src.loc)
	playsound(src, 'sound/effects/meteorimpact.ogg', 200, TRUE, 2, TRUE)
	return ..()

//mob/living/simple_animal/hostile/megafauna/lucift/Bump(atom/A)
//	SSexplosions.medturf += A
//	DestroySurroundings()
//	if(isliving(A))
//		var/mob/living/L = A
//		L.visible_message("<span class='danger'>[src] slams into [L]!</span>", "<span class='userdanger'>[src] tramples you into the ground!</span>")
//		src.forceMove(get_turf(L))
//		playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, TRUE)
//		shake_camera(L, 4, 3)
//		L.apply_damage(30, BRUTE, wound_bonus=CANT_WOUND)
//		shake_camera(src, 2, 3)
//	..()

/// Slams the ground around the wendigo throwing back enemies caught nearby
/mob/living/simple_animal/hostile/megafauna/lucift/proc/ground_slam(range, delay)
	var/turf/orgin = get_turf(src)
	var/list/all_turfs = RANGE_TURFS(range, orgin)
	for(var/i = 0 to range)
		for(var/turf/T in all_turfs)
			if(get_dist(orgin, T) > i)
				continue
			playsound(T,'sound/effects/bamf.ogg', 600, TRUE, 10)
			new /obj/effect/temp_visual/small_smoke/halfsecond(T)
			for(var/mob/living/L in T)
				if(L == src || L.throwing)
					continue
				to_chat(L, "<span class='userdanger'>[src]'s ground slam shockwave sends you flying!</span>")
				var/turf/thrownat = get_ranged_target_turf_direct(src, L, 8, rand(-10, 10))
				L.throw_at(thrownat, 8, 2, src, TRUE, force = MOVE_FORCE_OVERPOWERING, gentle = TRUE)
				L.apply_damage(20, BRUTE, wound_bonus=CANT_WOUND)
				shake_camera(L, 2, 1)
			all_turfs -= T

/// Larger but slower ground stomp
/mob/living/simple_animal/hostile/megafauna/lucift/proc/heavy_stomp()
	can_move = FALSE
	ground_slam(5, 2)
	SetRecoveryTime(0, 0)
	can_move = TRUE

/// Teleports to a location 4 turfs away from the enemy in view
/mob/living/simple_animal/hostile/megafauna/lucift/proc/teleport()
	var/list/possible_ends = list()
	for(var/turf/T in view(4, target.loc) - view(3, target.loc))
		if(isclosedturf(T))
			continue
		possible_ends |= T
	var/turf/end = pick(possible_ends)
	do_teleport(src, end, 0,  channel=TELEPORT_CHANNEL_BLUESPACE, forced = TRUE)
	SetRecoveryTime(20, 0)

/mob/living/simple_animal/hostile/megafauna/lucift/proc/summon_synth3()
	for(var/mob/living/L in get_hearers_in_view(7, src) - src)
		to_chat(L, "<span class='danger'>Luciftvian lets loose his minions!</span>")
	var/mob/living/simple_animal/hostile/lucift/petasia/A = new(loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction

/mob/living/simple_animal/hostile/megafauna/lucift/proc/summon_synth2()
	var/mob/living/simple_animal/hostile/lucift/gello/A = new(loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction

/mob/living/simple_animal/hostile/megafauna/lucift/proc/summon_synth1()
	var/mob/living/simple_animal/hostile/lucift/byzo/A = new(loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction

/// Applies dizziness to all nearby enemies that can hear the scream and animates the wendigo shaking up and down
/mob/living/simple_animal/hostile/megafauna/lucift/proc/lucift_scream()
	can_move = FALSE
	last_scream = world.time
	playsound(src, 'sound/magic/demon_dies.ogg', 600, FALSE, 10)
	animate(src, pixel_z = rand(5, 15), time = 1, loop = 6)
	animate(pixel_z = 0, time = 1)
	for(var/mob/living/L in get_hearers_in_view(7, src) - src)
		L.Dizzy(6)
		to_chat(L, "<span class='danger'>Luciftvian screams loudly!</span>")
	SetRecoveryTime(30, 0)
	SLEEP_CHECK_DEATH(12)
	can_move = TRUE
	teleport()
