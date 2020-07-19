/datum/computer_file/program/atmosscan
	filename = "atmosscan"
	filedesc = "Atmospheric Scanner"
	program_icon_state = "air"
	extended_desc = "A small built-in sensor reads out the atmospheric conditions around the device."
	network_destination = "atmos scan"
	size = 4
	tgui_id = "NtosAtmos"

/datum/computer_file/program/atmosscan/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/airlist = list()
	var/turf/T = get_turf(ui_host())
	if(T)
		var/datum/gas_mixture/environment = T.return_air()
		var/list/env_gases = environment.gases
		var/pressure = environment.return_pressure()
		var/total_moles = environment.total_moles()
		data["AirPressure"] = round(pressure,0.1)
		data["AirTemp"] = round(environment.temperature-T0C)
		if (total_moles)
			for(var/id in env_gases)
				var/gas_level = env_gases[id][MOLES]/total_moles
				if(gas_level > 0)
					airlist += list(list("name" = "[env_gases[id][GAS_META][META_GAS_NAME]]", "percentage" = round(gas_level*100, 0.01)))
		data["AirData"] = airlist
	return data

/datum/computer_file/program/atmosscan/ui_act(action, list/params)
	if(..())
		return TRUE
