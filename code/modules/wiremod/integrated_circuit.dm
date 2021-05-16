/**
 * # Integrated Circuitboard
 *
 * A circuitboard that holds components that work together
 *
 * Has a limited amount of power.
 */
/obj/item/integrated_circuit
	name = "integrated circuit"
	icon = 'icons/obj/module.dmi'
	icon_state = "circuit_map"
	inhand_icon_state = "electronic"

	/// The power of the integrated circuit
	var/obj/item/stock_parts/cell/cell

	/// The attached components
	var/list/obj/item/component/attached_components = list()

/obj/item/integrated_circuit/loaded/Initialize()
	. = ..()
	cell = new /obj/item/stock_parts/cell/high(src)

/obj/item/integrated_circuit/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(iscomponent(I))
		add_component(I)

/**
 * Adds a component to the circuitboard
 *
 * Once the component is added, the ports can be attached to other components
 */
/obj/item/integrated_circuit/proc/add_component(obj/item/component/to_add)
	if(to_add.parent)
		return
	to_add.rel_x = rand(COMPONENT_MIN_RANDOM_POS, COMPONENT_MAX_RANDOM_POS)
	to_add.rel_y = rand(COMPONENT_MIN_RANDOM_POS, COMPONENT_MAX_RANDOM_POS)
	to_add.parent = src
	to_add.forceMove(src)
	attached_components += to_add
	RegisterSignal(to_add, COMSIG_MOVABLE_MOVED, .proc/component_move_handler)
	SStgui.update_uis(src)

/obj/item/integrated_circuit/proc/component_move_handler(obj/item/component/source)
	SIGNAL_HANDLER
	if(source.loc != src)
		remove_component(source)

/**
 * Removes a component to the circuitboard
 *
 * This removes all connects between the ports
 */
/obj/item/integrated_circuit/proc/remove_component(obj/item/component/to_remove)
	to_remove.parent = null
	UnregisterSignal(to_remove, COMSIG_MOVABLE_MOVED)
	attached_components -= to_remove
	SStgui.update_uis(src)

/obj/item/integrated_circuit/get_cell()
	return cell

/obj/item/integrated_circuit/ui_data(mob/user)
	. = list()
	.["components"] = list()
	for(var/obj/item/component/component as anything in attached_components)
		var/list/component_data = list()
		component_data["input_ports"] = list()
		for(var/datum/port/input/port as anything in component.input_ports)
			component_data["input_ports"] += list(list(
				"name" = port.name,
				"type" = port.datatype,
				"ref" = REF(port), // The ref is the identifier to work out what it is connected to
				"connected_to" = REF(port.connected_port),
				"current_data" = port.input_value,
			))
		component_data["output_ports"] = list()
		for(var/datum/port/output/port as anything in component.output_ports)
			component_data["output_ports"] += list(list(
				"name" = port.name,
				"type" = port.datatype,
				"ref" = REF(port),
				"current_data" = port.output_value,
			))

		component_data["name"] = component.display_name
		component_data["x"] = component.rel_x
		component_data["y"] = component.rel_y
		component_data["option"] = component.current_option
		component_data["options"] = component.options
		.["components"] += list(component_data)

/obj/item/integrated_circuit/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IntegratedCircuit", name)
		ui.open()
		ui.set_autoupdate(FALSE)

#define WITHIN_RANGE(id, table) (id >= 1 && id <= length(table))

/obj/item/integrated_circuit/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("add_connection")
			var/input_component_id = text2num(params["input_component_id"])
			var/output_component_id = text2num(params["output_component_id"])
			var/input_port_id = text2num(params["input_port_id"])
			var/output_port_id = text2num(params["output_port_id"])
			if(!WITHIN_RANGE(input_component_id, attached_components) || !WITHIN_RANGE(output_component_id, attached_components))
				return
			var/obj/item/component/input_component = attached_components[input_component_id]
			var/obj/item/component/output_component = attached_components[output_component_id]

			if(!WITHIN_RANGE(input_port_id, input_component.input_ports) || !WITHIN_RANGE(output_port_id, output_component.output_ports))
				return
			var/datum/port/input/input_port = input_component.input_ports[input_port_id]
			var/datum/port/output/output_port = output_component.output_ports[output_port_id]

			if(input_port.datatype && input_port.datatype != output_port.datatype)
				return

			input_port.register_output_port(output_port)
			. = TRUE
		if("remove_connection")
			var/component_id = text2num(params["component_id"])
			var/is_input = params["is_input"]
			var/port_id = text2num(params["port_id"])

			if(!WITHIN_RANGE(component_id, attached_components))
				return
			var/obj/item/component/component = attached_components[component_id]

			var/list/port_table
			if(is_input)
				port_table = component.input_ports
			else
				port_table = component.output_ports

			if(!WITHIN_RANGE(port_id, port_table))
				return

			var/datum/port/port = port_table[port_id]
			port.disconnect()
			. = TRUE
		if("detach_component")
			var/component_id = text2num(params["component_id"])
			if(!WITHIN_RANGE(component_id, attached_components))
				return
			var/obj/item/component/component = attached_components[component_id]
			component.disconnect()
			remove_component(component)
			usr.put_in_hands(component)
			. = TRUE
		if("set_component_coordinates")
			var/component_id = text2num(params["component_id"])
			if(!WITHIN_RANGE(component_id, attached_components))
				return
			var/obj/item/component/component = attached_components[component_id]
			component.rel_x = min(max(0, text2num(params["rel_x"])), COMPONENT_MAX_POS)
			component.rel_y = min(max(0, text2num(params["rel_y"])), COMPONENT_MAX_POS)
			. = TRUE
		if("set_component_option")
			var/component_id = text2num(params["component_id"])
			if(!WITHIN_RANGE(component_id, attached_components))
				return
			var/obj/item/component/component = attached_components[component_id]
			var/option = params["option"]
			if(!(option in component.options))
				return
			component.set_option(option)
			. = TRUE
		if("set_component_input")
			var/component_id = text2num(params["component_id"])
			var/port_id = text2num(params["port_id"])
			if(!WITHIN_RANGE(component_id, attached_components))
				return
			var/obj/item/component/component = attached_components[component_id]
			if(!WITHIN_RANGE(port_id, component.input_ports))
				return
			var/datum/port/input/port = component.input_ports[port_id]
			var/user_input = params["input"]
			switch(port.datatype)
				if(PORT_TYPE_STRING, PORT_TYPE_ANY)
					port.set_value(copytext(user_input, 1, MAX_STRING_LENGTH))
				if(PORT_TYPE_NUMBER)
					port.set_value(text2num(user_input))
				// TODO: Add List support
			. = TRUE
#undef WITHIN_RANGE
