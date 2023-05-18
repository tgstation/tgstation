// swings at 3 targets in a direction
/datum/attack_style/swing
	cd = CLICK_CD_MELEE * 3 // Three times the turfs, 3 times the cooldown

/datum/attack_style/swing/get_swing_description()
	return "It swings in an arc of three tiles in the direction you are attacking."

/datum/attack_style/swing/select_targeted_turfs(mob/living/attacker, attack_direction, right_clicking)
	return get_turfs_and_adjacent_in_direction(attacker, attack_direction)

/datum/attack_style/swing/requires_wield

/datum/attack_style/swing/requires_wield/get_swing_description()
	return ..() + " Must be wielded."

/datum/attack_style/swing/requires_wield/execute_attack(mob/living/attacker, obj/item/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	if(!HAS_TRAIT(weapon, TRAIT_WIELDED))
		attacker.balloon_alert(attacker, "wield your weapon!")
		return ATTACK_STYLE_CANCEL
	return ..()

/datum/attack_style/swing/esword
	cd = CLICK_CD_MELEE * 1.25 // Much faster than normal swings
	reverse_for_lefthand = FALSE

/datum/attack_style/swing/esword/get_swing_description()
	return ..() + " It must be active to swing. Right-clicking will swing in the opposite direction."

/datum/attack_style/swing/esword/execute_attack(mob/living/attacker, obj/item/melee/energy/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	if(!weapon.blade_active)
		attacker.balloon_alert(attacker, "activate your weapon!")
		return FALSE

	// Right clicking attacks the opposite direction
	if(right_clicking)
		reverse_range(affecting)

	return ..()

/datum/attack_style/swing/requires_wield/desword
	cd = CLICK_CD_MELEE * 1.25
	reverse_for_lefthand = FALSE

/datum/attack_style/swing/requires_wield/desword/get_swing_description()
	return "It swings out to all adjacent tiles besides directly behind you."

/datum/attack_style/swing/requires_wield/desword/select_targeted_turfs(mob/living/attacker, attack_direction, right_clicking)
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
/datum/attack_style/stab_out
	reverse_for_lefthand = FALSE
	var/stab_range = 1

/datum/attack_style/stab_out/get_swing_description()
	return "It stabs out [stab_range] tiles in the direction you are attacking."

/datum/attack_style/stab_out/select_targeted_turfs(mob/living/attacker, attack_direction, right_clicking)
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

/datum/attack_style/stab_out/spear
	cd = CLICK_CD_MELEE * 2
	stab_range = 2

/datum/attack_style/stab_out/spear/execute_attack(mob/living/attacker, obj/item/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	if(!HAS_TRAIT(weapon, TRAIT_WIELDED))
		attacker.balloon_alert(attacker, "wield your weapon!")
		return FALSE
	return ..()
