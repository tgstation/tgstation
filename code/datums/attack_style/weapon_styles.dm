// swings at 3 targets in a direction
/datum/attack_style/melee_weapon/swing
	cd = CLICK_CD_MELEE * 3 // Three times the turfs, 3 times the cooldown
	sprite_size_multiplier = 1.5
	var/time_per_turf = 0.4 SECONDS

/datum/attack_style/melee_weapon/swing/get_swing_description()
	return "It swings in an arc of three tiles in the direction you are attacking."

/datum/attack_style/melee_weapon/swing/attack_effect_animation(mob/living/attacker, obj/item/weapon, list/turf/affecting)
	var/num_turfs_to_move = length(affecting)
	var/final_animation_length = time_per_turf * num_turfs_to_move
	var/initial_angle = -weapon_sprite_angle + get_angle(attacker, affecting[1])
	var/final_angle = -weapon_sprite_angle + get_angle(attacker, affecting[num_turfs_to_move])
	var/image/attack_image = create_attack_image(attacker, weapon, affecting[1], initial_angle)
	var/matrix/final_transform = turn(attack_image.transform, final_angle - initial_angle)
	var/final_x = (affecting[num_turfs_to_move].x - attacker.x) * 16
	var/final_y = (affecting[num_turfs_to_move].y - attacker.y) * 16

	attacker.do_attack_animation(affecting[ROUND_UP(length(affecting) / 2)], no_effect = TRUE)
	flick_overlay_global(attack_image, GLOB.clients, final_animation_length + time_per_turf) // add a little extra time
	animate(
		attack_image,
		time = final_animation_length,
		transform = final_transform,
		pixel_x = final_x,
		pixel_y = final_y,
		alpha = 175,
		easing = CUBIC_EASING|EASE_OUT,
	)
	animate(
		time = time_per_turf,
		alpha = 0,
		easing = CIRCULAR_EASING|EASE_OUT,
	)

/datum/attack_style/melee_weapon/swing/select_targeted_turfs(mob/living/attacker, attack_direction, right_clicking)
	return get_turfs_and_adjacent_in_direction(attacker, attack_direction)

/datum/attack_style/melee_weapon/swing/diagonal_sprite
	weapon_sprite_angle = 45

/datum/attack_style/melee_weapon/swing/requires_wield

/datum/attack_style/melee_weapon/swing/requires_wield/get_swing_description()
	return ..() + " Must be wielded."

/datum/attack_style/melee_weapon/swing/requires_wield/execute_attack(mob/living/attacker, obj/item/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	if(!HAS_TRAIT(weapon, TRAIT_WIELDED))
		attacker.balloon_alert(attacker, "wield your weapon!")
		return ATTACK_STYLE_CANCEL
	return ..()

/datum/attack_style/melee_weapon/swing/esword
	cd = CLICK_CD_MELEE * 1.25 // Much faster than normal swings
	slowdown = 0.75
	reverse_for_lefthand = FALSE
	time_per_turf = 0.1 SECONDS
	weapon_sprite_angle = 45

/datum/attack_style/melee_weapon/swing/esword/get_swing_description()
	return ..() + " It must be active to swing. Right-clicking will swing in the opposite direction."

/datum/attack_style/melee_weapon/swing/esword/execute_attack(mob/living/attacker, obj/item/melee/energy/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	if(!weapon.blade_active)
		attacker.balloon_alert(attacker, "activate your weapon!")
		return FALSE

	// Right clicking attacks the opposite direction
	if(right_clicking)
		reverse_range(affecting)

	return ..()

/datum/attack_style/melee_weapon/swing/requires_wield/desword
	cd = CLICK_CD_MELEE * 1.25
	reverse_for_lefthand = FALSE
	weapon_sprite_angle = 45

/datum/attack_style/melee_weapon/swing/requires_wield/desword/get_swing_description()
	return "It swings out to all adjacent tiles besides directly behind you."

/datum/attack_style/melee_weapon/swing/requires_wield/desword/select_targeted_turfs(mob/living/attacker, attack_direction, right_clicking)
	var/behind_us = REVERSE_DIR(attack_direction)
	var/list/cone_turfs = list()
	for(var/around_dir in GLOB.alldirs)
		if(around_dir & behind_us)
			continue
		var/turf/found_turf = get_step(attacker, around_dir)
		if(istype(found_turf))
			cone_turfs += found_turf

	return cone_turfs

// Direct stabs out to turfs in front
/datum/attack_style/melee_weapon/stab_out
	reverse_for_lefthand = FALSE
	var/stab_range = 1
	var/stab_duration_per_turf = 0.2 SECONDS

/datum/attack_style/melee_weapon/stab_out/get_swing_description()
	return "It stabs out [stab_range] tiles in the direction you are attacking."

/datum/attack_style/melee_weapon/stab_out/select_targeted_turfs(mob/living/attacker, attack_direction, right_clicking)
	var/max_range = stab_range
	var/turf/last_turf = get_turf(attacker)
	var/list/select_turfs = list()
	while(max_range > 0)
		var/turf/next_turf = get_step(last_turf, attack_direction)
		if(!isturf(next_turf) || next_turf.is_blocked_turf(exclude_mobs = TRUE, source_atom = attacker))
			return select_turfs
		select_turfs += next_turf
		last_turf = next_turf
		max_range--

	return select_turfs

/datum/attack_style/melee_weapon/stab_out/attack_effect_animation(mob/living/attacker, obj/item/weapon, list/turf/affecting)
	var/image/attack_image = create_attack_image(attacker, weapon, affecting[1])
	var/stab_length = stab_duration_per_turf * length(affecting)
	attacker.do_attack_animation(affecting[1], no_effect = TRUE)
	flick_overlay_global(attack_image, GLOB.clients, stab_length + stab_duration_per_turf)
	var/start_x = attack_image.pixel_x
	var/start_y = attack_image.pixel_y
	var/x_move = 0
	var/y_move = 0
	var/stab_dir = get_dir(attacker, affecting[1])
	if(stab_dir & NORTH)
		y_move += 8
	else if(stab_dir & SOUTH)
		y_move -= 8

	if(stab_dir & EAST)
		x_move += 8
	else if(stab_dir & WEST)
		x_move -= 8

	// Does a short pull in, then stab out
	animate(
		attack_image,
		time = stab_length * 0.25,
		pixel_x = start_x + (x_move * -1),
		pixel_y = start_y + (y_move * -1),
		easing = CUBIC_EASING|EASE_IN,
	)
	animate(
		time = stab_length * 0.75,
		pixel_x = start_x + (x_move * 1.5),
		pixel_y = start_y + (y_move * 1.5),
		alpha = 175,
		easing = CUBIC_EASING|EASE_OUT,
	)
	animate(
		time = stab_duration_per_turf,
		alpha = 0,
		easing = CIRCULAR_EASING|EASE_OUT,
	)

/datum/attack_style/melee_weapon/stab_out/spear
	cd = CLICK_CD_MELEE * 2
	stab_range = 2
	weapon_sprite_angle = 45
	sprite_size_multiplier = 1.5

/datum/attack_style/melee_weapon/stab_out/spear/execute_attack(mob/living/attacker, obj/item/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	if(!HAS_TRAIT(weapon, TRAIT_WIELDED))
		attacker.balloon_alert(attacker, "wield your weapon!")
		return FALSE
	return ..()
