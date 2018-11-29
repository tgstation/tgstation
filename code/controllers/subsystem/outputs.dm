SUBSYSTEM_DEF(outputs)
	name = "outputs"
	init_order = INIT_ORDER_OUTPUTS
	flags = SS_NO_FIRE
	var/list/outputs = list()

/datum/controller/subsystem/outputs/Initialize(timeofday)
	for(var/A in subtypesof(/datum/outputs))
		new A()
	return ..()
