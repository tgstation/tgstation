/obj/item/circuitboard/machine/engine
	name = "Shuttle Engine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/shuttle_engine
	needs_anchored = FALSE
	req_components = list(
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/micro_laser = 2,
	)

/obj/item/circuitboard/machine/engine/heater
	name = "Shuttle Engine Heater"
	build_path = /obj/machinery/power/shuttle_engine/heater

/obj/item/circuitboard/machine/engine/propulsion
	name = "Shuttle Engine Propulsion"
	build_path = /obj/machinery/power/shuttle_engine/propulsion
