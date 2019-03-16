SUBSYSTEM_DEF(outputs)
	name = "Outputs"
	init_order = INIT_ORDER_OUTPUTS
	flags = SS_NO_FIRE
	var/list/outputs = list()

/datum/controller/subsystem/outputs/Initialize(timeofday)
	for(var/A in subtypesof(/datum/outputs))
		outputs[A] = new A
	return ..()
