/obj/machinery/computer/security/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/nanomaps),
	)

/obj/machinery/computer/security/ui_static_data()
	var/list/data = ..()
	data["mapData"] = SSmapping.get_map_ui_data()
	return data
