// Swings at 3 targets in a direction
/datum/attack_style/melee_weapon/swing
	cd = CLICK_CD_MELEE * 2
	sprite_size_multiplier = 1.5
	/// If TRUE, the list of affected turfs will be reversed if the attack is being sourced from the lefthand
	var/reverse_for_lefthand = TRUE

/datum/attack_style/melee_weapon/swing/get_swing_description(has_alt_style)
	return "Swings in an arc of three tiles in the direction you are attacking."

/datum/attack_style/melee_weapon/swing/attack_effect_animation(mob/living/attacker, obj/item/weapon, list/turf/affected_turfs)
	var/num_turfs_to_move = length(affected_turfs)
	var/final_animation_length = max(0.1 SECONDS, time_per_turf) * num_turfs_to_move
	var/initial_angle = -weapon.weapon_sprite_angle + get_angle(attacker, affected_turfs[1])
	var/final_angle = -weapon.weapon_sprite_angle + get_angle(attacker, affected_turfs[num_turfs_to_move])
	var/image/attack_image = create_attack_image(attacker, weapon, affected_turfs[1], initial_angle)
	var/matrix/final_transform = turn(attack_image.transform, final_angle - initial_angle)
	var/final_x = (affected_turfs[num_turfs_to_move].x - attacker.x) * 16
	var/final_y = (affected_turfs[num_turfs_to_move].y - attacker.y) * 16

	attacker.do_attack_animation(affected_turfs[ROUND_UP(length(affected_turfs) / 2)], no_effect = TRUE)
	flick_overlay_global(attack_image, GLOB.clients, final_animation_length + max(0.1 SECONDS, time_per_turf)) // add a little extra time
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

/datum/attack_style/melee_weapon/swing/select_targeted_turfs(mob/living/attacker, obj/item/weapon, attack_direction, right_clicking)
	var/should_reverse = reverse_for_lefthand && (attacker.active_hand_index % 2 == 1)
	return get_turfs_and_adjacent_in_direction(attacker, attack_direction, reversed = should_reverse)

/datum/attack_style/melee_weapon/swing/wider_arc

/datum/attack_style/melee_weapon/swing/wider_arc/get_swing_description(has_alt_style)
	return "Swings in an arc of five tiles in the direction you are attacking."

/datum/attack_style/melee_weapon/swing/wider_arc/select_targeted_turfs(mob/living/attacker, obj/item/weapon, attack_direction, right_clicking)
	var/list/swing_turfs = ..()
	// Also grab turfs to the left and right of the attacker
	var/turf/adjacent_left = get_step(attacker, turn(attack_direction, -90))
	var/turf/adjacent_right = get_step(attacker, turn(attack_direction, 90))
	if(reverse_for_lefthand && (attacker.active_hand_index % 2 == 1))
		// If the list was reversed, right goes to the start and left goes to the end
		swing_turfs.Insert(1, adjacent_right)
		swing_turfs.Add(adjacent_left)
	else
		// Otherwise, left goes to the start and right goes to the end
		swing_turfs.Insert(1, adjacent_left)
		swing_turfs.Add(adjacent_right)
	return swing_turfs

/datum/attack_style/melee_weapon/swing/only_left
	cd = CLICK_CD_MELEE * 1.25
	slowdown = 0.8

/datum/attack_style/melee_weapon/swing/only_left/get_swing_description(has_alt_style)
	return "Swings in an arc of two tiles in the direction you are attacking, away from your active hand."

/datum/attack_style/melee_weapon/swing/only_left/select_targeted_turfs(mob/living/attacker, obj/item/weapon, attack_direction, right_clicking)
	// Does not hit the last turf (right most turf).
	var/list/swing_turfs = ..()
	if(length(swing_turfs))
		swing_turfs.len -= 1
	return swing_turfs

/datum/attack_style/melee_weapon/swing/fast
	cd = CLICK_CD_MELEE * 1.25
	slowdown = 0.75
