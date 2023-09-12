/datum/attack_style/melee_weapon/overhead

/datum/attack_style/melee_weapon/overhead/get_swing_description(has_alt_style)
	return "Comes down over the tile in the direction you are attacking. Always targets the head."

/datum/attack_style/melee_weapon/overhead/finalize_attack(mob/living/attacker, mob/living/smacked, obj/item/weapon, right_clicking)
	// Future todo : When we decouple more of attack chain this can be passed via proc args
	var/old_zone = attacker.zone_selected
	attacker.zone_selected = BODY_ZONE_HEAD
	. = ..()
	attacker.zone_selected = old_zone

/*
/datum/attack_style/melee_weapon/overhead/attack_effect_animation(mob/living/attacker, obj/item/weapon, list/turf/affected_turfs)
	var/side_angle = prob(50) ? -15 : 15 // so it slightly goes either left -> right or right -> left
	var/start_angle = -weapon.weapon_sprite_angle + get_angle(attacker, affected_turfs[1]) + side_angle
	var/image/attack_image = create_attack_image(attacker, weapon, affected_turfs[1], start_angle)
	var/matrix/final_matrix = turn(attack_image.transform, start_angle + (-2 * side_angle))
	var/strike_dir = get_dir(attacker, affected_turfs[1])
	var/y_move = 0
	var/x_move = 0
	if(strike_dir & NORTH)
		y_move += 3
	else if(strike_dir & SOUTH)
		y_move -= 3
	if(strike_dir & EAST)
		x_move += 3
	else if(strike_dir & WEST)
		x_move -= 3

	attacker.do_attack_animation(affected_turfs[1], no_effect = TRUE) // melbert todo
	flick_overlay_global(attack_image, GLOB.clients, time_per_turf * 2.5)

	// Moves out a little bit, then moves to the opposite side of the turf
	// We can't really do "up" so this'll have to do
	animate(
		attack_image,
		time = time_per_turf,
		pixel_x = x_move,
		pixel_y = y_move,
		easing = BACK_EASING|EASE_IN,
	)
	animate(
		time = time_per_turf,
		transform = final_matrix,
		alpha = 175,
		pixel_x = -x_move,
		pixel_y = -y_move,
		easing = BACK_EASING|EASE_OUT,
	)
	animate(
		time = time_per_turf * 0.5,
		alpha = 0,
		pixel_x = 0,
		pixel_y = 0,
		easing = CIRCULAR_EASING|EASE_OUT,
	)
*/
