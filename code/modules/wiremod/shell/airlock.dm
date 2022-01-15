/datum/wires/airlock/shell
	holder_type = /obj/machinery/door/airlock/shell
	proper_name = "Circuit Airlock"

/datum/wires/airlock/shell/on_cut(wire, mend)
	// Don't allow them to re-enable autoclose.
	if(wire == WIRE_TIMING)
		return
	return ..()

/obj/machinery/door/airlock/shell
	name = "circuit airlock"
	autoclose = FALSE

/obj/machinery/door/airlock/shell/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/shell, \
		unremovable_circuit_components = list(new /obj/item/circuit_component/airlock, new /obj/item/circuit_component/airlock_access_event), \
		capacity = SHELL_CAPACITY_LARGE, \
		shell_flags = SHELL_FLAG_ALLOW_FAILURE_ACTION|SHELL_FLAG_REQUIRE_ANCHOR \
	)

/obj/machinery/door/airlock/shell/check_access(obj/item/I)
	return FALSE

/obj/machinery/door/airlock/shell/canAIControl(mob/user)
	return FALSE

/obj/machinery/door/airlock/shell/canAIHack(mob/user)
	return FALSE

/obj/machinery/door/airlock/shell/allowed(mob/user)
	if(SEND_SIGNAL(src, COMSIG_AIRLOCK_SHELL_ALLOWED, user) & COMPONENT_AIRLOCK_SHELL_ALLOW)
		return TRUE
	return isAdminGhostAI(user)

/obj/machinery/door/airlock/shell/set_wires()
	return new /datum/wires/airlock/shell(src)

/obj/item/circuit_component/airlock
	display_name = "Airlock"
	desc = "The general interface with an airlock. Includes general statuses of the airlock"

	/// The shell, if it is an airlock.
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

/obj/item/circuit_component/airlock/populate_ports()
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

/obj/item/circuit_component/airlock/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/door/airlock))
		attached_airlock = shell
		RegisterSignal(shell, COMSIG_AIRLOCK_SET_BOLT, .proc/on_airlock_set_bolted)
		RegisterSignal(shell, COMSIG_AIRLOCK_OPEN, .proc/on_airlock_open)
		RegisterSignal(shell, COMSIG_AIRLOCK_CLOSE, .proc/on_airlock_closed)

/obj/item/circuit_component/airlock/unregister_shell(atom/movable/shell)
	attached_airlock = null
	UnregisterSignal(shell, list(
		COMSIG_AIRLOCK_SET_BOLT,
		COMSIG_AIRLOCK_OPEN,
		COMSIG_AIRLOCK_CLOSE,
	))
	return ..()

/obj/item/circuit_component/airlock/proc/on_airlock_set_bolted(datum/source, should_bolt)
	SIGNAL_HANDLER
	is_bolted.set_output(should_bolt)
	if(should_bolt)
		bolted.set_output(COMPONENT_SIGNAL)
	else
		unbolted.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/airlock/proc/on_airlock_open(datum/source, force)
	SIGNAL_HANDLER
	is_open.set_output(TRUE)
	opened.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/airlock/proc/on_airlock_closed(datum/source, forced)
	SIGNAL_HANDLER
	is_open.set_output(FALSE)
	closed.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/airlock/input_received(datum/port/input/port)

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


/obj/item/circuit_component/airlock_access_event
	display_name = "Airlock Access Event"
	desc = "An event that can be handled through circuit components to determine if the door should open or not for an entity that might be trying to access it."
	circuit_flags = CIRCUIT_FLAG_INSTANT

	/// The shell, if it is an airlock.
	var/obj/machinery/door/airlock/attached_airlock

	/// Tells the event to open the airlock.
	var/datum/port/input/open_airlock

	/// The person trying to open the airlock.
	var/datum/port/output/accessing_entity

	/// The signal sent when this event is triggered
	var/datum/port/output/event_triggered


/obj/item/circuit_component/airlock_access_event/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/door/airlock))
		attached_airlock = shell
		RegisterSignal(shell, COMSIG_OBJ_ALLOWED, .proc/handle_allowed)

/obj/item/circuit_component/airlock_access_event/unregister_shell(atom/movable/shell)
	attached_airlock = null
	UnregisterSignal(shell, list(
		COMSIG_OBJ_ALLOWED,
	))
	return ..()


/obj/item/circuit_component/airlock_access_event/populate_ports()
	open_airlock = add_input_port("Should Open Airlock", PORT_TYPE_RESPONSE_SIGNAL, trigger = .proc/should_open_airlock)
	accessing_entity = add_output_port("Accessing Entity", PORT_TYPE_ATOM)
	event_triggered = add_output_port("Event Triggered", PORT_TYPE_INSTANT_SIGNAL)


/obj/item/circuit_component/airlock_access_event/proc/should_open_airlock(datum/port/input/port, list/return_values)
	CIRCUIT_TRIGGER
	if(!return_values)
		return
	return_values["should_open"] = TRUE

/obj/item/circuit_component/airlock_access_event/proc/handle_allowed(datum/source, mob/accesser)
	SIGNAL_HANDLER
	if(!attached_airlock)
		return

	SScircuit_component.queue_instant_run()
	accessing_entity.set_output(accesser)
	event_triggered.set_output(COMPONENT_SIGNAL)
	var/list/result = SScircuit_component.execute_instant_run()

	if(!result)
		attached_airlock.visible_message(span_warning("[attached_airlock]'s circuitry overheats!"))
		return

	if(result["should_open"])
		return COMPONENT_OBJ_ALLOW
