/datum/computer_file/program/revelation
	filename = "revelation"
	filedesc = "Revelation"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "hostile"
	extended_desc = "This virus can destroy hard drive of system it is executed on. It may be obfuscated to look like another non-malicious program. Once armed, it will destroy the system upon next execution."
	size = 13
	requires_ntnet = FALSE
	available_on_ntnet = FALSE
	available_on_syndinet = TRUE
	tgui_id = "NtosRevelation"
	program_icon = "magnet"
	var/armed = 0

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

		computer.visible_message(span_notice("\The [computer]'s screen brightly flashes and loud electrical buzzing is heard."))
		computer.enabled = FALSE
		computer.update_appearance()

		QDEL_LIST(computer.stored_files)

		computer.take_damage(25, BRUTE, 0, 0)

		if(computer.internal_cell && prob(25))
			QDEL_NULL(computer.internal_cell)
			computer.visible_message(span_notice("\The [computer]'s battery explodes in rain of sparks."))
			var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
			spark_system.start()

/datum/computer_file/program/revelation/ui_act(action, params)
	. = ..()
	if(.)
		return
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
	var/list/data = get_header_data()

	data["armed"] = armed

	return data
