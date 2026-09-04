/// Space Operating System Interface

/datum/operating_system/default

	VAR_PROTECTED/obj/item/modular_computer/hardware

	///Idle programs on background. They still receive process calls but can't be interacted with.
	var/list/datum/computer_file/program/idle_threads = list()

	///Idle programs on background. They still receive process calls but can't be interacted with.
	var/list/datum/computer_file/program/active_threads = list()

	/// Amount of programs that can be ran at once
	var/max_idle_programs = 3

	var/datum/driver/filesystem/filesystem

	var/alist/drivers = alist()

/datum/operating_system/default/New(obj/item/modular_computer/computer)
	..()
	hardware = computer

/datum/operating_system/default/Destroy(force)
	. = ..()
	hardware = null
	QDEL_NULL(filesystem)
	QDEL_LIST(idle_threads)
	QDEL_LIST(active_threads)

/datum/operating_system/default/proc/activate_program(mob/user, datum/computer_file/program/program)

/datum/operating_system/default/proc/run_program(mob/user, datum/computer_file/program/program)

/datum/operating_system/default/proc/kill_program(datum/computer_file/program/program)

/datum/operating_system/default/proc/get_active_thread(identifier)
	if(isnum(identifier) && identifier > 0 && identifier <= active_threads.len)
		return active_threads[identifier]

/datum/operating_system/default/proc/get_driver(driver_type)
	return drivers[driver_type]

/datum/operating_system/default/proc/install_driver(driver_type, driver = null)
	if(driver)
		drivers[driver_type] = driver
	else
		drivers[driver_type] = new driver_type(hardware)

/datum/operating_system/default/proc/get_hardware_name()
	return "[hardware]"

/datum/operating_system/default/proc/is_hardware_type(type)
	return istype(hardware, type)
