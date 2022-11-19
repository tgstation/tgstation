/**
 * # Wall Smasher
 * An element you put on mobs to let their attacks break walls
 */
/datum/element/wall_smasher
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// Whether you can smash RWalls or not
	var/strength_flag

/datum/element/wall_smasher/Attach(datum/target, strength_flag = ENVIRONMENT_SMASH_WALLS)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.strength_flag = strength_flag
	RegisterSignal(target, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarm_attack)) // Players
	RegisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_pre_attackingtarget)) // AI

/datum/element/wall_smasher/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HOSTILE_PRE_ATTACKINGTARGET))
	return ..()

/datum/element/wall_smasher/proc/on_unarm_attack(mob/living/puncher, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	try_smashing(puncher, target)

/datum/element/wall_smasher/proc/on_pre_attackingtarget(mob/living/puncher, atom/target)
	SIGNAL_HANDLER
	try_smashing(puncher, target)

/datum/element/wall_smasher/proc/try_smashing(mob/living/puncher, atom/target)
	if (!isturf(target))
		return
	if (isfloorturf(target))
		return
	if (isindestructiblewall(target))
		return

	. = COMPONENT_HOSTILE_NO_ATTACK
	puncher.changeNext_move(CLICK_CD_MELEE)
	puncher.do_attack_animation(target)

	if (ismineralturf(target))
		var/turf/closed/mineral/mineral_wall = target
		mineral_wall.gets_drilled(puncher)
		return

	if (!iswallturf(target)) // In case you're some kind of non-wall non-mineral closed turf yet to be invented
		return

	var/turf/closed/wall/wall_turf = target

	if (istype(wall_turf, /turf/closed/wall/r_wall) && strength_flag != ENVIRONMENT_SMASH_RWALLS)
		playsound(wall_turf, 'sound/effects/bang.ogg', 50, TRUE)
		wall_turf.balloon_alert(puncher, span_warning("too tough!"))
		return

	wall_turf.dismantle_wall(1)
	playsound(wall_turf, 'sound/effects/meteorimpact.ogg', 100, TRUE)
