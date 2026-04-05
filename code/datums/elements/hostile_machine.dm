/// AIs will attack this as a potential target if they see it
/datum/element/hostile_machine
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/hostile_machine/Attach(datum/target)
	. = ..()

	if (!isatom(target))
		return ELEMENT_INCOMPATIBLE

#ifdef UNIT_TESTS
	if(!GLOB.target_interested_atoms[target.type])
		stack_trace("Tried to make a hostile machine without updating ai targeting to include it, they must be synced")
#endif

	if(ismovable(target))
		RegisterSignal(target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_z_change))

	add_to_z(target)

/datum/element/hostile_machine/Detach(datum/source)
	UnregisterSignal(source, COMSIG_MOVABLE_Z_CHANGED)
	remove_from_z(source)
	return ..()

/datum/element/hostile_machine/proc/on_z_change(atom/movable/source, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER

	if(same_z_layer)
		return
	remove_from_z(source, old_turf.z)
	add_to_z(source, new_turf.z)

/datum/element/hostile_machine/proc/add_to_z(atom/target, z)
	if(isnull(z))
		var/turf/target_turf = get_turf(target)
		z = target_turf?.z
	if(!z)
		return
	if(!GLOB.hostile_machines_by_z[z])
		GLOB.hostile_machines_by_z[z] = list()
	GLOB.hostile_machines_by_z[z] |= target

/datum/element/hostile_machine/proc/remove_from_z(atom/target, z)
	if(isnull(z))
		var/turf/target_turf = get_turf(target)
		z = target_turf?.z
	if(!z)
		return
	GLOB.hostile_machines_by_z[z] -= target
	if(!length(GLOB.hostile_machines_by_z[z]))
		GLOB.hostile_machines_by_z -= z
