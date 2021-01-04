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
	icon_dead = "beschutzer_death"
	hud_type = /datum/hud/human
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	gender = MALE
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
	deathmessage = "rips off his necklace and immediately collapses, motionless."
	environment_smash = ENVIRONMENT_SMASH_WALLS
	mouse_opacity = MOUSE_OPACITY_ICON
	attack_action_types = list(/datum/action/innate/megafauna_attack/leap,
							   /datum/action/innate/megafauna_attack/peaceful,
							   /datum/action/innate/megafauna_attack/signing,
							   /datum/action/innate/megafauna_attack/speaking)
	var/attack_state = FERAL_ATTACK_NEUTRAL
	var/list/available_channels = list()
	var/struck_target_leap = FALSE
	var/obj/item/radio/headset/ears = null
	faction = list("neutral","silicon","turret")

/datum/action/innate/megafauna_attack/leap
	name = "Leap"
	icon_icon = 'icons/effects/blood.dmi'
	button_icon_state = "floor1"
	chosen_message = "<span class='danger'>You can now leap to attack.</span>"
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/peaceful
	name = "Peaceful"
	icon_icon = 'icons/effects/blood.dmi'
	button_icon_state = "floor1"
	chosen_message = "<span class='danger'>You're not feeling bloodthirsty.</span>"
	chosen_attack_num = 2

/datum/action/innate/megafauna_attack/signing
	name = "Signing"
	icon_icon = 'icons/effects/blood.dmi'
	button_icon_state = "floor1"
	chosen_message = "<span class='danger'>You're signing.</span>"
	chosen_attack_num = 3

/datum/action/innate/megafauna_attack/speaking
	name = "Screaming"
	icon_icon = 'icons/effects/blood.dmi'
	button_icon_state = "floor1"
	chosen_message = "<span class='danger'>You're speaking.</span>"
	chosen_attack_num = 4

/mob/living/simple_animal/hostile/megafauna/beschutzer/OpenFire()
	if(client)
		switch(chosen_attack)
			if(1)
				leap()
			if(2)
				peaceful()
			if(3)
				signing()
			if(4)
				speaking()
		return

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

/mob/living/simple_animal/hostile/megafauna/beschutzer/Initialize()
	. = ..()
	if(!ears)
		var/headset = pick(/obj/item/radio/headset/headset_sec, \
						/obj/item/radio/headset/headset_eng, \
						/obj/item/radio/headset/headset_med, \
						/obj/item/radio/headset/headset_sci, \
						/obj/item/radio/headset/headset_cargo)
		ears = new headset(src)

/mob/living/simple_animal/hostile/megafauna/beschutzer/death()
	desc = "Beschützer's body, now lifeless and useless. Who will save you now?"
	return ..()

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

/mob/living/simple_animal/hostile/megafauna/beschutzer/Topic(href, href_list)
	if(!(iscarbon(usr) || iscyborg(usr)) || !usr.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		usr << browse(null, "window=mob[REF(src)]")
		usr.unset_machine()
		return

	//Removing from inventory
	if(href_list["remove_inv"])
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if("ears")
				if(!ears)
					to_chat(usr, "<span class='warning'>There is nothing to remove from his [remove_from]!</span>")
					return
				ears.forceMove(drop_location())
				ears = null

	//Adding things to inventory
	else if(href_list["add_inv"])
		var/add_to = href_list["add_inv"]
		if(!usr.get_active_held_item())
			to_chat(usr, "<span class='warning'>You have nothing in your hand to put on his [add_to]!</span>")
			return
		switch(add_to)
			if("ears")
				if(ears)
					to_chat(usr, "<span class='warning'>It's already wearing something!</span>")
					return
				else
					var/obj/item/item_to_add = usr.get_active_held_item()
					if(!item_to_add)
						return

					if( !istype(item_to_add,  /obj/item/radio/headset) )
						to_chat(usr, "<span class='warning'>This object won't fit!</span>")
						return

					var/obj/item/radio/headset/headset_to_add = item_to_add

					if(!usr.transferItemToLoc(headset_to_add, src))
						return
					ears = headset_to_add
					to_chat(usr, "<span class='notice'>You fit the headset onto [src].</span>")

					available_channels.Cut()
					for(var/ch in headset_to_add.channels)
						switch(ch)
							if(RADIO_CHANNEL_ENGINEERING)
								available_channels.Add(RADIO_TOKEN_ENGINEERING)
							if(RADIO_CHANNEL_COMMAND)
								available_channels.Add(RADIO_TOKEN_COMMAND)
							if(RADIO_CHANNEL_SECURITY)
								available_channels.Add(RADIO_TOKEN_SECURITY)
							if(RADIO_CHANNEL_SCIENCE)
								available_channels.Add(RADIO_TOKEN_SCIENCE)
							if(RADIO_CHANNEL_MEDICAL)
								available_channels.Add(RADIO_TOKEN_MEDICAL)
							if(RADIO_CHANNEL_SUPPLY)
								available_channels.Add(RADIO_TOKEN_SUPPLY)
							if(RADIO_CHANNEL_SERVICE)
								available_channels.Add(RADIO_TOKEN_SERVICE)

					if(headset_to_add.translate_binary)
						available_channels.Add(MODE_TOKEN_BINARY)
	else
		return ..()
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
