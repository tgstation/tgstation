/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash
	name = "Ashen passage"
	desc = "Low range spell allowing you to pass through a few walls."
	school = "transmutation"
	invocation = "ASH'N P'SSG'"
	invocation_type = "whisper"
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
	action_icon_state = "ash_shift"
	action_background_icon_state = "bg_ecult"

/obj/item/melee/touch_attack/mansus_fist
	name = "Mansus Grasp"
	desc = "A sinister looking aura that distorts the flow of reality around it."
	icon_state = "disintegrate"
	item_state = "disintegrate"
	catchphrase = "R'CH T'H TR'TH"

/obj/item/melee/touch_attack/mansus_fist/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(ishuman(target))
		var/mob/living/carbon/human/tar = target
		if(tar.anti_magic_check())
			tar.visible_message("<span class='danger'>Spell bounces off of [target]!</span>","<span class='danger'>The spell bounces off of you!</span>")
			return
	var/datum/mind/M = user.mind
	var/datum/antagonist/ecult/cultie = M.has_antag_datum(/datum/antagonist/ecult)

	for(var/X in cultie.get_all_knowledge())
		var/datum/eldritch_knowledge/EK = X
		EK.mansus_grasp_act(target, user, proximity_flag, click_parameters)

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.adjustBruteLoss(10)
		C.AdjustKnockdown(1 SECONDS)
		return

/obj/effect/proc_holder/spell/aoe_turf/rust_conversion
	name = "Aggressive Spread"
	desc = "Spreads rust onto nearby turfs."

	school = "transmutation"
	charge_max = 300 //twice as long as mansus grasp
	clothes_req = FALSE
	invocation = "A'GRSV SPR'D"
	invocation_type = "whisper"
	range = 3
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "ash_shift"
	action_background_icon_state = "bg_ecult"
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/closed,/turf/open/space,/turf/open/lava,/turf/open/chasm,/turf/open/floor/plating/rust))

/obj/effect/proc_holder/spell/aoe_turf/rust_conversion/cast(list/targets, mob/user = usr)
	playsound(get_turf(user), 'sound/items/welder.ogg', 75, TRUE)
	for(var/turf/T in targets)
		///What we want is the 3 tiles around the user and the tile under him to be rusted, so min(dist,1)-1 causes us to get 0 for these tiles, rest of the tiles are based on chance
		var/chance = 100 - (max(get_dist(T,user),1)-1)*100/(range+1)
		if(!prob(chance))
			continue
		if(!is_type_in_typecache(T, blacklisted_turfs))
			T.ChangeTurf(/turf/open/floor/plating/rust)
			continue
		if(T.type == /turf/closed/wall/rust)
			T.ScrapeAway()
			continue
		if(T.type == /turf/closed/wall/r_wall/rust && prob(50))
			T.ScrapeAway()
			continue
		if(T.type == /turf/closed/wall)
			T.ChangeTurf(/turf/closed/wall/rust)
			continue
		if(T.type == /turf/closed/wall/r_wall && prob(50))
			T.ChangeTurf(/turf/closed/wall/r_wall/rust)
			continue

/obj/effect/proc_holder/spell/aoe_turf/rust_conversion/small
	name = "Rust Conversion"
	desc = "Spreads rust onto nearby turfs."
	range = 2

/obj/effect/proc_holder/spell/aoe_turf/rust_conversion/big
	name = "Rustbringer's rite"
	desc = "Spreads rust onto a lot of turfs, and damages items worn on other peoplke"
	range = 8

/obj/effect/proc_holder/spell/aoe_turf/rust_conversion/big/cast(list/targets, mob/user)
	. = ..()
	for(var/turf/T in targets)

		for(var/Y in T.GetAllContents())

			if(!is_type_in_list(/mob/living/carbon,T.GetAllContents()))
				break

			if(!istype(Y,/mob/living/carbon))
				continue

			var/mob/living/carbon/C = Y
			if(C == user)
				continue

			for(var/X in C.GetAllContents())
				if(istype(X,/obj/item))
					var/obj/item/I = X
					if(prob(75))
						I.take_damage(rand(50,500))

/obj/effect/proc_holder/spell/targeted/touch/ash_leech
	name = "Blood Siphon"
	desc = "Touch spell that heals you while damaging the enemy."
	hand_path = /obj/item/melee/touch_attack/ash_leech
	school = "evocation"
	charge_max = 150
	clothes_req = FALSE
	invocation = "FL'MS O'ET'RN'ITY"
	invocation_type = "whisper"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "ash_shift"
	action_background_icon_state = "bg_ecult"

/obj/item/melee/touch_attack/ash_leech
	name = "Blood Siphon"
	desc = "A sinister looking aura that distorts the flow of reality around it."
	icon_state = "disintegrate"
	item_state = "disintegrate"
	catchphrase = "R'BRTH"

/obj/item/melee/touch_attack/ash_leech/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(ishuman(target))
		var/mob/living/carbon/human/tar = target
		if(tar.anti_magic_check())
			tar.visible_message("<span class='danger'>Spell bounces off of [target]!</span>","<span class='danger'>The spell bounces off of you!</span>")
			return
	if(iscarbon(target))
		var/mob/living/carbon/C1 = target
		var/mob/living/carbon/C2 = user
		C1.adjustBruteLoss(20)
		C1.blood_volume -= 100
		C2.adjustBruteLoss(-20)
		C2.blood_volume += 100
		return

/obj/effect/proc_holder/spell/targeted/projectile/dumbfire/rust_wave
	name = "Patron's Reach"
	desc = "Channels energy into your gauntlet - firing it results in a wave of rust being created in it's wake."
	proj_type = /obj/projectile/magic/spell/rust_wave
	charge_max = 350
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "ash_shift"
	action_background_icon_state = "bg_ecult"
	invocation = "SPR'D TH' WO'D"
	invocation_type = "whisper"

/obj/projectile/magic/spell/rust_wave
	name = "Patron's Reach"
	icon_state = "eldritch_projectile"
	alpha = 180
	damage = 30
	damage_type = TOX
	hitsound = 'sound/weapons/punch3.ogg'
	trigger_range = 0
	ignored_factions = list("ecult")
	range = 15
	speed = 1
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/closed,/turf/open/space,/turf/open/lava,/turf/open/chasm,/turf/open/floor/plating/rust))

/obj/projectile/magic/spell/rust_wave/Moved(atom/OldLoc, Dir)
	. = ..()
	var/list/turflist = list()
	var/turf/T1
	turflist += get_turf(src)
	switch(Dir)
		if(NORTH)
			T1 = get_step(src,WEST)
			turflist += T1
			turflist += get_step(T1,WEST)
			T1 = get_step(src,EAST)
			turflist += T1
			turflist += get_step(T1,EAST)
		if(SOUTH)
			T1 = get_step(src,WEST)
			turflist += T1
			turflist += get_step(T1,WEST)
			T1 = get_step(src,EAST)
			turflist += T1
			turflist += get_step(T1,EAST)
		if(WEST)
			T1 = get_step(src,NORTH)
			turflist += T1
			turflist += get_step(T1,NORTH)
			T1 = get_step(src,SOUTH)
			turflist += T1
			turflist += get_step(T1,SOUTH)
		if(EAST)
			T1 = get_step(src,NORTH)
			turflist += T1
			turflist += get_step(T1,NORTH)
			T1 = get_step(src,SOUTH)
			turflist += T1
			turflist += get_step(T1,SOUTH)

	for(var/X in turflist)
		var/turf/T = X
		if(!is_type_in_typecache(T, blacklisted_turfs) && prob(75))
			T.ChangeTurf(/turf/open/floor/plating/rust)

/obj/effect/proc_holder/spell/targeted/projectile/dumbfire/rust_wave/short
	name = "Small Patron's Reach"
	proj_type = /obj/projectile/magic/spell/rust_wave/short

/obj/projectile/magic/spell/rust_wave/short
	range = 7
	speed = 2

/obj/effect/proc_holder/spell/pointed/ash_cleave
	name = "Cleave"
	desc = "Causes severe bleeding on a target and people around him"
	school = "transmutation"
	charge_max = 350
	clothes_req = FALSE
	invocation = "CL'VE"
	invocation_type = "whisper"
	range = 9
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "ash_shift"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/pointed/ash_cleave/cast(list/targets, mob/user)
	if(!targets.len)
		to_chat(user, "<span class='warning'>No target found in range!</span>")
		return FALSE
	if(!can_target(targets[1], user))
		return FALSE

	for(var/mob/living/carbon/human/C in range(1,targets[1]))
		targets += C

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

		target.bleed_rate += 8
		target.adjustFireLoss(10)

/obj/effect/proc_holder/spell/pointed/ash_cleave/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(target,/mob/living/carbon/human))
		if(!silent)
			to_chat(user, "<span class='warning'>You are unable to cleave [target]!</span>")
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/ash_cleave/long
	charge_max = 650

/obj/effect/proc_holder/spell/targeted/touch/mad_touch
	name = "Touch of madness"
	desc = "Touch spell that drains your enemies sanity."
	hand_path = /obj/item/melee/touch_attack/mad_touch
	school = "evocation"
	charge_max = 150
	clothes_req = FALSE
	invocation = "OP'N Y'R M'ND"
	invocation_type = "whisper"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "ash_shift"
	action_background_icon_state = "bg_ecult"


/obj/item/melee/touch_attack/mad_touch
	name = "Ash Leech"
	desc = "A sinister looking aura that distorts the flow of reality around it."
	icon_state = "disintegrate"
	item_state = "disintegrate"
	catchphrase = "M'DNESS"

/obj/item/melee/touch_attack/mad_touch/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(ishuman(target))
		var/mob/living/carbon/human/tar = target
		if(tar.anti_magic_check())
			tar.visible_message("<span class='danger'>Spell bounces off of [target]!</span>","<span class='danger'>The spell bounces off of you!</span>")
			return
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(!C.mind.has_antag_datum(/datum/antagonist/ecult))
			SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)
		return

/obj/effect/proc_holder/spell/pointed/ash_final
	name = "Nightwatcher's Rite"
	desc = "Powerful spell that releases 5 streams of fire away from you."
	school = "transmutation"
	invocation = "F'RE"
	invocation_type = "whisper"
	charge_max = 300
	range = 15
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "ash_shift"
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
	. = ..()

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

/obj/effect/proc_holder/spell/pointed/ash_final/proc/fire_line(source, list/turfs)
	var/list/hit_list = list()
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			break
		new /obj/effect/hotspot(T)
		T.hotspot_expose(700,50,1)
		for(var/mob/living/L in T.contents)
			if(L.anti_magic_check())
				L.visible_message("<span class='danger'>Spell bounces off of [L.real_name]!</span>","<span class='danger'>The spell bounces off of you!</span>")
				continue
			if(L in hit_list || L == source)
				continue
			hit_list += L
			L.adjustFireLoss(20)
			to_chat(L, "<span class='userdanger'>You're hit by [source]'s fire breath!</span>")

		// deals damage to mechs
		for(var/obj/mecha/M in T.contents)
			if(M in hit_list)
				continue
			hit_list += M
			M.take_damage(45, BRUTE, "melee", 1)
		sleep(1.5)
