/**
 * # Wall Smasher
 * An element you put on mobs to let their attacks break walls
 * If put in the hands of a player this can cause a lot of problems, be careful
 */
/datum/element/wall_smasher
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Either ENVIRONMENT_SMASH_WALLS or ENVIRONMENT_SMASH_RWALLS, as in '_DEFINES/mobs.dm'
	var/strength_flag

/datum/element/wall_smasher/Attach(datum/target, strength_flag = ENVIRONMENT_SMASH_WALLS)
	. = ..()
	if (. == ELEMENT_INCOMPATIBLE)
		return ELEMENT_INCOMPATIBLE
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.strength_flag = strength_flag
	RegisterSignal(target, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarm_attack)) // Players
	RegisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_pre_attackingtarget)) // AI

	if (isanimal_or_basicmob(target))
		var/mob/living/simple_animal/animal_target = target
		animal_target.environment_smash = strength_flag

/datum/element/wall_smasher/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HOSTILE_PRE_ATTACKINGTARGET))
	if (isanimal_or_basicmob(target))
		var/mob/living/simple_animal/animal_target = target
		animal_target.environment_smash = initial(animal_target.environment_smash)

	return ..()

/datum/element/wall_smasher/proc/on_unarm_attack(mob/living/puncher, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	return try_smashing(puncher, target)

/datum/element/wall_smasher/proc/on_pre_attackingtarget(mob/living/puncher, atom/target)
	SIGNAL_HANDLER
	return try_smashing(puncher, target)

/datum/element/wall_smasher/proc/try_smashing(mob/living/puncher, atom/target)
	if (!isturf(target))
		return NONE
	if (isfloorturf(target))
		return NONE
	if (isindestructiblewall(target))
		return NONE

	puncher.changeNext_move(CLICK_CD_MELEE)
	puncher.do_attack_animation(target)

	if (ismineralturf(target))
		var/turf/closed/mineral/mineral_wall = target
		mineral_wall.gets_drilled(puncher)
		return COMPONENT_HOSTILE_NO_ATTACK

	if (!iswallturf(target)) // In case you're some kind of non-wall non-mineral closed turf yet to be invented
		return COMPONENT_HOSTILE_NO_ATTACK

	var/turf/closed/wall/wall_turf = target

	if (istype(wall_turf, /turf/closed/wall/r_wall) && strength_flag != ENVIRONMENT_SMASH_RWALLS)
		playsound(wall_turf, 'sound/effects/bang.ogg', 50, vary = TRUE)
		wall_turf.balloon_alert(puncher, "too tough!")
		return COMPONENT_HOSTILE_NO_ATTACK

	wall_turf.dismantle_wall(devastated = TRUE)
	playsound(wall_turf, 'sound/effects/meteorimpact.ogg', 100, vary = TRUE)
	return COMPONENT_HOSTILE_NO_ATTACK
