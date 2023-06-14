// Swings at 3 targets in a direction
/datum/attack_style/melee_weapon/swing
	cd = CLICK_CD_MELEE * 3 // Three times the turfs, 3 times the cooldown
	sprite_size_multiplier = 1.5
	time_per_turf = 0.2 SECONDS
	/// If TRUE, the list of affected turfs will be reversed if the attack is being sourced from the lefthand
	var/reverse_for_lefthand = TRUE

/datum/attack_style/melee_weapon/swing/get_swing_description(has_alt_style)
	return "Swings in an arc of three tiles in the direction you are attacking."

/datum/attack_style/melee_weapon/swing/attack_effect_animation(mob/living/attacker, obj/item/weapon, list/turf/affecting)
	var/num_turfs_to_move = length(affecting)
	var/final_animation_length = time_per_turf * num_turfs_to_move
	var/initial_angle = -weapon.weapon_sprite_angle + get_angle(attacker, affecting[1])
	var/final_angle = -weapon.weapon_sprite_angle + get_angle(attacker, affecting[num_turfs_to_move])
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
	var/list/swing_turfs = get_turfs_and_adjacent_in_direction(attacker, attack_direction)
	if(reverse_for_lefthand && (attacker.active_hand_index % 2 == 1))
		reverse_range(swing_turfs)
	return swing_turfs

// Swing for weapons which require being wielded
/datum/attack_style/melee_weapon/swing/requires_wield

/datum/attack_style/melee_weapon/swing/requires_wield/get_swing_description(has_alt_style)
	return ..() + " Must be wielded."

/datum/attack_style/melee_weapon/swing/requires_wield/execute_attack(mob/living/attacker, obj/item/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	if(!HAS_TRAIT(weapon, TRAIT_WIELDED))
		attacker.balloon_alert(attacker, "wield your weapon!")
		return ATTACK_SWING_CANCEL
	return ..()

/datum/attack_style/melee_weapon/swing/wider_arc

/datum/attack_style/melee_weapon/swing/wider_arc/get_swing_description(has_alt_style)
	return "Swings in an arc of six tiles in the direction you are attacking."

/datum/attack_style/melee_weapon/swing/wider_arc/select_targeted_turfs(mob/living/attacker, attack_direction, right_clicking)
	var/list/swing_turfs = ..()
	// Also grab turfs to the left and right of the attacker
	var/angle_to = dir2angle(attack_direction)
	var/turf/adjacent_left = get_step(attacker, angle2dir(angle_to - 90))
	var/turf/adjacent_right = get_step(attacker, angle2dir(angle_to + 90))
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
	cd = CLICK_CD_MELEE * 1.5
	slowdown = 0.8
	time_per_turf = 0.1 SECONDS

/datum/attack_style/melee_weapon/swing/only_left/get_swing_description(has_alt_style)
	return "Swings in an arc of two tiles in the direction you are attacking, away from your active hand."

/datum/attack_style/melee_weapon/swing/only_left/select_targeted_turfs(mob/living/attacker, attack_direction, right_clicking)
	// Does not hit the last turf (right most turf).
	var/list/swing_turfs = ..()
	if(length(swing_turfs))
		swing_turfs.len -= 1
	return swing_turfs

/datum/attack_style/melee_weapon/swing/fast
	cd = CLICK_CD_MELEE * 1.5
	slowdown = 0.75
	time_per_turf = 0.1 SECONDS
