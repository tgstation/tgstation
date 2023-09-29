/**
 * Attached to a basic mob that will then be able to tear down a wall after some time.
 */
/datum/element/tear_wall
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 3
	/// The rate at which we can break regular walls
	var/regular_tear_time
	/// The rate at which we can break reinforced walls
	var/reinforced_tear_time

/datum/element/tear_wall/Attach(datum/target, regular_tear_time = 2 SECONDS, reinforced_tear_time = 4 SECONDS)
	. = ..()
	if(!isbasicmob(target))
		return ELEMENT_INCOMPATIBLE

	src.regular_tear_time = regular_tear_time
	src.reinforced_tear_time = reinforced_tear_time
	RegisterSignal(target, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(attack_wall))

/datum/element/bonus_damage/Detach(datum/source)
	UnregisterSignal(source, COMSIG_HOSTILE_POST_ATTACKINGTARGET)
	return ..()

/// Checks if we are attacking a wall
/datum/element/tear_wall/proc/attack_wall(mob/living/basic/attacker, atom/target, success)
	SIGNAL_HANDLER

	if(!iswallturf(target))
		return
	var/turf/closed/wall/thewall = target
	var/prying_time = regular_tear_time
	if(istype(thewall, /turf/closed/wall/r_wall))
		prying_time = reinforced_tear_time
	INVOKE_ASYNC(src, PROC_REF(async_attack_wall), attacker, thewall, prying_time)

/// Performs taking down the wall
/datum/element/tear_wall/proc/async_attack_wall(mob/living/basic/attacker, turf/closed/wall/thewall, prying_time)
	if(DOING_INTERACTION_WITH_TARGET(attacker, thewall))
		attacker.balloon_alert(attacker, "busy!")
		return
	to_chat(attacker, span_warning("You begin tearing through the wall..."))
	playsound(attacker, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
	if(do_after(attacker, prying_time, target = thewall))
		if(isopenturf(thewall))
			return
		thewall.dismantle_wall(1)
		playsound(attacker, 'sound/effects/meteorimpact.ogg', 100, TRUE)
