/obj/machinery/door/airlock/shell
	name = "circuit airlock"

/obj/machinery/door/airlock/shell/Initialize()
	. = ..()
	AddComponent( \
		/datum/component/shell, \
		unremovable_circuit_components = list(new /obj/item/circuit_component/airlock), \
		capacity = SHELL_CAPACITY_LARGE, \
		shell_flags = SHELL_FLAG_ALLOW_FAILURE_ACTION \
	)

/obj/item/circuit_component/airlock
	display_name = "Airlock"
	display_desc = "The general interface with an airlock. Includes general statuses of the airlock"

	/// Called when attack_hand is called on the shell.
	var/obj/machinery/door/airlock/attached_airlock

	/// Bolts the airlock (if possible)
	var/datum/port/input/bolt
	/// Unbolts the airlock (if possible)
	var/datum/port/input/unbolt
	/// Opens the airlock (if possible)
	var/datum/port/input/open
	/// Closes the airlock (if possible)
	var/datum/port/input/close

	/// Contains whether the airlock is open or not
	var/datum/port/output/is_open
	/// Contains whether the airlock is bolted or not
	var/datum/port/output/is_bolted

	/// Called when the airlock is opened.
	var/datum/port/output/opened
	/// Called when the airlock is closed
	var/datum/port/output/closed

	/// Called when the airlock is bolted
	var/datum/port/output/bolted
	/// Called when the airlock is unbolted
	var/datum/port/output/unbolted

/obj/item/circuit_component/airlock/Initialize()
	. = ..()
	bolt = add_input_port("Bolt", PORT_TYPE_SIGNAL)
	unbolt = add_input_port("Unbolt", PORT_TYPE_SIGNAL)
	open = add_input_port("Open", PORT_TYPE_SIGNAL)
	close = add_input_port("Close", PORT_TYPE_SIGNAL)
	is_open = add_output_port("Is Open", PORT_TYPE_NUMBER)
	is_bolted = add_output_port("Is Bolted", PORT_TYPE_NUMBER)
	opened = add_output_port("Opened", PORT_TYPE_SIGNAL)
	closed = add_output_port("Closed", PORT_TYPE_SIGNAL)
	bolted = add_output_port("Bolted", PORT_TYPE_SIGNAL)
	unbolted = add_output_port("Unbolted", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/airlock/Destroy()
	bolt = null
	unbolt = null
	open = null
	close = null
	is_open = null
	is_bolted = null
	opened = null
	closed = null
	bolted = null
	unbolted = null
	return ..()

/obj/item/circuit_component/airlock/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/door/airlock))
		attached_airlock = shell

/obj/item/circuit_component/airlock/unregister_shell(atom/movable/shell)
	attached_airlock = null
	return ..()

/obj/item/circuit_component/airlock/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

