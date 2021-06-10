/*
 * An element that makes mobs run into lockers when they bump into them.
 */

/datum/element/skittish
	element_flags = ELEMENT_DETACH

/datum/element/skittish/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_MOVABLE_BUMP, .proc/Bump)

/datum/element/skittish/Detach(datum/target)
	UnregisterSignal(target, COMSIG_MOVABLE_BUMP)
	. = ..()

/datum/element/skittish/proc/Bump(mob/living/scooby, atom/target)
	SIGNAL_HANDLER
	if(scooby.stat != CONSCIOUS || scooby.m_intent != MOVE_INTENT_RUN)
		return

	if(!istype(target, /obj/structure/closet))
		return

	var/obj/structure/closet/closet = target

	if(!closet.divable)
		// Things like secure crates can blow up under certain circumstances
		return

	var/turf/closet_turf = get_turf(closet)

	if(!closet.opened)
		if(closet.locked)
			closet.togglelock(scooby, silent = TRUE)
		if(!closet.open(scooby))
			// No message if unable to open, since this is on Bump, spammy potential
			return

	// If it's a crate, "dive for cover" and start resting so people can jump into crates without slamming the lid on their head
	if(closet.horizontal)
		// need to rest before moving, otherwise "can't get crate to close" message will be printed erroneously
		scooby.set_resting(TRUE, silent = TRUE)

	scooby.forceMove(closet_turf)

	if(!closet.close(scooby))
		to_chat(scooby, "<span class='warning'>You can't get [closet] to close!</span>")
		if(closet.horizontal)
			scooby.set_resting(FALSE, silent = TRUE)
		return

	closet.togglelock(scooby, silent = TRUE)

	if(closet.horizontal)
		scooby.set_resting(FALSE, silent = TRUE)

	closet_turf.visible_message("<span class='warning'>[scooby] dives into [closet]!</span>")
	// If you run into a locker, you don't want to run out immediately
	scooby.Immobilize(0.5 SECONDS)
