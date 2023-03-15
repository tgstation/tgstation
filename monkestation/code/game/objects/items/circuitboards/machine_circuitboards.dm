/obj/item/circuitboard/machine/bountypad
	name = "Civilian Bounty Pad (Machine Board)"
	build_path = /obj/machinery/piratepad/civilian
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/micro_laser = 1
	)

/obj/item/circuitboard/machine/electrolyzer
	name = "Electrolyzer (Machine Board)"
	build_path = /obj/machinery/electrolyzer
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/cable_coil = 3,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/sheet/mineral/gold = 1,
		/obj/item/stack/sheet/mineral/silver = 1)

	needs_anchored = FALSE

/obj/item/circuitboard/machine/atmos_machine
	name = "evaporation machine (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/atmos_machine
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell = 1)
	needs_anchored = FALSE
