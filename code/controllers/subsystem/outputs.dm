SUBSYSTEM_DEF(outputs)
	name = "Outputs"
	init_order = INIT_ORDER_OUTPUTS
	flags = SS_NO_FIRE
	var/list/outputs = list()

	//echo lists
	var/list/echo_blacklist
	var/list/uniques
	var/list/echo_images

/datum/controller/subsystem/outputs/Initialize(timeofday)
	for(var/A in subtypesof(/datum/outputs))
		outputs[A] = new A
	echo_blacklist = typecacheof(list(
	/atom/movable/lighting_object,
	/obj/effect,
	/obj/screen,
	/image,
	/turf/open,
	/area)
	)

	uniques = typecacheof(list(
	/obj/structure/table,
	/mob/living/carbon/human)
	)

	echo_images = list()

	return ..()
