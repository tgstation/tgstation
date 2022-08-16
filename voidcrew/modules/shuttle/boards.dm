/obj/item/circuitboard/machine/shuttle/engine/electric
	name = "Ion Thruster (Machine Board)"
	build_path = /obj/machinery/power/shuttle/engine/electric
	req_components = list(
		/obj/item/stock_parts/capacitor = 3,
		/obj/item/stock_parts/micro_laser = 3,
	)

/obj/item/circuitboard/machine/shuttle/engine/oil
	name = "Oil Thruster (Machine Board)"
	build_path = /obj/machinery/power/shuttle/engine/liquid/oil
	req_components = list(
		/obj/item/reagent_containers/cup/beaker = 4,
		/obj/item/stock_parts/micro_laser = 2,
	)

/obj/item/circuitboard/machine/shuttle/engine/void
	name = "Void Thruster (Machine Board)"
	build_path = /obj/machinery/power/shuttle/engine/void
	req_components = list(
		/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/micro_laser/quadultra = 1,
	)

/obj/item/circuitboard/machine/shuttle/engine/plasma
	name = "Plasma Thruster (Machine Board)"
	build_path = /obj/machinery/power/shuttle/engine/fueled/plasma
	req_components = list(
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/micro_laser = 1,
	)

/obj/item/circuitboard/machine/shuttle/engine/expulsion
	name = "Expulsion Thruster (Machine Board)"
	build_path = /obj/machinery/power/shuttle/engine/fueled/expulsion
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/matter_bin = 2,
	)

/obj/item/circuitboard/computer/shuttle/helm
	name = "Shuttle Helm (Computer Board)"
	build_path = /obj/machinery/computer/helm
