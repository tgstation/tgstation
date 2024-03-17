GLOBAL_LIST_INIT(atmos_piping_layers, list(
	"First Layer" = 1,
	"Second Layer" = 2,
	"Third Layer" = 3,
	"Fourth Layer" = 4,
	"Fifth Layer" = 5,
))

/datum/forklift_module/atmos // TODO; get an atmos coder to fix this thing, it don't work
	name = "Atmospherics"
	current_selected_typepath = /obj/machinery/atmospherics/pipe/smart
	available_builds = list(
		/obj/machinery/atmospherics/pipe/smart,
		/obj/machinery/atmospherics/pipe/layer_manifold,
		/obj/machinery/atmospherics/pipe/color_adapter,
		/obj/machinery/atmospherics/pipe/bridge_pipe,
		/obj/machinery/atmospherics/pipe/multiz,
		/obj/machinery/atmospherics/components/unary/portables_connector,
		/obj/machinery/atmospherics/components/binary/pump,
		/obj/machinery/atmospherics/components/binary/volume_pump,
		/obj/machinery/atmospherics/components/trinary/filter,
		/obj/machinery/atmospherics/components/trinary/mixer,
		/obj/machinery/atmospherics/components/binary/passive_gate,
		/obj/machinery/atmospherics/components/unary/outlet_injector,
		/obj/machinery/atmospherics/components/unary/vent_scrubber,
		/obj/machinery/atmospherics/components/unary/vent_pump,
		/obj/machinery/atmospherics/components/unary/passive_vent,
		/obj/machinery/atmospherics/components/binary/valve,
		/obj/machinery/atmospherics/components/binary/valve/digital,
		/obj/machinery/atmospherics/components/binary/pressure_valve,
		/obj/machinery/atmospherics/components/binary/temperature_gate,
		/obj/machinery/atmospherics/components/binary/temperature_pump,
		/obj/machinery/atmospherics/pipe/heat_exchanging/simple,
		/obj/machinery/atmospherics/pipe/heat_exchanging/manifold,
		/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w,
		/obj/machinery/atmospherics/pipe/heat_exchanging/junction,
		/obj/machinery/atmospherics/components/unary/heat_exchanger,
	)
	resource_price = list(
		/obj/machinery/atmospherics/pipe/smart = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/pipe/layer_manifold = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/pipe/color_adapter = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/pipe/bridge_pipe = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/pipe/multiz = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/components/unary/portables_connector = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/components/binary/pump = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/components/binary/volume_pump = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/components/trinary/filter = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/components/trinary/mixer = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/components/binary/passive_gate = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/components/unary/outlet_injector = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/components/unary/vent_scrubber = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/components/unary/vent_pump = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/components/unary/passive_vent = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/components/binary/valve = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/components/binary/valve/digital = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/components/binary/pressure_valve = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/components/binary/temperature_gate = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/components/binary/temperature_pump = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/pipe/heat_exchanging/simple = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/pipe/heat_exchanging/manifold = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/pipe/heat_exchanging/junction = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/obj/machinery/atmospherics/components/unary/heat_exchanger = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,
		),
	)
	build_length = 1 SECONDS
	build_instantly = TRUE
	var/list/available_layers = list(
		"First Layer",
		"Second Layer",
		"Third Layer",
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
	var/selected_layer = "First Layer"

/datum/forklift_module/atmos/create_atom(atom/clickingon)
	var/obj/machinery/atmospherics/built_machine = new current_selected_typepath(get_turf(clickingon), , ,)
	built_machine.setDir(direction)
	built_machine.on = FALSE
	built_machine.on_construction(GLOB.pipe_paint_colors[selected_color], GLOB.atmos_piping_layers[selected_layer])
	return built_machine

/datum/forklift_module/atmos/on_middle_click(mob/source, atom/clickingon)
	selected_layer = next_list_item(selected_layer, available_layers)
	playsound(src, 'sound/effects/pop.ogg', 50, FALSE)
	my_forklift.balloon_alert(source, selected_layer)

/datum/forklift_module/atmos/on_alt_scrollwheel(mob/source, atom/A, scrolled_up)
	if(scrolled_up)
		selected_color = next_list_item(selected_color, available_colors)
	else
		selected_color = previous_list_item(selected_color, available_colors)
	playsound(src, 'sound/effects/pop.ogg', 50, FALSE)
	my_forklift.balloon_alert(source, selected_color)

/datum/forklift_module/atmos/valid_placement_location(location)
	if(!isopenturf(location))
		return FALSE
	. = TRUE
