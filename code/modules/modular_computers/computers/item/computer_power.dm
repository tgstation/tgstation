// Tries to draw power from charger or, if no operational charger is present, from power cell.
/obj/item/modular_computer/proc/use_power(amount = 0)
	if(check_power_override())
		return 1

	if(recharger && recharger.check_functionality())
		if(recharger.use_power(amount))
			return 1

	if(battery_module && battery_module.battery && battery_module.battery.charge)
		var/obj/item/weapon/stock_parts/cell/cell = battery_module.battery
		if(cell.use(amount * CELLRATE))
			return 1
		else // Discharge the cell anyway.
			cell.use(min(amount*CELLRATE, cell.charge))
			return 0
	return 0

/obj/item/modular_computer/proc/give_power(amount)
	if(battery_module && battery_module.battery)
		return battery_module.battery.give(amount)
	return 0


// Used in following function to reduce copypaste
/obj/item/modular_computer/proc/power_failure()
	if(enabled) // Shut down the computer
		if(active_program)
			active_program.event_powerfailure(0)
		for(var/I in idle_threads)
			var/datum/computer_file/program/PRG = I
			PRG.event_powerfailure(1)
		shutdown_computer(0)

// Handles power-related things, such as battery interaction, recharging, shutdown when it's discharged
/obj/item/modular_computer/proc/handle_power()
	if(recharger)
		recharger.process()

	var/power_usage = screen_on ? base_active_power_usage : base_idle_power_usage

	for(var/obj/item/weapon/computer_hardware/H in all_components)
		if(H.enabled)
			power_usage += H.power_usage

	if(use_power(power_usage))
		last_power_usage = power_usage
		return 1
	else
		power_failure()
		return 0

// Used by child types if they have other power source than battery or recharger
/obj/item/modular_computer/proc/check_power_override()
	return 0
