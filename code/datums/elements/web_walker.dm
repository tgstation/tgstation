/**
 * # Web Walker element
 *
 * A mob with this element will move more slowly when it's not stood on a webbed turf.
 */
/datum/element/web_walker
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Move speed modifier to apply when not stood on webs
	var/datum/movespeed_modifier/off_web_slowdown

/datum/element/web_walker/Attach(datum/target, datum/movespeed_modifier/off_web_slowdown)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.off_web_slowdown = off_web_slowdown

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/datum/element/web_walker/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

/// When we move, check if we're still on a web
/datum/element/web_walker/proc/on_moved(mob/living/source)
	SIGNAL_HANDLER

	var/obj/structure/spider/stickyweb/web = locate() in get_turf(source)
	if (web)
		source.remove_movespeed_modifier(off_web_slowdown)
	else
		source.add_movespeed_modifier(off_web_slowdown)
