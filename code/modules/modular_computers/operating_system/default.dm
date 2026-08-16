/// Space Operating System Interface

/datum/operating_system/default

	var/obj/item/modular_computer/hardware

	///Idle programs on background. They still receive process calls but can't be interacted with.
	var/list/datum/computer_file/program/idle_threads = list()

	///Idle programs on background. They still receive process calls but can't be interacted with.
	var/list/datum/computer_file/program/active_threads = list()

	/// Amount of programs that can be ran at once
	var/max_idle_programs = 3

/datum/operating_system/default/New(obj/item/modular_computer/computer)
	..()
	hardware = computer

/datum/operating_system/default/proc/activate_program(mob/user, datum/computer_file/program/program)

/datum/operating_system/default/proc/run_program(mob/user, datum/computer_file/program/program, open_ui = TRUE)

/datum/operating_system/default/proc/kill_program(datum/computer_file/program/program)

/datum/operating_system/default/proc/remove_file(datum/computer_file/file_removing)

/datum/operating_system/default/proc/store_file(datum/computer_file/file_storing, mob/user)

/datum/operating_system/default/proc/can_store_file(datum/computer_file/file)

/datum/operating_system/default/proc/find_file_by_name(filename, obj/item/disk/computer/target_disk)

/datum/operating_system/default/proc/find_file_by_full_name(full_path, obj/item/disk/computer/target_disk)

/datum/operating_system/default/proc/find_file_by_uid(uid, obj/item/disk/computer/target_disk)

/datum/operating_system/default/proc/get_active_thread(identifier)
	if(isnum(identifier) && identifier > 0 && identifier <= active_threads.len)
		return active_threads[identifier]
