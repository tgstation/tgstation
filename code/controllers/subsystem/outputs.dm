SUBSYSTEM_DEF(outputs)
	name = "Outputs"
	init_order = INIT_ORDER_OUTPUTS
	flags = SS_NO_FIRE
	var/list/outputs = list()

	//echo lists
	var/list/echo_blacklist
	var/list/needs_flattening

/datum/controller/subsystem/outputs/Initialize(timeofday)
	for(var/A in subtypesof(/datum/outputs))
		outputs[A] = new A
	echo_blacklist = typecacheof(list(
	/obj/effect,
	/obj/screen,
	/image)
	)

	needs_flattening = typecacheof(list(
	/obj/structure/table)
	)

	return ..()

