/datum/component/heat_sensitive
	var/max_heat
	var/min_heat
	var/atom/target

/datum/component/heat_sensitive/Initialize(max, min)
	if(!isatom(parent)) //How
		return COMPONENT_INCOMPATIBLE
	max_heat = max
	min_heat = min
	target = get_atom_on_turf(parent)
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/reset_targeting) //If our holder moves, move our turf watcher
	RegisterSignal(get_turf(target), COMSIG_TURF_EXPOSE, .proc/check_requirements)

/datum/component/heat_sensitive/proc/reset_targeting()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(get_turf(target), COMSIG_TURF_EXPOSE)
	target = get_atom_on_turf(parent)
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/reset_targeting)
	RegisterSignal(get_turf(target), COMSIG_TURF_EXPOSE, .proc/check_requirements)

/datum/component/heat_sensitive/proc/check_requirements(datum/source, datum/gas_mixture/mix, heat, volume)
	if(max_heat && heat >= max_heat)
		SEND_SIGNAL(parent, COMSIG_HEAT_HOT, mix, heat, volume)
	if(min_heat && heat <= min_heat)
		SEND_SIGNAL(parent, COMSIG_HEAT_COLD, mix, heat, volume)
