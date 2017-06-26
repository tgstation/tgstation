#define HUNTER_DASH_RANGE 4
/mob/living/simple_animal/hostile/megafauna/blood_drunk_hunter
	name = "blood-drunk hunter"
	desc = "A nightmare-riddled hunter wielding a vicious cleaving saw and a kinetic accelerator."
	health = 1000
	maxHealth = 1000
	icon_state = "hunter"
	icon_living = "hunter"
	icon = 'icons/mob/broadMobs.dmi'
	movement_type = GROUND
	speak_emote = list("roars")
	speed = 1
	move_to_delay = 3
	projectiletype = /obj/item/projectile/kinetic/hunter
	projectilesound = 'sound/weapons/kenetic_accel.ogg'
	ranged = 1
	pixel_x = -16
	crusher_loot = list(/obj/item/weapon/melee/transforming/cleaving_saw, /obj/item/weapon/gun/energy/kinetic_accelerator, /obj/item/crusher_trophy/hunter_eye)
	loot = list(/obj/item/weapon/melee/transforming/cleaving_saw, /obj/item/weapon/gun/energy/kinetic_accelerator)
	wander = FALSE
	del_on_death = TRUE
	stat_attack = UNCONSCIOUS
	blood_volume = BLOOD_VOLUME_NORMAL
	var/obj/item/weapon/melee/transforming/cleaving_saw/hunter/CS
	var/time_until_next_transform
	var/dashing = FALSE
	var/dash_cooldown = 15
	deathmessage = "falls to the ground, decaying into glowing particles."
	death_sound = "bodyfall"

/obj/item/weapon/melee/transforming/cleaving_saw/hunter //nerfed saw because it is very murdery
	force = 6
	force_on = 10

/obj/item/weapon/melee/transforming/cleaving_saw/hunter/attack(mob/living/target, mob/living/carbon/human/user)
	var/target_knockdown_amount = target.AmountKnockdown()
	..()
	var/new_knockdown = target.AmountKnockdown()
	if(new_knockdown != target_knockdown_amount)
		target.SetKnockdown(max(target_knockdown_amount, 6), ignore_canknockdown = TRUE) //doesn't knock targets down for long if it does so

/obj/item/projectile/kinetic/hunter
	damage = 20
	speed = 1
	icon_state = "ka_tracer"
	range = HUNTER_DASH_RANGE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_hunter/Initialize()
	. = ..()
	CS = new(src)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_hunter/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	var/adjustment_amount = amount * 0.15
	if(world.time + adjustment_amount > next_move)
		changeNext_move(adjustment_amount) //attacking it interrupts it attacking, but only briefly
	. = ..()
	if(prob(adjustment_amount + 5))
		INVOKE_ASYNC(src, .proc/dash)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_hunter/death()
	if(health > 0)
		return
	new /obj/effect/temp_visual/dir_setting/hunter_death(loc, dir)
	..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_hunter/Move(atom/newloc)
	if(dashing || (newloc && newloc.z == z && (istype(newloc, /turf/open/floor/plating/lava) || istype(newloc, /turf/open/chasm)))) //we're not stupid!
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_hunter/ex_act(severity, target)
	if(dash())
		return
	..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_hunter/AttackingTarget()
	if(next_move > world.time || !Adjacent(target)) //some cheating
		INVOKE_ASYNC(src, .proc/quick_attack_loop)
		return
	face_atom(target)
	changeNext_move(CLICK_CD_MELEE)
	CS.melee_attack_chain(src, target)
	transform_weapon()
	INVOKE_ASYNC(src, .proc/quick_attack_loop)
	if(prob(10))
		INVOKE_ASYNC(src, .proc/dash)
	return TRUE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_hunter/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect, end_pixel_y)
	if(!used_item)
		used_item = CS
	..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_hunter/GiveTarget(new_target)
	var/targets_the_same = (new_target == target)
	. = ..()
	if(. && target && !targets_the_same)
		wander = FALSE
		transform_weapon()
		INVOKE_ASYNC(src, .proc/quick_attack_loop)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_hunter/OpenFire()
	Goto(target, move_to_delay, minimum_distance)
	if(get_dist(src, target) >= HUNTER_DASH_RANGE && world.time >= dash_cooldown)
		INVOKE_ASYNC(src, .proc/dash, target)
	else if(next_move <= world.time)
		visible_message("<span class='danger'>[src] fires the proto-kinetic accelerator!</span>")
		new /obj/effect/temp_visual/dir_setting/firing_effect(loc, dir)
		face_atom(target)
		Shoot(target)
		changeNext_move(CLICK_CD_RANGE)
	transform_weapon()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_hunter/proc/quick_attack_loop()
	if(next_move <= world.time)
		sleep(1)
		.() //retry
		return
	sleep((next_move - world.time) * 1.5)
	if(QDELETED(target))
		return
	if(dashing || next_move > world.time || !Adjacent(target))
		if(dashing && next_move <= world.time)
			next_move = world.time + 1
		.() //recurse
		return
	AttackingTarget()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_hunter/proc/dash(atom/target)
	if(world.time < dash_cooldown)
		return
	dash_cooldown = world.time + initial(dash_cooldown)
	var/list/accessable_turfs = list()
	var/self_dist_to_target = 0
	var/turf/own_turf = get_turf(src)
	if(!QDELETED(target))
		self_dist_to_target += get_dist(target, own_turf)
	for(var/turf/open/O in RANGE_TURFS(HUNTER_DASH_RANGE, own_turf))
		var/turf_dist_to_target = 0
		if(!QDELETED(target))
			turf_dist_to_target += get_dist(target, O)
		if(get_dist(src, O) >= HUNTER_DASH_RANGE && turf_dist_to_target <= self_dist_to_target && !istype(O, /turf/open/floor/plating/lava) && !istype(O, /turf/open/chasm))
			var/valid = TRUE
			for(var/turf/T in getline(own_turf, O))
				if(is_blocked_turf(T, TRUE))
					valid = FALSE
					continue
			if(valid)
				accessable_turfs[O] = turf_dist_to_target
	if(!LAZYLEN(accessable_turfs))
		return
	var/turf/target_turf
	if(!QDELETED(target))
		var/closest_dist = HUNTER_DASH_RANGE
		for(var/t in accessable_turfs)
			if(accessable_turfs[t] < closest_dist)
				closest_dist = accessable_turfs[t]
		for(var/t in accessable_turfs)
			accessable_turfs[t] = (accessable_turfs[t] - closest_dist) * 10
		target_turf = pickweight(accessable_turfs)
	else
		target_turf = pick(accessable_turfs)
	var/turf/step_back_turf = get_step(target_turf, get_cardinal_dir(target_turf, own_turf))
	var/turf/step_forward_turf = get_step(own_turf, get_cardinal_dir(own_turf, target_turf))
	new /obj/effect/temp_visual/small_smoke/halfsecond(step_back_turf)
	new /obj/effect/temp_visual/small_smoke/halfsecond(step_forward_turf)
	var/obj/effect/temp_visual/decoy/fading/halfsecond/D = new /obj/effect/temp_visual/decoy/fading/halfsecond(own_turf, src)
	forceMove(step_back_turf)
	playsound(own_turf, 'sound/weapons/punchmiss.ogg', 40, 1, -1)
	dashing = TRUE
	alpha = 0
	animate(src, alpha = 255, time = 5)
	sleep(2)
	D.forceMove(step_forward_turf)
	forceMove(target_turf)
	playsound(target_turf, 'sound/weapons/punchmiss.ogg', 40, 1, -1)
	sleep(1)
	dashing = FALSE
	return TRUE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_hunter/proc/transform_weapon()
	if(time_until_next_transform <= world.time)
		CS.transform_cooldown = 0
		CS.transform_weapon(src, TRUE)
		icon_state = "hunter[CS.active ? "_transformed":""]"
		icon_living = "hunter[CS.active ? "_transformed":""]"
		time_until_next_transform = world.time + rand(50, 100)

/obj/effect/temp_visual/dir_setting/hunter_death
	icon_state = "hunter_death"
	duration = 10

/obj/effect/temp_visual/dir_setting/hunter_death/Initialize(mapload, set_dir)
	. = ..()
	INVOKE_ASYNC(src, .proc/fade_out)

/obj/effect/temp_visual/dir_setting/hunter_death/proc/fade_out()
	var/matrix/M = new
	M.Turn(pick(90, 270))
	var/final_dir = dir
	if(dir & (EAST|WEST)) //Facing east or west
		final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass

	animate(src, transform = M, pixel_y = -6, dir = final_dir, time = 2, easing = EASE_IN|EASE_OUT)
	sleep(2)
	animate(src, color = list("#A7A19E", "#A7A19E", "#A7A19E", list(0, 0, 0)), time = 8, easing = EASE_IN, flags = ANIMATION_PARALLEL)
	sleep(2)
	animate(src, alpha = 0, time = 6, easing = EASE_OUT, flags = ANIMATION_PARALLEL)

#undef HUNTER_DASH_RANGE
