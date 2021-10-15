/obj/machinery/limbgrower/infinite
	production_coefficient = 0

/obj/machinery/limbgrower/infinite/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/medicine/c2/synthflesh, reagents.maximum_volume)

/obj/machinery/limbgrower/infinite/RefreshParts()
	return

/obj/machinery/limbgrower/infinite/can_build(datum/design/limb_design)
	return TRUE
