/datum/forklift_module/plumbing
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
			/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 1,
		),
		/obj/machinery/plumbing/input = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/plumbing/output = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/plumbing/tank = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 20,
		),
		/obj/machinery/plumbing/synthesizer = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 15,
		),
		/obj/machinery/plumbing/reaction_chamber = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 15,
		),
		/obj/machinery/plumbing/buffer = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10,
		),
		/obj/machinery/plumbing/layer_manifold = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/plumbing/pill_press = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 20,
		),
		/obj/machinery/plumbing/acclimator = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10,
		),
		/obj/machinery/plumbing/bottler = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 50,
		),
		/obj/machinery/plumbing/disposer = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10,
		),
		/obj/machinery/plumbing/fermenter = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 30,
		),
		/obj/machinery/plumbing/filter = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/plumbing/grinder_chemical = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 30,
		),
		/obj/machinery/plumbing/liquid_pump = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 35,
		),
		/obj/machinery/plumbing/splitter = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/plumbing/sender = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 20,
		),
		/obj/machinery/plumbing/growing_vat = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 20,
		),
		/obj/machinery/iv_drip/plumbing = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 20,
		),
	)
	build_length = 1 SECONDS
	build_instantly = TRUE
	var/list/available_layers = list(
		"First Layer",
		"Second Layer",
		"Default Layer",
		"Fourth Layer",
		"Fifth Layer",
	)
	var/list/available_colors = list(
		"green",
		"blue",
		"red",
		"orange",
		"cyan",
		"dark",
		"yellow",
		"brown",
		"pink",
		"purple",
		"violet",
		"omni",
	)
	var/selected_color = "omni"
	var/selected_layer = "Default Layer"

/datum/forklift_module/plumbing/create_atom(atom/clickingon)
	var/atom/created_atom
	if(ispath(current_selected_typepath, /obj/machinery/duct))
		var/is_omni = selected_color == DUCT_COLOR_OMNI
		created_atom = new current_selected_typepath(get_turf(clickingon), FALSE, GLOB.pipe_paint_colors[selected_color], GLOB.plumbing_layers[selected_layer], null, is_omni)
	else
		created_atom = new current_selected_typepath(get_turf(clickingon), FALSE, GLOB.plumbing_layers[selected_layer])
	return created_atom

/datum/forklift_module/plumbing/on_alt_scrollwheel(mob/source, atom/A, scrolled_up)
	if(scrolled_up)
		selected_layer = next_list_item(selected_layer, available_layers)
	else
		selected_layer = previous_list_item(selected_layer, available_layers)
	playsound(src, 'sound/effects/pop.ogg', 50, FALSE)
	my_forklift.balloon_alert(source, selected_layer)

/datum/forklift_module/plumbing/on_ctrl_scrollwheel(mob/source, atom/A, scrolled_up)
	if(current_selected_typepath != /obj/machinery/duct)
		return ..()
	if(scrolled_up)
		selected_color = next_list_item(selected_color, available_colors)
	else
		selected_color = previous_list_item(selected_color, available_colors)
	playsound(src, 'sound/effects/pop.ogg', 50, FALSE)
	my_forklift.balloon_alert(source, selected_color)

/datum/forklift_module/plumbing/valid_placement_location(location)
	if(!isopenturf(location))
		return FALSE
	. = TRUE
	var/turf/turf_to_check = get_turf(location)

	var/layer_id = GLOB.plumbing_layers[selected_layer]

	for(var/obj/content_obj in turf_to_check.contents)
		// make sure plumbling isn't overlapping.
		for(var/datum/component/plumbing/plumber as anything in content_obj.GetComponents(/datum/component/plumbing))
			if(plumber.ducting_layer & layer_id)
				return FALSE

		if(istype(content_obj, /obj/machinery/duct))
			// Make sure ducts aren't overlapping.
			var/obj/machinery/duct/duct_machine = content_obj
			if(duct_machine.duct_layer & layer_id)
				return FALSE
