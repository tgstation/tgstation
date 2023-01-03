/// This living will be slower when pulling/moving anything in the given typecache
/datum/element/nerfed_pulling
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2

	/// The typecache of things that shouldn't be easily movable
	var/list/typecache

/datum/element/nerfed_pulling/Attach(datum/target, list/typecache)
	. = ..()

	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.typecache = typecache

	RegisterSignal(target, COMSIG_LIVING_PUSHING_MOVABLE, PROC_REF(on_push_movable))
	RegisterSignal(target, COMSIG_LIVING_UPDATING_PULL_MOVESPEED, PROC_REF(on_updating_pull_movespeed))

/datum/element/nerfed_pulling/Detach(mob/living/source)
	source.remove_movespeed_modifier(/datum/movespeed_modifier/nerfed_bump)
	source.remove_movespeed_modifier(/datum/movespeed_modifier/nerfed_pull)

	UnregisterSignal(source, list(COMSIG_LIVING_PUSHING_MOVABLE, COMSIG_LIVING_UPDATING_PULL_MOVESPEED))

	return ..()

/datum/element/nerfed_pulling/proc/on_push_movable(mob/living/source, atom/movable/being_pushed)
	SIGNAL_HANDLER

	if (!will_slow_down(being_pushed))
		return

	source.add_movespeed_modifier(/datum/movespeed_modifier/nerfed_bump)
	addtimer(CALLBACK(source, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/nerfed_bump), 1 SECONDS, TIMER_OVERRIDE | TIMER_UNIQUE)

/datum/element/nerfed_pulling/proc/on_updating_pull_movespeed(mob/living/source)
	SIGNAL_HANDLER

	if (!will_slow_down(source.pulling))
		source.remove_movespeed_modifier(/datum/movespeed_modifier/nerfed_pull)
		return

	source.add_movespeed_modifier(/datum/movespeed_modifier/nerfed_pull)

/datum/element/nerfed_pulling/proc/will_slow_down(datum/input)
	return !isnull(input) && typecache[input.type]

/datum/movespeed_modifier/nerfed_pull
	multiplicative_slowdown = 5.5

/datum/movespeed_modifier/nerfed_bump
	multiplicative_slowdown = 5.5
