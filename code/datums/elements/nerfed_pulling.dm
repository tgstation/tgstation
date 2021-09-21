/// This living will be slower when pulling/moving some dangerous objects in its obj_flags
/datum/element/nerfed_pulling
	element_flags = ELEMENT_DETACH

	var/static/list/nerf_pulling_of_typecache = typecacheof(list(
		/obj/machinery/portable_atmospherics/canister,
		/obj/structure/reagent_dispensers,
	))

/datum/element/nerfed_pulling/Attach(datum/target)
	. = ..()

	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_LIVING_PUSHING_MOVABLE, .proc/on_push_movable)
	RegisterSignal(target, COMSIG_LIVING_UPDATING_PULL_MOVESPEED, .proc/on_updating_pull_movespeed)

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
	addtimer(CALLBACK(source, /mob/proc/remove_movespeed_modifier, /datum/movespeed_modifier/nerfed_bump), 1 SECONDS, TIMER_OVERRIDE | TIMER_UNIQUE)

/datum/element/nerfed_pulling/proc/on_updating_pull_movespeed(mob/living/source)
	SIGNAL_HANDLER

	if (!will_slow_down(source.pulling))
		source.remove_movespeed_modifier(/datum/movespeed_modifier/nerfed_pull)
		return

	source.add_movespeed_modifier(/datum/movespeed_modifier/nerfed_pull)

/datum/element/nerfed_pulling/proc/will_slow_down(datum/input)
	return nerf_pulling_of_typecache[input.type]

/datum/movespeed_modifier/nerfed_pull
	multiplicative_slowdown = 5.5

/datum/movespeed_modifier/nerfed_bump
	multiplicative_slowdown = 5.5
