///The multiplier given to the base overtime charge drain value if its flashlight is on.
#define FLASHLIGHT_DRAIN_MULTIPLIER 1.1

// Tries to draw power from charger or, if no operational charger is present, from power cell.
/obj/item/modular_computer/proc/use_power(amount = 0)
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
	if(light_on)
		set_light_on(FALSE)
	for(var/datum/computer_file/program/programs as anything in idle_threads)
		programs.event_powerfailure()
	shutdown_computer(loud = FALSE)

///Takes the charge necessary from the Computer, shutting it off if it's unable to provide it.
///Charge depends on whether the PC is on, and what programs are running/idle on it.
/obj/item/modular_computer/proc/handle_power(seconds_per_tick)
	var/power_usage = screen_on ? base_active_power_usage : base_idle_power_usage
	if(light_on)
		power_usage *= FLASHLIGHT_DRAIN_MULTIPLIER
	if(active_program)
		power_usage += active_program.power_cell_use
	for(var/datum/computer_file/program/open_programs as anything in idle_threads)
		if(!open_programs.power_cell_use)
			continue
		if(open_programs in idle_threads)
			power_usage += (open_programs.power_cell_use / 2)

	if(use_power(power_usage * seconds_per_tick))
		return TRUE
	power_failure()
	return FALSE

///Used by subtypes for special cases for power usage, returns TRUE if it should stop the use_power chain.
/obj/item/modular_computer/proc/check_power_override()
	return FALSE

//Integrated (Silicon) tablets don't drain power, because the tablet is required to state laws, so it being disabled WILL cause problems.
/obj/item/modular_computer/pda/silicon/check_power_override()
	return TRUE

#undef FLASHLIGHT_DRAIN_MULTIPLIER
