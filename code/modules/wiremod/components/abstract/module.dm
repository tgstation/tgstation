/**
 * # Module Component
 *
 * A component that has an input, output
 */
/obj/item/circuit_component/module
	display_name = "Module"
	desc = "A component that has other components within it, acting like a function. Use it in your hand to control the amount of input and output ports it has, as well as being able to access the integrated circuit contained inside."
	category = "Abstract"

	var/obj/item/integrated_circuit/module/internal_circuit

	var/obj/item/circuit_component/module_input/input_component
	var/obj/item/circuit_component/module_output/output_component

	/// Linked ports that follow a `first_port = second_port` keyed structure.
	var/list/linked_ports = list()

	var/port_limit = 10

	ui_buttons = list(
		"edit" = "action"
	)

/obj/item/integrated_circuit/module
	var/obj/item/circuit_component/module/attached_module

/obj/item/integrated_circuit/module/ui_host(mob/user)
	if(attached_module)
		return attached_module.ui_host()
	return ..()

/obj/item/integrated_circuit/module/set_display_name(new_name)
	. = ..()
	attached_module.display_name = new_name
	attached_module.name = "module ([new_name])"

/obj/item/integrated_circuit/module/load_component(type)
	if(!attached_module)
		return ..()

	if(ispath(type, /obj/item/circuit_component/module_input))
		return attached_module.input_component

	if(ispath(type, /obj/item/circuit_component/module_output))
		return attached_module.output_component

	return ..()

/obj/item/integrated_circuit/module/add_component(obj/item/circuit_component/to_add, mob/living/user)
	if(to_add.circuit_flags & CIRCUIT_FLAG_REFUSE_MODULE)
		balloon_alert(user, "doesn't fit into module!")
		return
	. = ..()
	if(attached_module)
		attached_module.circuit_size += to_add.circuit_size

/obj/item/integrated_circuit/module/remove_component(obj/item/circuit_component/to_remove)
	if(attached_module)
		attached_module.circuit_size -= to_remove.circuit_size
	return ..()

/obj/item/integrated_circuit/module/Destroy()
	attached_module = null
	return ..()

/obj/item/circuit_component/module_input
	display_name = "Input"
	desc = "A component that receives data from the module it is attached to"

	removable = FALSE

	/// The currently attached module
	var/obj/item/circuit_component/module/attached_module

/obj/item/circuit_component/module_input/Destroy()
	attached_module = null
	return ..()

/obj/item/circuit_component/module_output
	display_name = "Output"
	desc = "A component that outputs data to the module it is attached to."

	removable = FALSE

	/// The currently attached module
	var/obj/item/circuit_component/module/attached_module

/obj/item/circuit_component/module_output/pre_input_received(datum/port/input/port)
	if(!port)
		return
	// We don't check the parent here because frankly, we don't care. We only sync our input with the module's output
	var/datum/port/output/port_to_update = attached_module.linked_ports[port]
	if(!port_to_update)
		CRASH("[port.type] doesn't have a linked port in [type]!")

	port_to_update.set_output(port.value)

/obj/item/circuit_component/module/pre_input_received(datum/port/input/port)
	if(!port)
		return
	var/datum/port/output/port_to_update = linked_ports[port]
	if(!port_to_update)
		CRASH("[port.type] doesn't have a linked port in [type]!")

	port_to_update.set_output(port.value)

/obj/item/circuit_component/module_output/Destroy()
	attached_module = null
	return ..()

/obj/item/circuit_component/module/Initialize(mapload)
	. = ..()
	internal_circuit = new(src)
	internal_circuit.attached_module = src

	input_component = new(internal_circuit)
	input_component.attached_module = src
	internal_circuit.add_component(input_component)
	input_component.rel_x = 0
	input_component.rel_y = 200

	output_component = new(internal_circuit)
	output_component.attached_module = src
	internal_circuit.add_component(output_component)
	output_component.rel_x = 400
	output_component.rel_y = 200

/obj/item/circuit_component/module/save_data_to_list(list/component_data)
	. = ..()
	component_data["integrated_circuit"] = internal_circuit.convert_to_json()

	var/list/input_data = list()
	for(var/datum/port/input/input_port as anything in input_ports)
		input_data += list(list(
			"name" = input_port.name,
			"type" = input_port.datatype,
		))

	var/list/output_data = list()
	for(var/datum/port/output/output_port as anything in output_ports)
		output_data += list(list(
			"name" = output_port.name,
			"type" = output_port.datatype,
		))

	component_data["input_ports"] = input_data
	component_data["output_ports"] = output_data

/obj/item/circuit_component/module/load_data_from_list(list/component_data)
	. = ..()

	var/list/input_ports = component_data["input_ports"]
	for(var/list/port_data as anything in input_ports)
		add_and_link_input_port(port_data["name"], port_data["type"])

	var/list/output_ports = component_data["output_ports"]
	for(var/list/port_data as anything in output_ports)
		add_and_link_output_port(port_data["name"], port_data["type"])

	if(component_data["integrated_circuit"])
		internal_circuit.load_circuit_data(component_data["integrated_circuit"])

/obj/item/circuit_component/module/proc/add_and_link_input_port(name, type)
	var/datum/port/new_port = add_input_port(name, type)
	linked_ports[new_port] = input_component.add_output_port(name, type)

/obj/item/circuit_component/module/proc/add_and_link_output_port(name, type)
	var/datum/port/new_port = output_component.add_input_port(name, type)
	linked_ports[new_port] = add_output_port(name, type)

/obj/item/circuit_component/module/add_to(obj/item/integrated_circuit/added_to)
	. = ..()
	RegisterSignal(added_to, COMSIG_CIRCUIT_SET_CELL, PROC_REF(handle_set_cell))
	RegisterSignal(added_to, COMSIG_CIRCUIT_SET_ON, PROC_REF(handle_set_on))
	RegisterSignal(added_to, COMSIG_CIRCUIT_SET_SHELL, PROC_REF(handle_set_shell))
	internal_circuit.set_cell(added_to.cell)
	internal_circuit.set_shell(added_to.shell)
	internal_circuit.set_on(added_to.on)


/obj/item/circuit_component/module/removed_from(obj/item/integrated_circuit/removed_from)
	internal_circuit.set_cell(null)
	internal_circuit.set_on(FALSE)
	internal_circuit.remove_current_shell()
	UnregisterSignal(removed_from, list(
		COMSIG_CIRCUIT_SET_CELL,
		COMSIG_CIRCUIT_SET_ON,
		COMSIG_CIRCUIT_SET_SHELL,
	))
	return ..()

/obj/item/circuit_component/module/proc/handle_set_cell(datum/source, obj/item/stock_parts/power_store/cell/cell)
	SIGNAL_HANDLER
	internal_circuit.set_cell(cell)

/obj/item/circuit_component/module/proc/handle_set_on(datum/source, new_value)
	SIGNAL_HANDLER
	internal_circuit.set_on(new_value)

/obj/item/circuit_component/module/proc/handle_set_shell(datum/source, atom/movable/new_shell)
	SIGNAL_HANDLER
	internal_circuit.set_shell(new_shell)

/obj/item/circuit_component/module/Destroy()
	QDEL_NULL(input_component)
	QDEL_NULL(output_component)
	QDEL_NULL(internal_circuit)
	linked_ports = null
	return ..()

/obj/item/circuit_component/module/ui_data(mob/user)
	. = list()
	.["input_ports"] = list()
	for(var/datum/port/input/input_port as anything in input_ports)
		.["input_ports"] += list(list(
			"name" = input_port.name,
			"type" = input_port.datatype,
		))

	.["output_ports"] = list()
	for(var/datum/port/output/output_port as anything in output_ports)
		.["output_ports"] += list(list(
			"name" = output_port.name,
			"type" = output_port.datatype,
		))

/obj/item/circuit_component/module/ui_static_data(mob/user)
	. = list()
	.["global_port_types"] = GLOB.wiremod_basic_types

/obj/item/circuit_component/module/attackby(obj/item/I, mob/living/user, list/modifiers)
	if(istype(I, /obj/item/circuit_component))
		internal_circuit.attackby(I, user, modifiers)
		return
	return ..()

#define WITHIN_RANGE(id, table) (id >= 1 && id <= length(table))

/obj/item/circuit_component/module/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("open_internal_circuit")
			internal_circuit.interact(usr)
			. = TRUE
		if("add_input_port")
			if(length(input_ports) > port_limit)
				return
			add_and_link_input_port("Input Port", PORT_TYPE_ANY)
			. = TRUE
		if("remove_input_port")
			var/port_id = text2num(params["port_id"])
			if(!WITHIN_RANGE(port_id, input_ports))
				return
			var/datum/port/removed_port = input_ports[port_id]
			linked_ports -= removed_port
			remove_input_port(removed_port)
			input_component.remove_output_port(input_component.output_ports[port_id])
			. = TRUE
		if("add_output_port")
			if(length(output_ports) > port_limit)
				return
			add_and_link_output_port("Output Port", PORT_TYPE_ANY)
			. = TRUE
		if("remove_output_port")
			var/port_id = text2num(params["port_id"])
			if(!WITHIN_RANGE(port_id, output_ports))
				return

			var/datum/port/removed_port = output_component.input_ports[port_id]
			linked_ports -= removed_port
			remove_output_port(output_ports[port_id])
			output_component.remove_input_port(removed_port)
			. = TRUE
		if("set_port_name", "set_port_type")
			var/port_id = text2num(params["port_id"])
			var/is_input = params["is_input"]

			var/list/ports_to_use
			var/list/internal_ports_to_use
			if(is_input)
				ports_to_use = input_ports
				internal_ports_to_use = input_component.output_ports
			else
				ports_to_use = output_ports
				internal_ports_to_use = output_component.input_ports

			if(!WITHIN_RANGE(port_id, ports_to_use))
				return

			var/datum/port/component_port = ports_to_use[port_id]
			var/datum/port/internal_component_port = internal_ports_to_use[port_id]

			if(action == "set_port_type")
				var/type = params["port_type"]
				if(!(type in GLOB.wiremod_basic_types))
					return
				component_port.set_datatype(type)
				internal_component_port.set_datatype(type)
			else
				var/port_name = params["port_name"]
				if(!port_name)
					return
				port_name = strip_html(port_name, PORT_MAX_NAME_LENGTH)
				component_port.name = port_name
				internal_component_port.name = port_name
			. = TRUE

	if(.)
		SStgui.update_uis(internal_circuit)

#undef WITHIN_RANGE

/obj/item/circuit_component/module/ui_perform_action(mob/user, action)
	interact(user)

/obj/item/circuit_component/module/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CircuitModule", name)
		ui.open()
		ui.set_autoupdate(FALSE)
