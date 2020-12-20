#define FERAL_ATTACK_NEUTRAL 0
#define FERAL_ATTACK_WARMUP 1
#define FERAL_ATTACK_ACTIVE 2
#define FERAL_ATTACK_RECOVERY 3
#define FERAL_ATTACK_PEACEFUL 5
#define FERAL_ATTACK_HURT 6
#define ATTACK_INTERMISSION_TIME 7

/mob/living/simple_animal/hostile/megafauna/beschutzer
	name = "Beschützer"
	desc = "Love suffereth all things, And we, Out of the travail and pain of our striving, Bring unto Thee the perfect prayer: For the lips of no man utter love, Suffering even for love's sake."
	icon = 'icons/mob/beschutzer.dmi'
	icon_state = "beschutzer"
	icon_living = "beschutzer"
	hud_type = /datum/hud/human
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	AIStatus = AI_OFF
	pixel_x = -16
	speak_emote = list("screeches")
	maxHealth = 10000
	health = 10000
	melee_damage_lower = 30
	melee_damage_upper = 60
	pixel_y = 0
	movement_type = GROUND
	ventcrawler = VENTCRAWLER_ALWAYS //LMAO
	initial_language_holder = /datum/language_holder/spiritual
	stop_automated_movement = 1
	see_in_dark = 8
	dextrous = TRUE
	held_items = list(null, null)
	hud_possible = list(HEALTH_HUD,STATUS_HUD,ANTAG_HUD,GLAND_HUD,NANITE_HUD,DIAG_NANITE_FULL_HUD)
	possible_a_intents = list(INTENT_HELP, INTENT_GRAB, INTENT_DISARM, INTENT_HARM)
	ranged = TRUE
	ranged_cooldown_time = 10
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
	pet_bonus = TRUE
	environment_smash = ENVIRONMENT_SMASH_WALLS
	mouse_opacity = MOUSE_OPACITY_ICON
	attack_action_types = list(/datum/action/innate/megafauna_attack/voidspread,
							   /datum/action/innate/megafauna_attack/summon_apostle,
							   /datum/action/innate/megafauna_attack/leap,
							   /datum/action/innate/megafauna_attack/peaceful,
							   /datum/action/innate/megafauna_attack/signing,
							   /datum/action/innate/megafauna_attack/speaking)
	var/attack_state = FERAL_ATTACK_NEUTRAL
	var/struck_target_leap = FALSE
	faction = list("neutral","silicon","turret")

/datum/action/innate/megafauna_attack/voidspread
	name = "Void Spread"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = "<span class='danger'>You are now spreading Her influence.</span>"
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/summon_apostle
	name = "Summon Apostle"
	icon_icon = 'icons/effects/bubblegum.dmi'
	button_icon_state = "smack ya one"
	chosen_message = "<span class='danger'>You summon your minions.</span>"
	chosen_attack_num = 2

/datum/action/innate/megafauna_attack/leap
	name = "Leap"
	icon_icon = 'icons/effects/blood.dmi'
	button_icon_state = "floor1"
	chosen_message = "<span class='danger'>You can now leap to attack.</span>"
	chosen_attack_num = 3

/datum/action/innate/megafauna_attack/peaceful
	name = "Peaceful"
	icon_icon = 'icons/effects/blood.dmi'
	button_icon_state = "floor1"
	chosen_message = "<span class='danger'>You're not feeling bloodthirsty.</span>"
	chosen_attack_num = 4

/datum/action/innate/megafauna_attack/signing
	name = "Signing"
	icon_icon = 'icons/effects/blood.dmi'
	button_icon_state = "floor1"
	chosen_message = "<span class='danger'>You're signing.</span>"
	chosen_attack_num = 5

/datum/action/innate/megafauna_attack/speaking
	name = "Screaming"
	icon_icon = 'icons/effects/blood.dmi'
	button_icon_state = "floor1"
	chosen_message = "<span class='danger'>You're speaking.</span>"
	chosen_attack_num = 6

/mob/living/simple_animal/hostile/megafauna/beschutzer/OpenFire()
	if(client)
		switch(chosen_attack)
			if(1)
				voidspread()
			if(2)
				summon_robot()
				summon_guirec()
				summon_carrey()
				summon_olivia()
			if(3)
				leap()
			if(4)
				peaceful()
			if(5)
				signing()
			if(6)
				speaking()
		return

/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/voidspread()
	if(!isturf(loc) || isspaceturf(loc))
		return
	if(locate(/obj/structure/void/weeds/node) in get_turf(src))
		return
	for(var/mob/living/L in get_hearers_in_view(7, src) - src)
		to_chat(L, "<span class='danger'>Beschützer spreads the void!</span>")
	new /obj/structure/void/weeds/node(loc)


/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/summon_robot()
	for(var/mob/living/L in get_hearers_in_view(7, src) - src)
		to_chat(L, "<span class='danger'>Beschützer summons his apostles!</span>")
	var/mob/living/simple_animal/hostile/apostle/robot/A = new(loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction

/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/summon_guirec()
	var/mob/living/simple_animal/hostile/apostle/poison/guirec/A = new(loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction

/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/summon_carrey()
	var/mob/living/simple_animal/hostile/apostle/carrey/A = new(loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction

/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/summon_olivia()
	var/mob/living/simple_animal/hostile/apostle/olivia/A = new(loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction

/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/leap()
	if(isliving(target))
		var/mob/living/L = target
		if(L.incapacitated())
			return
	WarmupAttack()

/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/peaceful()
	attack_state = FERAL_ATTACK_PEACEFUL
	update_icons()

/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/signing()
	speak_emote = list("signs")

/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/speaking()
	speak_emote = list("screeches")

///mob/living/simple_animal/hostile/megafauna/beschutzer/CanAllowThrough(atom/movable/O)
//	. = ..()
//	if(istype(O, /mob/living/simple_animal/hostile/megafauna/beschutzer))
//		var/mob/living/simple_animal/hostile/beschutzer/M = O
//		if(M.attack_state == FERAL_ATTACK_ACTIVE && M.throwing)
//			return TRUE

//mob/living/simple_animal/hostile/megafauna/beschutzer/Moved(atom/OldLoc, Dir, Forced = FALSE)
//	if(Dir)
//		new /obj/effect/decal/cleanable/blood/drip(src.loc)
//	return ..()

/mob/living/simple_animal/hostile/megafauna/beschutzer/AttackingTarget()
	if(isliving(target))
		if(ranged_cooldown <= world.time && attack_state == FERAL_ATTACK_NEUTRAL)
			var/mob/living/L = target
			if(L.incapacitated())
				WarmupAttack(forced_slash_combo = TRUE)
				return
			WarmupAttack()
		return

	return ..()

/mob/living/simple_animal/hostile/megafauna/beschutzer/Goto()
	if(attack_state != FERAL_ATTACK_NEUTRAL)
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/beschutzer/Move()
	if(attack_state == FERAL_ATTACK_WARMUP || attack_state == FERAL_ATTACK_RECOVERY)
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/WarmupAttack(forced_slash_combo = FALSE)
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

/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/SlashCombo()
	if(attack_state == FERAL_ATTACK_WARMUP && !stat)
		attack_state = FERAL_ATTACK_ACTIVE
		update_icons()
		SlashAttack()
		addtimer(CALLBACK(src, .proc/SlashAttack), 3)
		addtimer(CALLBACK(src, .proc/SlashAttack), 6)
		addtimer(CALLBACK(src, .proc/AttackRecovery), 9)

/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/SlashAttack()
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

/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/LeapAttack()
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

/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/AttackRecovery()
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

/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/ResetNeutral()
	if(attack_state == FERAL_ATTACK_RECOVERY)
		attack_state = FERAL_ATTACK_NEUTRAL
		ranged_cooldown = world.time + ranged_cooldown_time
		update_icons()
		if(target && !stat)
			update_icons()
			Goto(target, move_to_delay, minimum_distance)

/mob/living/simple_animal/hostile/megafauna/beschutzer/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
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
			if(istype(ML, /mob/living/simple_animal/hostile/megafauna/beschutzer) && !mook_under_us)//If we land on the same tile as another mook, spread out so we don't stack our sprite on the same tile
				var/mob/living/simple_animal/hostile/megafauna/beschutzer/M = ML
				if(!M.stat)
					mook_under_us = TRUE
					var/anydir = pick(GLOB.cardinals)
					Move(get_step(src, anydir), anydir)
					continue

/mob/living/simple_animal/hostile/megafauna/beschutzer/handle_automated_action()
	if(attack_state)
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/beschutzer/AttackingTarget(mob/living/M, mob/living/user, def_zone)
	. = ..()
	if(istype(target, /obj/item/reagent_containers/food))
		if (health >= maxHealth)
			to_chat(src, "<span class='warning'>You feel fine, no need to eat anything!</span>")
			return
		to_chat(src, "<span class='green'>You eat \the [src], restoring some health.</span>")
		heal_bodypart_damage(10)
		qdel(target)

//Throwing stuff
/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/toggle_throw_mode()
	if(stat)
		return
	if(in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()


/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/throw_mode_off()
	in_throw_mode = FALSE
	if(hud_used)
		hud_used.throw_icon.icon_state = "act_throw_off"


/mob/living/simple_animal/hostile/megafauna/beschutzer/proc/throw_mode_on()
	in_throw_mode = TRUE
	if(hud_used)
		hud_used.throw_icon.icon_state = "act_throw_on"

/mob/living/simple_animal/hostile/megafauna/beschutzer/throw_item(atom/target)
	. = ..()
	throw_mode_off()
	if(!target || !isturf(loc))
		return
	if(istype(target, /obj/screen))
		return

	var/atom/movable/thrown_thing
	var/obj/item/I = get_active_held_item()

	if(!I)
		if(pulling && isliving(pulling) && grab_state >= GRAB_AGGRESSIVE)
			var/mob/living/throwable_mob = pulling
			if(!throwable_mob.buckled)
				thrown_thing = throwable_mob
				stop_pulling()
				if(HAS_TRAIT(src, TRAIT_PACIFISM))
					to_chat(src, "<span class='notice'>You gently let go of [throwable_mob].</span>")
					return
	else
		thrown_thing = I.on_thrown(src, target)

	if(thrown_thing)

		if(isliving(thrown_thing))
			var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
			var/turf/end_T = get_turf(target)
			if(start_T && end_T)
				log_combat(src, thrown_thing, "thrown", addition="grab from tile in [AREACOORD(start_T)] towards tile at [AREACOORD(end_T)]")
		var/power_throw = 0
		if(HAS_TRAIT(src, TRAIT_HULK))
			power_throw++
		if(HAS_TRAIT(src, TRAIT_DWARF))
			power_throw--
		if(HAS_TRAIT(thrown_thing, TRAIT_DWARF))
			power_throw++
		if(pulling && grab_state >= GRAB_NECK)
			power_throw++
		visible_message("<span class='danger'>[src] throws [thrown_thing][power_throw ? " really hard!" : "."]</span>", \
						"<span class='danger'>You throw [thrown_thing][power_throw ? " really hard!" : "."]</span>")
		log_message("has thrown [thrown_thing] [power_throw ? "really hard" : ""]", LOG_ATTACK)
		newtonian_move(get_dir(target, src))
		thrown_thing.safe_throw_at(target, thrown_thing.throw_range, thrown_thing.throw_speed + power_throw, src, null, null, null, move_force)

/mob/living/simple_animal/hostile/megafauna/beschutzer/update_icons()
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
			if(FERAL_ATTACK_PEACEFUL)
				icon_state = "beschutzer_peaceful"
			if(FERAL_ATTACK_HURT)
				icon_state = "beschutzer_hurt"

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
#define FERAL_ATTACK_PEACEFUL
#define FERAL_ATTACK_HURT
#define ATTACK_INTERMISSION_TIME
