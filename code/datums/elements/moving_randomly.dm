/// Just move something around in the simplest way possible
/datum/element/moving_randomly
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

	/// Movables that we are moving around
	var/list/movers = list()

/datum/element/moving_randomly/Attach(datum/target)
	. = ..()

	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	movers += target

/datum/element/moving_randomly/Detach(datum/source, ...)
	. = ..()

	movers -= source

/datum/element/moving_randomly/New()
	START_PROCESSING(SSdcs, src)

/datum/element/moving_randomly/process(seconds_per_tick)
	for(var/atom/movable/mover as anything in movers)
		mover.Move(get_step(mover, pick(GLOB.alldirs)))
