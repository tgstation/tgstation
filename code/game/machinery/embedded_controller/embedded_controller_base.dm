/datum/computer/file/embedded_program
	var/list/memory = list()
	var/state
	var/obj/machinery/embedded_controller/master

/datum/computer/file/embedded_program/proc/post_signal(datum/signal/signal, comm_line)
	if(master)
		master.post_signal(signal, comm_line)
	else
		qdel(signal)

/datum/computer/file/embedded_program/proc/receive_user_command(command)

/datum/computer/file/embedded_program/proc/receive_signal(datum/signal/signal)
	return null

/datum/computer/file/embedded_program/process()
	return 0

/obj/machinery/embedded_controller
	var/datum/computer/file/embedded_program/program

	name = "embedded controller"
	density = FALSE

	var/on = TRUE

/obj/machinery/embedded_controller/ui_interact(mob/user)
	. = ..()
	user.set_machine(src)
	var/datum/browser/popup = new(user, "computer", name) // Set up the popup browser window
	popup.set_content(return_text())
	popup.open()

/obj/machinery/embedded_controller/proc/return_text()

/obj/machinery/embedded_controller/proc/post_signal(datum/signal/signal, comm_line)
	return

/obj/machinery/embedded_controller/proc/receive_signal(datum/signal/signal)
	if(istype(signal) && program)
		program.receive_signal(signal)

/obj/machinery/embedded_controller/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(program)
		program.receive_user_command(href_list["command"])
		addtimer(CALLBACK(program, /datum/computer/file/embedded_program.proc/process), 5)

	usr.set_machine(src)
	addtimer(CALLBACK(src, .proc/updateDialog), 5)

/obj/machinery/embedded_controller/process()
	if(program)
		program.process()

	update_icon()
	src.updateDialog()

/obj/machinery/embedded_controller/radio
	var/frequency = 0
	var/radio_filter = null

// if we care about radio, make sure frequency is NOT 0 when the device is created
// Otherwise the component was never installed
/obj/machinery/atmospherics/components/ComponentInitialize()
	if(frequency)
		AddComponent(/datum/component/radio_interface, frequency, radio_filter)
		RegisterSignal(src, COMSIG_RADIO_RECEIVE_DATA, .proc/receive_signal)

/obj/machinery/embedded_controller/receive_signal(datum/signal/signal)
	. = ..()

/obj/machinery/embedded_controller/radio/post_signal(datum/signal/signal,comm_line)
	var/datum/component/radio_interface/radio_connection = GetComponent(/datum/component/radio_interface)
	signal.transmission_method = TRANSMISSION_RADIO
	if(radio_connection)
		return radio_connection.brodcast(signal)
	else
		signal = null

// handles some basic checking on the signal
/obj/machinery/embedded_controller/radio/proc/set_frequency(freq, filter=null)
	SEND_SIGNAL(src, COMSIG_RADIO_NEW_FREQUENCY, freq, filter)
