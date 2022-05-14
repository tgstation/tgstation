/datum/component/machine_power_modifier
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// Multiplier for the idle power consumption of the attached machine.
	var/idle_power_multiplier = 1
	/// Multiplier for the active power consumption of the attached machine.
	var/active_power_multiplier = 1
	/// Trait to give to the machine we're getting attached to.
	var/trait_to_add
	/// Objects to drop when the machine is deconstructed.
	var/list/objects_to_drop

/datum/component/machine_power_modifier/Initialize(idle_power_multiplier = 1, active_power_multiplier = 1, trait_to_add, list/objects_to_drop)
	if(!ismachinery(parent) || istype(parent, /obj/machinery/power) || istype(parent, /obj/machinery/computer))
		return COMPONENT_INCOMPATIBLE
	src.idle_power_multiplier = idle_power_multiplier
	src.active_power_multiplier = active_power_multiplier
	RegisterSignal(parent, COMSIG_MACHINERY_REFRESH_PARTS, .proc/on_refresh_parts)
	if(objects_to_drop?.len)
		RegisterSignal(parent, COMSIG_OBJ_DECONSTRUCT, .proc/on_machine_deconstruct)
		src.objects_to_drop = objects_to_drop
	if(trait_to_add)
		src.trait_to_add = trait_to_add
		ADD_TRAIT(parent, trait_to_add, REF(src))

/datum/component/machine_power_modifier/Destroy(force, silent)
	UnregisterSignal(parent, list(COMSIG_MACHINERY_REFRESH_PARTS, COMSIG_OBJ_DECONSTRUCT))
	if(trait_to_add)
		REMOVE_TRAIT(parent, trait_to_add, REF(src))
	return ..()

/**
 * What to do when the machine we're attached to refreshes its parts.
 */
/datum/component/machine_power_modifier/proc/on_refresh_parts(obj/machinery/source)
	SIGNAL_HANDLER

	source.idle_power_usage *= idle_power_multiplier
	source.active_power_usage *= active_power_multiplier
	source.update_current_power_usage()

/**
 * What to do when the machine we're attached to is deconstructed.
 */
/datum/component/machine_power_modifier/proc/on_machine_deconstruct(obj/machinery/source)
	SIGNAL_HANDLER

	for(var/obj in objects_to_drop)
		for(var/i in 1 to objects_to_drop[obj])
			new obj(source.loc)
