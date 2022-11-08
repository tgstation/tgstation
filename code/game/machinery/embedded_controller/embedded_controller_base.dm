/datum/computer/file/embedded_program
	var/state
	var/obj/machinery/embedded_controller/master

/datum/computer/file/embedded_program/Destroy()
	master = null
	. = ..()

/datum/computer/file/embedded_program/proc/receive_user_command(command)

/datum/computer/file/embedded_program/process()
	return 0

/obj/machinery/embedded_controller
	var/datum/computer/file/embedded_program/program

	name = "embedded controller"
	density = FALSE

	var/on = TRUE

/obj/machinery/embedded_controller/Destroy()
	if(program)
		QDEL_NULL(program)
	. = ..()

/obj/machinery/embedded_controller/ui_interact(mob/user)
	. = ..()
	user.set_machine(src)
	var/datum/browser/popup = new(user, "computer", name) // Set up the popup browser window
	popup.set_content(return_text())
	popup.open()

/obj/machinery/embedded_controller/proc/return_text()

/obj/machinery/embedded_controller/proc/post_signal(datum/signal/signal, comm_line)
	return

/obj/machinery/embedded_controller/Topic(href, href_list)
	. = ..()
	if(.)
		return

	process_command(href_list["command"])

	usr.set_machine(src)
	addtimer(CALLBACK(src, .proc/updateDialog), 5)

/obj/machinery/embedded_controller/proc/process_command(command)
	if(program)
		program.receive_user_command(command)
		addtimer(CALLBACK(program, /datum/computer/file/embedded_program.proc/process), 5)

/obj/machinery/embedded_controller/process(delta_time)
	if(program)
		program.process(delta_time)

	update_appearance()
	src.updateDialog()
