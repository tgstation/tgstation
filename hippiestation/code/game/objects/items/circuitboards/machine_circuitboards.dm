/obj/item/circuitboard/machine/clonepod	//hippie start, re-add cloning
	name = "Clone Pod (Machine Board)"
	build_path = /obj/machinery/clonepod
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/clonepod/experimental
	name = "Experimental Clone Pod (Machine Board)"
	build_path = /obj/machinery/clonepod/experimental
	icon_state = "medical"
	build_path = /obj/machinery/clonepod/experimental

/obj/item/circuitboard/machine/clonescanner	//hippie end, re-add cloning
	name = "Cloning Scanner (Machine Board)"
	icon_state = "medical"
	build_path = /obj/machinery/dna_scannernew
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 2)
