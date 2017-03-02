// This is special hardware configuration program.
// It is to be used only with modular computers.
// It allows you to toggle components of your device.

/datum/computer_file/program/computerconfig
	filename = "compconfig"
	filedesc = "Computer Configuration Tool"
	extended_desc = "This program allows configuration of computer's hardware"
	program_icon_state = "generic"
	unsendable = 1
	undeletable = 1
	size = 4
	available_on_ntnet = 0
	requires_ntnet = 0
	var/obj/item/device/modular_computer/movable = null


/datum/computer_file/program/computerconfig/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = default_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if (!ui)

		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/headers)
		assets.send(user)

		ui = new(user, src, ui_key, "laptop_configuration", "NTOS Configuration Utility", 575, 700, state = state)
		ui.open()
		ui.set_autoupdate(state = 1)

/datum/computer_file/program/computerconfig/ui_data(mob/user)
	movable = computer
	var/obj/item/weapon/computer_hardware/hard_drive/hard_drive = movable.all_components[MC_HDD]
	var/obj/item/weapon/computer_hardware/battery/battery_module = movable.all_components[MC_CELL]
	if(!istype(movable))
		movable = null

	// No computer connection, we can't get data from that.
	if(!movable)
		return 0

	var/list/data = get_header_data()

	data["disk_size"] = hard_drive.max_capacity
	data["disk_used"] = hard_drive.used_capacity
	data["power_usage"] = movable.last_power_usage
	data["battery_exists"] = battery_module ? 1 : 0
	if(battery_module && battery_module.battery)
		data["battery_rating"] = battery_module.battery.maxcharge
		data["battery_percent"] = round(battery_module.battery.percent())

	if(battery_module && battery_module.battery)
		data["battery"] = list("max" = battery_module.battery.maxcharge, "charge" = round(battery_module.battery.charge))

	var/list/all_entries[0]
	for(var/I in movable.all_components)
		var/obj/item/weapon/computer_hardware/H = movable.all_components[I]
		all_entries.Add(list(list(
		"name" = H.name,
		"desc" = H.desc,
		"enabled" = H.enabled,
		"critical" = H.critical,
		"powerusage" = H.power_usage
		)))

	data["hardware"] = all_entries
	return data


/datum/computer_file/program/computerconfig/ui_act(action,params)
	if(..())
		return
	switch(action)
		if("PC_toggle_component")
			var/obj/item/weapon/computer_hardware/H = movable.find_hardware_by_name(params["name"])
			if(H && istype(H))
				H.enabled = !H.enabled
			. = TRUE
