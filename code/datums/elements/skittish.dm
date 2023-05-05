/*
 * An element that makes mobs run into lockers when they bump into them.
 */

/datum/element/skittish

/datum/element/skittish/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_MOVABLE_BUMP, PROC_REF(Bump))

/datum/element/skittish/Detach(datum/target)
	UnregisterSignal(target, COMSIG_MOVABLE_BUMP)
	. = ..()

/datum/element/skittish/proc/Bump(mob/living/scooby, atom/target)
	SIGNAL_HANDLER
	if(scooby.stat != CONSCIOUS || scooby.m_intent != MOVE_INTENT_RUN)
		return

	if(!istype(target, /obj/structure/locker))
		return

	var/obj/structure/locker/locker = target

	if(!locker.divable)
		// Things like secure crates can blow up under certain circumstances
		return

	var/turf/locker_turf = get_turf(locker)

	if(!locker.opened)
		if(locker.locked)
			locker.togglelock(scooby, silent = TRUE)
		if(!locker.open(scooby))
			// No message if unable to open, since this is on Bump, spammy potential
			return

	// If it's a crate, "dive for cover" and start resting so people can jump into crates without slamming the lid on their head
	if(locker.horizontal)
		// need to rest before moving, otherwise "can't get crate to close" message will be printed erroneously
		scooby.set_resting(TRUE, silent = TRUE)

	scooby.forceMove(locker_turf)

	if(!locker.close(scooby))
		to_chat(scooby, span_warning("You can't get [locker] to close!"))
		if(locker.horizontal)
			scooby.set_resting(FALSE, silent = TRUE)
		return

	locker.togglelock(scooby, silent = TRUE)

	if(locker.horizontal)
		scooby.set_resting(FALSE, silent = TRUE)

	locker_turf.visible_message(span_warning("[scooby] dives into [locker]!"))
	// If you run into a locker, you don't want to run out immediately
	scooby.Immobilize(0.5 SECONDS)
