/datum/component/constant_emp

/datum/component/constant_emp/Initialize()
	if(!ismovableatom(parent))
		. = COMPONENT_INCOMPATIBLE
		CRASH("[type] added to a [parent.type]")

	START_PROCESSING(SSprocessing, src)

/datum/component/constant_emp/process()
	var/atom/movable/AM = parent
	AM.emp_act(EMP_HEAVY)
