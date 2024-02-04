#define LOW_STOCK_THRESHOLD 75

/**
 * The restock tracker computer keeps tabs on which vending machines on station are running low on stock.
 * It can be used by cargo technicians to quickly find out which machines need to be restocked, and rewards crew
 */

/obj/machinery/computer/restock_tracker
	name = "restock tracker"
	desc = "A computer that tracks how well stocked the station's vending machines are."

/obj/machinery/computer/restock_tracker/examine(mob/user)
	. = ..()

	for(var/obj/machinery/vending/vm as anything in GLOB.vending_machines_to_restock)
		var/stock = vm.total_loaded_stock()
		var/max_stock = vm.total_max_stock()
		var/percentage = (stock / max_stock) * 100
		. += span_notice("\The [vm] in [get_area_name(vm)] has [percentage]% stock remaining.")
		if(percentage < LOW_STOCK_THRESHOLD)
			. += span_notice("Shit's low!")
