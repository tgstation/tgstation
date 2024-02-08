/// Movables with this component will automatically return to their original turf if moved outside their initial area
/datum/component/areabound
	var/area/bound_area
	var/turf/reset_turf
	var/datum/movement_detector/move_tracker
	var/moving = FALSE //Used to prevent infinite recursion if your reset turf places you somewhere on enter or something

/datum/component/areabound/Initialize()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	bound_area = get_area(parent)
	reset_turf = get_turf(parent)
	move_tracker = new(parent,CALLBACK(src, PROC_REF(check_bounds)))

/datum/component/areabound/proc/check_bounds()
	var/atom/movable/AM = parent
	var/area/current = get_area(AM)
	if(current != bound_area)
		if(!reset_turf || reset_turf.loc != bound_area)
			stack_trace("Invalid areabound configuration") //qdel(src)
			return
		if(moving)
			stack_trace("Moved during a reset move, giving up to prevent infinite recursion. Turf: [reset_turf.type] at [reset_turf.x], [reset_turf.y], [reset_turf.z]")
			return
		moving = TRUE
		AM.forceMove(reset_turf)
		moving = FALSE

/datum/component/areabound/Destroy(force)
	QDEL_NULL(move_tracker)
	. = ..()
