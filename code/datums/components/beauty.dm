/datum/component/beauty
	var/beauty = 0

/datum/component/beauty/Initialize(beautyamount)
	if(!isatom(parent) || isarea(parent))
		return COMPONENT_INCOMPATIBLE

	beauty = beautyamount

	if(ismovable(parent))
		RegisterSignal(parent, COMSIG_ENTER_AREA, .proc/enter_area)
		RegisterSignal(parent, COMSIG_EXIT_AREA, .proc/exit_area)

	var/area/A = get_area(parent)
	if(A)
		enter_area(null, A)

/datum/component/beauty/proc/enter_area(datum/source, area/A)
	SIGNAL_HANDLER

	if(A.outdoors)
		return
	A.totalbeauty += beauty
	A.update_beauty()

/datum/component/beauty/proc/exit_area(datum/source, area/A)
	SIGNAL_HANDLER

	if(A.outdoors)
		return
	A.totalbeauty -= beauty
	A.update_beauty()

/datum/component/beauty/Destroy()
	. = ..()
	var/area/A = get_area(parent)
	if(A)
		exit_area(null, A)
