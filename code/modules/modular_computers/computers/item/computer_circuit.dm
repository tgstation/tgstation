///A simple circuit component compatible with stationary consoles, laptops and PDAs, independent from programs.
/obj/item/circuit_component/modpc
	display_name = "Modular Computer"
	desc = "Circuit of a modular computer. Ports depend on the programs installed. Only open (idle or active) programs will receive inputs."
	var/obj/item/modular_computer/computer
	///Turns the PC on/off
	var/datum/port/input/on_off
	///When set, will print a piece of paper with its value
	var/datum/port/input/print

/obj/item/circuit_component/modpc/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/item/modular_computer))
		computer = shell
	else if(istype(shell, /obj/machinery/modular_computer))
		var/obj/machinery/modular_computer/console = shell
		computer = console.cpu

/obj/item/circuit_component/modpc/unregister_shell(atom/movable/shell)
	computer = null
	return ..()

/obj/item/circuit_component/modpc/populate_ports()
	on_off = add_input_port("Turn On/Off", PORT_TYPE_SIGNAL)
	print = add_input_port("Print Text", PORT_TYPE_STRING)

/obj/item/circuit_component/modpc/input_received(datum/port/input/port)
	if(isnull(computer))
		return
	if(COMPONENT_TRIGGERED_BY(on_off, port))
		if(computer.enabled)
			computer.shutdown_computer()
		else
			computer.turn_on()
		return

	if(!computer.enabled)
		return

	if(COMPONENT_TRIGGERED_BY(print, port))
		computer.print_text(print.value)
