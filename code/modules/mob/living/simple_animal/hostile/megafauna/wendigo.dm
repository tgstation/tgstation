#define WENDIGO_ENRAGED (health <= maxHealth*0.5)

/*

Difficulty: Hard

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
	speed = 6
	move_to_delay = 6
	rapid_melee = 8 // every 1/4 second
	melee_queue_distance = 20 // as far as possible really, need this because of charging and teleports
	ranged = TRUE
	pixel_x = -16
	gps_name = "Berserk Signal"
	loot = list()
	butcher_results = list()
	guaranteed_butcher_results = list(/obj/item/wendigo_blood = 1, /obj/item/wendigo_skull = 1)
	crusher_loot = list(/obj/item/crusher_trophy/wendigo_horn)
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
							   /datum/action/innate/megafauna_attack/teleport,
							   /datum/action/innate/megafauna_attack/shockwave_scream)
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

/datum/action/innate/megafauna_attack/shockwave_scream
	name = "Shockwave Scream"
	icon_icon = 'icons/turf/walls/wall.dmi'
	button_icon_state = "wall"
	chosen_message = "<span class='colossus'>You are now screeching, sending out shockwaves of sound.</span>"
	chosen_attack_num = 3

/mob/living/simple_animal/hostile/megafauna/wendigo/Initialize()
	. = ..()
	starting = get_turf(src)

/mob/living/simple_animal/hostile/megafauna/wendigo/OpenFire()
	SetRecoveryTime(100)
	if(WENDIGO_ENRAGED)
		speed = 4
		move_to_delay = 4
	else
		stomp_range = initial(stomp_range)
		speed = initial(speed)
		move_to_delay = initial(move_to_delay)

	if(client)
		switch(chosen_attack)
			if(1)
				heavy_stomp()
			if(2)
				try_teleport()
			if(3)
				shockwave_scream()
		return

	if(world.time > last_scream + 100)
		chosen_attack = rand(1, 3)
	else
		chosen_attack = rand(1, 2)
	switch(chosen_attack)
		if(1)
			heavy_stomp()
		if(2)
			try_teleport()
		if(3)
			do_teleport(src, starting, 0,  channel=TELEPORT_CHANNEL_BLUESPACE, forced = TRUE)
			shockwave_scream()

/mob/living/simple_animal/hostile/megafauna/wendigo/Move(atom/newloc, direct)
	if(!can_move)
		return
	stored_move_dirs |= direct
	return ..()

/mob/living/simple_animal/hostile/megafauna/wendigo/Moved(atom/oldloc, direct)
	. = ..()
	stored_move_dirs &= ~direct
	if(!stored_move_dirs)
		INVOKE_ASYNC(GLOBAL_PROC, .proc/wendigo_slam, src, stomp_range, 1, 8)

/// Slams the ground around the source throwing back enemies caught nearby, delay is for the radius increase
/proc/wendigo_slam(atom/source, range, delay, throw_range)
	var/turf/orgin = get_turf(source)
	var/list/all_turfs = RANGE_TURFS(range, orgin)
	for(var/i = 0 to range)
		playsound(orgin,'sound/effects/bamf.ogg', 600, TRUE, 10)
		for(var/turf/T in all_turfs)
			if(get_dist(orgin, T) > i)
				continue
			new /obj/effect/temp_visual/small_smoke/halfsecond(T)
			for(var/mob/living/L in T)
				if(L == source || L.throwing)
					continue
				to_chat(L, "<span class='userdanger'>[source]'s ground slam shockwave sends you flying!</span>")
				var/turf/thrownat = get_ranged_target_turf_direct(source, L, throw_range, rand(-10, 10))
				L.throw_at(thrownat, 8, 2, src, TRUE, force = MOVE_FORCE_OVERPOWERING, gentle = TRUE)
				L.apply_damage(20, BRUTE, wound_bonus=CANT_WOUND)
				shake_camera(L, 2, 1)
			all_turfs -= T
		sleep(delay)

/// Larger but slower ground stomp
/mob/living/simple_animal/hostile/megafauna/wendigo/proc/heavy_stomp()
	can_move = FALSE
	wendigo_slam(src, 5, 3 - WENDIGO_ENRAGED, 8)
	SetRecoveryTime(0)
	can_move = TRUE

/// Teleports to a location 4 turfs away from the enemy in view
/mob/living/simple_animal/hostile/megafauna/wendigo/proc/try_teleport()
	teleport(6)
	if(WENDIGO_ENRAGED)
		playsound(src.loc, 'sound/magic/clockwork/invoke_general.ogg', 100, TRUE)
		for(var/shots in 1 to 5)
			var/spread = shots * 10 - 30
			var/turf/startloc = get_step(get_turf(src), get_dir(src, target))
			var/turf/endloc = get_turf(target)
			if(!endloc)
				break
			var/obj/projectile/wendigo_shockwave/P = new /obj/projectile/wendigo_shockwave(src.loc)
			P.speed = 8
			P.preparePixelProjectile(endloc, startloc, null, spread)
			P.firer = src
			if(target)
				P.original = target
			P.fire()
	SetRecoveryTime(0)

/mob/living/simple_animal/hostile/megafauna/wendigo/proc/teleport(range = 6)
	var/list/possible_ends = view(range, target.loc) - view(range - 1, target.loc)
	for(var/turf/T in possible_ends)
		if(isopenturf(T))
			continue
		possible_ends -= T
	if(!possible_ends.len)
		return
	var/turf/end = pick(possible_ends)
	do_teleport(src, end, 0,  channel=TELEPORT_CHANNEL_BLUESPACE, forced = TRUE)

/// Applies dizziness to all nearby enemies that can hear the scream and animates the wendigo shaking up and down as shockwave projectiles shoot outward
/mob/living/simple_animal/hostile/megafauna/wendigo/proc/shockwave_scream()
	can_move = FALSE
	last_scream = world.time
	SLEEP_CHECK_DEATH(5)
	playsound(src, 'sound/magic/demon_dies.ogg', 600, FALSE, 10)
	animate(src, pixel_z = rand(5, 15), time = 1, loop = 20)
	animate(pixel_z = 0, time = 1)
	for(var/mob/living/L in get_hearers_in_view(7, src) - src)
		L.Dizzy(6)
		to_chat(L, "<span class='danger'>The wendigo screams loudly!</span>")
	SLEEP_CHECK_DEATH(10)
	spiral_attack()
	SetRecoveryTime(30)
	SLEEP_CHECK_DEATH(30)
	can_move = TRUE

/// Shoots shockwave projectiles in a random preset pattern
/mob/living/simple_animal/hostile/megafauna/wendigo/proc/spiral_attack()
	var/list/choices = list("Alternating Circle", "Spiral")
	if(WENDIGO_ENRAGED)
		choices += "Wave"
	var/spiral_type = pick(choices)
	switch(spiral_type)
		if("Alternating Circle")
			var/shots_per = 24
			for(var/shoot_times in 1 to 8)
				var/offset = shoot_times % 2
				for(var/shot in 1 to shots_per)
					var/angle = shot * 360 / shots_per + (offset * 360 / shots_per) * 0.5
					var/obj/projectile/wendigo_shockwave/P = new /obj/projectile/wendigo_shockwave(src.loc)
					P.firer = src
					P.speed = 3 - WENDIGO_ENRAGED
					P.fire(angle)
				SLEEP_CHECK_DEATH(6 - WENDIGO_ENRAGED * 2)
		if("Spiral")
			var/shots_spiral = 40
			var/angle_to_target = Get_Angle(src, target)
			var/spiral_direction = pick(-1, 1)
			for(var/shot in 1 to shots_spiral)
				var/shots_per_tick = 5 - WENDIGO_ENRAGED * 3
				var/angle_change = (5 + WENDIGO_ENRAGED * shot / 6) * spiral_direction
				for(var/count in 1 to shots_per_tick)
					var/angle = angle_to_target + shot * angle_change + count * 360 / shots_per_tick
					var/obj/projectile/wendigo_shockwave/P = new /obj/projectile/wendigo_shockwave(src.loc)
					P.firer = src
					P.damage = 15
					P.fire(angle)
				SLEEP_CHECK_DEATH(1)
		if("Wave")
			var/shots_per = 7
			var/difference = 360 / shots_per
			var/wave_direction = pick(-1, 1)
			for(var/shoot_times in 1 to 32)
				for(var/shot in 1 to shots_per)
					var/angle = shot * difference + shoot_times * 5 * wave_direction * -1
					var/obj/projectile/wendigo_shockwave/P = new /obj/projectile/wendigo_shockwave(src.loc)
					P.firer = src
					P.wave_movement = TRUE
					P.speed = 8
					P.wave_speed = 10 * wave_direction
					P.fire(angle)
				SLEEP_CHECK_DEATH(2)

/mob/living/simple_animal/hostile/megafauna/wendigo/death(gibbed, list/force_grant)
	if(health > 0)
		return
	var/obj/effect/portal/permanent/one_way/exit = new /obj/effect/portal/permanent/one_way(starting)
	exit.id = "wendigo arena exit"
	exit.add_atom_colour(COLOR_RED_LIGHT, ADMIN_COLOUR_PRIORITY)
	exit.set_light(20, 1, COLOR_SOFT_RED)
	return ..()

/obj/projectile/wendigo_shockwave
	name ="wendigo shockwave"
	icon_state= "chronobolt"
	damage = 25
	armour_penetration = 100
	speed = 2
	eyeblur = 5
	damage_type = BRUTE
	pass_flags = PASSTABLE
	/// If wave movement is enabled
	var/wave_movement = FALSE
	/// Amount the angle changes every pixel move
	var/wave_speed = 15
	/// Amount of movements this projectile has made
	var/pixel_moves = 0

/obj/projectile/wendigo_shockwave/pixel_move(trajectory_multiplier, hitscanning = FALSE)
	. = ..()
	if(wave_movement)
		pixel_moves++
		setAngle(original_angle + pixel_moves * wave_speed)

/obj/item/wendigo_blood
	name = "bottle of wendigo blood"
	desc = "You're not actually going to drink this, are you?"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/wendigo_blood/attack_self(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(!H.mind)
		return
	to_chat(H, "<span class='danger'>Power courses through you! You can now shift your form at will.</span>")
	var/obj/effect/proc_holder/spell/targeted/shapeshift/polar_bear/P = new
	H.mind.AddSpell(P)
	playsound(H.loc,'sound/items/drink.ogg', rand(10,50), TRUE)
	qdel(src)

/obj/effect/proc_holder/spell/targeted/shapeshift/polar_bear
	name = "Polar Bear Form"
	desc = "Take on the shape of a polar bear."
	invocation = "RAAAAAAAAWR!"
	convert_damage = FALSE
	shapeshift_type = /mob/living/simple_animal/hostile/asteroid/polarbear/lesser

/obj/item/crusher_trophy/wendigo_horn
	name = "wendigo horn"
	desc = "A horn from the head of an unstoppable beast."
	icon_state = "wendigo_horn"
	denied_type = /obj/item/crusher_trophy/wendigo_horn

/obj/item/crusher_trophy/wendigo_horn/effect_desc()
	return "melee hits inflict twice as much damage"

/obj/item/crusher_trophy/wendigo_horn/add_to(obj/item/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.AddComponent(/datum/component/two_handed, force_wielded=40)

/obj/item/crusher_trophy/wendigo_horn/remove_from(obj/item/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.AddComponent(/datum/component/two_handed, force_wielded=20)

/obj/item/wendigo_skull
	name = "wendigo skull"
	desc = "A skull of a massive hulking beast."
	icon = 'icons/obj/ice_moon/artifacts.dmi'
	icon_state = "wendigo_skull"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
