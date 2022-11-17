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
		return 0

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

	var/list/all_entries[0]
	for(var/I in computer.all_components)
		var/obj/item/computer_hardware/H = computer.all_components[I]
		all_entries.Add(list(list(
		"name" = H.name,
		"desc" = H.desc,
		"enabled" = H.enabled,
		"critical" = H.critical,
		"powerusage" = H.power_usage,
	)))

	data["hardware"] = all_entries
	return data


/datum/computer_file/program/computerconfig/ui_act(action,params)
	. = ..()
	if(.)
		return
	switch(action)
		if("PC_toggle_component")
			var/obj/item/computer_hardware/H = computer.find_hardware_by_name(params["name"])
			if(H && istype(H))
				H.enabled = !H.enabled
			. = TRUE
