SUBSYSTEM_DEF(outputs)
	name = "Outputs"
	init_order = INIT_ORDER_OUTPUTS
	flags = SS_NO_FIRE
	var/list/outputs = list()

/datum/controller/subsystem/outputs/Initialize(timeofday)
	for(var/A in subtypesof(/datum/outputs))
		var/datum/O = new A()
		outputs[O.type] = O
	return ..()
