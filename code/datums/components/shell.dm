/// Makes an atom a shell that is able to take in an attached circuit.
/datum/component/shell
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// The circuitboard attached to this shell
	var/obj/item/integrated_circuit/attached_circuit

	/// Flags containing what this shell can do
	var/shell_flags = 0

	/// The capacity of the shell.
	var/capacity = INFINITY

	/// A list of components that cannot be removed
	var/list/obj/item/component/unremovable_components

/datum/component/shell/Initialize(unremovable_components, capacity = src.capacity, shell_flags = src.shell_flags)
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.shell_flags = shell_flags
	src.capacity = capacity
	src.unremovable_components = unremovable_components

	for(var/obj/item/component/comp as anything in unremovable_components)
		comp.removable = FALSE

/datum/component/shell/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/on_attack_by)
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), .proc/on_screwdriver_act)
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), .proc/on_multitool_act)

/datum/component/shell/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_ATTACKBY,
		COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER),
	))

	QDEL_NULL(attached_circuit)

/datum/component/shell/Destroy(force, silent)
	QDEL_LIST(unremovable_components)
	return ..()

/**
 * Called when an item hits the parent. This is the method to add the circuitboard to the component.
 */
/datum/component/shell/proc/on_attack_by(atom/source, obj/item/item, mob/living/attacker)
	SIGNAL_HANDLER
	if(!istype(item, /obj/item/integrated_circuit))
		return
	var/obj/item/integrated_circuit/logic_board = item
	. = COMPONENT_NO_AFTERATTACK

	if(logic_board.shell) // I'll be surprised if this ever happens
		return

	if(attached_circuit)
		to_chat(attacker, "<span class='warning'>There is already a circuitboard inside!</span>")
		return

	if(length(logic_board.attached_components) > capacity)
		to_chat(attacker, "<span class='warning'>This is too large to fit into [parent]!</span>")
		return

	attach_circuit(logic_board, attacker)

/datum/component/shell/proc/on_multitool_act(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(!attached_circuit)
		return

	attached_circuit.interact(user)

/**
 * Called when a screwdriver is used on the parent. Removes the circuitboard from the component.
 */
/datum/component/shell/proc/on_screwdriver_act(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(!attached_circuit)
		return

	if(shell_flags & SHELL_FLAG_CIRCUIT_FIXED)
		return

	tool.play_tool_sound(parent)
	to_chat(user, "<span class='notice'>You unscrew [attached_circuit] from [parent].</span>")
	remove_circuit()
	return COMPONENT_BLOCK_TOOL_ATTACK

/**
 * Checks for when the circuitboard moves. If it moves, removes it from the component.
 */
/datum/component/shell/proc/on_circuit_moved(obj/item/integrated_circuit/circuit, atom/new_loc)
	SIGNAL_HANDLER
	if(new_loc != parent)
		remove_circuit()

/**
 * Checks for when the circuitboard deletes so that it can be unassigned.
 */
/datum/component/shell/proc/on_circuit_delete(datum/source)
	SIGNAL_HANDLER
	remove_circuit()

/datum/component/shell/proc/on_circuit_add_component(datum/source, obj/item/component/added_comp)
	SIGNAL_HANDLER
	return COMPONENT_CANCEL_ADD_COMPONENT

/**
 * Attaches a circuit to the parent. Doesn't do any checks to see for any existing circuits so that should be done beforehand.
 */
/datum/component/shell/proc/attach_circuit(obj/item/integrated_circuit/circuitboard, mob/living/user)
	if(!user.transferItemToLoc(circuitboard, parent))
		return
	attached_circuit = circuitboard
	RegisterSignal(circuitboard, COMSIG_MOVABLE_MOVED, .proc/on_circuit_moved)
	RegisterSignal(circuitboard, COMSIG_PARENT_QDELETING, .proc/on_circuit_delete)
	for(var/obj/item/component/to_add as anything in unremovable_components)
		to_add.forceMove(attached_circuit)
		attached_circuit.add_component(to_add)
	RegisterSignal(circuitboard, COMSIG_CIRCUIT_ADD_COMPONENT, .proc/on_circuit_add_component)
	attached_circuit.set_shell(parent)

/**
 * Removes the circuit from the component. Doesn't do any checks to see for an existing circuit so that should be done beforehand.
 */
/datum/component/shell/proc/remove_circuit()
	attached_circuit.remove_current_shell()
	UnregisterSignal(attached_circuit, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_PARENT_QDELETING,
		COMSIG_CIRCUIT_ADD_COMPONENT,
	))
	if(attached_circuit.loc == parent)
		var/atom/parent_atom = parent
		attached_circuit.forceMove(parent_atom.drop_location())

	for(var/obj/item/component/to_remove as anything in unremovable_components)
		attached_circuit.remove_component(to_remove)
		to_remove.moveToNullspace()
	attached_circuit = null
