/// Movables with this component will automatically return to their original turf if moved outside their initial area
/datum/component/areabound
	var/area/bound_area
	var/turf/reset_turf
	var/datum/movement_detector/move_tracker

/datum/component/areabound/Initialize()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	bound_area = get_area(parent)
	reset_turf = get_turf(parent)
	move_tracker = new(parent,CALLBACK(src,.proc/check_bounds))

/datum/component/areabound/proc/check_bounds()
	var/atom/movable/AM = parent
	var/area/current = get_area(AM)
	if(current != bound_area)
		if(!reset_turf || reset_turf.loc != bound_area)
			stack_trace("Invalid areabound configuration") //qdel(src)
			return
		AM.forceMove(reset_turf)

/datum/component/areabound/Destroy(force, silent)
	QDEL_NULL(move_tracker)
	. = ..()
