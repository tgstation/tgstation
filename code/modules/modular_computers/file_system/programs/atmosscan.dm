/datum/computer_file/program/atmosscan
	filename = "atmosscan"
	filedesc = "AtmoZphere"
	category = PROGRAM_CATEGORY_ENGI
	program_icon_state = "air"
	extended_desc = "A small built-in sensor reads out the atmospheric conditions around the device."
	size = 4
	tgui_id = "NtosGasAnalyzer"
	program_icon = "thermometer-half"

/datum/computer_file/program/atmosscan/run_program(mob/living/user)
	. = ..()
	if (!.)
		return
	if(!computer?.get_modular_computer_part(MC_SENSORS)) //Giving a clue to users why the program is spitting out zeros.
		to_chat(user, span_warning("\The [computer] flashes an error: \"hardware\\sensorpackage\\startup.bin -- file not found\"."))

/datum/computer_file/program/atmosscan/ui_static_data(mob/user)
	return return_atmos_handbooks()

/datum/computer_file/program/atmosscan/ui_data(mob/user)
	var/list/data = get_header_data()
	var/turf/turf = get_turf(computer)
	var/datum/gas_mixture/air = turf?.return_air()
	var/obj/item/computer_hardware/sensorpackage/air_sensor = computer?.get_modular_computer_part(MC_SENSORS)

	if(!air_sensor)
		data["gasmixes"] = list(gas_mixture_parser(null, "No Sensors Detected!"))
		return data
	
	data["gasmixes"] = list(gas_mixture_parser(air, "Sensor Reading")) //Null air wont cause errors, don't worry.
	return data

/datum/computer_file/program/atmosscan/ui_act(action, list/params)
	. = ..()
	if(.)
		return
