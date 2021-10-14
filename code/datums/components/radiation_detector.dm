/datum/component/radiation_detector
	var/current_tick_radiation_count = 0
	var/radiation_count = 0
	var/grace = 0

/datum/component/radiation_detector/Initialize()
	START_PROCESSING(SSobj, src)

/datum/component/radiation_detector/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_RAD_CONTAMINATING, .proc/rad_contaminate)
	RegisterSignal(parent, COMSIG_ATOM_RAD_ACT, .proc/rad_update)

/datum/component/radiation_detector/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_RAD_CONTAMINATING)
	UnregisterSignal(parent, COMSIG_ATOM_RAD_ACT)

/datum/component/radiation_detector/process(delta_time)
	radiation_count = LPFILTER(radiation_count, current_tick_radiation_count, delta_time, RAD_GEIGER_RC)
	if(current_tick_radiation_count)
		grace = RAD_GEIGER_GRACE_PERIOD
	else
		grace -= delta_time
		if(grace <= 0)
			radiation_count = 0

	current_tick_radiation_count = 0
	
	SEND_SIGNAL(parent, COMSIG_RADIATION_DETECTOR_UPDATE, radiation_count)

/datum/component/radiation_detector/proc/rad_contaminate(datum/source, strength)
	SIGNAL_HANDLER
	return COMPONENT_BLOCK_CONTAMINATION // Before the contamination issue gets fixed at least the component that detects radiation shouldn't cause more contamination

/datum/component/radiation_detector/proc/rad_update(datum/source,strength)
	SIGNAL_HANDLER
	current_tick_radiation_count += strength
