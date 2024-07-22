///Used to change name for apcs on away missions
/obj/machinery/power/apc/worn_out
	name = "Worn out APC"

/obj/machinery/power/apc/auto_name
	auto_name = TRUE

/obj/machinery/power/apc/auto_name/high_capacity
	cell_type = /obj/item/stock_parts/power_store/battery/high

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/power/apc/worn_out, APC_PIXEL_OFFSET)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/power/apc/auto_name, APC_PIXEL_OFFSET)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/power/apc/auto_name/high_capacity, APC_PIXEL_OFFSET)
