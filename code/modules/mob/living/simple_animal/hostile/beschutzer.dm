#define FERAL_ATTACK_NEUTRAL 0
#define FERAL_ATTACK_WARMUP 1
#define FERAL_ATTACK_ACTIVE 2
#define FERAL_ATTACK_RECOVERY 3
#define ATTACK_INTERMISSION_TIME 5

/mob/living/simple_animal/hostile/beschutzer
	name = "Beschützer"
	desc = "Love suffereth all things, And we, Out of the travail and pain of our striving, Bring unto Thee the perfect prayer: For the lips of no man utter love, Suffering even for love's sake."
	icon = 'icons/mob/beschutzer.dmi'
	icon_state = "beschutzer"
	icon_living = "beschutzer"
	icon_dead = "beschutzer_dead"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	pixel_x = -16
	speak_emote = list("screeches")
	maxHealth = 10000
	health = 10000
	melee_damage_lower = 30
	melee_damage_upper = 30
	pixel_y = 0
	ventcrawler = VENTCRAWLER_ALWAYS
	initial_language_holder = /datum/language_holder/spiritual
	see_in_dark = 8
	ranged = TRUE
	ranged_cooldown_time = 10
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER
	blood_volume = BLOOD_VOLUME_MAXIMUM
	friendly_verb_continuous = "stares"
	friendly_verb_simple = "stare"
	response_help_continuous = "pats"
	response_help_simple = "pat"
	pass_flags = LETPASSTHROW
	robust_searching = TRUE
	stat_attack = HARD_CRIT
	footstep_type = FOOTSTEP_MOB_HEAVY
	attack_sound = 'sound/weapons/rapierhit.ogg'
	deathsound = 'sound/voice/mook_death.ogg'
	aggro_vision_range = 15 //A little more aggressive once in combat to balance out their really low HP
	var/attack_state = FERAL_ATTACK_NEUTRAL
	var/struck_target_leap = FALSE

/mob/living/simple_animal/hostile/beschutzer/CanAllowThrough(atom/movable/O)
	. = ..()
	if(istype(O, /mob/living/simple_animal/hostile/beschutzer))
		var/mob/living/simple_animal/hostile/beschutzer/M = O
		if(M.attack_state == FERAL_ATTACK_ACTIVE && M.throwing)
			return TRUE

/mob/living/simple_animal/hostile/beschutzer/Moved(atom/OldLoc, Dir, Forced = FALSE)
	if(Dir)
		new /obj/effect/decal/cleanable/blood/drip(src.loc)
	return ..()

/mob/living/simple_animal/hostile/beschutzer/death()
	desc = "The beast is not dead, but is unable to continue fighting. It's seemingly unkillable."
	return ..()

/mob/living/simple_animal/hostile/beschutzer/AttackingTarget()
	if(isliving(target))
		if(ranged_cooldown <= world.time && attack_state == FERAL_ATTACK_NEUTRAL)
			var/mob/living/L = target
			if(L.incapacitated())
				WarmupAttack(forced_slash_combo = TRUE)
				return
			WarmupAttack()
		return
	return ..()

/mob/living/simple_animal/hostile/beschutzer/Goto()
	if(attack_state != FERAL_ATTACK_NEUTRAL)
		return
	return ..()

/mob/living/simple_animal/hostile/beschutzer/Move()
	if(attack_state == FERAL_ATTACK_WARMUP || attack_state == FERAL_ATTACK_RECOVERY)
		return
	return ..()

/mob/living/simple_animal/hostile/beschutzer/proc/WarmupAttack(forced_slash_combo = FALSE)
	if(attack_state == FERAL_ATTACK_NEUTRAL && target)
		attack_state = FERAL_ATTACK_WARMUP
		walk(src,0)
		update_icons()
		if(prob(50) && get_dist(src,target) <= 3 || forced_slash_combo)
			addtimer(CALLBACK(src, .proc/SlashCombo), ATTACK_INTERMISSION_TIME)
			return
		addtimer(CALLBACK(src, .proc/LeapAttack), ATTACK_INTERMISSION_TIME + rand(0,3))
		return
	attack_state = FERAL_ATTACK_RECOVERY
	ResetNeutral()

/mob/living/simple_animal/hostile/beschutzer/proc/SlashCombo()
	if(attack_state == FERAL_ATTACK_WARMUP && !stat)
		attack_state = FERAL_ATTACK_ACTIVE
		update_icons()
		SlashAttack()
		addtimer(CALLBACK(src, .proc/SlashAttack), 3)
		addtimer(CALLBACK(src, .proc/SlashAttack), 6)
		addtimer(CALLBACK(src, .proc/AttackRecovery), 9)

/mob/living/simple_animal/hostile/beschutzer/proc/SlashAttack()
	if(target && !stat && attack_state == FERAL_ATTACK_ACTIVE)
		melee_damage_lower = 15
		melee_damage_upper = 15
		var/mob_direction = get_dir(src,target)
		if(get_dist(src,target) > 1)
			step(src,mob_direction)
		if(targets_from && isturf(targets_from.loc) && target.Adjacent(targets_from) && isliving(target))
			var/mob/living/L = target
			L.attack_animal(src)
			return
		var/swing_turf = get_step(src,mob_direction)
		new /obj/effect/temp_visual/kinetic_blast(swing_turf)
		playsound(src, 'sound/weapons/slashmiss.ogg', 50, TRUE)

/mob/living/simple_animal/hostile/beschutzer/proc/LeapAttack()
	if(target && !stat && attack_state == FERAL_ATTACK_WARMUP)
		attack_state = FERAL_ATTACK_ACTIVE
		density = FALSE
		melee_damage_lower = 30
		melee_damage_upper = 30
		update_icons()
		new /obj/effect/temp_visual/beschutzer_dust(get_turf(src))
		playsound(src, 'sound/weapons/thudswoosh.ogg', 25, TRUE)
		playsound(src, 'sound/voice/mook_leap_yell.ogg', 100, TRUE)
		var/target_turf = get_turf(target)
		throw_at(target_turf, 7, 1, src, FALSE, callback = CALLBACK(src, .proc/AttackRecovery))
		return
	attack_state = FERAL_ATTACK_RECOVERY
	ResetNeutral()

/mob/living/simple_animal/hostile/beschutzer/proc/AttackRecovery()
	if(attack_state == FERAL_ATTACK_ACTIVE && !stat)
		attack_state = FERAL_ATTACK_RECOVERY
		density = TRUE
		face_atom(target)
		if(!struck_target_leap)
			update_icons()
		struck_target_leap = FALSE
		if(prob(40))
			attack_state = FERAL_ATTACK_NEUTRAL
			if(target)
				if(isliving(target))
					var/mob/living/L = target
					if(L.incapacitated() && L.stat != DEAD)
						addtimer(CALLBACK(src, .proc/WarmupAttack, TRUE), ATTACK_INTERMISSION_TIME)
						return
			addtimer(CALLBACK(src, .proc/WarmupAttack), ATTACK_INTERMISSION_TIME)
			return
		addtimer(CALLBACK(src, .proc/ResetNeutral), ATTACK_INTERMISSION_TIME)

/mob/living/simple_animal/hostile/beschutzer/proc/ResetNeutral()
	if(attack_state == FERAL_ATTACK_RECOVERY)
		attack_state = FERAL_ATTACK_NEUTRAL
		ranged_cooldown = world.time + ranged_cooldown_time
		update_icons()
		if(target && !stat)
			update_icons()
			Goto(target, move_to_delay, minimum_distance)

/mob/living/simple_animal/hostile/beschutzer/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(isliving(hit_atom) && attack_state == FERAL_ATTACK_ACTIVE)
		var/mob/living/L = hit_atom
		if(CanAttack(L))
			L.attack_animal(src)
			struck_target_leap = TRUE
			density = TRUE
			update_icons()
	var/mook_under_us = FALSE
	for(var/A in get_turf(src))
		if(struck_target_leap && mook_under_us)
			break
		if(A == src)
			continue
		if(isliving(A))
			var/mob/living/ML = A
			if(!struck_target_leap && CanAttack(ML))//Check if some joker is attempting to use rest to evade us
				struck_target_leap = TRUE
				ML.attack_animal(src)
				density = TRUE
				struck_target_leap = TRUE
				update_icons()
				continue
			if(istype(ML, /mob/living/simple_animal/hostile/beschutzer) && !mook_under_us)//If we land on the same tile as another mook, spread out so we don't stack our sprite on the same tile
				var/mob/living/simple_animal/hostile/beschutzer/M = ML
				if(!M.stat)
					mook_under_us = TRUE
					var/anydir = pick(GLOB.cardinals)
					Move(get_step(src, anydir), anydir)
					continue

/mob/living/simple_animal/hostile/beschutzer/handle_automated_action()
	if(attack_state)
		return
	return ..()

/mob/living/simple_animal/hostile/beschutzer/OpenFire()
	if(isliving(target))
		var/mob/living/L = target
		if(L.incapacitated())
			return
	WarmupAttack()

/mob/living/simple_animal/hostile/beschutzer/update_icons()
	. = ..()
	if(!stat)
		switch(attack_state)
			if(FERAL_ATTACK_NEUTRAL)
				icon_state = "beschutzer"
			if(FERAL_ATTACK_WARMUP)
				icon_state = "beschutzer_warmup"
			if(FERAL_ATTACK_ACTIVE)
				if(!density)
					icon_state = "beschutzer_leap"
					return
				if(struck_target_leap)
					icon_state = "beschutzer_strike"
					return
				icon_state = "beschutzer_slash_combo"
			if(FERAL_ATTACK_RECOVERY)
				icon_state = "beschutzer"

/obj/effect/temp_visual/beschutzer_dust
	name = "dust"
	desc = "It's just a dust cloud!"
	icon = 'icons/mob/beschutzer.dmi'
	icon_state = "beschutzer_leap_cloud"
	layer = BELOW_MOB_LAYER
	pixel_x = -16
	pixel_y = -16
	duration = 10

#undef FERAL_ATTACK_NEUTRAL
#undef FERAL_ATTACK_WARMUP
#undef FERAL_ATTACK_ACTIVE
#undef FERAL_ATTACK_RECOVERY
#undef ATTACK_INTERMISSION_TIME
