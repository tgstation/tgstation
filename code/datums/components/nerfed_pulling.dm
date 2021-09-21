/// This atom will be slower when pulling/moving into an object with HAS_NERFED_PULLING in its obj_flags
/datum/component/nerfed_pulling

/datum/component/nerfed_pulling/Initialize()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/nerfed_pulling/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_PUSHING_MOVABLE, .proc/on_push_movable)
	RegisterSignal(parent, COMSIG_LIVING_UPDATING_PULL_MOVESPEED, .proc/on_updating_pull_movespeed)

/datum/component/nerfed_pulling/Destroy(force, silent)
	var/mob/living/living_parent = parent

	living_parent.remove_movespeed_modifier(/datum/movespeed_modifier/nerfed_bump)
	living_parent.remove_movespeed_modifier(/datum/movespeed_modifier/nerfed_pull)

	return ..()

/datum/component/nerfed_pulling/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_PUSHING_MOVABLE, COMSIG_LIVING_UPDATING_PULL_MOVESPEED))

/datum/component/nerfed_pulling/proc/on_push_movable(mob/living/source, atom/movable/being_pushed)
	SIGNAL_HANDLER

	if (!will_slow_down(being_pushed))
		return

	source.add_movespeed_modifier(/datum/movespeed_modifier/nerfed_bump)
	addtimer(CALLBACK(source, /mob/proc/remove_movespeed_modifier, /datum/movespeed_modifier/nerfed_bump), 1 SECONDS, TIMER_OVERRIDE | TIMER_UNIQUE)

/datum/component/nerfed_pulling/proc/on_updating_pull_movespeed(mob/living/source)
	SIGNAL_HANDLER

	if (!will_slow_down(source.pulling))
		source.remove_movespeed_modifier(/datum/movespeed_modifier/nerfed_pull)
		return

	source.add_movespeed_modifier(/datum/movespeed_modifier/nerfed_pull)

/datum/component/nerfed_pulling/proc/will_slow_down(obj/input)
	return isobj(input) && (input.obj_flags & HAS_NERFED_PULLING)

/datum/movespeed_modifier/nerfed_pull
	multiplicative_slowdown = 5.5

/datum/movespeed_modifier/nerfed_bump
	multiplicative_slowdown = 5.5
