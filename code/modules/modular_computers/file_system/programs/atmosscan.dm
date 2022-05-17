/datum/computer_file/program/atmosscan
	filename = "atmosscan"
	filedesc = "AtmoZphere"
	category = PROGRAM_CATEGORY_ENGI
	program_icon_state = "air"
	extended_desc = "A small built-in sensor reads out the atmospheric conditions around the device."
	size = 4
	tgui_id = "NtosGasAnalyzer"
	program_icon = "thermometer-half"

/datum/computer_file/program/atmosscan/ui_static_data(mob/user)
	return return_atmos_handbooks()

/datum/computer_file/program/atmosscan/ui_data(mob/user)
	var/list/data = get_header_data()
	var/turf/turf = get_turf(computer)
	var/datum/gas_mixture/air = turf?.return_air()

	data["gasmixes"] = list(gas_mixture_parser(air, "Sensor Reading")) //Null air wont cause errors, don't worry.
	return data

/datum/computer_file/program/atmosscan/ui_act(action, list/params)
	. = ..()
	if(.)
		return
