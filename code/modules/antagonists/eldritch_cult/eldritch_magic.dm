/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash
	name = "Ashen passage"
	desc = "Low range spell allowing you to pass through a few walls."
	school = "transmutation"
	invocation = "ASH'N P'SSG'"
	invocation_type = INVOCATION_WHISPER
	charge_max = 150
	range = -1
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "ash_shift"
	action_background_icon_state = "bg_ecult"
	jaunt_in_time = 13
	jaunt_duration = 10
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/ash_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/ash_shift/out

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/long
	jaunt_duration = 50

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/play_sound()
	return

/obj/effect/temp_visual/dir_setting/ash_shift
	name = "ash_shift"
	icon = 'icons/mob/mob.dmi'
	icon_state = "ash_shift2"
	duration = 13

/obj/effect/temp_visual/dir_setting/ash_shift/out
	icon_state = "ash_shift"

/obj/effect/proc_holder/spell/targeted/touch/mansus_grasp
	name = "Mansus Grasp"
	desc = "Touch spell that let's you channel the power of the old gods through you."
	hand_path = /obj/item/melee/touch_attack/mansus_fist
	school = "evocation"
	charge_max = 150
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mansus_grasp"
	action_background_icon_state = "bg_ecult"

/obj/item/melee/touch_attack/mansus_fist
	name = "Mansus Grasp"
	desc = "A sinister looking aura that distorts the flow of reality around it. Causes knockdown, major stamina damage aswell as some Brute. It gains additional beneficial effects with certain knowledges you can research."
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
	catchphrase = "R'CH T'H TR'TH"

/obj/item/melee/touch_attack/mansus_fist/afterattack(atom/target, mob/user, proximity_flag, click_parameters)

	if(!proximity_flag || target == user)
		return
	playsound(user, 'sound/items/welder.ogg', 75, TRUE)
	if(ishuman(target))
		var/mob/living/carbon/human/tar = target
		if(tar.anti_magic_check())
			tar.visible_message("<span class='danger'>Spell bounces off of [target]!</span>","<span class='danger'>The spell bounces off of you!</span>")
			return ..()
	var/datum/mind/M = user.mind
	var/datum/antagonist/heretic/cultie = M.has_antag_datum(/datum/antagonist/heretic)

	var/use_charge = FALSE
	if(iscarbon(target))
		use_charge = TRUE
		var/mob/living/carbon/C = target
		C.adjustBruteLoss(10)
		C.AdjustKnockdown(5 SECONDS)
		C.adjustStaminaLoss(80)
	var/list/knowledge = cultie.get_all_knowledge()

	for(var/X in knowledge)
		var/datum/eldritch_knowledge/EK = knowledge[X]
		if(EK.on_mansus_grasp(target, user, proximity_flag, click_parameters))
			use_charge = TRUE
	if(use_charge)
		return ..()

/obj/effect/proc_holder/spell/aoe_turf/rust_conversion
	name = "Aggressive Spread"
	desc = "Spreads rust onto nearby turfs."
	school = "transmutation"
	charge_max = 300 //twice as long as mansus grasp
	clothes_req = FALSE
	invocation = "A'GRSV SPR'D"
	invocation_type = INVOCATION_WHISPER
	range = 3
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "corrode"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/aoe_turf/rust_conversion/cast(list/targets, mob/user = usr)
	playsound(user, 'sound/items/welder.ogg', 75, TRUE)
	for(var/turf/T in targets)
		///What we want is the 3 tiles around the user and the tile under him to be rusted, so min(dist,1)-1 causes us to get 0 for these tiles, rest of the tiles are based on chance
		var/chance = 100 - (max(get_dist(T,user),1)-1)*100/(range+1)
		if(!prob(chance))
			continue
		T.rust_heretic_act()

/obj/effect/proc_holder/spell/aoe_turf/rust_conversion/small
	name = "Rust Conversion"
	desc = "Spreads rust onto nearby turfs."
	range = 2

/obj/effect/proc_holder/spell/targeted/touch/blood_siphon
	name = "Blood Siphon"
	desc = "Touch spell that heals you while damaging the enemy, has a chance to transfer wounds between you and your enemy."
	hand_path = /obj/item/melee/touch_attack/blood_siphon
	school = "evocation"
	charge_max = 150
	clothes_req = FALSE
	invocation = "FL'MS O'ET'RN'ITY"
	invocation_type = INVOCATION_WHISPER
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "blood_siphon"
	action_background_icon_state = "bg_ecult"

/obj/item/melee/touch_attack/blood_siphon
	name = "Blood Siphon"
	desc = "A sinister looking aura that distorts the flow of reality around it."
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
	catchphrase = "R'BRTH"

/obj/item/melee/touch_attack/blood_siphon/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	playsound(user, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	if(ishuman(target))
		var/mob/living/carbon/human/tar = target
		if(tar.anti_magic_check())
			tar.visible_message("<span class='danger'>Spell bounces off of [target]!</span>","<span class='danger'>The spell bounces off of you!</span>")
			return ..()
	var/mob/living/carbon/C2 = user
	if(isliving(target))
		var/mob/living/L = target
		L.adjustBruteLoss(20)
		C2.adjustBruteLoss(-20)
	if(iscarbon(target))
		var/mob/living/carbon/C1 = target
		for(var/obj/item/bodypart/bodypart in C2.bodyparts)
			for(var/datum/wound/wound in bodypart.wounds)
				if(prob(50))
					continue
				var/obj/item/bodypart/target_bodypart = locate(bodypart.type) in C1.bodyparts
				if(!target_bodypart)
					continue
				wound.remove_wound()
				wound.apply_wound(target_bodypart)

		C1.blood_volume -= 20
		if(C2.blood_volume < BLOOD_VOLUME_MAXIMUM) //we dont want to explode after all
			C2.blood_volume += 20
		return ..()

/obj/effect/proc_holder/spell/targeted/projectile/dumbfire/rust_wave
	name = "Patron's Reach"
	desc = "Channels energy into your gauntlet - firing it results in a wave of rust being created in it's wake."
	proj_type = /obj/projectile/magic/spell/rust_wave
	charge_max = 350
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "rust_wave"
	action_background_icon_state = "bg_ecult"
	invocation = "SPR'D TH' WO'D"
	invocation_type = INVOCATION_WHISPER

/obj/projectile/magic/spell/rust_wave
	name = "Patron's Reach"
	icon_state = "eldritch_projectile"
	alpha = 180
	damage = 30
	damage_type = TOX
	hitsound = 'sound/weapons/punch3.ogg'
	trigger_range = 0
	ignored_factions = list("heretics")
	range = 15
	speed = 1

/obj/projectile/magic/spell/rust_wave/Moved(atom/OldLoc, Dir)
	. = ..()
	playsound(src, 'sound/items/welder.ogg', 75, TRUE)
	var/list/turflist = list()
	var/turf/T1
	turflist += get_turf(src)
	T1 = get_step(src,turn(dir,90))
	turflist += T1
	turflist += get_step(T1,turn(dir,90))
	T1 = get_step(src,turn(dir,-90))
	turflist += T1
	turflist += get_step(T1,turn(dir,-90))
	for(var/X in turflist)
		if(!X || prob(25))
			continue
		var/turf/T = X
		T.rust_heretic_act()

/obj/effect/proc_holder/spell/targeted/projectile/dumbfire/rust_wave/short
	name = "Small Patron's Reach"
	proj_type = /obj/projectile/magic/spell/rust_wave/short

/obj/projectile/magic/spell/rust_wave/short
	range = 7
	speed = 2

/obj/effect/proc_holder/spell/pointed/cleave
	name = "Cleave"
	desc = "Causes severe bleeding on a target and people around them"
	school = "transmutation"
	charge_max = 350
	clothes_req = FALSE
	invocation = "CL'VE"
	invocation_type = INVOCATION_WHISPER
	range = 9
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "cleave"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/pointed/cleave/cast(list/targets, mob/user)
	if(!targets.len)
		to_chat(user, "<span class='warning'>No target found in range!</span>")
		return FALSE
	if(!can_target(targets[1], user))
		return FALSE

	for(var/mob/living/carbon/human/C in range(1,targets[1]))
		targets |= C


	for(var/X in targets)
		var/mob/living/carbon/human/target = X
		if(target == user)
			continue
		if(target.anti_magic_check())
			to_chat(user, "<span class='warning'>The spell had no effect!</span>")
			target.visible_message("<span class='danger'>[target]'s veins flash with fire, but their magic protection repulses the blaze!</span>", \
							"<span class='danger'>Your veins flash with fire, but your magic protection repels the blaze!</span>")
			continue

		target.visible_message("<span class='danger'>[target]'s veins are shredded from within as an unholy blaze erupts from their blood!</span>", \
							"<span class='danger'>Your veins burst from within and unholy flame erupts from your blood!</span>")
		var/obj/item/bodypart/bodypart = pick(target.bodyparts)
		var/datum/wound/brute/cut/critical/crit_wound = new
		crit_wound.apply_wound(bodypart)
		target.adjustFireLoss(20)
		new /obj/effect/temp_visual/cleave(target.drop_location())

/obj/effect/proc_holder/spell/pointed/cleave/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(target,/mob/living/carbon/human))
		if(!silent)
			to_chat(user, "<span class='warning'>You are unable to cleave [target]!</span>")
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/cleave/long
	charge_max = 650

/obj/effect/proc_holder/spell/pointed/touch/mad_touch
	name = "Touch of madness"
	desc = "Touch spell that drains your enemies sanity."
	school = "transmutation"
	charge_max = 150
	clothes_req = FALSE
	invocation_type = "none"
	range = 2
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mad_touch"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/pointed/touch/mad_touch/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(target,/mob/living/carbon/human))
		if(!silent)
			to_chat(user, "<span class='warning'>You are unable to touch [target]!</span>")
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/touch/mad_touch/cast(list/targets, mob/user)
	. = ..()
	for(var/mob/living/carbon/target in targets)
		if(ishuman(targets))
			var/mob/living/carbon/human/tar = target
			if(tar.anti_magic_check())
				tar.visible_message("<span class='danger'>Spell bounces off of [target]!</span>","<span class='danger'>The spell bounces off of you!</span>")
				return
		if(target.mind && !target.mind.has_antag_datum(/datum/antagonist/heretic))
			to_chat(user,"<span class='warning'>[target.name] has been cursed!</span>")
			SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)

/obj/effect/proc_holder/spell/pointed/ash_final
	name = "Nightwatcher's Rite"
	desc = "Powerful spell that releases 5 streams of fire away from you."
	school = "transmutation"
	invocation = "F'RE"
	invocation_type = INVOCATION_WHISPER
	charge_max = 300
	range = 15
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "flames"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/pointed/ash_final/cast(list/targets, mob/user)
	for(var/X in targets)
		var/T
		T = line_target(-25, range, X, user)
		INVOKE_ASYNC(src, .proc/fire_line, user,T)
		T = line_target(10, range, X, user)
		INVOKE_ASYNC(src, .proc/fire_line, user,T)
		T = line_target(0, range, X, user)
		INVOKE_ASYNC(src, .proc/fire_line, user,T)
		T = line_target(-10, range, X, user)
		INVOKE_ASYNC(src, .proc/fire_line, user,T)
		T = line_target(25, range, X, user)
		INVOKE_ASYNC(src, .proc/fire_line, user,T)
	return ..()

/obj/effect/proc_holder/spell/pointed/ash_final/proc/line_target(offset, range, atom/at , atom/user)
	if(!at)
		return
	var/angle = ATAN2(at.x - user.x, at.y - user.y) + offset
	var/turf/T = get_turf(user)
	for(var/i in 1 to range)
		var/turf/check = locate(user.x + cos(angle) * i, user.y + sin(angle) * i, user.z)
		if(!check)
			break
		T = check
	return (getline(user, T) - get_turf(user))

/obj/effect/proc_holder/spell/pointed/ash_final/proc/fire_line(atom/source, list/turfs)
	var/list/hit_list = list()
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			break

		for(var/mob/living/L in T.contents)
			if(L.anti_magic_check())
				L.visible_message("<span class='danger'>Spell bounces off of [L]!</span>","<span class='danger'>The spell bounces off of you!</span>")
				continue
			if(L in hit_list || L == source)
				continue
			hit_list += L
			L.adjustFireLoss(20)
			to_chat(L, "<span class='userdanger'>You're hit by [source]'s fire breath!</span>")

		new /obj/effect/hotspot(T)
		T.hotspot_expose(700,50,1)
		// deals damage to mechs
		for(var/obj/mecha/M in T.contents)
			if(M in hit_list)
				continue
			hit_list += M
			M.take_damage(45, BURN, "melee", 1)
		sleep(1.5)

/obj/effect/proc_holder/spell/targeted/shapeshift/eldritch
	invocation = "SH'PE"
	invocation_type = INVOCATION_WHISPER
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	possible_shapes = list(/mob/living/simple_animal/mouse,\
		/mob/living/simple_animal/pet/dog/corgi,\
		/mob/living/simple_animal/hostile/carp,\
		/mob/living/simple_animal/bot/secbot, \
		/mob/living/simple_animal/pet/fox,\
		/mob/living/simple_animal/pet/cat )

/obj/effect/proc_holder/spell/targeted/emplosion/eldritch
	name = "Energetic Pulse"
	invocation = "E'P"
	invocation_type = INVOCATION_WHISPER
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 300
	emp_heavy = 6
	emp_light = 10

/obj/effect/proc_holder/spell/aoe_turf/fire_cascade
	name = "Fire Cascade"
	desc = "creates hot turfs around you."
	school = "transmutation"
	charge_max = 300 //twice as long as mansus grasp
	clothes_req = FALSE
	invocation = "C'SC'DE"
	invocation_type = INVOCATION_WHISPER
	range = 4
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "fire_ring"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/aoe_turf/fire_cascade/cast(list/targets, mob/user = usr)
	INVOKE_ASYNC(src, .proc/fire_cascade, user,range)

/obj/effect/proc_holder/spell/aoe_turf/fire_cascade/proc/fire_cascade(atom/centre,max_range)
	playsound(get_turf(centre), 'sound/items/welder.ogg', 75, TRUE)
	var/_range = 1
	for(var/i = 0, i <= max_range,i++)
		for(var/turf/T in spiral_range_turfs(_range,centre))
			new /obj/effect/hotspot(T)
			T.hotspot_expose(700,50,1)
			for(var/mob/living/livies in T.contents)
				livies.adjustFireLoss(10)
		_range++
		sleep(3)

/obj/effect/proc_holder/spell/aoe_turf/fire_cascade/big
	range = 6

/obj/effect/proc_holder/spell/targeted/telepathy/eldritch
	invocation = ""
	invocation_type = INVOCATION_WHISPER
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/targeted/fire_sworn
	name = "Oath of Fire"
	desc = "For a minute you will passively create a ring of fire around you."
	invocation = "FL'MS"
	invocation_type = INVOCATION_WHISPER
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 700
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "fire_ring"
	///how long it lasts
	var/duration = 1 MINUTES
	///who casted it right now
	var/mob/current_user
	///Determines if you get the fire ring effect
	var/has_fire_ring = FALSE

/obj/effect/proc_holder/spell/targeted/fire_sworn/cast(list/targets, mob/user)
	. = ..()
	current_user = user
	has_fire_ring = TRUE
	addtimer(CALLBACK(src, .proc/remove, user), duration, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/effect/proc_holder/spell/targeted/fire_sworn/proc/remove()
	has_fire_ring = FALSE

/obj/effect/proc_holder/spell/targeted/fire_sworn/process()
	. = ..()
	if(!has_fire_ring)
		return
	for(var/turf/T in range(1,current_user))
		new /obj/effect/hotspot(T)
		T.hotspot_expose(700,50,1)
		for(var/mob/living/livies in T.contents)
			livies.adjustFireLoss(5)


/obj/effect/proc_holder/spell/targeted/worm_contract
	name = "Force Contract"
	desc = "Forces all the worm parts to collapse onto a single turf"
	invocation_type = "none"
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 300
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "worm_contract"

/obj/effect/proc_holder/spell/targeted/worm_contract/cast(list/targets, mob/user)
	. = ..()
	if(!istype(user,/mob/living/simple_animal/hostile/eldritch/armsy))
		to_chat(user, "<span class='userdanger'>You try to contract your muscles but nothing happens...</span>")
	var/mob/living/simple_animal/hostile/eldritch/armsy/armsy = user
	armsy.contract_next_chain_into_single_tile()

/obj/effect/temp_visual/cleave
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cleave"
	duration = 6

/obj/effect/temp_visual/eldritch_smoke
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "smoke"
	duration = 10

/obj/effect/proc_holder/spell/targeted/fiery_rebirth
	name = "Nightwatcher's Rebirth"
	desc = "Drains nearby alive people that are engulfed in flames. It heals 10 of each damage type per person. If a person is in critical condition it finishes them off."
	invocation = "GL'RY T' TH' N'GHT'W'TCH'ER"
	invocation_type = INVOCATION_WHISPER
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 600
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "smoke"

/obj/effect/proc_holder/spell/targeted/fiery_rebirth/cast(list/targets, mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	for(var/mob/living/carbon/target in view(7,user))
		if(target.stat == DEAD || !target.on_fire)
			continue
		//This is essentially a death mark, use this to finish your opponent quicker.
		if(target.InCritical())
			target.death()
		target.adjustFireLoss(20)
		new /obj/effect/temp_visual/eldritch_smoke(target.drop_location())
		human_user.ExtinguishMob()
		human_user.adjustBruteLoss(-10, FALSE)
		human_user.adjustFireLoss(-10, FALSE)
		human_user.adjustStaminaLoss(-10, FALSE)
		human_user.adjustToxLoss(-10, FALSE)
		human_user.adjustOxyLoss(-10)
