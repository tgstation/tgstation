/obj/item/circuitboard/machine/rad_collector
	name = "Radiation Collector (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	desc = "Comes with a small amount solder of arranged in the corner: \"If you can read this, you're too close.\""
	build_path = /obj/machinery/power/rad_collector
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/sheet/plasmarglass = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

