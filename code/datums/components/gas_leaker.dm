#define PROCESS_PORTABLE "portable"
#define PROCESS_COMPONENT "component"

/datum/component/gas_leaker
	var/process_type
	var/integrity_leak_percent
	var/leak_rate

/datum/component/gas_leaker/Initialize(integrity_leak_percent=0.9, leak_rate=1)
	. = ..()
	if(istype(parent, /obj/machinery/portable_atmospherics))
		process_type = PROCESS_PORTABLE
	else if(istype(parent, /obj/machinery/atmospherics/components))
		process_type = PROCESS_COMPONENT
	else
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_OBJ_TAKE_DAMAGE, .proc/start_processing)

	src.integrity_leak_percent = integrity_leak_percent
	src.leak_rate = leak_rate

/datum/component/gas_leaker/process()
	. = ..()
	switch(process_type)
		if(PROCESS_PORTABLE)
			. = process_portable()
		if(PROCESS_COMPONENT)
			. = process_component()
		else
			. = TRUE

/datum/component/gas_leaker/proc/start_processing()
	SIGNAL_HANDLER
	// We're totally a pipe network, dont tell anyone
	// This component needs to tick at the same rate as the atmos system
	SSair.networks += src

/datum/component/gas_leaker/proc/process_portable()
	var/obj/machinery/portable_atmospherics/master = parent
	return process_machine(master, list(master.air_contents))

/datum/component/gas_leaker/proc/process_component()
	var/obj/machinery/atmospherics/components/master = parent
	return process_machine(master, master.airs)

/datum/component/gas_leaker/proc/process_machine(obj/machinery/master, list/airs)
	. = TRUE
	if(master.machine_stat & BROKEN)
		return
	if(master.obj_integrity > master.max_integrity * integrity_leak_percent)
		return
	var/turf/location = get_turf(master)
	var/true_rate = (1 - (master.obj_integrity / master.max_integrity)) * leak_rate
	for(var/datum/gas_mixture/mix as anything in airs)
		var/pressure = mix.return_pressure()
		if(mix.release_gas_to(location.return_air(), pressure, true_rate))
			. = FALSE
			location.air_update_turf(FALSE, FALSE)
