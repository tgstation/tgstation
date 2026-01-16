///We can empty beakers in here and everything
/obj/machinery/plumbing/input
	name = "input gate"
	desc = "Can be manually filled with reagents from containers."
	icon_state = "pipe_input"
	pass_flags_self = PASSMACHINE | LETPASSTHROW // Small
	reagent_flags = TRANSPARENT | REFILLABLE

/obj/machinery/plumbing/input/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, layer)

///We can fill beakers in here and everything. we dont inheret from input because it has nothing that we need
/obj/machinery/plumbing/output
	name = "output gate"
	desc = "A manual output for plumbing systems, for taking reagents directly into containers."
	icon_state = "pipe_output"
	pass_flags_self = PASSMACHINE | LETPASSTHROW // Small
	reagent_flags = TRANSPARENT | DRAINABLE
	reagents = /datum/reagents

/obj/machinery/plumbing/output/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, layer, distinct_reagent_cap = 5)

///For pouring reagents from ducts directly into cups
/obj/machinery/plumbing/output/tap
	name = "drinking tap"
	desc = "A manual output for plumbing systems, for taking drinks directly into glasses."
	icon_state = "tap_output"

///For storing large volume of reagents
/obj/machinery/plumbing/tank
	name = "chemical tank"
	desc = "A massive chemical holding tank."
	icon_state = "tank"
	buffer = 400

/obj/machinery/plumbing/tank/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/tank, layer)

///Layer manifold machine that connects a bunch of layers
/obj/machinery/plumbing/layer_manifold
	name = "layer manifold"
	desc = "A plumbing manifold for layers."
	icon_state = "manifold"
	density = FALSE

/obj/machinery/plumbing/layer_manifold/Initialize(mapload, layer)
	. = ..()

	AddComponent(/datum/component/plumbing/manifold, FIRST_DUCT_LAYER)
	AddComponent(/datum/component/plumbing/manifold, SECOND_DUCT_LAYER)
	AddComponent(/datum/component/plumbing/manifold, THIRD_DUCT_LAYER)
	AddComponent(/datum/component/plumbing/manifold, FOURTH_DUCT_LAYER)
	AddComponent(/datum/component/plumbing/manifold, FIFTH_DUCT_LAYER)
