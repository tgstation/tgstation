/**
 * spinny.dm
 *
 * It's a component that spins things a whole bunch, like [proc/dance_rotate] but without the sleeps)
*/
/datum/component/spinny
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// How many turns are left?
	var/steps_left
	/// Turns clockwise by default, or counterclockwise if the reverse argument is TRUE
	var/turn_degrees = 90

/datum/component/spinny/Initialize(steps = 12, reverse = FALSE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	steps_left = steps
	turn_degrees = (reverse ? -90 : 90)
	START_PROCESSING(SSfastprocess, src)

/datum/component/spinny/Destroy(force, silent)
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/component/spinny/process(delta_time)
	steps_left--
	var/atom/spinny_boy = parent
	if(!istype(spinny_boy) || steps_left <= 0)
		qdel(src)
		return

	// 25% chance to make 2 turns instead of 1 since the old dance_rotate wasn't strictly clockwise/counterclockwise
	spinny_boy.setDir(turn(spinny_boy.dir, turn_degrees * (prob(25) ? 2 : 1)))
