#define PROCESS_COMPONENT "component"
#define PROCESS_MACHINE "machine"
#define PROCESS_OBJ "obj"

/// A component to leak gas over time from damaged objects with gas storage
/datum/component/gas_leaker
	/// Keeps track of what type we were attached to so we don't need to istype every process
	var/process_type

	/// The percent of max integrity that we start leaking. From 0 to 1
	var/integrity_leak_percent

	/// The rate at which gas leaks, you probably want this *very* low. From 0 to 1
	var/leak_rate

	/// Mirror of the machine var signifying whether this is live in the air subsystem
	var/atmos_processing = FALSE

/datum/component/gas_leaker/Initialize(integrity_leak_percent=0.9, leak_rate=1)
	. = ..()
	if(istype(parent, /obj/machinery/atmospherics/components))
		process_type = PROCESS_COMPONENT
	else if(istype(parent, /obj/machinery))
		process_type = PROCESS_MACHINE
	else if(isobj(parent))
		process_type = PROCESS_OBJ
	else
		return COMPONENT_INCOMPATIBLE

	src.integrity_leak_percent = integrity_leak_percent
	src.leak_rate = leak_rate

/datum/component/gas_leaker/Destroy(force, silent)
	SSair.stop_processing_machine(src)
	return ..()

/datum/component/gas_leaker/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_TAKE_DAMAGE, .proc/start_processing)

/datum/component/gas_leaker/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_TAKE_DAMAGE)

/datum/component/gas_leaker/proc/process_atmos()
	. = PROCESS_KILL
	switch(process_type)
		if(PROCESS_OBJ)
			. = process_obj(parent)
		if(PROCESS_MACHINE)
			. = process_machine(parent)
		if(PROCESS_COMPONENT)
			. = process_component(parent)

/datum/component/gas_leaker/proc/start_processing()
	SIGNAL_HANDLER
	// Hello fellow atmospherics machines, I too am definitely an atmos machine like you!
	// This component needs to tick at the same rate as the atmos system
	SSair.start_processing_machine(src)

/datum/component/gas_leaker/proc/process_obj(obj/master, list/airs=list())
	airs += master.return_air()
	return process_leak(master, airs)

/datum/component/gas_leaker/proc/process_machine(obj/machinery/master, list/airs=list())
	if(master.machine_stat & BROKEN)
		return PROCESS_KILL
	return process_obj(master, airs)

/datum/component/gas_leaker/proc/process_component(obj/machinery/atmospherics/components/master, list/airs=list())
	airs += master.airs
	return process_machine(master, airs)

/datum/component/gas_leaker/proc/process_leak(obj/master, list/airs)
	var/current_integrity = master.get_integrity()
	if(current_integrity > master.max_integrity * integrity_leak_percent)
		return PROCESS_KILL
	var/turf/location = get_turf(master)
	var/true_rate = (1 - (current_integrity / master.max_integrity)) * leak_rate
	for(var/datum/gas_mixture/mix as anything in airs)
		var/pressure = mix.return_pressure()
		if(mix.release_gas_to(location.return_air(), pressure, true_rate))
			location.air_update_turf(FALSE, FALSE)

#undef PROCESS_OBJ
#undef PROCESS_MACHINE
#undef PROCESS_COMPONENT
