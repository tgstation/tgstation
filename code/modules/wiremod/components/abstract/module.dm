/**
 * # Module Component
 *
 * A component that has an input, output
 */
/obj/item/circuit_component/module
	display_name = "Module"
	display_desc = "A component that has other components within it, acting like a function."

	var/obj/item/integrated_circuit/internal_circuit

	var/obj/item/circuit_component/module_input/input_component
	var/obj/item/circuit_component/module_output/output_component

	var/port_limit = 10

/obj/item/circuit_component/module_input
	display_name = "Input"
	display_desc = "A component that receives data from the module it is attached to"

	removable = FALSE

	/// The input ports from attached module, mapped by index.
	var/list/input_ports_by_index

	/// The currently attached module
	var/obj/item/circuit_component/module/attached_module

/obj/item/circuit_component/module_input/Destroy()
	attached_module = null
	input_ports_by_index = null
	return ..()

/obj/item/circuit_component/module_output
	display_name = "Output"
	display_desc = "A component that outputs data to the module it is attached to."

	removable = FALSE


	/// The currently attached module
	var/obj/item/circuit_component/module/attached_module

/obj/item/circuit_component/module_output/Destroy()
	attached_module = null
	return ..()

/obj/item/circuit_component/module/Initialize()
	. = ..()
	internal_circuit = new(src)

	input_component = new(src)
	internal_circuit.add_component(input_component)
	input_component.rel_x = 400
	input_component.rel_y = 200

	output_component = new(src)
	internal_circuit.add_component(output_component)
	output_component.rel_x = 400
	output_component.rel_y = 200

/obj/item/circuit_component/module/add_to(obj/item/integrated_circuit/added_to)
	. = ..()
	RegisterSignal(added_to, COMSIG_CIRCUIT_SET_CELL, .proc/handle_set_cell)
	RegisterSignal(added_to, COMSIG_CIRCUIT_SET_ON, .proc/handle_set_on)
	internal_circuit.set_cell(added_to.cell)
	internal_circuit.set_on(added_to.on)

/obj/item/circuit_component/module/removed_from(obj/item/integrated_circuit/removed_from)
	internal_circuit.set_cell(null)
	internal_circuit.set_on(FALSE)
	UnregisterSignal(removed_from, list(
		COMSIG_CIRCUIT_SET_CELL,
		COMSIG_CIRCUIT_SET_ON,
	))
	return ..()

/obj/item/circuit_component/module/proc/handle_set_cell(datum/source, obj/item/stock_parts/cell/cell)
	SIGNAL_HANDLER
	internal_circuit.set_cell(cell)

/obj/item/circuit_component/module/Destroy()
	QDEL_NULL(input_component)
	QDEL_NULL(output_component)
	return ..()

/obj/item/circuit_component/module/ui_data(mob/user)
	. = list()
	.["input_ports"] = list()
	for(var/datum/port/input/input_port as anything in input_ports)
		.["input_ports"] += list(list(
			"name" = input_port.name,
			"type" = input_port.type,
		))

	.["output_ports"] = list()
	for(var/datum/port/output/output_port as anything in output_ports)
		.["output_ports"] += list(list(
			"name" = output_port.name,
			"type" = output_port.type,
		))

/obj/item/circuit_component/module/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("add_input_port")
			add_input_port("Input Port", PORT_TYPE_ANY)
			input_component.add_output_port("Input Port", PORT_TYPE_ANY)
			. = TRUE
		if("remove_input_port")
		if("add_output_port")
		if("remove_output_port")
		if("set_port_name")
		if("set_port_type")

/obj/item/circuit_component/module/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CircuitModule", name)
		ui.open()
		ui.set_autoupdate(FALSE)
