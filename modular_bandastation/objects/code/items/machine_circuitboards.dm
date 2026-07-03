/obj/item/circuitboard/machine/teapot
	name = "Чайник"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/teapot
	req_components = list(
		/datum/stock_part/capacitor = 1,
		/datum/stock_part/matter_bin = 1,
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/sheet/glass = 5
		)
	needs_anchored = FALSE

/datum/techweb_node/cafeteria_equip/New()
	. = ..()
	design_ids += "teapot"
