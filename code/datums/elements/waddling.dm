/datum/element/waddling
	element_flags = ELEMENT_DETACH
	var/list/waddle_tracker = list()

/datum/element/waddling/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	if(isliving(target))
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/LivingWaddle)
	else
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/Waddle)
	waddle_tracker[target] = 0

/datum/element/waddling/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	waddle_tracker -= source

/datum/element/waddling/proc/LivingWaddle(mob/living/target)
	if(target.incapacitated() || !(target.mobility_flags & MOBILITY_STAND))
		return
	Waddle(target)

/datum/element/waddling/proc/Waddle(atom/movable/target)
	if(world.time < waddle_tracker[target])
		return
	waddle_tracker[target] = world.time + 0.25 SECONDS
	animate(target, pixel_z = 4, time = 0)
	var/prev_trans = matrix(target.transform)
	animate(pixel_z = 0, transform = turn(target.transform, pick(-12, 0, 12)), time=2)
	animate(pixel_z = 0, transform = prev_trans, time = 0)
