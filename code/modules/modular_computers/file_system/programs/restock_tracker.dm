/datum/computer_file/program/restock_tracker
	filename = "restockapp"
	filedesc = "NT Restock Tracker"
	downloader_category = PROGRAM_CATEGORY_SUPPLY
	program_open_overlay = "restock"
	extended_desc = "Nanotrasen IoT network listing all the vending machines found on station, and how well stocked they are each. Profitable!"
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	can_run_on_flags = PROGRAM_ALL
	size = 4
	program_icon = "cash-register"
	tgui_id = "NtosRestock"

/datum/computer_file/program/restock_tracker/ui_data()
	var/list/data = list()
	var/list/vending_list = list()
	var/id_increment = 1
	for(var/obj/machinery/vending/vendor as anything in GLOB.vending_machines_to_restock)
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
