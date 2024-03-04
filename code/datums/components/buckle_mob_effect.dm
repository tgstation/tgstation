
/**
 * # Buckle mob effect component
 *
 * A mob with this component will continously apply a callback while its buckled to a mob
 * Intended for slimes draining your life force, leeches drinking your blood, snakes constricting you
 *
 */

/datum/component/buckle_mob_effect
///Callback to be ran when we are processing
	var/datum/callback/mob_effect_callback


/datum/component/buckle_mob_effect/Initialize(datum/callback/mob_effect_callback)

	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	if(isnull(mob_effect_callback))
		CRASH("Initialised buckle_mob_effect component with no buckle effect callback.")

	src.mob_effect_callback = mob_effect_callback

/datum/component/buckle_mob_effect/Destroy(force)
	mob_effect_callback = null
	return ..()

/datum/component/buckle_mob_effect/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOB_BUCKLED, PROC_REF(on_buckled))
	RegisterSignal(parent, COMSIG_MOB_UNBUCKLED, PROC_REF(on_unbuckled))

/datum/component/buckle_mob_effect/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_MOB_BUCKLED, COMSIG_MOB_UNBUCKLED))
	stop_buckle_effect()

/datum/component/buckle_mob_effect/process(seconds_per_tick = SSMOBS_DT)
	var/mob/living/our_leech = parent
	if(our_leech.stat == DEAD)
		stop_buckle_effect()
		return FALSE

	if(mob_effect_callback)
		mob_effect_callback.Invoke(seconds_per_tick)

///Start processing if we are attached to a mob/living, do not suck out the life of chairs
/datum/component/buckle_mob_effect/proc/on_buckled(atom/movable/buckle_target)
	SIGNAL_HANDLER

	if(!isliving(buckle_target))
		return

	START_PROCESSING(SSobj, src)

///If we are unbuckled, stop processing
/datum/component/buckle_mob_effect/proc/on_unbuckled(atom/movable/buckle_target)
	SIGNAL_HANDLER
	stop_buckle_effect()

///Effects to perform when the buckle is done
/datum/component/buckle_mob_effect/proc/stop_buckle_effect()
	STOP_PROCESSING(SSobj, src)
