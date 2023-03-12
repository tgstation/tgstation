/// A list of all integrated circuits
GLOBAL_LIST_EMPTY_TYPED(integrated_circuits, /obj/item/integrated_circuit)

/**
 * # Integrated Circuitboard
 *
 * A circuitboard that holds components that work together
 *
 * Has a limited amount of power.
 */
/obj/item/integrated_circuit
	name = "integrated circuit"
	desc = "By inserting components and a cell into this, wiring them up, and putting them into a shell, anyone can pretend to be a programmer."
	icon = 'icons/obj/module.dmi'
	icon_state = "integrated_circuit"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'

	/// The name that appears on the shell.
	var/display_name = ""

	/// The max length of the name.
	var/label_max_length = 24

	/// The power of the integrated circuit
	var/obj/item/stock_parts/cell/cell

	/// The shell that this circuitboard is attached to. Used by components.
	var/atom/movable/shell

	/// The attached components
	var/list/obj/item/circuit_component/attached_components = list()

	/// Whether the integrated circuit is on or not. Handled by the shell.
	var/on = FALSE

	/// Whether the integrated circuit is locked or not. Handled by the shell.
	var/locked = FALSE

	/// Whether the integrated circuit is admin only. Disables power usage and allows admin circuits to be attached, at the cost of making it inaccessible to regular users.
	var/admin_only = FALSE

	/// The ID that is authorized to unlock/lock the shell so that the circuit can/cannot be removed.
	var/datum/weakref/owner_id

	/// The current examined component. Used in IntegratedCircuit UI
	var/datum/weakref/examined_component

	/// Set by the shell. Holds the reference to the owner who inserted the component into the shell.
	var/datum/weakref/inserter_mind

	/// Variables stored on this integrated circuit, with a `variable_name = value` structure
	var/list/datum/circuit_variable/circuit_variables = list()

	/// Variables stored on this integrated circuit that can be set by a setter, with a `variable_name = value` structure
	var/list/datum/circuit_variable/modifiable_circuit_variables = list()

	/// List variables stored on this integrated circuit, with a `variable_name = value` structure
	var/list/datum/circuit_variable/list_variables = list()

	/// The maximum amount of setters and getters a circuit can have
	var/max_setters_and_getters = 30

	/// The current setter and getter count the circuit has.
	var/setter_and_getter_count = 0

	/// X position of the examined_component
	var/examined_rel_x = 0

	/// Y position of the examined component
	var/examined_rel_y = 0

	/// The X position of the screen. Used for adding components
	var/screen_x = 0

	/// The Y position of the screen. Used for adding components.
	var/screen_y = 0

	/// The current size of the circuit.
	var/current_size = 0

	/// The current linked component printer. Lets you remotely print off circuit components and places them in the integrated circuit.
	var/datum/weakref/linked_component_printer

/obj/item/integrated_circuit/Initialize(mapload)
	. = ..()

	GLOB.integrated_circuits += src

	RegisterSignal(src, COMSIG_ATOM_USB_CABLE_TRY_ATTACH, PROC_REF(on_atom_usb_cable_try_attach))

/obj/item/integrated_circuit/loaded/Initialize(mapload)
	. = ..()
	set_cell(new /obj/item/stock_parts/cell/high(src))

/obj/item/integrated_circuit/Destroy()
	for(var/obj/item/circuit_component/to_delete in attached_components)
		remove_component(to_delete)
		qdel(to_delete)
	QDEL_LIST_ASSOC_VAL(circuit_variables)
	QDEL_LIST_ASSOC_VAL(list_variables)
	attached_components.Cut()
	shell = null
	examined_component = null
	owner_id = null
	QDEL_NULL(cell)
	GLOB.integrated_circuits -= src
	return ..()

/obj/item/integrated_circuit/examine(mob/user)
	. = ..()
	if(cell)
		. += span_notice("The charge meter reads [cell ? round(cell.percent(), 1) : 0]%.")
	else
		. += span_notice("There is no power cell installed.")

/obj/item/integrated_circuit/drop_location()
	if(shell)
		return shell.drop_location()
	return ..()

/**
 * Sets the cell of the integrated circuit.
 *
 * Arguments:
 * * cell_to_set - The new cell of the circuit. Can be null.
 **/
/obj/item/integrated_circuit/proc/set_cell(obj/item/stock_parts/cell_to_set)
	SEND_SIGNAL(src, COMSIG_CIRCUIT_SET_CELL, cell_to_set)
	cell = cell_to_set

/**
 * Sets the locked status of the integrated circuit.
 *
 * Arguments:
 * * new_value - A boolean that determines if the circuit is locked or not.
 **/
/obj/item/integrated_circuit/proc/set_locked(new_value)
	SEND_SIGNAL(src, COMSIG_CIRCUIT_SET_LOCKED, new_value)
	locked = new_value

/obj/item/integrated_circuit/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/circuit_component))
		add_component_manually(I, user)
		return

	if(istype(I, /obj/item/stock_parts/cell))
		if(cell)
			balloon_alert(user, "there already is a cell inside!")
			return
		if(!user.transferItemToLoc(I, src))
			return
		set_cell(I)
		I.add_fingerprint(user)
		user.visible_message(span_notice("[user] inserts a power cell into [src]."), span_notice("You insert the power cell into [src]."))
		return

	if(isidcard(I))
		balloon_alert(user, "owner id set for [I]")
		owner_id = WEAKREF(I)
		return

	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(!cell)
			return
		I.play_tool_sound(src)
		user.visible_message(span_notice("[user] unscrews the power cell from [src]."), span_notice("You unscrew the power cell from [src]."))
		cell.forceMove(drop_location())
		set_cell(null)
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
	set_on(TRUE)
	SEND_SIGNAL(src, COMSIG_CIRCUIT_SET_SHELL, new_shell)
	shell = new_shell
	RegisterSignal(shell, COMSIG_PARENT_QDELETING, PROC_REF(remove_current_shell))
	for(var/obj/item/circuit_component/attached_component as anything in attached_components)
		attached_component.register_shell(shell)
		// Their input ports may be updated with user values, but the outputs haven't updated
		// because on is FALSE
		attached_component.trigger_component()

/**
 * Unregisters the current shell attached to this circuit.
 */
/obj/item/integrated_circuit/proc/remove_current_shell()
	SIGNAL_HANDLER
	if(!shell)
		return
	shell.name = initial(shell.name)
	for(var/obj/item/circuit_component/attached_component as anything in attached_components)
		attached_component.unregister_shell(shell)
	UnregisterSignal(shell, COMSIG_PARENT_QDELETING)
	shell = null
	set_on(FALSE)
	SEND_SIGNAL(src, COMSIG_CIRCUIT_SHELL_REMOVED)

/**
 * Sets the on status of the integrated circuit.
 *
 * Arguments:
 * * new_value - A boolean that determines if the circuit is on or not.
 **/
/obj/item/integrated_circuit/proc/set_on(new_value)
	SEND_SIGNAL(src, COMSIG_CIRCUIT_SET_ON, new_value)
	on = new_value

/**
 * Used for checking if another component of to_check's type exists in the circuit.
 * Introspects through modules.
 *
 * Arguments:
 * * to_check - The component to check.
 **/
/obj/item/integrated_circuit/proc/is_duplicate(obj/item/circuit_component/to_check)
	for(var/component as anything in attached_components)
		if(component == to_check)
			continue
		if(istype(component, to_check.type))
			return TRUE
		if(istype(component, /obj/item/circuit_component/module))
			var/obj/item/circuit_component/module/module = component
			for(var/module_component as anything in module.internal_circuit.attached_components)
				if(module_component == to_check)
					continue
				if(istype(module_component, to_check.type))
					return TRUE
	return FALSE

/**
 * Adds a component to the circuitboard
 *
 * Once the component is added, the ports can be attached to other components
 */
/obj/item/integrated_circuit/proc/add_component(obj/item/circuit_component/to_add, mob/living/user)
	if(to_add.parent)
		return FALSE

	if(SEND_SIGNAL(src, COMSIG_CIRCUIT_ADD_COMPONENT, to_add, user) & COMPONENT_CANCEL_ADD_COMPONENT)
		return FALSE

	if(!to_add.add_to(src))
		return FALSE

	if(to_add.circuit_flags & CIRCUIT_NO_DUPLICATES)
		if(is_duplicate(to_add))
			to_chat(user, span_danger("You can't insert multiple instances of this component into the same circuit!"))
			return FALSE

	var/success = FALSE
	if(user)
		success = user.transferItemToLoc(to_add, src)
	else
		success = to_add.forceMove(src)

	if(!success)
		return FALSE

	to_add.rel_x = rand(COMPONENT_MIN_RANDOM_POS, COMPONENT_MAX_RANDOM_POS) - screen_x
	to_add.rel_y = rand(COMPONENT_MIN_RANDOM_POS, COMPONENT_MAX_RANDOM_POS) - screen_y
	to_add.parent = src
	attached_components += to_add
	current_size += to_add.circuit_size
	RegisterSignal(to_add, COMSIG_MOVABLE_MOVED, PROC_REF(component_move_handler))
	SStgui.update_uis(src)

	if(shell)
		to_add.register_shell(shell)
	return TRUE

/**
 * Adds a component to the circuitboard through a manual action.
 */
/obj/item/integrated_circuit/proc/add_component_manually(obj/item/circuit_component/to_add, mob/living/user)
	if (SEND_SIGNAL(src, COMSIG_CIRCUIT_ADD_COMPONENT_MANUALLY, to_add, user) & COMPONENT_CANCEL_ADD_COMPONENT)
		return

	return add_component(to_add, user)

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
	current_size -= to_remove.circuit_size
	attached_components -= to_remove
	to_remove.disconnect()
	to_remove.parent = null
	SEND_SIGNAL(to_remove, COMSIG_CIRCUIT_COMPONENT_REMOVED, src)
	SStgui.update_uis(src)
	to_remove.removed_from(src)

/obj/item/integrated_circuit/get_cell()
	return cell

/obj/item/integrated_circuit/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/circuit_assets),
		get_asset_datum(/datum/asset/json/circuit_components)
	)

/obj/item/integrated_circuit/ui_static_data(mob/user)
	. = list()
	.["global_basic_types"] = GLOB.wiremod_basic_types
	.["screen_x"] = screen_x
	.["screen_y"] = screen_y

	var/obj/machinery/component_printer/printer = linked_component_printer?.resolve()
	if(!printer)
		return
	.["stored_designs"] = printer.current_unlocked_designs

/obj/item/integrated_circuit/ui_data(mob/user)
	. = list()
	.["components"] = list()
	for(var/obj/item/circuit_component/component as anything in attached_components)
		if (component.circuit_flags & CIRCUIT_FLAG_HIDDEN)
			.["components"] += null
			continue

		var/list/component_data = list()
		component_data["input_ports"] = list()
		for(var/datum/port/input/port as anything in component.input_ports)
			var/current_data = port.value
			if(isatom(current_data)) // Prevent passing the name of the atom.
				current_data = null
			var/list/connected_to = list()
			for(var/datum/port/output/output as anything in port.connected_ports)
				connected_to += REF(output)
			component_data["input_ports"] += list(list(
				"name" = port.name,
				"type" = port.datatype,
				"ref" = REF(port), // The ref is the identifier to work out what it is connected to
				"connected_to" = connected_to,
				"color" = port.color,
				"current_data" = current_data,
				"datatype_data" = port.datatype_ui_data(user)
			))
		component_data["output_ports"] = list()
		for(var/datum/port/output/port as anything in component.output_ports)
			component_data["output_ports"] += list(list(
				"name" = port.name,
				"type" = port.datatype,
				"ref" = REF(port),
				"color" = port.color,
				"datatype_data" = port.datatype_ui_data(user)
			))

		component_data["name"] = component.display_name
		component_data["x"] = component.rel_x
		component_data["y"] = component.rel_y
		component_data["removable"] = component.removable
		component_data["color"] = component.ui_color
		component_data["ui_buttons"] = component.ui_buttons
		.["components"] += list(component_data)

	.["variables"] = list()
	for(var/variable_name in circuit_variables)
		var/datum/circuit_variable/variable = circuit_variables[variable_name]
		var/list/variable_data = list()
		variable_data["name"] = variable.name
		variable_data["datatype"] = variable.datatype
		variable_data["color"] = variable.color
		if(islist(variable.value))
			variable_data["is_list"] = TRUE
		.["variables"] += list(variable_data)

	.["display_name"] = display_name

	var/obj/item/circuit_component/examined
	if(examined_component)
		examined = examined_component.resolve()

	.["examined_name"] = examined?.display_name
	.["examined_desc"] = examined?.desc
	.["examined_notices"] = examined?.get_ui_notices()
	.["examined_rel_x"] = examined_rel_x
	.["examined_rel_y"] = examined_rel_y

	.["is_admin"] = check_rights_for(user.client, R_VAREDIT)

/obj/item/integrated_circuit/ui_host(mob/user)
	if(shell)
		return shell
	return ..()

/obj/item/integrated_circuit/can_interact(mob/user)
	if(locked)
		return FALSE
	return ..()

/obj/item/integrated_circuit/ui_status(mob/user)
	. = ..()

	if (isobserver(user))
		. = max(., UI_UPDATE)

	// Extra protection because ui_state will not close the UI if they already have the ui open,
	// as ui_state is only set during
	if(admin_only)
		if(!check_rights_for(user.client, R_VAREDIT))
			return UI_CLOSE
		else
			return UI_INTERACTIVE

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

/obj/item/integrated_circuit/ui_act(action, list/params, datum/tgui/ui)
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

			if(!input_port.can_receive_from_datatype(output_port.datatype))
				return
			input_port.connect(output_port)
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
			port.disconnect_all()
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
			if(component.loc == src)
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
		if("set_component_input")
			var/component_id = text2num(params["component_id"])
			var/port_id = text2num(params["port_id"])
			if(!WITHIN_RANGE(component_id, attached_components))
				return
			var/obj/item/circuit_component/component = attached_components[component_id]
			if(!WITHIN_RANGE(port_id, component.input_ports))
				return
			var/datum/port/input/port = component.input_ports[port_id]

			if(params["set_null"])
				port.set_input(null)
				return TRUE

			if(params["marked_atom"])
				if(!(port.datatype_handler.datatype_flags & DATATYPE_FLAG_ALLOW_ATOM_INPUT))
					return
				var/obj/item/multitool/circuit/marker = usr.get_active_held_item()
				// Let's admins upload marked datums to an entity port.
				if(!istype(marker))
					var/client/user = usr.client
					if(!check_rights_for(user, R_VAREDIT))
						return TRUE
					var/atom/marked_atom = user.holder.marked_datum
					if(!marked_atom)
						return TRUE
					port.set_input(marked_atom)
					balloon_alert(usr, "updated [port.name]'s value to marked object.")
					return TRUE
				if(!marker.marked_atom)
					port.set_input(null)
					marker.say("Cleared port ('[port.name]')'s value.")
					return TRUE
				marker.say("Updated port ('[port.name]')'s value to the marked entity.")
				port.set_input(marker.marked_atom)
				return TRUE

			var/user_input = port.handle_manual_input(usr, params["input"])
			if(isnull(user_input))
				return TRUE
			port.set_input(user_input)
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
			var/value = port.value
			if(isatom(value))
				value = PORT_TYPE_ATOM
			else if(isnull(value))
				value = "null"
			var/string_form = copytext("[value]", 1, PORT_MAX_STRING_DISPLAY)
			if(length(string_form) >= PORT_MAX_STRING_DISPLAY-1)
				string_form += "..."
			balloon_alert(usr, "[port.name] value: [string_form]")
			. = TRUE
		if("set_display_name")
			var/new_name = params["display_name"]

			if(new_name)
				set_display_name(params["display_name"])
			else
				set_display_name("")
			. = TRUE
		if("set_examined_component")
			var/component_id = text2num(params["component_id"])
			if(!WITHIN_RANGE(component_id, attached_components))
				return
			examined_component = WEAKREF(attached_components[component_id])
			examined_rel_x = text2num(params["x"])
			examined_rel_y = text2num(params["y"])
			. = TRUE
		if("remove_examined_component")
			examined_component = null
			. = TRUE
		if("save_circuit")
			return attempt_save_to(usr.client)
		if("add_variable")
			var/variable_identifier = trim(copytext(params["variable_name"], 1, PORT_MAX_NAME_LENGTH))
			if(variable_identifier in circuit_variables)
				return TRUE
			if(variable_identifier == "")
				return TRUE
			var/variable_datatype = params["variable_datatype"]
			if(!(variable_datatype in GLOB.wiremod_basic_types))
				return
			if(params["is_list"])
				variable_datatype = PORT_TYPE_LIST(variable_datatype)
			var/datum/circuit_variable/variable = new /datum/circuit_variable(variable_identifier, variable_datatype)
			if(params["is_list"])
				variable.set_value(list())
				list_variables[variable_identifier] = variable
			else
				modifiable_circuit_variables[variable_identifier] = variable
			circuit_variables[variable_identifier] = variable
			. = TRUE
		if("remove_variable")
			var/variable_identifier = params["variable_name"]
			if(!(variable_identifier in circuit_variables))
				return
			var/datum/circuit_variable/variable = circuit_variables[variable_identifier]
			if(!variable)
				return
			circuit_variables -= variable_identifier
			list_variables -= variable_identifier
			modifiable_circuit_variables -= variable_identifier
			qdel(variable)
			. = TRUE
		if("add_setter_or_getter")
			if(setter_and_getter_count >= max_setters_and_getters)
				balloon_alert(usr, "setter and getter count at maximum capacity")
				return
			var/designated_type = /obj/item/circuit_component/variable/getter
			if(params["is_setter"])
				designated_type = /obj/item/circuit_component/variable/setter
			var/obj/item/circuit_component/variable/component = new designated_type(src)
			if(!add_component(component, usr))
				qdel(component)
				return
			component.variable_name.set_input(params["variable"])
			component.rel_x = text2num(params["rel_x"])
			component.rel_y = text2num(params["rel_y"])
			RegisterSignal(component, COMSIG_CIRCUIT_COMPONENT_REMOVED, PROC_REF(clear_setter_or_getter))
			setter_and_getter_count++
			return TRUE
		if("move_screen")
			screen_x = text2num(params["screen_x"])
			screen_y = text2num(params["screen_y"])
		if("perform_action")
			var/component_id = text2num(params["component_id"])
			if(!WITHIN_RANGE(component_id, attached_components))
				return
			var/obj/item/circuit_component/component = attached_components[component_id]
			SEND_SIGNAL(component, COMSIG_CIRCUIT_COMPONENT_PERFORM_ACTION, ui.user, params["action_name"])
			component.ui_perform_action(ui.user, params["action_name"])
		if("print_component")
			var/component_path = text2path(params["component_to_print"])
			var/obj/item/circuit_component/component
			if(!check_rights_for(ui.user.client, R_SPAWN))
				var/obj/machinery/component_printer/printer = linked_component_printer?.resolve()
				if(!printer)
					balloon_alert(ui.user, "linked printer not found!")
					return
				component = printer.print_component(component_path)
				if(!component)
					balloon_alert(ui.user, "failed to make the component!")
					return
			else
				if(!ispath(component_path, /obj/item/circuit_component))
					return
				component = new component_path(drop_location())
				component.datum_flags |= DF_VAR_EDITED
			if(!add_component(component))
				return
			component.rel_x = text2num(params["rel_x"])
			component.rel_y = text2num(params["rel_y"])
			return TRUE

#undef WITHIN_RANGE

/obj/item/integrated_circuit/balloon_alert(mob/viewer, text)
	if(shell)
		return shell.balloon_alert(viewer, text)
	return ..()

/obj/item/integrated_circuit/proc/clear_setter_or_getter(datum/source)
	SIGNAL_HANDLER
	// This'll also be called in the Destroy() override of /obj/item/circuit_component
	if(!QDELING(source))
		qdel(source)
	setter_and_getter_count--

/obj/item/integrated_circuit/proc/on_atom_usb_cable_try_attach(datum/source, obj/item/usb_cable/usb_cable, mob/user)
	SIGNAL_HANDLER
	usb_cable.balloon_alert(user, "circuit needs to be in a compatible shell")
	return COMSIG_CANCEL_USB_CABLE_ATTACK

/// Sets the display name that appears on the shell.
/obj/item/integrated_circuit/proc/set_display_name(new_name)
	display_name = copytext(new_name, 1, label_max_length)
	if(!shell)
		return

	if(display_name != "")
		if(!admin_only)
			shell.name = "[initial(shell.name)] ([strip_html(display_name)])"
		else
			shell.name = display_name
	else
		shell.name = initial(shell.name)

/**
 * Returns the creator of the integrated circuit. Used in admin messages and other related things.
 */
/obj/item/integrated_circuit/proc/get_creator_admin()
	return get_creator(include_link = TRUE)

/**
 * Returns the creator of the integrated circuit. Used in admin logs and other related things.
 */
/obj/item/integrated_circuit/proc/get_creator(include_link = FALSE)
	var/datum/mind/inserter
	if(inserter_mind)
		inserter = inserter_mind.resolve()

	var/obj/item/card/id/id_card
	if(owner_id)
		id_card = owner_id.resolve()

	return "[src] (Shell: [shell || "*null*"], Inserter: [key_name(inserter, include_link)], Owner ID: [id_card?.name || "*null*"])"

/// Attempts to save a circuit to a given client
/obj/item/integrated_circuit/proc/attempt_save_to(client/saver)
	if(!check_rights_for(saver, R_VAREDIT))
		return FALSE
	var/temp_file = file("data/CircuitDownloadTempFile")
	fdel(temp_file)
	WRITE_FILE(temp_file, convert_to_json())
	DIRECT_OUTPUT(saver, ftp(temp_file, "[display_name || "circuit"].json"))
	return TRUE

/obj/item/integrated_circuit/admin
	name = "administrative circuit"
	desc = "The components installed in here are far beyond your comprehension."

	admin_only = TRUE
