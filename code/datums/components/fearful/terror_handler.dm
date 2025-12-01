/// Terror handlers, aka datums which determine current fear behaviors.
/// Separated into two groups, fear sources and fear effects, latter processing after all former are finished
/datum/terror_handler
	/// Owner of this fear handler
	var/mob/living/owner
	/// Component which "houses" this handler
	var/datum/component/fearful/component
	/// Type of this handler, determines if it should run in the first or second batch
	var/handler_type = TERROR_HANDLER_SOURCE
	/// Is this a "default" handler? If so, it will be added to any fearful component unless its initialized with add_defaults = FALSE
	var/default = FALSE
	/// Other effects which should be disabled while this one is running
	var/list/overrides

/datum/terror_handler/New(mob/living/new_owner, datum/component/fearful/new_component)
	. = ..()
	owner = new_owner
	component = new_component

/datum/terror_handler/Destroy(force)
	owner = null
	component = null
	return ..()

/// Single tick of terror handler, returns adjustment to terror buildup
/datum/terror_handler/proc/tick(seconds_per_tick, terror_buildup)
	return 0
