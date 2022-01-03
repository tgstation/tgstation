/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash
	name = "Ashen Passage"
	desc = "A short range spell allowing you to pass unimpeded through a few walls."
	school = SCHOOL_FORBIDDEN
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
	desc = "A touch spell that lets you channel the power of the Old Gods through your grip."
	hand_path = /obj/item/melee/touch_attack/mansus_fist
	school = SCHOOL_EVOCATION
	charge_max = 100
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mansus_grasp"
	action_background_icon_state = "bg_ecult"

/obj/item/melee/touch_attack/mansus_fist
	name = "Mansus Grasp"
	desc = "A sinister looking aura that distorts the flow of reality around it. Causes knockdown and major stamina damage in addition to some brute. It gains additional beneficial effects as you expand your knowledge of the Mansus."
	icon_state = "mansus"
	inhand_icon_state = "mansus"
	catchphrase = "R'CH T'H TR'TH"

/obj/item/melee/touch_attack/mansus_fist/ignition_effect(atom/A, mob/user)
	. = span_notice("[user] effortlessly snaps [user.p_their()] fingers near [A], igniting it with eldritch energies. Fucking badass!")
	qdel(src)

/obj/item/melee/touch_attack/mansus_fist/afterattack(atom/target, mob/user, proximity_flag, click_parameters)

	if(!proximity_flag || target == user)
		return
	playsound(user, 'sound/items/welder.ogg', 75, TRUE)
	if(ishuman(target))
		var/mob/living/carbon/human/tar = target
		if(tar.anti_magic_check())
			tar.visible_message(span_danger("The spell bounces off of [target]!"),span_danger("The spell bounces off of you!"))
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

/obj/item/melee/touch_attack/mansus_fist/suicide_act(mob/user)
	. = FIRELOSS
	user.visible_message(span_suicide("[user] covers [user.p_their()] face with [user.p_their()] sickly-looking hand! It looks like [user.p_theyre()] trying to commit suicide!"))
	var/mob/living/carbon/C = user	//iscarbon already used in spell's parent
	var/datum/antagonist/heretic/cultie = C.mind.has_antag_datum(/datum/antagonist/heretic)
	var/list/knowledge = cultie.get_all_knowledge()
	var/escape_our_torment = 0
	while(C.stat == CONSCIOUS)
		if(escape_our_torment > 20)	//Stops us from infinitely stunning ourselves if we're just not taking the damage
			return
		if(prob(70))
			C.adjustFireLoss(20)
			playsound(C, 'sound/effects/wounds/sizzle1.ogg', 70, TRUE)
			if(prob(50))
				C.emote("scream")
				C.stuttering += 13

		for(var/X in knowledge)
			var/datum/eldritch_knowledge/EK = knowledge[X]
			EK.on_mansus_grasp(C, C)

		C.adjustBruteLoss(10)
		C.AdjustKnockdown(5 SECONDS)
		C.adjustStaminaLoss(80)
		escape_our_torment++
		sleep(0.4 SECONDS)

/obj/effect/proc_holder/spell/aoe_turf/rust_conversion
	name = "Aggressive Spread"
	desc = "Spreads rust onto nearby surfaces."
	school = SCHOOL_FORBIDDEN
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
	desc = "Spreads rust onto nearby surfaces."
	range = 2

/obj/effect/proc_holder/spell/pointed/blood_siphon
	name = "Blood Siphon"
	desc = "A touch spell that heals your wounds while damaging the enemy. It has a chance to transfer wounds between you and your enemy."
	school = SCHOOL_EVOCATION
	charge_max = 150
	clothes_req = FALSE
	invocation = "FL'MS O'ET'RN'ITY"
	invocation_type = INVOCATION_WHISPER
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "blood_siphon"
	action_background_icon_state = "bg_ecult"
	range = 9

/obj/effect/proc_holder/spell/pointed/blood_siphon/cast(list/targets, mob/user)
	. = ..()
	var/target = targets[1]
	playsound(user, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	if(ishuman(target))
		var/mob/living/carbon/human/tar = target
		if(tar.anti_magic_check())
			tar.visible_message(span_danger("The spell bounces off of [target]!"),span_danger("The spell bounces off of you!"))
			return ..()
	var/mob/living/carbon/carbon_user = user
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.adjustBruteLoss(20)
		carbon_user.adjustBruteLoss(-20)
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		for(var/bp in carbon_user.bodyparts)
			var/obj/item/bodypart/bodypart = bp
			for(var/i in bodypart.wounds)
				var/datum/wound/iter_wound = i
				if(prob(50))
					continue
				var/obj/item/bodypart/target_bodypart = locate(bodypart.type) in carbon_target.bodyparts
				if(!target_bodypart)
					continue
				iter_wound.remove_wound()
				iter_wound.apply_wound(target_bodypart)

		carbon_target.blood_volume -= 20
		if(carbon_user.blood_volume < BLOOD_VOLUME_MAXIMUM) //we dont want to explode after all
			carbon_user.blood_volume += 20
		return

/obj/effect/proc_holder/spell/pointed/blood_siphon/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(target,/mob/living))
		if(!silent)
			to_chat(user, span_warning("You are unable to siphon [target]!"))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/targeted/projectile/dumbfire/rust_wave
	name = "Patron's Reach"
	desc = "Channels energy into your gauntlet- unleashing it creates a wave of rust in its wake."
	proj_type = /obj/projectile/magic/spell/rust_wave
	school = SCHOOL_FORBIDDEN
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
	desc = "Causes severe bleeding on a target and several targets around them."
	school = SCHOOL_FORBIDDEN
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
		to_chat(user, span_warning("No target found in range!"))
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
			to_chat(user, span_warning("The spell had no effect!"))
			target.visible_message(span_danger("[target]'s veins flash with fire, but their magic protection repulses the blaze!"), \
							span_danger("Your veins flash with fire, but your magic protection repels the blaze!"))
			continue

		target.visible_message(span_danger("[target]'s veins are shredded from within as an unholy blaze erupts from their blood!"), \
							span_danger("Your veins burst from within and unholy flame erupts from your blood!"))
		var/obj/item/bodypart/bodypart = pick(target.bodyparts)
		var/datum/wound/slash/critical/crit_wound = new
		crit_wound.apply_wound(bodypart)
		target.adjustFireLoss(20)
		new /obj/effect/temp_visual/cleave(target.drop_location())

/obj/effect/proc_holder/spell/pointed/cleave/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(target,/mob/living/carbon/human))
		if(!silent)
			to_chat(user, span_warning("You are unable to cleave [target]!"))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/cleave/long
	charge_max = 650

/obj/effect/proc_holder/spell/pointed/touch/mad_touch
	name = "Touch of Madness"
	desc = "A touch spell that drains your enemy's sanity."
	school = SCHOOL_FORBIDDEN
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
			to_chat(user, span_warning("You are unable to touch [target]!"))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/touch/mad_touch/cast(list/targets, mob/user)
	. = ..()
	for(var/mob/living/carbon/target in targets)
		if(ishuman(targets))
			var/mob/living/carbon/human/tar = target
			if(tar.anti_magic_check())
				tar.visible_message(span_danger("The spell bounces off of [target]!"),span_danger("The spell bounces off of you!"))
				return
		if(target.mind && !target.mind.has_antag_datum(/datum/antagonist/heretic))
			to_chat(user,span_warning("[target.name] has been cursed!"))
			SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)

/obj/effect/proc_holder/spell/pointed/ash_final
	name = "Nightwatcher's Rite"
	desc = "A powerful spell that releases 5 streams of fire away from you."
	school = SCHOOL_FORBIDDEN
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
	return (get_line(user, T) - get_turf(user))

/obj/effect/proc_holder/spell/pointed/ash_final/proc/fire_line(atom/source, list/turfs)
	var/list/hit_list = list()
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			break

		for(var/mob/living/L in T.contents)
			if(L.anti_magic_check())
				L.visible_message(span_danger("The spell bounces off of [L]!"),span_danger("The spell bounces off of you!"))
				continue
			if(L in hit_list || L == source)
				continue
			hit_list += L
			L.adjustFireLoss(20)
			to_chat(L, span_userdanger("You're hit by [source]'s eldritch flames!"))

		new /obj/effect/hotspot(T)
		T.hotspot_expose(700,50,1)
		// deals damage to mechs
		for(var/obj/vehicle/sealed/mecha/M in T.contents)
			if(M in hit_list)
				continue
			hit_list += M
			M.take_damage(45, BURN, MELEE, 1)
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
	school = SCHOOL_FORBIDDEN
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
	desc = "Heats the air around you."
	school = SCHOOL_FORBIDDEN
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
	for(var/i in 0 to max_range)
		for(var/turf/T in spiral_range_turfs(_range,centre))
			new /obj/effect/hotspot(T)
			T.hotspot_expose(700,50,1)
			for(var/mob/living/livies in T.contents - centre)
				livies.adjustFireLoss(5)
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
	desc = "For a minute, you will passively create a ring of fire around you."
	invocation = "FL'MS"
	invocation_type = INVOCATION_WHISPER
	school = SCHOOL_FORBIDDEN
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

/obj/effect/proc_holder/spell/targeted/fire_sworn/process(delta_time)
	. = ..()
	if(!has_fire_ring)
		return
	for(var/turf/T in RANGE_TURFS(1,current_user))
		new /obj/effect/hotspot(T)
		T.hotspot_expose(700, 250 * delta_time, 1)
		for(var/mob/living/livies in T.contents - current_user)
			livies.adjustFireLoss(2.5 * delta_time)


/obj/effect/proc_holder/spell/targeted/worm_contract
	name = "Force Contract"
	desc = "Forces your body to contract onto a single tile."
	invocation_type = "none"
	school = SCHOOL_FORBIDDEN
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
		to_chat(user, span_userdanger("You try to contract your muscles but nothing happens..."))
		return
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
	desc = "Drains nearby alive people that are engulfed in flames. It heals 10 of each damage type per person. If a target is in critical condition it drains the last of their vitality, killing them."
	invocation = "GL'RY T' TH' N'GHT'W'TCH'ER"
	invocation_type = INVOCATION_WHISPER
	school = SCHOOL_FORBIDDEN
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
		if(HAS_TRAIT(target, TRAIT_CRITICAL_CONDITION))
			target.death()
		target.adjustFireLoss(20)
		new /obj/effect/temp_visual/eldritch_smoke(target.drop_location())
		human_user.extinguish_mob()
		human_user.adjustBruteLoss(-10, FALSE)
		human_user.adjustFireLoss(-10, FALSE)
		human_user.adjustStaminaLoss(-10, FALSE)
		human_user.adjustToxLoss(-10, FALSE)
		human_user.adjustOxyLoss(-10)

/obj/effect/proc_holder/spell/pointed/manse_link
	name = "Mansus Link"
	desc = "Piercing through reality, connecting minds. This spell allows you to add people to a Mansus Net, allowing them to communicate with each other from afar."
	school = SCHOOL_FORBIDDEN
	charge_max = 300
	clothes_req = FALSE
	invocation = "PI'RC' TH' M'ND"
	invocation_type = "whisper"
	range = 10
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mansus_link"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/pointed/manse_link/can_target(atom/target, mob/user, silent)
	if(!isliving(target))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/manse_link/cast(list/targets, mob/user)
	var/mob/living/simple_animal/hostile/eldritch/raw_prophet/originator = user

	var/mob/living/target = targets[1]

	to_chat(originator, span_notice("You begin linking [target]'s mind to yours..."))
	to_chat(target, span_warning("You feel your mind being pulled... connected... intertwined with the very fabric of reality..."))
	if(!do_after(originator, 6 SECONDS, target))
		return
	if(!originator.link_mob(target))
		to_chat(originator, span_warning("You can't seem to link [target]'s mind..."))
		to_chat(target, span_warning("The foreign presence leaves your mind."))
		return
	to_chat(originator, span_notice("You connect [target]'s mind to your mansus link!"))


/datum/action/innate/mansus_speech
	name = "Mansus Link"
	desc = "Send a psychic message to everyone connected to your Mansus Net."
	button_icon_state = "link_speech"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_ecult"
	var/mob/living/simple_animal/hostile/eldritch/raw_prophet/originator

/datum/action/innate/mansus_speech/New(_originator)
	. = ..()
	originator = _originator

/datum/action/innate/mansus_speech/Activate()
	var/mob/living/living_owner = owner
	if(!originator?.linked_mobs[living_owner])
		CRASH("Uh oh the mansus link got somehow activated without it being linked to a raw prophet or the mob not being in a list of mobs that should be able to do it.")

	var/message = sanitize(tgui_input_text(living_owner, "Enter your message", "Telepathy from the Manse"))
	if(!message)
		return

	if(QDELETED(living_owner))
		return

	if(!originator?.linked_mobs[living_owner])
		to_chat(living_owner, span_warning("The link seems to have been severed..."))
		Remove(living_owner)
		return

	var/msg = "<i><font color=#568b00>\[Mansus Link\] <b>[living_owner]:</b> [message]</font></i>"
	log_directed_talk(living_owner, originator, msg, LOG_SAY, "Mansus Link")
	to_chat(originator.linked_mobs, msg)

	for(var/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, living_owner)
		to_chat(dead_mob, "[link] [msg]")

/obj/effect/proc_holder/spell/pointed/trigger/blind/eldritch
	range = 10
	invocation = "E'E'S"
	action_background_icon_state = "bg_ecult"

/obj/effect/temp_visual/dir_setting/entropic
	icon = 'icons/effects/160x160.dmi'
	icon_state = "entropic_plume"
	duration = 3 SECONDS

/obj/effect/temp_visual/dir_setting/entropic/setDir(dir)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_x = -64
		if(SOUTH)
			pixel_x = -64
			pixel_y = -128
		if(EAST)
			pixel_y = -64
		if(WEST)
			pixel_y = -64
			pixel_x = -128

/obj/effect/temp_visual/glowing_rune
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "small_rune_1"
	duration = 1 MINUTES
	layer = LOW_SIGIL_LAYER

/obj/effect/temp_visual/glowing_rune/Initialize(mapload)
	. = ..()
	pixel_y = rand(-6,6)
	pixel_x = rand(-6,6)
	icon_state = "small_rune_[rand(12)]"
	update_appearance()

/obj/effect/proc_holder/spell/cone/staggered/entropic_plume
	name = "Entropic Plume"
	desc = "Spews forth a disorienting plume that causes enemies to strike each other, briefly blinds them(increasing with range) and poisons them(decreasing with range). Also spreads rust in the path of the plume."
	school = SCHOOL_FORBIDDEN
	invocation = "'NTR'P'C PL'M'"
	invocation_type = INVOCATION_WHISPER
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "entropic_plume"
	charge_max = 300
	cone_levels = 5
	respect_density = TRUE

/obj/effect/proc_holder/spell/cone/staggered/entropic_plume/cast(list/targets,mob/user = usr)
	. = ..()
	new /obj/effect/temp_visual/dir_setting/entropic(get_step(user,user.dir), user.dir)

/obj/effect/proc_holder/spell/cone/staggered/entropic_plume/do_turf_cone_effect(turf/target_turf, level)
	. = ..()
	target_turf.rust_heretic_act()

/obj/effect/proc_holder/spell/cone/staggered/entropic_plume/do_mob_cone_effect(mob/living/victim, level)
	. = ..()
	if(victim.anti_magic_check() || IS_HERETIC(victim) || IS_HERETIC_MONSTER(victim))
		return
	victim.apply_status_effect(STATUS_EFFECT_AMOK)
	victim.apply_status_effect(STATUS_EFFECT_CLOUDSTRUCK, (level*10))
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		carbon_victim.reagents.add_reagent(/datum/reagent/eldritch, min(1, 6-level))

/obj/effect/proc_holder/spell/cone/staggered/entropic_plume/calculate_cone_shape(current_level)
	if(current_level == cone_levels)
		return 5
	else if(current_level == cone_levels-1)
		return 3
	else
		return 2

/obj/effect/proc_holder/spell/targeted/shed_human_form
	name = "Shed form"
	desc = "Shed your fragile form, become one with the arms, become one with the emperor."
	invocation_type = INVOCATION_SHOUT
	invocation = "REALITY UNCOIL!"
	school = SCHOOL_FORBIDDEN
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 100
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "worm_ascend"
	var/segment_length = 10

/obj/effect/proc_holder/spell/targeted/shed_human_form/cast(list/targets, mob/user)
	. = ..()
	var/mob/living/target = user
	var/mob/living/mob_inside = locate() in target.contents - target

	if(!mob_inside)
		var/mob/living/simple_animal/hostile/eldritch/armsy/prime/outside = new(user.loc,TRUE,segment_length)
		target.mind.transfer_to(outside, TRUE)
		target.forceMove(outside)
		target.apply_status_effect(STATUS_EFFECT_STASIS,STASIS_ASCENSION_EFFECT)
		for(var/mob/living/carbon/human/humie in view(9,outside)-target)
			if(IS_HERETIC(humie) || IS_HERETIC_MONSTER(humie))
				continue
			SEND_SIGNAL(humie, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)
			///They see the very reality uncoil before their eyes.
			if(prob(25))
				var/trauma = pick(subtypesof(BRAIN_TRAUMA_MILD) + subtypesof(BRAIN_TRAUMA_SEVERE))
				humie.gain_trauma(new trauma(), TRAUMA_RESILIENCE_LOBOTOMY)
		return

	if(iscarbon(mob_inside))
		var/mob/living/simple_animal/hostile/eldritch/armsy/prime/armsy = target
		if(mob_inside.remove_status_effect(STATUS_EFFECT_STASIS,STASIS_ASCENSION_EFFECT))
			mob_inside.forceMove(armsy.loc)
		armsy.mind.transfer_to(mob_inside, TRUE)
		segment_length = armsy.get_length()
		qdel(armsy)
		return

/obj/effect/proc_holder/spell/pointed/void_blink
	name = "Void Phase"
	desc = "Let's you blink to your pointed destination, causes 3x3 aoe damage bubble around your pointed destination and your current location. It has a minimum range of 3 tiles and a maximum range of 9 tiles."
	invocation_type = INVOCATION_WHISPER
	school = SCHOOL_FORBIDDEN
	invocation = "RE'L'TY PH'S'E"
	clothes_req = FALSE
	range = 9
	action_background_icon_state = "bg_ecult"
	charge_max = 300
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "voidblink"
	selection_type = "range"

/obj/effect/proc_holder/spell/pointed/void_blink/can_target(atom/target, mob/user, silent)
	. = ..()
	if(get_dist(get_turf(user),get_turf(target)) < 3 )
		return FALSE

/obj/effect/proc_holder/spell/pointed/void_blink/cast(list/targets, mob/user)
	. = ..()
	var/target = targets[1]
	var/turf/targeted_turf = get_turf(target)

	playsound(user,'sound/magic/voidblink.ogg',100)
	playsound(targeted_turf,'sound/magic/voidblink.ogg',100)

	new /obj/effect/temp_visual/voidin(user.drop_location())
	new /obj/effect/temp_visual/voidout(targeted_turf)

	for(var/mob/living/living_mob in range(1,user)-user)
		if(IS_HERETIC(living_mob) || IS_HERETIC_MONSTER(living_mob))
			continue
		living_mob.adjustBruteLoss(40)

	for(var/mob/living/living_mob in range(1,targeted_turf)-user)
		if(IS_HERETIC(living_mob) || IS_HERETIC_MONSTER(living_mob))
			continue
		living_mob.adjustBruteLoss(40)

	do_teleport(user,targeted_turf,TRUE,no_effects = TRUE,channel=TELEPORT_CHANNEL_MAGIC)

/obj/effect/temp_visual/voidin
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_in"
	alpha = 150
	duration = 6
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/voidout
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_out"
	alpha = 150
	duration = 6
	pixel_x = -32
	pixel_y = -32

/obj/effect/proc_holder/spell/targeted/void_pull
	name = "Void Pull"
	desc = "Call the void, this pulls all nearby people closer to you, damages people already around you. If they are 4 tiles or closer they are also knocked down and a micro-stun is applied."
	invocation_type = INVOCATION_WHISPER
	invocation = "BR'NG F'RTH TH'M T' M'"
	school = SCHOOL_FORBIDDEN
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 400
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "voidpull"

/obj/effect/proc_holder/spell/targeted/void_pull/cast(list/targets, mob/user)
	. = ..()
	for(var/mob/living/living_mob in range(1,user)-user)
		if(IS_HERETIC(living_mob) || IS_HERETIC_MONSTER(living_mob))
			continue
		living_mob.adjustBruteLoss(30)

	playsound(user,'sound/magic/voidblink.ogg',100)
	new /obj/effect/temp_visual/voidin(user.drop_location())
	for(var/mob/living/livies in view(7,user)-user)

		if(get_dist(user,livies) < 4)
			livies.AdjustKnockdown(3 SECONDS)
			livies.AdjustParalyzed(0.5 SECONDS)

		for(var/i in 1 to 3)
			livies.forceMove(get_step_towards(livies,user))

