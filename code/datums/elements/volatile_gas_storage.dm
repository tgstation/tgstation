/datum/element/volatile_gas_storage
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	var/minimum_explosive_pressure
	var/max_explosive_pressure
	var/max_explosive_force

/datum/element/volatile_gas_storage/Attach(datum/target, minimum_explosive_pressure=5000, max_explosive_pressure=100000, max_explosive_force=9)
	. = ..()
	if(istype(target, /obj/machinery/portable_atmospherics))
		RegisterSignal(target, COMSIG_OBJ_BREAK, .proc/PortableBreak)
	else if(istype(target, /obj/machinery/atmospherics/components))
		RegisterSignal(target, COMSIG_OBJ_BREAK, .proc/AtmosComponentBreak)
	else
		return ELEMENT_INCOMPATIBLE

	src.minimum_explosive_pressure = minimum_explosive_pressure
	src.max_explosive_pressure = max_explosive_pressure
	src.max_explosive_force = max_explosive_force

/datum/element/volatile_gas_storage/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_OBJ_BREAK)

/datum/element/volatile_gas_storage/proc/Break(atom/origin, datum/gas_mixture/released_gas)
	var/expelled_pressure = min(released_gas?.return_pressure(), max_explosive_pressure)

	if(expelled_pressure < minimum_explosive_pressure)
		return

	var/explosive_force = CEILING((expelled_pressure / max_explosive_pressure) * max_explosive_force , 1)
	// This is supposed to represent only shrapnel and no fire
	// Maybe one day we'll get something a bit better
	explosion(get_turf(origin), light_impact_range=explosive_force, smoke=FALSE)

/datum/element/volatile_gas_storage/proc/PortableBreak(obj/machinery/portable_atmospherics/owner)
	SIGNAL_HANDLER
	Break(owner, owner.air_contents)

/datum/element/volatile_gas_storage/proc/AtmosComponentBreak(obj/machinery/atmospherics/components/owner)
	SIGNAL_HANDLER
	for(var/datum/gas_mixture/gas_contents as anything in owner.airs)
		if(!gas_contents)
			continue
		Break(owner, gas_contents)
