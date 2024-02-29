
/**
 * The restock tracker computer keeps tabs on which vending machines on station are running low on stock.
 * It can be used by cargo technicians to quickly find out which machines need to be restocked, and rewards crew
 */

/obj/machinery/computer/restock_tracker
	name = "restock tracker"
	desc = "A computer that tracks how well stocked the station's vending machines are."
	circuit = /obj/item/circuitboard/computer/restock

/obj/machinery/computer/restock_tracker/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Restock", name)
		ui.open()

/obj/machinery/computer/restock_tracker/ui_data(mob/living/carbon/human/user)
	. = ..()
	var/list/data = list()
	var/list/vending_list = list()
	var/id_increment = 1
	for(var/obj/machinery/vending/vendor in GLOB.vending_machines_to_restock)
		var/stock = vendor.total_loaded_stock()
		var/max_stock = vendor.total_max_stock()
		if((max_stock == 0 || (stock >= max_stock)) && vendor.credits_contained == 0)
			continue
		vending_list += list(list(
			"name" = vendor.name,
			"location" = get_area_name(vendor),
			"credits" = vendor.credits_contained,
			"percentage" = (stock / max_stock) * 100,
			"id" = id_increment,
		))
		id_increment++
	data["vending_list"] = vending_list
	return data
