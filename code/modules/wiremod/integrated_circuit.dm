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
	icon_state = "integrated_circuit"
	inhand_icon_state = "electronic"

	/// The power of the integrated circuit
	var/obj/item/stock_parts/cell/cell

	/// The shell that this circuitboard is attached to. Used by components.
	var/atom/movable/shell

	/// The attached components
	var/list/obj/item/circuit_component/attached_components = list()

	/// Whether the integrated circuit is on or not. Handled by the shell.
	var/on = FALSE

/obj/item/integrated_circuit/loaded/Initialize()
	. = ..()
	cell = new /obj/item/stock_parts/cell/high(src)

/obj/item/integrated_circuit/Destroy()
	for(var/obj/item/circuit_component/to_delete in attached_components)
		remove_component(to_delete)
		qdel(to_delete)
	shell = null
	QDEL_NULL(cell)
	return ..()

/obj/item/integrated_circuit/examine(mob/user)
	. = ..()
	if(cell)
		. += "<span class='notice'>The charge meter reads [cell ? round(cell.percent(), 1) : 0]%.</span>"
	else
		. += "<span class='notice'>There is no power cell installed.</span>"

/obj/item/integrated_circuit/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/circuit_component))
		add_component(I, user)
		return

	if(istype(I, /obj/item/stock_parts/cell))
		if(cell)
			balloon_alert(user, "<span class='warning'>There already is a cell inside!</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		cell = I
		I.add_fingerprint(user)
		user.visible_message("<span class='notice'>[user] inserts a power cell into [src].</span>", "<span class='notice'>You insert the power cell into [src].</span>")
		return

	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(!cell)
			return
		I.play_tool_sound(src)
		user.visible_message("<span class='notice'>[user] unscrews the power cell from [src].</span>", "<span class='notice'>You unscrew the power cell from [src].</span>")
		cell.forceMove(drop_location())
		cell = null
		return

/**
 * Registers an movable atom as a shell
 *
 * No functionality is done here. This is so that input components
 * can properly register any signals on the shell.
 * Arguments:
 * * new_shell - The new shell to register.
 */
/obj/item/integrated_circuit/proc/set_shell(atom/movable/new_shell)
	remove_current_shell()
	on = TRUE
	shell = new_shell
	RegisterSignal(shell, COMSIG_PARENT_QDELETING, .proc/remove_current_shell)
	for(var/obj/item/circuit_component/attached_component as anything in attached_components)
		attached_component.register_shell(shell)
		// Their input ports may be updated with user values, but the outputs haven't updated
		// because on is FALSE
		attached_component.input_received()

/**
 * Unregisters the current shell attached to this circuit.
 */
/obj/item/integrated_circuit/proc/remove_current_shell()
	SIGNAL_HANDLER
	if(!shell)
		return
	for(var/obj/item/circuit_component/attached_component as anything in attached_components)
		attached_component.unregister_shell(shell)
	UnregisterSignal(shell, COMSIG_PARENT_QDELETING)
	shell = null
	on = FALSE

/**
 * Adds a component to the circuitboard
 *
 * Once the component is added, the ports can be attached to other components
 */
/obj/item/integrated_circuit/proc/add_component(obj/item/circuit_component/to_add, mob/living/user)
	if(to_add.parent)
		return

	if(SEND_SIGNAL(src, COMSIG_CIRCUIT_ADD_COMPONENT, to_add, user) & COMPONENT_CANCEL_ADD_COMPONENT)
		return

	var/success = FALSE
	if(user)
		success = user.transferItemToLoc(to_add, src)
	else
		success = to_add.forceMove(src)

	if(!success)
		return

	to_add.rel_x = rand(COMPONENT_MIN_RANDOM_POS, COMPONENT_MAX_RANDOM_POS)
	to_add.rel_y = rand(COMPONENT_MIN_RANDOM_POS, COMPONENT_MAX_RANDOM_POS)
	to_add.parent = src
	attached_components += to_add
	RegisterSignal(to_add, COMSIG_MOVABLE_MOVED, .proc/component_move_handler)
	SStgui.update_uis(src)

	if(shell)
		to_add.register_shell(shell)

/obj/item/integrated_circuit/proc/component_move_handler(obj/item/circuit_component/source)
	SIGNAL_HANDLER
	if(source.loc != src)
		remove_component(source)

/**
 * Removes a component to the circuitboard
 *
 * This removes all connects between the ports
 */
/obj/item/integrated_circuit/proc/remove_component(obj/item/circuit_component/to_remove)
	if(shell)
		to_remove.unregister_shell(shell)

	UnregisterSignal(to_remove, COMSIG_MOVABLE_MOVED)
	attached_components -= to_remove
	to_remove.disconnect()
	to_remove.parent = null
	SStgui.update_uis(src)

/obj/item/integrated_circuit/get_cell()
	return cell

/obj/item/integrated_circuit/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/circuit_assets)
	)

/obj/item/integrated_circuit/ui_data(mob/user)
	. = list()
	.["components"] = list()
	for(var/obj/item/circuit_component/component as anything in attached_components)
		var/list/component_data = list()
		component_data["input_ports"] = list()
		for(var/datum/port/input/port as anything in component.input_ports)
			var/current_data = port.input_value
			if(isatom(current_data)) // Prevent passing the name of the atom.
				current_data = null
			component_data["input_ports"] += list(list(
				"name" = port.name,
				"type" = port.datatype,
				"ref" = REF(port), // The ref is the identifier to work out what it is connected to
				"connected_to" = REF(port.connected_port),
				"color" = port.color,
				"current_data" = current_data,
			))
		component_data["output_ports"] = list()
		for(var/datum/port/output/port as anything in component.output_ports)
			component_data["output_ports"] += list(list(
				"name" = port.name,
				"type" = port.datatype,
				"ref" = REF(port),
				"color" = port.color
			))

		component_data["name"] = component.display_name
		component_data["x"] = component.rel_x
		component_data["y"] = component.rel_y
		component_data["option"] = component.current_option
		component_data["options"] = component.options
		component_data["removable"] = component.removable
		.["components"] += list(component_data)

/obj/item/integrated_circuit/ui_host(mob/user)
	if(shell)
		return shell
	return ..()

/obj/item/integrated_circuit/ui_state(mob/user)
	if(!shell)
		return GLOB.hands_state
	return GLOB.physical_obscured_state

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
			var/obj/item/circuit_component/input_component = attached_components[input_component_id]
			var/obj/item/circuit_component/output_component = attached_components[output_component_id]

			if(!WITHIN_RANGE(input_port_id, input_component.input_ports) || !WITHIN_RANGE(output_port_id, output_component.output_ports))
				return
			var/datum/port/input/input_port = input_component.input_ports[input_port_id]
			var/datum/port/output/output_port = output_component.output_ports[output_port_id]

			if(input_port.datatype && !output_port.compatible_datatype(input_port.datatype))
				return

			input_port.register_output_port(output_port)
			. = TRUE
		if("remove_connection")
			var/component_id = text2num(params["component_id"])
			var/is_input = params["is_input"]
			var/port_id = text2num(params["port_id"])

			if(!WITHIN_RANGE(component_id, attached_components))
				return
			var/obj/item/circuit_component/component = attached_components[component_id]

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
			var/obj/item/circuit_component/component = attached_components[component_id]
			if(!component.removable)
				return
			component.disconnect()
			remove_component(component)
			usr.put_in_hands(component)
			. = TRUE
		if("set_component_coordinates")
			var/component_id = text2num(params["component_id"])
			if(!WITHIN_RANGE(component_id, attached_components))
				return
			var/obj/item/circuit_component/component = attached_components[component_id]
			component.rel_x = min(max(-COMPONENT_MAX_POS, text2num(params["rel_x"])), COMPONENT_MAX_POS)
			component.rel_y = min(max(-COMPONENT_MAX_POS, text2num(params["rel_y"])), COMPONENT_MAX_POS)
			. = TRUE
		if("set_component_option")
			var/component_id = text2num(params["component_id"])
			if(!WITHIN_RANGE(component_id, attached_components))
				return
			var/obj/item/circuit_component/component = attached_components[component_id]
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
			var/obj/item/circuit_component/component = attached_components[component_id]
			if(!WITHIN_RANGE(port_id, component.input_ports))
				return
			var/datum/port/input/port = component.input_ports[port_id]

			if(port.connected_port)
				return

			if(params["set_null"])
				port.set_input(null)
				return TRUE

			if(params["marked_atom"])
				if(port.datatype != PORT_TYPE_ATOM && port.datatype != PORT_TYPE_ANY)
					return
				var/obj/item/multitool/circuit/marker = usr.get_active_held_item()
				if(!istype(marker))
					return TRUE
				if(!marker.marked_atom)
					port.set_input(null)
					marker.say("Cleared port ('[port.name]')'s value.")
					return TRUE
				marker.say("Updated port ('[port.name]')'s value to the marked entity.")
				port.set_input(marker.marked_atom)
				return TRUE

			var/user_input = params["input"]
			switch(port.datatype)
				if(PORT_TYPE_NUMBER)
					port.set_input(text2num(user_input))
				if(PORT_TYPE_ANY)
					var/any_type = copytext(user_input, 1, PORT_MAX_STRING_LENGTH)
					port.set_input(text2num(any_type) || any_type)
				if(PORT_TYPE_STRING)
					port.set_input(copytext(user_input, 1, PORT_MAX_STRING_LENGTH))
			. = TRUE
		if("get_component_value")
			var/component_id = text2num(params["component_id"])
			var/port_id = text2num(params["port_id"])
			if(!WITHIN_RANGE(component_id, attached_components))
				return
			var/obj/item/circuit_component/component = attached_components[component_id]
			if(!WITHIN_RANGE(port_id, component.output_ports))
				return

			var/datum/port/output/port = component.output_ports[port_id]
			var/value = port.output_value
			if(isatom(value))
				value = port.convert_value(port.output_value)
			else if(isnull(value))
				value = "null"
			balloon_alert(usr, "[port.name] value: [value]")
			. = TRUE

#undef WITHIN_RANGE
