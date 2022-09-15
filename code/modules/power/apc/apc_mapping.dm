/obj/machinery/power/apc/unlocked
	locked = FALSE

/obj/machinery/power/apc/syndicate //general syndicate access
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/power/apc/away //general away mission access
	req_access = list(ACCESS_AWAY_GENERAL)

/obj/machinery/power/apc/highcap/five_k
	cell_type = /obj/item/stock_parts/cell/upgraded/plus

/obj/machinery/power/apc/highcap/ten_k
	cell_type = /obj/item/stock_parts/cell/high

/obj/machinery/power/apc/auto_name
	auto_name = TRUE

/obj/machinery/power/apc/sm_apc
	auto_name = TRUE
	cell_type = /obj/item/stock_parts/cell/high

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/power/apc/auto_name, APC_PIXEL_OFFSET)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/power/apc/highcap/five_k, APC_PIXEL_OFFSET)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/power/apc/highcap/ten_k, APC_PIXEL_OFFSET)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/power/apc/sm_apc, APC_PIXEL_OFFSET)
