/datum/computer_file/program/navigator
	filename = "ntos_navigator"
	filedesc = "Навигатор"
	extended_desc = "Просмотр вашего текущего местоположения, и карты станции. Так же позволяет найти ближайшую лестницу."
	program_open_overlay = "generic"
	tgui_id = "NtosNavigator"
	program_icon = "route"
	size = 5
	power_cell_use = PROGRAM_BASIC_CELL_USE * 0.5 // Designed to be always on display
	program_flags = PROGRAM_ON_NTNET_STORE
	can_run_on_flags = PROGRAM_PDA | PROGRAM_LAPTOP

/datum/computer_file/program/navigator/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/nanomaps),
	)

/datum/computer_file/program/navigator/ui_data(mob/user)
	var/list/data = list()
	var/current_signal = computer.get_ntnet_status()

	data["mapData"] = SSmapping.get_map_ui_data()
	data["signal"] = current_signal

	if(current_signal)
		var/area/area = get_area(user)
		data["location"] = list(
			"x" = user.x,
			"y" = user.y,
			"z" = user.z,
			"dir" = user.dir,
			"area" = area.declent_ru(NOMINATIVE),
		)

	return data
