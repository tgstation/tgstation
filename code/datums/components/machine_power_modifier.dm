/datum/component/machine_power_modifier
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/idle_power_multiplier = 1
	var/active_power_multiplier = 1

/datum/component/machine_power_modifier/Initialize(idle_power_multiplier, active_power_multiplier)
	if(!istype(parent, /obj/machinery) || istype(parent, /obj/machinery/power) || istype(parent, /obj/machinery/computer))
		return COMPONENT_INCOMPATIBLE
	src.idle_power_multiplier = idle_power_multiplier
	src.active_power_multiplier = active_power_multiplier
	RegisterSignal(parent, COMSIG_MACHINERY_REFRESH_PARTS, .proc/on_refresh_parts)
	RegisterSignal(parent, COMSIG_OBJ_DECONSTRUCT, .proc/on_machine_deconstruct)
	ADD_TRAIT(parent, TRAIT_MACHINE_POWER_UPGRADED, src)

/datum/component/machine_power_modifier/Destroy(force, silent)
	UnregisterSignal(parent, list(COMSIG_MACHINERY_REFRESH_PARTS, COMSIG_OBJ_DECONSTRUCT))
	REMOVE_TRAIT(parent, TRAIT_MACHINE_POWER_UPGRADED, src)
	return ..()

/datum/component/machine_power_modifier/proc/on_refresh_parts(obj/machinery/source)
	SIGNAL_HANDLER

	source.idle_power_usage *= idle_power_multiplier
	source.active_power_usage *= active_power_multiplier
	source.update_current_power_usage()

/datum/component/machine_power_modifier/proc/on_machine_deconstruct(obj/machinery/source)
	SIGNAL_HANDLER

	new /obj/item/stack/sheet/mineral/metal_hydrogen(source.loc, 2)
