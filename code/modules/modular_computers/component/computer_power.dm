// Tries to draw power from charger or, if no operational charger is present, from power cell.
/datum/modular_computer_host/proc/use_power(amount = 0)
	if(check_power_override())
		return TRUE
	if(ismachinery(physical))
		var/obj/machinery/machine_holder = physical
		if(machine_holder.powered())
			machine_holder.use_power(amount)
			return TRUE

	if(!internal_cell || !internal_cell.charge)
		return FALSE

	if(!internal_cell.use(amount JOULES))
		internal_cell.use(min(amount JOULES, internal_cell.charge)) //drain it anyways.
		return FALSE
	return TRUE

/datum/modular_computer_host/proc/give_power(amount)
	if(internal_cell)
		return internal_cell.give(amount)
	return 0 // zero power

// Used in following function to reduce copypaste
/datum/modular_computer_host/proc/power_failure()
	if(powered_on) // Shut down the computer
		if(active_program)
			active_program.event_powerfailure(0)
		for(var/datum/computer_file/program/programs as anything in idle_threads)
			programs.event_powerfailure(background = TRUE)
		shutdown_computer(0)

// Handles power-related things, such as battery interaction, recharging, shutdown when it's discharged
/datum/modular_computer_host/proc/handle_power(delta_time)
	//var/power_usage = screen_on ? base_active_power_usage : base_idle_power_usage

	var/power_usage = base_active_power_usage
	if(use_power(power_usage))
		last_power_usage = power_usage
		return TRUE
	else
		power_failure()
		return FALSE

///Used by subtypes for special cases for power usage, returns TRUE if it should stop the use_power chain.
/datum/modular_computer_host/proc/check_power_override()
	return FALSE
