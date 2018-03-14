/datum/component/beauty
	var/beauty = 0

/datum/component/beauty/Initialize(beautyamount)
	if(!ismovableatom(parent))
		. = COMPONENT_INCOMPATIBLE
		CRASH("Someone put a beauty component on a non-atom/movable, not everything can be pretty.")
	beauty = beautyamount
	RegisterSignal(COMSIG_ENTER_AREA, .proc/enter_area)
	RegisterSignal(COMSIG_EXIT_AREA, .proc/exit_area)
	var/area/A = get_area(parent)
	if(!A || A.outdoors)
		return
	A.totalbeauty += beauty
	A.update_beauty()

/datum/component/beauty/proc/enter_area(area/A)
	if(A.outdoors) //Fuck the outside.
		return FALSE
	A.totalbeauty += beauty
	A.update_beauty()

/datum/component/beauty/proc/exit_area(area/A)
	if(A.outdoors) //Fuck the outside.
		return FALSE
	A.totalbeauty -= beauty
	A.update_beauty()

/datum/component/beauty/Destroy()
	. = ..()
	var/area/A = get_area(parent)
	if(!A || A.outdoors)
		return
	A.totalbeauty -= beauty
	A.update_beauty()
