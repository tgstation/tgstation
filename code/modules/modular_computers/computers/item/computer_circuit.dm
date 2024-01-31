///A simple circuit component compatible with stationary consoles, laptops and PDAs, independent from programs.
/obj/item/circuit_component/modpc
	display_name = "Modular Computer"
	desc = "Circuit for basic functions of a modular computer."
	var/obj/item/modular_computer/computer
	///Turns the PC on/off
	var/datum/port/input/on_off
	///When set, will print a piece of paper with the value as text.
	var/datum/port/input/print

	///Sent when turned on
	var/datum/port/output/is_on
	///Sent when shut down
	var/datum/port/output/is_off

	///Toggles lights on and off. Also RGB.
	var/datum/port/input/lights
	var/datum/port/input/red
	var/datum/port/input/green
	var/datum/port/input/blue

/obj/item/circuit_component/modpc/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/item/modular_computer))
		computer = shell
	else if(istype(shell, /obj/machinery/modular_computer))
		var/obj/machinery/modular_computer/console = shell
		computer = console.cpu

	if(isnull(computer))
		return

	RegisterSignal(computer, COMSIG_MODULAR_COMPUTER_TURNED_ON, PROC_REF(computer_on))
	RegisterSignal(computer, COMSIG_MODULAR_COMPUTER_SHUT_DOWN, PROC_REF(computer_off))

	/**
	 * Some mod pc have lights while some don't, but populate_ports()
	 * is called before we get to know which object this has attahed to,
	 * I hope you're cool with me doing it here.
	 */
	if(computer.has_light && isnull(lights))
		lights = add_input_port("Toggle Lights", PORT_TYPE_SIGNAL)
		red = add_input_port("Red", PORT_TYPE_NUMBER)
		green = add_input_port("Green", PORT_TYPE_NUMBER)
		blue = add_input_port("Blue", PORT_TYPE_NUMBER)

/obj/item/circuit_component/modpc/unregister_shell(atom/movable/shell)
	if(computer)
		UnregisterSignal(computer, list(COMSIG_MODULAR_COMPUTER_TURNED_ON, COMSIG_MODULAR_COMPUTER_SHUT_DOWN))
		computer = null
	return ..()

/obj/item/circuit_component/modpc/populate_ports()
	on_off = add_input_port("Turn On/Off", PORT_TYPE_SIGNAL)
	print = add_input_port("Print Text", PORT_TYPE_STRING)

	is_on = add_output_port("Turned On", PORT_TYPE_SIGNAL)
	is_on = add_output_port("Shut Down", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/modpc/pre_input_received(datum/port/input/port)
	if(isnull(computer))
		return
	if(COMPONENT_TRIGGERED_BY(print, port))
		print.set_value(html_encode(trim(print.value, MAX_PAPER_LENGTH)))
	else if(COMPONENT_TRIGGERED_BY(red, port))
		red.set_value(clamp(red.value, 0, 255))
	else if(COMPONENT_TRIGGERED_BY(blue, port))
		blue.set_value(clamp(blue.value, 0, 255))
	else if(COMPONENT_TRIGGERED_BY(green, port))
		green.set_value(clamp(green.value, 0, 255))

/obj/item/circuit_component/modpc/input_received(datum/port/input/port)
	if(isnull(computer))
		return
	if(COMPONENT_TRIGGERED_BY(on_off, port))
		if(computer.enabled)
			INVOKE_ASYNC(computer, TYPE_PROC_REF(/obj/item/modular_computer, shutdown_computer))
		else
			INVOKE_ASYNC(computer, TYPE_PROC_REF(/obj/item/modular_computer, turn_on))
		return

	if(!computer.enabled)
		return

	if(COMPONENT_TRIGGERED_BY(print, port))
		computer.print_text(print.value)

	if(lights)
		if(COMPONENT_TRIGGERED_BY(lights, port))
			computer.toggle_flashlight()
		if(COMPONENT_TRIGGERED_BY(red, port) || COMPONENT_TRIGGERED_BY(green, port) || COMPONENT_TRIGGERED_BY(blue, port))
			computer.set_flashlight_color(rgb(red.value || 0, green.value || 0, blue.value || 0))

/obj/item/circuit_component/modpc/proc/computer_on(datum/source, mob/user)
	SIGNAL_HANDLER
	is_on.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/modpc/proc/computer_off(datum/source, loud)
	SIGNAL_HANDLER
	is_off.set_output(COMPONENT_SIGNAL)
