/**
 * ## Cone spells
 *
 * Cone spells shoot off as a cone from the caster.
 */
/datum/action/cooldown/spell/cone
	/// This controls how many levels the cone has. Increase this value to make a bigger cone.
	var/cone_levels = 3
	/// This value determines if the cone penetrates walls.
	var/respect_density = FALSE

/datum/action/cooldown/spell/cone/cast(atom/cast_on)
	. = ..()
	var/list/cone_turfs = get_cone_turfs(get_turf(cast_on), cast_on.dir, cone_levels)
	SEND_SIGNAL(src, COMSIG_SPELL_CONE_ON_CAST, cone_turfs, cast_on)
	make_cone(cone_turfs, cast_on)

/datum/action/cooldown/spell/cone/proc/make_cone(list/cone_turfs, atom/caster)
	for(var/list/turf_list in cone_turfs)
		do_cone_effects(turf_list, caster)

/// This proc does obj, mob and turf cone effects on all targets in the passed list.
/datum/action/cooldown/spell/cone/proc/do_cone_effects(list/target_turf_list, atom/caster, level = 1)
	SEND_SIGNAL(src, COMSIG_SPELL_CONE_ON_LAYER_EFFECT, target_turf_list, caster, level)
	for(var/turf/target_turf as anything in target_turf_list)
		if(QDELETED(target_turf)) //if turf is no longer there
			continue

		do_turf_cone_effect(target_turf, caster, level)
		if(!isopenturf(target_turf))
			continue

		for(var/atom/movable/movable_content as anything in target_turf)
			if(isobj(movable_content))
				do_obj_cone_effect(movable_content, level)
			else if(isliving(movable_content))
				do_mob_cone_effect(movable_content, level)

///This proc deterimines how the spell will affect turfs.
/datum/action/cooldown/spell/cone/proc/do_turf_cone_effect(turf/target_turf, atom/caster, level)
	return

///This proc deterimines how the spell will affect objects.
/datum/action/cooldown/spell/cone/proc/do_obj_cone_effect(obj/target_obj, atom/caster, level)
	return

///This proc deterimines how the spell will affect mobs.
/datum/action/cooldown/spell/cone/proc/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	return

///This proc creates a list of turfs that are hit by the cone.
/datum/action/cooldown/spell/cone/proc/get_cone_turfs(turf/starter_turf, dir_to_use, cone_levels = 3)
	var/list/turfs_to_return = list()
	var/turf/turf_to_use = starter_turf
	var/turf/left_turf
	var/turf/right_turf
	var/right_dir
	var/left_dir
	switch(dir_to_use)
		if(NORTH)
			left_dir = WEST
			right_dir = EAST
		if(SOUTH)
			left_dir = EAST
			right_dir = WEST
		if(EAST)
			left_dir = NORTH
			right_dir = SOUTH
		if(WEST)
			left_dir = SOUTH
			right_dir = NORTH

	for(var/i in 1 to cone_levels)
		var/list/level_turfs = list()
		turf_to_use = get_step(turf_to_use, dir_to_use)
		level_turfs += turf_to_use
		if(i != 1)
			left_turf = get_step(turf_to_use, left_dir)
			level_turfs += left_turf
			right_turf = get_step(turf_to_use, right_dir)
			level_turfs += right_turf
			for(var/left_i in 1 to i -calculate_cone_shape(i))
				if(left_turf.density && respect_density)
					break
				left_turf = get_step(left_turf, left_dir)
				level_turfs += left_turf
			for(var/right_i in 1 to i -calculate_cone_shape(i))
				if(right_turf.density && respect_density)
					break
				right_turf = get_step(right_turf, right_dir)
				level_turfs += right_turf
		turfs_to_return += list(level_turfs)
		if(i == cone_levels)
			continue
		if(turf_to_use.density && respect_density)
			break
	return turfs_to_return

///This proc adjusts the cones width depending on the level.
/datum/action/cooldown/spell/cone/proc/calculate_cone_shape(current_level)
	var/end_taper_start = round(cone_levels * 0.8)
	if(current_level > end_taper_start)
		return (current_level % end_taper_start) * 2 //someone more talented and probably come up with a better formula.
	else
		return 2

/**
 * ### Staggered Cone
 *
 * Staggered Cone spells will reach each cone level
 * gradually / with a delay, instead of affecting the entire
 * cone area at once.
 */
/datum/action/cooldown/spell/cone/staggered

	/// The delay between each cone level triggering.
	var/delay_between_level = 0.2 SECONDS

/datum/action/cooldown/spell/cone/staggered/make_cone(list/cone_turfs, atom/caster)
	var/level_counter = 0
	for(var/list/turf_list in cone_turfs)
		level_counter++
		addtimer(CALLBACK(src, .proc/do_cone_effects, turf_list, caster, level_counter), delay_between_level * level_counter)
