/datum/reagent
	///how good we are at being lubricant and how good the flow is.
	var/viscosity = 0

/datum/reagent/proc/circulator_process(obj/machinery/atmospherics/components/binary/circulator/source, datum/gas_mixture/removed_gas)
