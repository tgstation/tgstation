// Tries to draw power from charger or, if no operational charger is present, from power cell.
/obj/item/modular_computer/proc/use_power(amount = 0)
	if(check_power_override())
		return TRUE
	if(ismachinery(loc))
		var/obj/machinery/machine_holder = loc
		if(machine_holder.powered())
			machine_holder.use_power(amount)
			return TRUE

	if(!internal_cell || !internal_cell.charge)
		return FALSE

	if(!internal_cell.use(amount JOULES))
		internal_cell.use(min(amount JOULES, internal_cell.charge)) //drain it anyways.
		return FALSE
	return TRUE

/obj/item/modular_computer/proc/give_power(amount)
	if(internal_cell)
		return internal_cell.give(amount)
	return 0

// Used in following function to reduce copypaste
/obj/item/modular_computer/proc/power_failure()
	if(!enabled) // Shut down the computer
		return
	if(active_program)
		active_program.event_powerfailure()
	for(var/datum/computer_file/program/programs as anything in idle_threads)
		programs.event_powerfailure()
	shutdown_computer(loud = FALSE)

// Handles power-related things, such as battery interaction, recharging, shutdown when it's discharged
/obj/item/modular_computer/proc/handle_power(seconds_per_tick)
	var/power_usage = screen_on ? base_active_power_usage : base_idle_power_usage

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
/obj/item/modular_computer/pda/silicon/check_power_override()
	return TRUE
