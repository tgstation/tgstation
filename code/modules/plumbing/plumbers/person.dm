/obj/machinery/plumbing/milker
	name = "people milker"
	desc = "A mechanical rig with an input leading to the mouth and an output leading to... my god."

	icon_state = "acclimator"
	buffer = 200

	can_buckle = TRUE

/obj/machinery/plumbing/milker/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/milker, bolt)
