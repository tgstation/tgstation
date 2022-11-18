// Tries to draw power from charger or, if no operational charger is present, from power cell.
/obj/item/modular_computer/proc/use_power(amount = 0)
	if(check_power_override())
		return TRUE

	if(ismachinery(loc))
		var/obj/machinery/machine_holder = loc
		if(machine_holder.powered())
			machine_holder.use_power(amount)
			return TRUE

	var/obj/item/computer_hardware/battery/battery_module = all_components[MC_CELL]
	if(battery_module && battery_module.battery && battery_module.battery.charge)
		var/obj/item/stock_parts/cell/cell = battery_module.battery
		if(cell.use(amount JOULES))
			return TRUE
		else // Discharge the cell anyway.
			cell.use(min(amount JOULES, cell.charge))
			return FALSE
	return FALSE

/obj/item/modular_computer/proc/give_power(amount)
	var/obj/item/computer_hardware/battery/battery_module = all_components[MC_CELL]
	if(battery_module?.battery)
		return battery_module.battery.give(amount)
	return 0

/obj/item/modular_computer/get_cell()
	var/obj/item/computer_hardware/battery/battery_module = all_components[MC_CELL]
	return battery_module?.get_cell()

// Used in following function to reduce copypaste
/obj/item/modular_computer/proc/power_failure()
	if(enabled) // Shut down the computer
		if(active_program)
			active_program.event_powerfailure(0)
		for(var/datum/computer_file/program/programs as anything in idle_threads)
			programs.event_powerfailure(background = TRUE)
		shutdown_computer(0)

// Handles power-related things, such as battery interaction, recharging, shutdown when it's discharged
/obj/item/modular_computer/proc/handle_power(delta_time)
	var/power_usage = screen_on ? base_active_power_usage : base_idle_power_usage

	for(var/obj/item/computer_hardware/H in all_components)
		if(H.enabled)
			power_usage += H.power_usage

	if(use_power(power_usage))
		last_power_usage = power_usage
		return TRUE
	else
		power_failure()
		return FALSE

///Used by subtypes for special cases for power usage, returns TRUE if it should stop the use_power chain.
/obj/item/modular_computer/proc/check_power_override()
	return FALSE

//Integrated (Silicon) tablets don't drain power, because the tablet is required to state laws, so it being disabled WILL cause problems.
/obj/item/modular_computer/tablet/integrated/check_power_override()
	return TRUE
