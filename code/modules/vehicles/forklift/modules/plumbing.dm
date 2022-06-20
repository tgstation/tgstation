/datum/forklift_module/plumbing // TODO: make ctrl-wheel adjust the selected layer
	name = "Plumbing"
	current_selected_typepath = /obj/machinery/duct
	available_builds = list(
		/obj/machinery/duct,
		/obj/machinery/plumbing/input,
		/obj/machinery/plumbing/output,
		/obj/machinery/plumbing/tank,
		/obj/machinery/plumbing/synthesizer,
		/obj/machinery/plumbing/reaction_chamber,
		/obj/machinery/plumbing/buffer,
		/obj/machinery/plumbing/layer_manifold,
		/obj/machinery/plumbing/pill_press,
		/obj/machinery/plumbing/acclimator,
		/obj/machinery/plumbing/bottler,
		/obj/machinery/plumbing/disposer,
		/obj/machinery/plumbing/fermenter,
		/obj/machinery/plumbing/filter,
		/obj/machinery/plumbing/grinder_chemical,
		/obj/machinery/plumbing/liquid_pump,
		/obj/machinery/plumbing/splitter,
		/obj/machinery/plumbing/sender,
		/obj/machinery/plumbing/growing_vat,
		/obj/machinery/iv_drip/plumbing,
	)
	resource_price = list(
		/obj/machinery/duct = list(
			/datum/material/plastic = MINERAL_MATERIAL_AMOUNT * 1,
		),
		/obj/machinery/plumbing/input = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/plumbing/output = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/plumbing/tank = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 20,
		),
		/obj/machinery/plumbing/synthesizer = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 15,
		),
		/obj/machinery/plumbing/reaction_chamber = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 15,
		),
		/obj/machinery/plumbing/buffer = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 10,
		),
		/obj/machinery/plumbing/layer_manifold = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/plumbing/pill_press = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 20,
		),
		/obj/machinery/plumbing/acclimator = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 10,
		),
		/obj/machinery/plumbing/bottler = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 50,
		),
		/obj/machinery/plumbing/disposer = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 10,
		),
		/obj/machinery/plumbing/fermenter = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 30,
		),
		/obj/machinery/plumbing/filter = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/plumbing/grinder_chemical = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 30,
		),
		/obj/machinery/plumbing/liquid_pump = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 35,
		),
		/obj/machinery/plumbing/splitter = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/plumbing/sender = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 20,
		),
		/obj/machinery/plumbing/growing_vat = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 20,
		),
		/obj/machinery/iv_drip/plumbing = list(
			/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 20,
		),
	)
	build_length = 1 SECONDS
	build_instantly = TRUE

/datum/forklift_module/plumbing/valid_placement_location(location)
	if(istype(location, /turf/open/floor))
		return TRUE
	else
		return FALSE
