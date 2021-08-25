/// Makes an atom a shell that is able to take in an attached circuit.
/datum/component/shell
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// The circuitboard attached to this shell
	var/obj/item/integrated_circuit/attached_circuit

	/// Flags containing what this shell can do
	var/shell_flags = NONE

	/// The capacity of the shell.
	var/capacity = INFINITY

	/// A list of components that cannot be removed
	var/list/obj/item/circuit_component/unremovable_circuit_components

	var/locked = FALSE

/datum/component/shell/Initialize(unremovable_circuit_components, capacity, shell_flags)
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.shell_flags = shell_flags || src.shell_flags
	src.capacity = capacity || src.capacity
	set_unremovable_circuit_components(unremovable_circuit_components)

/datum/component/shell/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/on_attack_by)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, .proc/on_attack_ghost)
	if(!(shell_flags & SHELL_FLAG_CIRCUIT_FIXED))
		RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), .proc/on_screwdriver_act)
		RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), .proc/on_multitool_act)
		RegisterSignal(parent, COMSIG_OBJ_DECONSTRUCT, .proc/on_object_deconstruct)
	if(shell_flags & SHELL_FLAG_REQUIRE_ANCHOR)
		RegisterSignal(parent, COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH, .proc/on_unfasten)
	RegisterSignal(parent, COMSIG_ATOM_USB_CABLE_TRY_ATTACH, .proc/on_atom_usb_cable_try_attach)
	RegisterSignal(parent, COMSIG_MOVABLE_CIRCUIT_LOADED, .proc/on_load)

/datum/component/shell/proc/set_unremovable_circuit_components(list/components)
	if(unremovable_circuit_components)
		QDEL_LIST(unremovable_circuit_components)

	unremovable_circuit_components = list()

	for(var/obj/item/circuit_component/circuit_component as anything in components)
		if(ispath(circuit_component))
			circuit_component = new circuit_component()
		circuit_component.removable = FALSE
		RegisterSignal(circuit_component, COMSIG_CIRCUIT_COMPONENT_SAVE, .proc/save_component)
		unremovable_circuit_components += circuit_component

/datum/component/shell/proc/save_component(datum/source, list/objects)
	SIGNAL_HANDLER
	objects += parent

/datum/component/shell/proc/on_load(datum/source, obj/item/integrated_circuit/circuit, list/components)
	SIGNAL_HANDLER
	var/list/components_in_list = list()
	for(var/obj/item/circuit_component/component as anything in components)
		components_in_list += component.type

	for(var/obj/item/circuit_component/component as anything in unremovable_circuit_components)
		if(component.type in components_in_list)
			continue
		var/new_type = component.type
		components += new new_type()
	set_unremovable_circuit_components(components)
	attach_circuit(circuit)


/datum/component/shell/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_ATTACKBY,
		COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER),
		COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL),
		COMSIG_OBJ_DECONSTRUCT,
		COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH,
		COMSIG_PARENT_EXAMINE,
		COMSIG_ATOM_ATTACK_GHOST,
		COMSIG_ATOM_USB_CABLE_TRY_ATTACH,
		COMSIG_MOVABLE_CIRCUIT_LOADED,
	))

	QDEL_NULL(attached_circuit)

/datum/component/shell/Destroy(force, silent)
	QDEL_LIST(unremovable_circuit_components)
	return ..()

/datum/component/shell/proc/on_object_deconstruct()
	SIGNAL_HANDLER
	if(!attached_circuit.admin_only)
		remove_circuit()

/datum/component/shell/proc/on_attack_ghost(datum/source, mob/dead/observer/ghost)
	SIGNAL_HANDLER
	if(attached_circuit)
		INVOKE_ASYNC(attached_circuit, /datum.proc/ui_interact, ghost)

/datum/component/shell/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!attached_circuit)
		examine_text += span_notice("There is no integrated circuit attached.")
		return

	examine_text += span_notice("There is an integrated circuit attached. Use a multitool to access the wiring. Use a screwdriver to remove it from [source].")
	examine_text += span_notice("The cover panel to the integrated circuit is [locked? "locked" : "unlocked"].")
	var/obj/item/stock_parts/cell/cell = attached_circuit.cell
	examine_text += span_notice("The charge meter reads [cell ? round(cell.percent(), 1) : 0]%.")

	if (shell_flags & SHELL_FLAG_USB_PORT)
		examine_text += span_notice("There is a <b>USB port</b> on the front.")

/**
 * Called when the shell is wrenched.
 *
 * Only applies if the shell has SHELL_FLAG_REQUIRE_ANCHOR.
 * Disables the integrated circuit if unanchored, otherwise enable the circuit.
 */
/datum/component/shell/proc/on_unfasten(atom/source, anchored)
	SIGNAL_HANDLER
	attached_circuit?.on = anchored
/**
 * Called when an item hits the parent. This is the method to add the circuitboard to the component.
 */
/datum/component/shell/proc/on_attack_by(atom/source, obj/item/item, mob/living/attacker)
	SIGNAL_HANDLER
	if(istype(item, /obj/item/stock_parts/cell))
		source.balloon_alert(attacker, "can't put cell in directly!")
		return

	if(istype(item, /obj/item/inducer))
		var/obj/item/inducer/inducer = item
		INVOKE_ASYNC(inducer, /obj/item.proc/attack_obj, attached_circuit, attacker, list())
		return COMPONENT_NO_AFTERATTACK

	if(attached_circuit)
		if(attached_circuit.owner_id && item == attached_circuit.owner_id.resolve())
			set_locked(!locked)
			source.balloon_alert(attacker, "[locked? "locked" : "unlocked"] [source]")
			return COMPONENT_NO_AFTERATTACK

		if(!attached_circuit.owner_id && istype(item, /obj/item/card/id))
			source.balloon_alert(attacker, "owner id set for [item]")
			attached_circuit.owner_id = WEAKREF(item)
			return COMPONENT_NO_AFTERATTACK

		if(istype(item, /obj/item/circuit_component))
			attached_circuit.add_component_manually(item, attacker)
			return

	if(!istype(item, /obj/item/integrated_circuit))
		return
	var/obj/item/integrated_circuit/logic_board = item
	. = COMPONENT_NO_AFTERATTACK

	if(logic_board.shell) // I'll be surprised if this ever happens
		return

	if(attached_circuit)
		source.balloon_alert(attacker, "there is already a circuitboard inside!")
		return

	if(length(logic_board.attached_components) - length(unremovable_circuit_components) > capacity)
		source.balloon_alert(attacker, "this is too large to fit into [parent]!")
		return

	logic_board.inserter_mind = WEAKREF(attacker.mind)
	attach_circuit(logic_board, attacker)

/// Sets whether the shell is locked or not
/datum/component/shell/proc/set_locked(new_value)
	locked = new_value
	attached_circuit?.locked = locked


/datum/component/shell/proc/on_multitool_act(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(!attached_circuit)
		return

	if(locked)
		if(shell_flags & SHELL_FLAG_ALLOW_FAILURE_ACTION)
			return
		source.balloon_alert(user, "it's locked!")
		return COMPONENT_BLOCK_TOOL_ATTACK

	attached_circuit.interact(user)
	return COMPONENT_BLOCK_TOOL_ATTACK

/**
 * Called when a screwdriver is used on the parent. Removes the circuitboard from the component.
 */
/datum/component/shell/proc/on_screwdriver_act(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(!attached_circuit)
		return

	if(locked)
		if(shell_flags & SHELL_FLAG_ALLOW_FAILURE_ACTION)
			return
		source.balloon_alert(user, "it's locked!")
		return COMPONENT_BLOCK_TOOL_ATTACK

	tool.play_tool_sound(parent)
	source.balloon_alert(user, "you unscrew [attached_circuit] from [parent].")
	remove_circuit()
	return COMPONENT_BLOCK_TOOL_ATTACK

/**
 * Checks for when the circuitboard moves. If it moves, removes it from the component.
 */
/datum/component/shell/proc/on_circuit_moved(obj/item/integrated_circuit/circuit, atom/old_loc)
	SIGNAL_HANDLER
	if(circuit.loc != parent)
		remove_circuit()

/**
 * Checks for when the circuitboard deletes so that it can be unassigned.
 */
/datum/component/shell/proc/on_circuit_delete(datum/source)
	SIGNAL_HANDLER
	remove_circuit()

/datum/component/shell/proc/on_circuit_add_component_manually(atom/source, obj/item/circuit_component/added_comp, mob/living/user)
	SIGNAL_HANDLER
	if(locked)
		source.balloon_alert(user, "it's locked!")
		return COMPONENT_CANCEL_ADD_COMPONENT

	if(length(attached_circuit.attached_components) - length(unremovable_circuit_components) >= capacity)
		source.balloon_alert(user, "it's at maximum capacity!")
		return COMPONENT_CANCEL_ADD_COMPONENT

/**
 * Attaches a circuit to the parent. Doesn't do any checks to see for any existing circuits so that should be done beforehand.
 */
/datum/component/shell/proc/attach_circuit(obj/item/integrated_circuit/circuitboard, mob/living/user)
	var/atom/movable/parent_atom = parent
	if(user && !user.transferItemToLoc(circuitboard, parent_atom))
		return
	locked = FALSE
	attached_circuit = circuitboard
	RegisterSignal(circuitboard, COMSIG_MOVABLE_MOVED, .proc/on_circuit_moved)
	RegisterSignal(circuitboard, COMSIG_PARENT_QDELETING, .proc/on_circuit_delete)
	for(var/obj/item/circuit_component/to_add as anything in unremovable_circuit_components)
		to_add.forceMove(attached_circuit)
		attached_circuit.add_component(to_add)
	RegisterSignal(circuitboard, COMSIG_CIRCUIT_ADD_COMPONENT_MANUALLY, .proc/on_circuit_add_component_manually)
	attached_circuit.set_shell(parent_atom)
	if(attached_circuit.display_name != "")
		parent_atom.name = "[initial(parent_atom.name)] ([attached_circuit.display_name])"
	attached_circuit.locked = FALSE

	if(shell_flags & SHELL_FLAG_REQUIRE_ANCHOR)
		on_unfasten(parent_atom, parent_atom.anchored)

	if(circuitboard.loc != parent_atom)
		circuitboard.forceMove(parent_atom)

/**
 * Removes the circuit from the component. Doesn't do any checks to see for an existing circuit so that should be done beforehand.
 */
/datum/component/shell/proc/remove_circuit()
	attached_circuit.on = TRUE
	attached_circuit.remove_current_shell()
	UnregisterSignal(attached_circuit, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_PARENT_QDELETING,
		COMSIG_CIRCUIT_ADD_COMPONENT_MANUALLY,
	))
	if(attached_circuit.loc == parent)
		var/atom/parent_atom = parent
		attached_circuit.forceMove(parent_atom.drop_location())

	for(var/obj/item/circuit_component/to_remove as anything in unremovable_circuit_components)
		attached_circuit.remove_component(to_remove)
		to_remove.moveToNullspace()
	attached_circuit.locked = FALSE
	attached_circuit = null

/datum/component/shell/proc/on_atom_usb_cable_try_attach(atom/source, obj/item/usb_cable/usb_cable, mob/user)
	SIGNAL_HANDLER

	if (!(shell_flags & SHELL_FLAG_USB_PORT))
		source.balloon_alert(user, "this shell has no usb ports")
		return COMSIG_CANCEL_USB_CABLE_ATTACK

	if (isnull(attached_circuit))
		source.balloon_alert(user, "no circuit inside")
		return COMSIG_CANCEL_USB_CABLE_ATTACK

	usb_cable.attached_circuit = attached_circuit
	return COMSIG_USB_CABLE_CONNECTED_TO_CIRCUIT
