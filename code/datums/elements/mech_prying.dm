/datum/element/mech_prying
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/pry_time = 5 SECONDS
	var/enclosed_time_multiplier = 0.5 // 5 SECONDS vs 3 SECONDS for enclosed mechs

/datum/element/mech_prying/Attach(datum/target, time_to_pry)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	if(time_to_pry)
		pry_time = time_to_pry

	RegisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(try_pry_mech))

/datum/element/mech_prying/Detach(datum/source)
	UnregisterSignal(source, COMSIG_HOSTILE_PRE_ATTACKINGTARGET)
	return ..()

/datum/element/mech_prying/proc/try_pry_mech(mob/living/johnny, atom/target)
	SIGNAL_HANDLER

	if(!istype(target, /obj/vehicle/sealed/mecha))
		return

	// Check if mob is in combat mode
	if(johnny.combat_mode)
		// If in combat mode, let the attack go through normally
		return

	var/obj/vehicle/sealed/mecha/target_mech = target

	// Check if mech is empty or only has AI pilot
	if(!LAZYLEN(target_mech.occupants) || (LAZYLEN(target_mech.occupants) == 1 && target_mech.mecha_flags & SILICON_PILOT))
		target_mech.balloon_alert(johnny, "it's empty!")
		return COMPONENT_HOSTILE_NO_ATTACK

	INVOKE_ASYNC(src, PROC_REF(do_pry_mech), johnny, target_mech)
	return COMPONENT_HOSTILE_NO_ATTACK

/datum/element/mech_prying/proc/do_pry_mech(mob/living/johnny, obj/vehicle/sealed/mecha/target_mech)
	// Log the initial attempt
	johnny.log_message("tried to pry open [target_mech], located at [loc_name(target_mech)], which is currently occupied by [target_mech.occupants.Join(", ")].", LOG_ATTACK)

	var/mech_dir = target_mech.dir
	target_mech.balloon_alert(johnny, "prying open...")
	playsound(target_mech, 'sound/machines/airlock/airlock_alien_prying.ogg', 100, TRUE)

	// Calculate pry time based on if mech is enclosed
	var/actual_pry_time = (target_mech.mecha_flags & IS_ENCLOSED) ? (pry_time * enclosed_time_multiplier) : pry_time

	if(!do_after(johnny, actual_pry_time, target_mech, extra_checks = CALLBACK(src, PROC_REF(extra_checks), target_mech, mech_dir, johnny)))
		target_mech.balloon_alert(johnny, "interrupted!")
		return

	// Log the successful pry
	johnny.log_message("pried open [target_mech], located at [loc_name(target_mech)], which is currently occupied by [target_mech.occupants.Join(", ")].", LOG_ATTACK)

	// Eject all non-AI occupants
	for(var/mob/living/occupant as anything in target_mech.occupants)
		if(isAI(occupant))
			continue
		target_mech.mob_exit(occupant, randomstep = TRUE)

	playsound(target_mech, 'sound/machines/airlock/airlockforced.ogg', 75, TRUE)

/datum/element/mech_prying/proc/extra_checks(obj/vehicle/sealed/mecha/mech, mech_dir, mob/living/johnny)
	// Also verify the mob hasn't switched to combat mode during the prying
	if(johnny.combat_mode)
		return FALSE
	return LAZYLEN(mech.occupants) && mech.dir == mech_dir
