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
	/// Whether the device is currently displaying the blue screen of death.
	var/bluescreen = FALSE

/datum/computer_file/program/revelation/on_start(mob/living/user)
	. = ..(user)
	if(armed)
		activate()

/datum/computer_file/program/revelation/proc/activate()
	if(computer)
		if(istype(computer, /obj/item/modular_computer/pda/silicon)) //If this is a borg's integrated tablet
			var/obj/item/modular_computer/pda/silicon/modularInterface = computer
			to_chat(modularInterface.silicon_owner,span_userdanger("SYSTEM PURGE DETECTED/"))
			addtimer(CALLBACK(modularInterface.silicon_owner, TYPE_PROC_REF(/mob/living/silicon/robot/, death)), 2 SECONDS, TIMER_UNIQUE)
			return

		if(bluescreen) //Already triggered, don't double-schedule the wipe.
			return

		computer.visible_message(span_notice("\The [computer]'s screen brightly flashes and loud electrical buzzing is heard."))
		bluescreen = TRUE
		computer.update_appearance()
		INVOKE_ASYNC(computer, TYPE_PROC_REF(/obj/item/modular_computer, update_tablet_open_uis))
		addtimer(CALLBACK(src, PROC_REF(wipe_device)), 2 SECONDS, TIMER_UNIQUE)

/// Purges the device: kills all running programs, wipes every stored file and damages the hardware
/datum/computer_file/program/revelation/proc/wipe_device()
	var/obj/item/modular_computer/computer_ref = computer
	if(!computer_ref || QDELETED(computer_ref))
		return
	computer_ref.enabled = FALSE
	computer_ref.close_all_programs()
	for(var/datum/computer_file/file as anything in computer_ref.stored_files)
		qdel(file, force = TRUE)
	computer_ref.stored_files.Cut()
	computer_ref.used_capacity = 0
	computer_ref.update_appearance()
	computer_ref.take_damage(25, BRUTE, 0, 0)
	if(computer_ref.internal_cell && prob(25))
		QDEL_NULL(computer_ref.internal_cell)
		computer_ref.visible_message(span_notice("\The [computer_ref]'s battery explodes in rain of sparks."))
		do_sparks(3, FALSE, computer_ref)

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
	data["bluescreen"] = bluescreen

	return data
