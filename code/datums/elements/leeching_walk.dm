/// Buffs and heals the target while standing on rust.
/datum/element/leeching_walk
	var/healing_multiplier = 1.0 // How much healing to do

/datum/element/leeching_walk/Attach(datum/target)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(target, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/element/leeching_walk/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_LIFE))

/*
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Checks if we should have baton resistance on the new turf.
 */
/datum/element/leeching_walk/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/turf/mover_turf = get_turf(source)
	if(HAS_TRAIT(mover_turf, TRAIT_RUSTY))
		ADD_TRAIT(source, TRAIT_BATON_RESISTANCE, type)
	else
		REMOVE_TRAIT(source, TRAIT_BATON_RESISTANCE, type)

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Gradually heals the heretic ([source]) on rust,
 * including baton knockdown and stamina damage.
 */
/datum/element/leeching_walk/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	var/turf/our_turf = get_turf(source)
	if(!HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return

	// Heals all damage + Stamina
	var/need_mob_update = FALSE
	var/delta_time = DELTA_WORLD_TIME(SSmobs) * 0.5 // SSmobs.wait is 2 secs, so this should be halved.
	need_mob_update += source.adjust_brute_loss(-3 * delta_time * healing_multiplier, updating_health = FALSE)
	need_mob_update += source.adjust_fire_loss(-3 * delta_time * healing_multiplier, updating_health = FALSE)
	need_mob_update += source.adjust_tox_loss(-3 * delta_time * healing_multiplier, updating_health = FALSE, forced = TRUE) // Slimes are people too
	need_mob_update += source.adjust_oxy_loss(-1.5 * delta_time * healing_multiplier, updating_health = FALSE)
	need_mob_update += source.adjust_stamina_loss(-10 * delta_time * healing_multiplier, updating_stamina = FALSE)
	if(need_mob_update)
		source.updatehealth()
		new /obj/effect/temp_visual/heal(get_turf(source), COLOR_BROWN)
	// Reduces duration of stuns/etc
	source.AdjustAllImmobility((-0.5 SECONDS) * delta_time)
	// Heals blood loss
	source.adjust_blood_volume(2.5 * delta_time, maximum = BLOOD_VOLUME_NORMAL)
	// Slowly regulates your body temp
	source.adjust_bodytemperature((source.get_body_temp_normal() - source.bodytemperature) / 5)

/datum/element/leeching_walk/minor
	healing_multiplier = 0.5

// Minor variant which heals slightly less and no baton resistance
/datum/element/leeching_walk/minor/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	return
