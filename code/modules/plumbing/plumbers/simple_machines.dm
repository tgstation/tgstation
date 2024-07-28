///We can empty beakers in here and everything
/obj/machinery/plumbing/input
	name = "input gate"
	desc = "Can be manually filled with reagents from containers."
	icon_state = "pipe_input"
	pass_flags_self = PASSMACHINE | LETPASSTHROW // Small
	reagent_flags = TRANSPARENT | REFILLABLE

/obj/machinery/plumbing/input/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, bolt, layer)

///We can fill beakers in here and everything. we dont inheret from input because it has nothing that we need
/obj/machinery/plumbing/output
	name = "output gate"
	desc = "A manual output for plumbing systems, for taking reagents directly into containers."
	icon_state = "pipe_output"
	pass_flags_self = PASSMACHINE | LETPASSTHROW // Small
	reagent_flags = TRANSPARENT | DRAINABLE
	reagents = /datum/reagents

/obj/machinery/plumbing/output/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, bolt, layer)

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

/obj/machinery/plumbing/tank/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/tank, bolt, layer)

///Layer manifold machine that connects a bunch of layers
/obj/machinery/plumbing/layer_manifold
	name = "layer manifold"
	desc = "A plumbing manifold for layers."
	icon_state = "manifold"
	density = FALSE

/obj/machinery/plumbing/layer_manifold/Initialize(mapload, bolt, layer)
	. = ..()

	AddComponent(/datum/component/plumbing/manifold, bolt, FIRST_DUCT_LAYER)
	AddComponent(/datum/component/plumbing/manifold, bolt, SECOND_DUCT_LAYER)
	AddComponent(/datum/component/plumbing/manifold, bolt, THIRD_DUCT_LAYER)
	AddComponent(/datum/component/plumbing/manifold, bolt, FOURTH_DUCT_LAYER)
	AddComponent(/datum/component/plumbing/manifold, bolt, FIFTH_DUCT_LAYER)
