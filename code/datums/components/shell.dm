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

	/// Whether the shell is locked or not
	var/locked = FALSE

	// The variables below are used only for anchored shells
	/// The amount of power used in the last minute
	var/power_used_in_minute = 0

	/// The cooldown time to reset the power_used_in_minute to 0
	COOLDOWN_DECLARE(power_used_cooldown)

	/// The maximum power that the shell can use in a minute before entering overheating and destroying itself.
	var/max_power_use_in_minute = 20000

/datum/component/shell/Initialize(unremovable_circuit_components, capacity, shell_flags, starting_circuit)
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.shell_flags = shell_flags || src.shell_flags
	src.capacity = capacity || src.capacity
	set_unremovable_circuit_components(unremovable_circuit_components)

	if(starting_circuit)
		attach_circuit(starting_circuit)

/datum/component/shell/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, PROC_REF(on_attack_ghost))
	if(!(shell_flags & SHELL_FLAG_CIRCUIT_UNMODIFIABLE))
		RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), PROC_REF(on_multitool_act))
		RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attack_by))
	if(!(shell_flags & SHELL_FLAG_CIRCUIT_UNREMOVABLE))
		RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), PROC_REF(on_screwdriver_act))
		RegisterSignal(parent, COMSIG_OBJ_DECONSTRUCT, PROC_REF(on_object_deconstruct))
	if(shell_flags & SHELL_FLAG_REQUIRE_ANCHOR)
		RegisterSignal(parent, COMSIG_MOVABLE_SET_ANCHORED, PROC_REF(on_set_anchored))
	RegisterSignal(parent, COMSIG_ATOM_USB_CABLE_TRY_ATTACH, PROC_REF(on_atom_usb_cable_try_attach))
	RegisterSignal(parent, COMSIG_MOVABLE_CIRCUIT_LOADED, PROC_REF(on_load))

/datum/component/shell/proc/set_unremovable_circuit_components(list/components)
	if(unremovable_circuit_components)
		QDEL_LIST(unremovable_circuit_components)

	unremovable_circuit_components = list()

	for(var/obj/item/circuit_component/circuit_component as anything in components)
		if(ispath(circuit_component))
			circuit_component = new circuit_component()
		circuit_component.removable = FALSE
		circuit_component.set_circuit_size(0)
		RegisterSignal(circuit_component, COMSIG_CIRCUIT_COMPONENT_SAVE, PROC_REF(save_component))
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
		COMSIG_MOVABLE_SET_ANCHORED,
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
	if(!attached_circuit)
		return
	if(attached_circuit.admin_only)
		return
	if(shell_flags & SHELL_FLAG_CIRCUIT_UNREMOVABLE)
		return
	remove_circuit()

/datum/component/shell/proc/on_attack_ghost(datum/source, mob/dead/observer/ghost)
	SIGNAL_HANDLER
	if(!is_authorized(ghost))
		return

	if(attached_circuit)
		INVOKE_ASYNC(attached_circuit, TYPE_PROC_REF(/datum, ui_interact), ghost)

/datum/component/shell/proc/on_examine(atom/movable/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!is_authorized(user))
		return

	if(!attached_circuit)
		examine_text += span_notice("There is no integrated circuit attached.")
		return

	examine_text += span_notice("There is an integrated circuit attached. Use a multitool to access the wiring. Use a screwdriver to remove it from [source].")
	examine_text += span_notice("The cover panel to the integrated circuit is [locked? "locked" : "unlocked"].")
	var/obj/item/stock_parts/cell/cell = attached_circuit.cell
	examine_text += span_notice("The charge meter reads [cell ? round(cell.percent(), 1) : 0]%.")

	if (shell_flags & SHELL_FLAG_USB_PORT)
		examine_text += span_notice("There is a <b>USB port</b> on the front.")

	if(shell_flags & SHELL_FLAG_REQUIRE_ANCHOR)
		examine_text += span_notice("The shell does not require a battery to function and will draw from the area's APC whenever possible.")
		if(!source.anchored)
			examine_text += span_danger("<b>The integrated circuit is non-functional whilst the shell is unanchored.</b>")


/**
 * Called when the shell is anchored.
 *
 * Only applies if the shell has SHELL_FLAG_REQUIRE_ANCHOR.
 * Disables the integrated circuit if unanchored, otherwise enable the circuit.
 */
/datum/component/shell/proc/on_set_anchored(atom/movable/source, previous_value)
	SIGNAL_HANDLER
	attached_circuit?.on = source.anchored

/**
 * Called when an item hits the parent. This is the method to add the circuitboard to the component.
 */
/datum/component/shell/proc/on_attack_by(atom/source, obj/item/item, mob/living/attacker)
	SIGNAL_HANDLER
	if(!is_authorized(attacker))
		return

	if(istype(item, /obj/item/stock_parts/cell))
		source.balloon_alert(attacker, "can't put cell in directly!")
		return

	if(istype(item, /obj/item/inducer))
		var/obj/item/inducer/inducer = item
		INVOKE_ASYNC(inducer, TYPE_PROC_REF(/obj/item, attack_atom), attached_circuit, attacker, list())
		return COMPONENT_NO_AFTERATTACK

	if(attached_circuit)
		if(attached_circuit.owner_id && item == attached_circuit.owner_id.resolve())
			set_locked(!locked)
			source.balloon_alert(attacker, "[locked ? "locked" : "unlocked"] [source]")
			return COMPONENT_NO_AFTERATTACK

		if(!attached_circuit.owner_id && isidcard(item))
			source.balloon_alert(attacker, "owner id set for [item]")
			attached_circuit.owner_id = WEAKREF(item)
			return COMPONENT_NO_AFTERATTACK

		if(istype(item, /obj/item/circuit_component))
			attached_circuit.add_component_manually(item, attacker)
			return COMPONENT_NO_AFTERATTACK

	if(!istype(item, /obj/item/integrated_circuit))
		return
	var/obj/item/integrated_circuit/logic_board = item
	. = COMPONENT_NO_AFTERATTACK

	if(logic_board.shell) // I'll be surprised if this ever happens
		return

	if(attached_circuit)
		source.balloon_alert(attacker, "there is already a circuitboard inside!")
		return

	if(logic_board.current_size > capacity)
		source.balloon_alert(attacker, "this is too large to fit into [parent]!")
		return

	logic_board.inserter_mind = WEAKREF(attacker.mind)
	attach_circuit(logic_board, attacker)

/// Sets whether the shell is locked or not
/datum/component/shell/proc/set_locked(new_value)
	locked = new_value
	attached_circuit?.set_locked(new_value)


/datum/component/shell/proc/on_multitool_act(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(!is_authorized(user))
		return

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
	if(!is_authorized(user))
		return

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

	if(attached_circuit.current_size + added_comp.circuit_size > capacity)
		source.balloon_alert(user, "it won't fit!")
		return COMPONENT_CANCEL_ADD_COMPONENT

/datum/component/shell/proc/override_power_usage(datum/source, power_to_use)
	SIGNAL_HANDLER
	if(COOLDOWN_FINISHED(src, power_used_cooldown))
		power_used_in_minute = 0

	var/area/location = get_area(parent)
	if(!location.powered(AREA_USAGE_EQUIP))
		return

	if(power_used_in_minute > max_power_use_in_minute)
		explosion(parent, light_impact_range = 1, explosion_cause = attached_circuit)
		if(attached_circuit)
			remove_circuit()
		return
	location.use_power(power_to_use, AREA_USAGE_EQUIP)
	power_used_in_minute += power_to_use
	COOLDOWN_START(src, power_used_cooldown, 1 MINUTES)
	return COMPONENT_OVERRIDE_POWER_USAGE

/**
 * Attaches a circuit to the parent. Doesn't do any checks to see for any existing circuits so that should be done beforehand.
 */
/datum/component/shell/proc/attach_circuit(obj/item/integrated_circuit/circuitboard, mob/living/user)
	var/atom/movable/parent_atom = parent
	if(user && !user.transferItemToLoc(circuitboard, parent_atom))
		return
	locked = FALSE
	attached_circuit = circuitboard
	if(!(shell_flags & SHELL_FLAG_CIRCUIT_UNREMOVABLE) && !circuitboard.admin_only)
		RegisterSignal(circuitboard, COMSIG_MOVABLE_MOVED, PROC_REF(on_circuit_moved))
	if(shell_flags & SHELL_FLAG_REQUIRE_ANCHOR)
		RegisterSignal(circuitboard, COMSIG_CIRCUIT_PRE_POWER_USAGE, PROC_REF(override_power_usage))
	RegisterSignal(circuitboard, COMSIG_PARENT_QDELETING, PROC_REF(on_circuit_delete))
	for(var/obj/item/circuit_component/to_add as anything in unremovable_circuit_components)
		to_add.forceMove(attached_circuit)
		attached_circuit.add_component(to_add)
	RegisterSignal(circuitboard, COMSIG_CIRCUIT_ADD_COMPONENT_MANUALLY, PROC_REF(on_circuit_add_component_manually))
	if(attached_circuit.display_name != "")
		parent_atom.name = "[initial(parent_atom.name)] ([attached_circuit.display_name])"
	attached_circuit.set_locked(FALSE)

	if(shell_flags & SHELL_FLAG_REQUIRE_ANCHOR)
		attached_circuit.on = parent_atom.anchored

	if((shell_flags & SHELL_FLAG_CIRCUIT_UNREMOVABLE) || circuitboard.admin_only)
		circuitboard.moveToNullspace()
	else if(circuitboard.loc != parent_atom)
		circuitboard.forceMove(parent_atom)
	attached_circuit.set_shell(parent_atom)

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
		COMSIG_CIRCUIT_PRE_POWER_USAGE,
	))
	if(attached_circuit.loc == parent || (!QDELETED(attached_circuit) && attached_circuit.loc == null))
		var/atom/parent_atom = parent
		attached_circuit.forceMove(parent_atom.drop_location())

	for(var/obj/item/circuit_component/to_remove as anything in unremovable_circuit_components)
		attached_circuit.remove_component(to_remove)
		to_remove.moveToNullspace()
	attached_circuit.set_locked(FALSE)
	attached_circuit = null

/datum/component/shell/proc/on_atom_usb_cable_try_attach(atom/source, obj/item/usb_cable/usb_cable, mob/user)
	SIGNAL_HANDLER
	if(!is_authorized(user))
		return

	if (!(shell_flags & SHELL_FLAG_USB_PORT))
		source.balloon_alert(user, "this shell has no usb ports")
		return COMSIG_CANCEL_USB_CABLE_ATTACK

	if (isnull(attached_circuit))
		source.balloon_alert(user, "no circuit inside")
		return COMSIG_CANCEL_USB_CABLE_ATTACK

	if(attached_circuit.locked)
		source.balloon_alert(user, "circuit is locked!")
		return COMSIG_CANCEL_USB_CABLE_ATTACK

	usb_cable.attached_circuit = attached_circuit
	return COMSIG_USB_CABLE_CONNECTED_TO_CIRCUIT

/**
 * Determines if a user is authorized to see the existance of this shell. Returns false if they are not
 *
 * Arguments:
 * * user - The user to check if they are authorized
 */
/datum/component/shell/proc/is_authorized(mob/user)
	if((shell_flags & SHELL_FLAG_CIRCUIT_UNREMOVABLE) && (shell_flags & SHELL_FLAG_CIRCUIT_UNMODIFIABLE))
		return FALSE

	if(attached_circuit?.admin_only)
		if(check_rights_for(user.client, R_VAREDIT))
			return TRUE
		return FALSE

	return TRUE
