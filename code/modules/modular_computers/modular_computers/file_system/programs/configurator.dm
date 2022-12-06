// This is special hardware configuration program.
// It is to be used only with modular computers.
// It allows you to toggle components of your device.

/datum/computer_file/program/computerconfig
	filename = "compconfig"
	filedesc = "Hardware Configuration Tool"
	extended_desc = "This program allows configuration of computer's hardware"
	program_icon_state = "generic"
	undeletable = TRUE
	size = 4
	available_on_ntnet = FALSE
	requires_ntnet = FALSE
	tgui_id = "NtosConfiguration"
	program_icon = "cog"

/datum/computer_file/program/computerconfig/ui_data(mob/user)
	// No computer connection, we can't get data from that.
	if(!computer)
		return FALSE

	var/list/data = get_header_data()

	data["disk_size"] = computer.max_capacity
	data["disk_used"] = computer.used_capacity
	data["power_usage"] = computer.last_power_usage
	data["battery"] = null
	if(computer.internal_cell)
		data["battery"] = list(
			"max" = computer.internal_cell.maxcharge,
			"charge" = round(computer.internal_cell.charge),
		)

	return data
