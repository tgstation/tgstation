/datum/component/waddling
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

/datum/component/waddling/Initialize()
	. = ..()
	if(!ismovableatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(isliving(parent))
		RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), .proc/LivingWaddle)
	else
		RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), .proc/Waddle)

/datum/component/waddling/proc/LivingWaddle()
	var/mob/living/L = parent
	if(L.incapacitated() || !(L.mobility_flags & MOBILITY_STAND))
		return
	Waddle()

/datum/component/waddling/proc/Waddle()
	animate(parent, pixel_z = 4, time = 0)
	animate(pixel_z = 0, transform = turn(matrix(), pick(-12, 0, 12)), time=2)
	animate(pixel_z = 0, transform = matrix(), time = 0)
