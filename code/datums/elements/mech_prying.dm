/datum/element/mech_prying
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/pry_time = 5 SECONDS
	var/enclosed_time_multiplier = 5/3 // 5 SECONDS vs 3 SECONDS for enclosed mechs

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

/datum/element/mech_prying/proc/try_pry_mech(mob/living/basic/source, atom/target)
	SIGNAL_HANDLER

	if(!istype(target, /obj/vehicle/sealed/mecha))
		return

	// Check if mob is in combat mode
	if(source.combat_mode)
		// If in combat mode, let the attack go through normally
		return

/*
	// For xenos, check if they're not in disarm mode (if they have that capability)
	if(istype(source, /mob/living/carbon/alien))
		var/mob/living/carbon/alien/alien_source = source
		if(alien_source.a_intent != INTENT_DISARM)
			return
*/
	var/obj/vehicle/sealed/mecha/target_mech = target

	// Check if mech is empty or only has AI pilot
	if(!LAZYLEN(target_mech.occupants) || (LAZYLEN(target_mech.occupants) == 1 && target_mech.mecha_flags & SILICON_PILOT))
		target_mech.balloon_alert(source, "it's empty!")
		return COMPONENT_HOSTILE_NO_ATTACK

	INVOKE_ASYNC(src, PROC_REF(do_pry_mech), source, target_mech)
	return COMPONENT_HOSTILE_NO_ATTACK

/datum/element/mech_prying/proc/do_pry_mech(mob/living/basic/source, obj/vehicle/sealed/mecha/target_mech)
	// Log the initial attempt
	source.log_message("tried to pry open [target_mech], located at [loc_name(target_mech)], which is currently occupied by [target_mech.occupants.Join(", ")].", LOG_ATTACK)

	var/mech_dir = target_mech.dir
	target_mech.balloon_alert(source, "prying open...")
	playsound(target_mech, 'sound/machines/airlock/airlock_alien_prying.ogg', 100, TRUE)

	// Calculate pry time based on if mech is enclosed
	var/actual_pry_time = (target_mech.mecha_flags & IS_ENCLOSED) ? (pry_time * enclosed_time_multiplier) : pry_time

	if(!do_after(source, actual_pry_time, target_mech, extra_checks = CALLBACK(src, PROC_REF(extra_checks), target_mech, mech_dir, source)))
		target_mech.balloon_alert(source, "interrupted!")
		return

	// Log the successful pry
	source.log_message("pried open [target_mech], located at [loc_name(target_mech)], which is currently occupied by [target_mech.occupants.Join(", ")].", LOG_ATTACK)

	// Eject all non-AI occupants
	for(var/mob/living/occupant as anything in target_mech.occupants)
		if(isAI(occupant))
			continue
		target_mech.mob_exit(occupant, randomstep = TRUE)

	playsound(target_mech, 'sound/machines/airlock/airlockforced.ogg', 75, TRUE)

/datum/element/mech_prying/proc/extra_checks(obj/vehicle/sealed/mecha/mech, mech_dir, mob/living/basic/source)
	// Also verify the mob hasn't switched to combat mode during the prying
	if(source.combat_mode)
		return FALSE
/*
	// For xenos, verify they're still in disarm mode
	if(istype(source, /mob/living/carbon/alien))
		var/mob/living/carbon/alien/alien_source = source
		if(alien_source.a_intent != INTENT_DISARM)
			return FALSE
*/
	return LAZYLEN(mech.occupants) && mech.dir == mech_dir
