/datum/component/radiation_detector
	var/current_tick_radiation_count = 0

/datum/component/radiation_detector/Initialize()
	START_PROCESSING(SSobj, src)

/datum/component/radiation_detector/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_RAD_CONTAMINATING, .proc/rad_act)

/datum/component/radiation_detector/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_RAD_CONTAMINATING)

/datum/component/radiation_detector/process(delta_time)
	parent.radiation_count = LPFILTER(parent.radiation_count, current_tick_radiation_count, delta_time, RAD_GEIGER_RC)
	
	if(current_tick_radiation_count)
		grace = RAD_GEIGER_GRACE_PERIOD
	else
		grace -= delta_time
		if(grace <= 0)
			parent.radiation_count = 0
	
	current_tick_radiation_count = 0

/datum/component/radiation_detector/rad_act(datum/source, strength)
	SIGNAL_HANDLER
	
	current_tick_radiation_count += strength
	
	return COMPONENT_BLOCK_CONTAMINATION // Before the contamination issue gets fixed at least the component that detects radiation shouldn't cause more contamination
	