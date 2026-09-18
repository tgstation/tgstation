/datum/computer_file/program/revelation
	filename = "revelation"
	filedesc = "Revelation"
	downloader_category = PROGRAM_CATEGORY_DEVICE
	program_open_overlay = "hostile"
	extended_desc = "This virus can destroy hard drive of system it is executed on. It may be obfuscated to look like another non-malicious program. Once armed, it will destroy the system upon next execution."
	size = 13
	program_flags = PROGRAM_ON_SYNDINET_STORE
	tgui_id = "NtosRevelation"
	program_icon = "magnet"
	var/armed = 0

/datum/computer_file/program/revelation/on_install(datum/computer_file/source, obj/item/modular_computer/computer_installing, mob/user)
	. = ..()
	os.install_driver(/datum/driver/kernel32)


/datum/computer_file/program/revelation/on_start(mob/living/user)
	. = ..(user)
	if(armed)
		activate()

/datum/computer_file/program/revelation/proc/activate()
	var/datum/driver/kernel32/driver = os.get_driver(/datum/driver/kernel32)

	// Somehow you managed to safe your computer!
	if(!driver)
		return

	driver.activate()

/datum/computer_file/program/revelation/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("PRG_arm")
			armed = !armed
			return TRUE
		if("PRG_activate")
			activate()
			return TRUE
		if("PRG_obfuscate")
			var/newname = params["new_name"]
			if(!newname)
				return
			filedesc = newname
			return TRUE


/datum/computer_file/program/revelation/clone()
	var/datum/computer_file/program/revelation/temp = ..()
	temp.armed = armed
	return temp

/datum/computer_file/program/revelation/ui_data(mob/user)
	var/list/data = list()

	data["armed"] = armed

	return data


// The most important driver of the system. It's not replaced with malware, right?
/datum/driver/kernel32

/datum/driver/kernel32/proc/activate()
	if(!hardware)
		return

	var/datum/driver/silicon_power/silicon_driver = hardware.os.get_driver(/datum/driver/silicon_power)
	// Attacking silicon unit's driver
	if(silicon_driver)
		to_chat(silicon_driver.silicon_owner,span_userdanger("SYSTEM PURGE DETECTED/"))
		addtimer(CALLBACK(silicon_driver.silicon_owner, TYPE_PROC_REF(/mob/living/silicon/robot/, death)), 2 SECONDS, TIMER_UNIQUE)
		return

	hardware.visible_message(span_notice("\The [hardware]'s screen brightly flashes and loud electrical buzzing is heard."))
	hardware.enabled = FALSE
	hardware.update_appearance()

	QDEL_LIST(hardware.stored_files)

	hardware.take_damage(25, BRUTE, 0, 0)

	if(hardware.internal_cell && prob(25))
		QDEL_NULL(hardware.internal_cell)
		hardware.visible_message(span_notice("\The [hardware]'s battery explodes in rain of sparks."))
		do_sparks(3, FALSE, src)

