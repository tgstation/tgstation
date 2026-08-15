///The multiplier given to the base overtime charge drain value if its flashlight is on.
#define FLASHLIGHT_DRAIN_MULTIPLIER 1.1

///Draws power from its rightful source (area if its a computer, the cell otherwise)
///Takes into account special cases, like silicon PDAs through override, and nopower apps.
/obj/item/modular_computer/proc/use_energy(amount = 0, check_programs = TRUE)
	if(check_power_override(amount))
		return TRUE
	if(!internal_cell)
		return FALSE
	if(!amount || internal_cell.use(amount))
		return TRUE
	if(!check_programs)
		return FALSE

	INVOKE_ASYNC(os, TYPE_PROC_REF(/datum/operating_system/sosix, shutdown_os))
	return FALSE

/obj/item/modular_computer/proc/give_power(amount)
	if(internal_cell)
		return internal_cell.give(amount)
	return 0

///Shuts down the computer from powerloss.
/obj/item/modular_computer/proc/power_failure()
	if(!enabled)
		return
	for(var/datum/computer_file/program/program as anything in os.active_threads)
		program.event_powerfailure()
	if(light_on)
		set_light_on(FALSE)
	for(var/datum/computer_file/program/program as anything in os.idle_threads)
		program.event_powerfailure()
	shutdown_computer()

///Takes the charge necessary from the Computer, shutting it off if it's unable to provide it.
///Charge depends on whether the PC is on, and what programs are running/idle on it.
/obj/item/modular_computer/proc/handle_power(seconds_per_tick)
	var/power_usage = screen_on ? base_active_power_usage : base_idle_power_usage
	if(light_on)
		power_usage *= FLASHLIGHT_DRAIN_MULTIPLIER
	for(var/datum/computer_file/program/program as anything in os.active_threads)
		power_usage += program.power_cell_use

	for(var/datum/computer_file/program/program as anything in os.idle_threads)
		if(!program.power_cell_use)
			continue
		if(program in os.idle_threads)
			power_usage += (program.power_cell_use / 2)

	if(use_energy(power_usage * seconds_per_tick))
		return TRUE
	power_failure()
	return FALSE

///Returns TRUE if the PC should not be using any power, FALSE otherwise.
/obj/item/modular_computer/proc/check_power_override(amount)
	return !amount && !internal_cell?.charge

//Integrated (Silicon) tablets don't drain power, because the tablet is required to state laws, so it being disabled WILL cause problems.
/obj/item/modular_computer/pda/silicon/check_power_override()
	return TRUE

#undef FLASHLIGHT_DRAIN_MULTIPLIER
