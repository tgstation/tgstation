/// Buffs and heals the target while standing on rust.
/datum/element/rust_healing
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// How much HP to heal per second
	var/heal_amount
	/// How much stamina to heal per second
	var/stamina_heal_amount

/datum/element/rust_healing/Attach(atom/target, baton_resistance = TRUE, heal_amount = 3, stamina_heal_amount = 10)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	if (baton_resistance)
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(target, COMSIG_LIVING_LIFE, PROC_REF(on_life))

	src.heal_amount = heal_amount
	src.stamina_heal_amount = stamina_heal_amount
	ADD_TRAIT(target, TRAIT_RUSTIMMUNE, ELEMENT_TRAIT(type))

/datum/element/rust_healing/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_LIFE))
	REMOVE_TRAIT(source, TRAIT_RUSTIMMUNE, ELEMENT_TRAIT(type))

/*
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Checks if we should have baton resistance on the new turf.
 */
/datum/element/rust_healing/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	if(source.is_touching_rust())
		ADD_TRAIT(source, TRAIT_BATON_RESISTANCE, type)
	else
		REMOVE_TRAIT(source, TRAIT_BATON_RESISTANCE, type)

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Gradually heals the heretic ([source]) on rust,
 * including baton knockdown and stamina damage.
 */
/datum/element/rust_healing/proc/on_life(mob/living/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(!source.is_touching_rust())
		return

	// Heals all damage + Stamina
	var/need_mob_update = FALSE
	var/delta_time = DELTA_WORLD_TIME(SSmobs) * 0.5 // SSmobs.wait is 2 secs, so this should be halved.
	need_mob_update += source.adjust_brute_loss(-heal_amount * delta_time, updating_health = FALSE)
	need_mob_update += source.adjust_fire_loss(-heal_amount * delta_time, updating_health = FALSE)
	need_mob_update += source.adjust_tox_loss(-heal_amount * delta_time, updating_health = FALSE, forced = TRUE) // Slimes are people too
	need_mob_update += source.adjust_oxy_loss(-heal_amount / 2 * delta_time, updating_health = FALSE)
	need_mob_update += source.adjust_stamina_loss(-stamina_heal_amount * delta_time, updating_stamina = FALSE)
	if(need_mob_update)
		source.updatehealth()
		new /obj/effect/temp_visual/heal(get_turf(source), COLOR_BROWN)
	// Reduces duration of stuns/etc
	source.AdjustAllImmobility((-0.5 SECONDS) * delta_time)
	// Heals blood loss
	source.adjust_blood_volume(2.5 * delta_time, maximum = BLOOD_VOLUME_NORMAL)
	// Slowly regulates your body temp
	source.adjust_bodytemperature((source.get_body_temp_normal() - source.bodytemperature) / 5)
