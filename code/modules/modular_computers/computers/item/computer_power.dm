///The multiplier given to the base overtime charge drain value if its flashlight is on.
#define FLASHLIGHT_DRAIN_MULTIPLIER 1.1

///Draws power from its rightful source (area if its a computer, the cell otherwise)
///Takes into account special cases, like silicon PDAs through override, and nopower apps.
/obj/item/modular_computer/proc/use_energy(amount = 0, check_programs = TRUE)
	if(check_power_override(amount))
		return TRUE

	if(!internal_cell)
		return FALSE
	if(internal_cell.use(amount))
		return TRUE
	if(!check_programs)
		return FALSE
	internal_cell.use(min(amount, internal_cell.charge)) //drain it anyways.
	if(active_program?.program_flags & PROGRAM_RUNS_WITHOUT_POWER)
		return TRUE
	INVOKE_ASYNC(src, PROC_REF(close_all_programs))
	for(var/datum/computer_file/program/programs as anything in stored_files)
		if((programs.program_flags & PROGRAM_RUNS_WITHOUT_POWER) && open_program(program = programs))
			return TRUE
	return FALSE

/obj/item/modular_computer/proc/give_power(amount)
	if(internal_cell)
		return internal_cell.give(amount)
	return 0

///Shuts down the computer from powerloss.
/obj/item/modular_computer/proc/power_failure()
	if(!enabled)
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

	if(use_energy(power_usage * seconds_per_tick))
		return TRUE
	power_failure()
	return FALSE

///Returns TRUE if the PC should not be using any power, FALSE otherwise.
///Checks to see if the current app allows to be ran without power, if so we'll run with it.
/obj/item/modular_computer/proc/check_power_override(amount)
	return !amount && !internal_cell?.charge && (active_program?.program_flags & PROGRAM_RUNS_WITHOUT_POWER)

//Integrated (Silicon) tablets don't drain power, because the tablet is required to state laws, so it being disabled WILL cause problems.
/obj/item/modular_computer/pda/silicon/check_power_override()
	return TRUE

#undef FLASHLIGHT_DRAIN_MULTIPLIER
