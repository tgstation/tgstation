/datum/crewmonitor/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/nanomaps),
	)

/datum/crewmonitor/ui_static_data(mob/user)
	var/list/data = list()
	data["mapData"] = SSmapping.get_map_ui_data()
	return data

/**
 * Open an individual UI for each possible machine or object
 * Cause we need tgui_shared_state
 */
/obj/machinery/computer/crew/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CrewConsole220")
		ui.open()

/obj/machinery/computer/crew/ui_data(mob/user)
	return GLOB.crewmonitor.ui_data(user)

/obj/machinery/computer/crew/ui_static_data(user)
	return GLOB.crewmonitor.ui_static_data(user)

/obj/machinery/computer/crew/ui_assets(user)
	return GLOB.crewmonitor.ui_assets(user)

// Handheld Crew Monitor
/obj/item/sensor_device/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CrewConsole220")
		ui.open()

/obj/item/sensor_device/ui_data(mob/user)
	return GLOB.crewmonitor.ui_data(user)

/obj/item/sensor_device/ui_static_data(user)
	return GLOB.crewmonitor.ui_static_data(user)

/obj/item/sensor_device/ui_assets(user)
	return GLOB.crewmonitor.ui_assets(user)
