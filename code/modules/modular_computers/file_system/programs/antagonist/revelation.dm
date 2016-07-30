/datum/computer_file/program/revelation
	filename = "revelation"
	filedesc = "Revelation"
	program_icon_state = "hostile"
	extended_desc = "This virus can destroy hard drive of system it is executed on. It may be obfuscated to look like another non-malicious program. Once armed, it will destroy the system upon next execution."
	size = 13
	requires_ntnet = 0
	available_on_ntnet = 0
	available_on_syndinet = 1
	nanomodule_path = /datum/nano_module/program/revelation/
	var/armed = 0

/datum/computer_file/program/revelation/run_program(var/mob/living/user)
	. = ..(user)
	if(armed)
		activate()

/datum/computer_file/program/revelation/proc/activate()
	if(computer)
		computer.visible_message("<span class='notice'>\The [computer]'s screen brightly flashes and loud electrical buzzing is heard.</span>")
		computer.enabled = 0
		computer.update_icon()
		qdel(computer.hard_drive)
		if(computer.battery_module && prob(25))
			qdel(computer.battery_module)
			computer.visible_message("<span class='notice'>\The [computer]'s battery explodes in rain of sparks.</span>")
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(10, 1, computer.loc)
			s.start()
		if(istype(computer, /obj/item/modular_computer/processor))
			var/obj/item/modular_computer/processor/P = computer
			if(P.machinery_computer.tesla_link && prob(50))
				qdel(P.machinery_computer.tesla_link)
				computer.visible_message("<span class='notice'>\The [computer]'s tesla link explodes in rain of sparks.</span>")
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(10, 1, computer.loc)
				s.start()

/datum/computer_file/program/revelation/Topic(href, href_list)
	if(..())
		return 1
	else if(href_list["PRG_arm"])
		armed = !armed
	else if(href_list["PRG_activate"])
		activate()
	else if(href_list["PRG_obfuscate"])
		var/mob/living/user = usr
		var/newname = sanitize(input(user, "Enter new program name: "))
		if(!newname)
			return
		filedesc = newname
	return 1

/datum/computer_file/program/revelation/clone()
	var/datum/computer_file/program/revelation/temp = ..()
	temp.armed = armed
	return temp

/datum/nano_module/program/revelation
	name = "Revelation Virus"

/datum/nano_module/program/revelation/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = default_state)
	var/list/data = list()
	var/datum/computer_file/program/revelation/PRG = program
	if(!istype(PRG))
		return

	data = PRG.get_header_data()

	data["armed"] = PRG.armed

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "revelation.tmpl", "Revelation Virus", 400, 250, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

