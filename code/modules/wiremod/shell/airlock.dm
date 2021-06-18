/obj/machinery/door/airlock/shell
	name = "circuit airlock"
	autoclose = FALSE

/obj/machinery/door/airlock/shell/Initialize()
	. = ..()
	AddComponent( \
		/datum/component/shell, \
		unremovable_circuit_components = list(new /obj/item/circuit_component/airlock), \
		capacity = SHELL_CAPACITY_LARGE, \
		shell_flags = SHELL_FLAG_ALLOW_FAILURE_ACTION \
	)

/obj/machinery/door/airlock/shell/check_access(obj/item/I)
	return FALSE

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
	// Input Signals
	bolt = add_input_port("Bolt", PORT_TYPE_SIGNAL)
	unbolt = add_input_port("Unbolt", PORT_TYPE_SIGNAL)
	open = add_input_port("Open", PORT_TYPE_SIGNAL)
	close = add_input_port("Close", PORT_TYPE_SIGNAL)
	// States
	is_open = add_output_port("Is Open", PORT_TYPE_NUMBER)
	is_bolted = add_output_port("Is Bolted", PORT_TYPE_NUMBER)
	// Output Signals
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
	attached_airlock = null
	return ..()

/obj/item/circuit_component/airlock/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/door/airlock))
		attached_airlock = shell
		RegisterSignal(shell, COMSIG_AIRLOCK_BOLT, .proc/airlock_bolted)
		RegisterSignal(shell, COMSIG_AIRLOCK_UNBOLT, .proc/airlock_unbolted)
		RegisterSignal(shell, COMSIG_AIRLOCK_OPEN, .proc/airlock_open)
		RegisterSignal(shell, COMSIG_AIRLOCK_CLOSE, .proc/airlock_closed)

/obj/item/circuit_component/airlock/unregister_shell(atom/movable/shell)
	attached_airlock = null
	UnregisterSignal(shell, list(
		COMSIG_AIRLOCK_BOLT,
		COMSIG_AIRLOCK_UNBOLT,
		COMSIG_AIRLOCK_OPEN,
		COMSIG_AIRLOCK_CLOSE,
	))
	return ..()

/obj/item/circuit_component/airlock/proc/airlock_bolted(datum/source)
	SIGNAL_HANDLER
	is_bolted.set_output(TRUE)
	bolted.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/airlock/proc/airlock_unbolted(datum/source)
	SIGNAL_HANDLER
	is_bolted.set_output(FALSE)
	unbolted.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/airlock/proc/airlock_open(datum/source, force)
	SIGNAL_HANDLER
	is_open.set_output(TRUE)
	opened.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/airlock/proc/airlock_closed(datum/source, forced)
	SIGNAL_HANDLER
	is_open.set_output(FALSE)
	closed.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/airlock/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(!attached_airlock)
		return

	if(COMPONENT_TRIGGERED_BY(bolt, port))
		attached_airlock.bolt()
	if(COMPONENT_TRIGGERED_BY(unbolt, port))
		attached_airlock.unbolt()
	if(COMPONENT_TRIGGERED_BY(open, port) && attached_airlock.density)
		INVOKE_ASYNC(attached_airlock, /obj/machinery/door/airlock.proc/open)
	if(COMPONENT_TRIGGERED_BY(close, port) && !attached_airlock.density)
		INVOKE_ASYNC(attached_airlock, /obj/machinery/door/airlock.proc/close)
