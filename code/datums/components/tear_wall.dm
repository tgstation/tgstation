/**
 * Attached to a basic mob that will then be able to tear down a wall after some time.
 */
/datum/component/tear_wall
	/// The rate at which we can break regular walls
	var/regular_tear_time = 2 SECONDS
	/// The rate at which we can break reinforced walls
	var/reinforced_tear_time = 4 SECONDS
	/// If we are already deconstructing a wall
	var/tearing_wall = FALSE

/datum/component/tear_wall/Initialize(regular_tear_time = 2 SECONDS, reinforced_tear_time = 4 SECONDS)
	if(!isbasicmob(parent))
		return ELEMENT_INCOMPATIBLE

	src.regular_tear_time = regular_tear_time
	src.reinforced_tear_time = reinforced_tear_time

/datum/component/tear_wall/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(attack_wall))

/datum/component/tear_wall/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HOSTILE_POST_ATTACKINGTARGET)

/// Checks if we are attacking a wall
/datum/component/tear_wall/proc/attack_wall(mob/living/basic/attacker, atom/target, success)
	SIGNAL_HANDLER

	if(!iswallturf(target))
		return
	var/turf/closed/wall/thewall = target
	var/prying_time = regular_tear_time
	if(istype(thewall, /turf/closed/wall/r_wall))
		prying_time = reinforced_tear_time
	INVOKE_ASYNC(src, PROC_REF(async_attack_wall), attacker, thewall, prying_time)

/// Performs taking down the wall
/datum/component/tear_wall/proc/async_attack_wall(mob/living/basic/attacker, turf/closed/wall/thewall, prying_time)
	if(tearing_wall)
		return
	tearing_wall = TRUE
	to_chat(attacker, span_warning("You begin tearing through the wall..."))
	playsound(attacker, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
	if(do_after(attacker, prying_time, target = thewall))
		if(isopenturf(thewall))
			return
		thewall.dismantle_wall(1)
		playsound(attacker, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	tearing_wall = FALSE
