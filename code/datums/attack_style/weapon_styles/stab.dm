// Direct stabs out to turfs in front
/datum/attack_style/melee_weapon/stab_out
	time_per_turf = 0.2 SECONDS
	var/stab_range = 1

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
	var/stab_length = stab_range * length(affecting)
	attacker.do_attack_animation(affecting[1], no_effect = TRUE)
	flick_overlay_global(attack_image, GLOB.clients, stab_length + stab_range)
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
		time = stab_range,
		alpha = 0,
		easing = CIRCULAR_EASING|EASE_OUT,
	)

/datum/attack_style/melee_weapon/stab_out/spear
	cd = CLICK_CD_MELEE * 2
	stab_range = 2
	sprite_size_multiplier = 1.5

/datum/attack_style/melee_weapon/stab_out/spear/execute_attack(mob/living/attacker, obj/item/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	if(!HAS_TRAIT(weapon, TRAIT_WIELDED))
		attacker.balloon_alert(attacker, "wield your weapon!")
		return FALSE
	return ..()
