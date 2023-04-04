GLOBAL_LIST_INIT(attack_styles, init_attack_styles())

/proc/init_attack_styles()
	var/list/styles = list()
	for(var/style_type in typesof(/datum/attack_style))
		styles[style_type] = new style_type()

	return styles

/datum/attack_style
	var/execute_sound = 'sound/weapons/fwoosh.ogg'
	var/cd = 1 SECONDS
	var/reverse_for_lefthand = TRUE

/datum/attack_style/proc/process_attack(mob/living/attacker, obj/item/weapon, atom/aimed_towards)

	var/attack_direction = get_dir(attacker, get_turf(aimed_towards))
	var/list/affecting = select_targeted_turfs(attacker, attack_direction)
	if(reverse_for_lefthand)
		// Determine which hand the attacker is attacking from
		// If they are not holding the weapon passed / the weapon is null, default to active hand
		var/which_hand = (!isnull(weapon) && attacker.get_held_index_of_item(weapon)) || attacker.active_hand_index

		// Left hand will reverse the turfs list order
		if(which_hand % 2 == 1)
			reverse_range(affecting)

	return execute_attack(attacker, weapon, affecting)

/datum/attack_style/proc/execute_attack(mob/living/attacker, obj/item/weapon, list/affecting)
	for(var/turf/hitting as anything in affecting)
		for(var/mob/living/smacked in hitting)
			weapon.attack(smacked, attacker)
			break

		#ifdef TESTING
		hitting.add_atom_colour(COLOR_RED, TEMPORARY_COLOUR_PRIORITY)
		hitting.maptext = MAPTEXT("[affecting.Find(hitting)]")
		animate(hitting, 1 SECONDS, color = null)
		addtimer(CALLBACK(src, PROC_REF(testing_clear_color), hitting), 1 SECONDS)
		#endif

	if(execute_sound)
		playsound(attacker, execute_sound, 50, TRUE)
	attacker.changeNext_move(cd)
	return TRUE

#ifdef TESTING
/datum/attack_style/proc/testing_clear_color(turf/hit)
	hit.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_RED)
	hit.maptext = null
#endif

/datum/attack_style/proc/select_targeted_turfs(mob/living/attacker, attack_direction)
	RETURN_TYPE(/list)
	return list(get_step(attacker, attack_direction))

// swings at 3 targets in a direction
/datum/attack_style/swing

/datum/attack_style/swing/select_targeted_turfs(mob/living/attacker, attack_direction)
	return get_turfs_and_adjacent_in_direction(attacker, attack_direction)

/datum/attack_style/stab_out
	reverse_for_lefthand = FALSE
	var/stab_range = 1

/datum/attack_style/stab_out/select_targeted_turfs(mob/living/attacker, attack_direction)
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
	stab_range = 2

/datum/attack_style/stab_out/spear/execute_attack(mob/living/attacker, obj/item/weapon, list/affecting)
	if(!HAS_TRAIT(weapon, TRAIT_WIELDED))
		return FALSE
	return ..()
