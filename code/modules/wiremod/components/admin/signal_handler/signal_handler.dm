#define COMP_SIGNAL_HANDLER_GLOBAL "Global"
#define COMP_SIGNAL_HANDLER_OBJECT "Object"

/**
 * # Signal Handler Component
 *
 * A component that registers signals on events and listens for them.
 */
/obj/item/circuit_component/signal_handler
	display_name = "Signal Handler"
	desc = "A component that listens for signals on an object."
	category = "Admin"
	circuit_flags = CIRCUIT_FLAG_ADMIN|CIRCUIT_FLAG_INSTANT

	/// Whether it is a global or object signal
	var/datum/port/input/option/signal_handler_options

	/// The list of signal IDs that can be selected as an option.
	var/datum/port/input/option/signal_id

	/// Whether this executes instantly or not. If set to 0, this will not execute instantly.
	var/datum/port/input/instant

	var/list/signal_map

	/// Entity to register the signal on
	var/datum/port/input/target
	/// Registers the signal
	var/datum/port/input/register
	/// Unregisters the signal on the target.
	var/datum/port/input/unregister
	/// Unregisters the signal from everyone.
	var/datum/port/input/unregister_all

	/// The custom signal ports from the current signal type. Used for saving and loading.
	var/list/signal_ports
	/// The custom input from the current signal type.
	var/list/datum/port/input/input_signal_ports = list()
	/// The custom output from the current signal type.
	var/list/datum/port/output/output_signal_ports = list()

	/// The entity received from the event.
	var/datum/port/output/entity
	/// The event has been triggered
	var/datum/port/output/event_triggered

	/// The current entities that have the signal registered on it
	var/list/datum/weakref/registered_entities = list()
	/// The current registered signal
	var/registered_signal

	/// Whether it is a custom signal id or not.
	var/custom_signal = FALSE

/obj/item/circuit_component/signal_handler/populate_options()
	var/static/list/component_options = list(
		COMP_SIGNAL_HANDLER_OBJECT,
		COMP_SIGNAL_HANDLER_GLOBAL,
	)
	signal_handler_options = add_option_port("Signal Handler Options", component_options, trigger = null)

	signal_id = add_option_port("Signal ID", GLOB.integrated_circuit_signal_ids, trigger = null)
	signal_map = GLOB.integrated_circuit_signal_ids

/obj/item/circuit_component/signal_handler/populate_ports()
	instant = add_input_port("Instant", PORT_TYPE_NUMBER, order = 0.5, trigger = null, default = 1)
	register = add_input_port("Register", PORT_TYPE_SIGNAL, order = 2, trigger = .proc/register_signals)
	unregister = add_input_port("Unregister", PORT_TYPE_SIGNAL, order = 2, trigger = .proc/unregister_signals)
	unregister_all = add_input_port("Unregister All", PORT_TYPE_SIGNAL, order = 2, trigger = .proc/unregister_signals_all)

	add_source_entity()
	event_triggered = add_output_port("Triggered", PORT_TYPE_INSTANT_SIGNAL, order = 2)

/obj/item/circuit_component/signal_handler/proc/add_source_entity()
	if(target)
		remove_input_port(target)
	if(entity)
		remove_output_port(entity)

	target = add_input_port("Target", PORT_TYPE_DATUM, order = 1, trigger = null)
	entity = add_output_port("Source Entity", PORT_TYPE_DATUM, order = 0)

/obj/item/circuit_component/signal_handler/save_data_to_list(list/component_data)
	. = ..()
	component_data["signal_id"] = signal_id.value
	component_data["signal_port_data"] = signal_ports

/obj/item/circuit_component/signal_handler/load_data_from_list(list/component_data)
	signal_id.set_value(component_data["signal_id"], force = TRUE)
	registered_signal = signal_id.value
	load_new_ports(component_data["signal_port_data"])
	custom_signal = TRUE
	return ..()


/obj/item/circuit_component/signal_handler/pre_input_received(datum/port/input/port)
	if(signal_id.value != registered_signal)
		custom_signal = FALSE
		unregister_signals_all(port)
		registered_signal = signal_id.value
		var/list/data = signal_map[registered_signal]
		if(data)
			load_new_ports(data)

	if(signal_handler_options == port)
		set_signal_options(port)

/obj/item/circuit_component/signal_handler/proc/set_signal_options(datum/port/input/port)
	CIRCUIT_TRIGGER

	switch(signal_handler_options.value)
		if(COMP_SIGNAL_HANDLER_GLOBAL)
			signal_id.possible_options = GLOB.integrated_circuit_global_signal_ids
			signal_map = GLOB.integrated_circuit_global_signal_ids
			remove_output_port(entity)
			remove_input_port(target)
			target = null
			entity = null
		if(COMP_SIGNAL_HANDLER_OBJECT)
			signal_id.possible_options = GLOB.integrated_circuit_signal_ids
			signal_map = GLOB.integrated_circuit_signal_ids
			add_source_entity()

	if(!custom_signal)
		signal_id.set_value(null, TRUE)
	unregister_signals_all(port)

/obj/item/circuit_component/signal_handler/proc/register_signals(datum/port/input/port)
	CIRCUIT_TRIGGER
	var/datum/target_datum = target?.value
	if(signal_handler_options.value == COMP_SIGNAL_HANDLER_GLOBAL)
		target_datum = SSdcs

	if(target_datum)
		log_admin_circuit("[parent.get_creator()] registered the signal '[registered_signal]' on [target_datum]")
		// We override because an admin may try registering a signal on the same object/datum again, so this prevents any runtimes from occuring
		RegisterSignal(target_datum, registered_signal, .proc/handle_signal_received, override = TRUE)
		registered_entities |= WEAKREF(target_datum)

/obj/item/circuit_component/signal_handler/proc/load_new_ports(list/ports_to_load)
	for(var/datum/port/input/input_port as anything in input_signal_ports)
		remove_input_port(input_port)
	for(var/datum/port/output/output_port as anything in output_signal_ports)
		remove_output_port(output_port)
	input_signal_ports = list()
	output_signal_ports = list()

	signal_ports = ports_to_load
	for(var/list/data in signal_ports)
		if(data["is_response"])
			var/datum/port/input/bitflag_input = add_input_port(data["name"], PORT_TYPE_SIGNAL, order = 3, trigger = .proc/handle_bitflag_received)
			input_signal_ports[bitflag_input] = data["bitflag"]
		else
			output_signal_ports += add_output_port(data["name"], data["type"], order = 1)


/obj/item/circuit_component/signal_handler/proc/unregister_signals_all(datum/port/input/port)
	CIRCUIT_TRIGGER
	for(var/datum/weakref/weakref_of_object as anything in registered_entities)
		var/datum/datum_to_unregister = weakref_of_object.resolve()
		if(!datum_to_unregister)
			continue
		UnregisterSignal(datum_to_unregister, registered_signal)
	registered_entities.Cut()

/obj/item/circuit_component/signal_handler/proc/unregister_signals(datum/port/input/port)
	CIRCUIT_TRIGGER

	var/datum/registered_datum = target?.value
	if(signal_handler_options.value == COMP_SIGNAL_HANDLER_GLOBAL)
		registered_datum = SSdcs

	if(!registered_datum)
		return

	UnregisterSignal(registered_datum, registered_signal)
	registered_entities -= WEAKREF(registered_datum)

/obj/item/circuit_component/signal_handler/proc/run_ports_on_args(list/arguments)
	var/first_arg = popleft(arguments)
	if(entity)
		entity.set_output(first_arg)

	for(var/datum/port/output/port as anything in output_signal_ports)
		port.set_output(popleft(arguments))
	event_triggered.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/signal_handler/proc/handle_signal_received(...)
	SIGNAL_HANDLER
	var/list/arguments = args.Copy()

	if(!instant.value)
		run_ports_on_args(arguments)
		return

	// usr is not supposed to be defined whilst these execute, which it can be for some signal IDs.
	// Especially if you try to proccall something - it'll fail because of this reason.
	// No other way to solve this problem without refactoring proccall code, but it's admin tooling so it's whatever.
	var/temp_usr = usr
	usr = null

	var/list/displayArgs = arguments.Copy()
	log_admin_circuit("[parent.get_creator()] received a signal from [popleft(displayArgs)] ([registered_signal]) with the parameters \[[displayArgs.Join(", ")]]")
	SScircuit_component.queue_instant_run()
	run_ports_on_args(arguments)
	var/list/output = SScircuit_component.execute_instant_run()

	usr = temp_usr

	if(!output)
		message_admins("[parent.get_creator_admin()] took too much CPU time trying to handle a signal. Reduce the amount of circuit components attached to your [name] circuit component.")
		return

	return output["bitflag"] || NONE

/obj/item/circuit_component/signal_handler/proc/handle_bitflag_received(datum/port/input/port, list/return_values)
	CIRCUIT_TRIGGER
	if(!return_values)
		return

	if(!return_values["bitflag"])
		return_values["bitflag"] = NONE

	var/bitflag = input_signal_ports[port]
	log_admin_circuit("[parent.get_creator()] received bitflag [bitflag] for '[registered_signal]'")
	return_values["bitflag"] |= bitflag

#undef COMP_SIGNAL_HANDLER_GLOBAL
#undef COMP_SIGNAL_HANDLER_OBJECT
