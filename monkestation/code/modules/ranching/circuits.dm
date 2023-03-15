/obj/item/circuitboard/machine/egg_incubator
	name = "incubator (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/egg_incubator
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/chicken_grinder
	name = "the grinder (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/chicken_grinder
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE


/obj/item/circuitboard/machine/feed_machine
	name = "feed machine (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/feed_machine
	req_components = list(
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE
