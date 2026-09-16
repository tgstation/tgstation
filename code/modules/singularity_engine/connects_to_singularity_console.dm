// This doesn't connect to new computers.
// For the purposes of the prototype, I don't care.
// It also doesn't disconnect when the computer is destroyed. Easily fixable, but I'm busy.
/datum/component/connects_to_singularity_console
	VAR_PRIVATE
		datum/weakref/current_connected_computer_ref
		datum/weakref/last_cable_ref
		datum/weakref/last_powernet_ref
		connected = FALSE

/datum/component/connects_to_singularity_console/Initialize(...)
	. = ..()

	if (!isatom(parent))
		return ELEMENT_INCOMPATIBLE

/datum/component/connects_to_singularity_console/RegisterWithParent()
	var/atom/atom_parent = parent
	RegisterSignal(atom_parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(atom_parent, COMSIG_MACHINERY_POWERED, PROC_REF(on_powered_check))

	if (isturf(atom_parent.loc))
		RegisterSignals(atom_parent.loc, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED), PROC_REF(check_connection))

	check_connection()

	if (!connected)
		update_machine_power()

/datum/component/connects_to_singularity_console/UnregisterFromParent()
	disconnect_cable()
	disconnect_computer()

/datum/component/connects_to_singularity_console/proc/on_moved(atom/source, atom/old_loc)
	SIGNAL_HANDLER

	if (isturf(old_loc))
		UnregisterSignal(old_loc, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))

	if (isturf(source.loc))
		RegisterSignals(source.loc, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED), PROC_REF(check_connection))

/datum/component/connects_to_singularity_console/proc/on_powered_check()
	SIGNAL_HANDLER

	if (!connected)
		return FLAG_MACHINERY_POWERED_FORCE_OFF

/datum/component/connects_to_singularity_console/proc/check_connection()
	SIGNAL_HANDLER

	var/atom/atom_parent = parent

	var/turf/turf_loc = atom_parent.loc
	if (!isturf(turf_loc))
		return

	var/obj/structure/cable/our_cable = locate() in turf_loc
	if (isnull(our_cable))
		disconnect_cable()
		disconnect_computer()
		return

	connect_cable(our_cable)

	var/obj/machinery/computer/singularity/current_connected_computer = current_connected_computer_ref?.resolve()
	if (!isnull(current_connected_computer))
		var/obj/structure/cable/computer_cable = locate() in get_turf(current_connected_computer)
		if (isnull(computer_cable?.powernet) || computer_cable.powernet != our_cable.powernet)
			disconnect_computer()

	if (!isnull(current_connected_computer_ref))
		return

	for (var/obj/machinery/computer/singularity/singularity_computer as anything in GLOB.singularity_computers)
		var/obj/structure/cable/computer_cable = locate() in get_turf(singularity_computer)
		if (isnull(computer_cable?.powernet))
			continue

		if (computer_cable.powernet == our_cable.powernet)
			connect_computer(singularity_computer)
			return

/datum/component/connects_to_singularity_console/proc/connect_computer(obj/machinery/computer/singularity/singularity_computer)
	disconnect_computer()

	current_connected_computer_ref = WEAKREF(singularity_computer)

	singularity_computer.connect_machine(parent)

	var/atom/atom_parent = parent
	ADD_TRAIT(atom_parent, TRAIT_CONNECTED_TO_SINGULARITY_CONSOLE, "[type]")
	connected = TRUE
	update_machine_power()

/datum/component/connects_to_singularity_console/proc/connect_cable(obj/structure/cable/our_cable)
	var/cable_changed = !IS_WEAKREF_OF(our_cable, last_cable_ref)
	var/powernet_changed = !IS_WEAKREF_OF(our_cable.powernet, last_powernet_ref)

	if (cable_changed)
		var/last_cable = last_cable_ref?.resolve()
		if (!isnull(last_cable))
			UnregisterSignal(last_cable_ref.resolve(), list(COMSIG_CABLE_ADDED_TO_POWERNET, COMSIG_CABLE_REMOVED_FROM_POWERNET))

		last_cable_ref = WEAKREF(our_cable)
		RegisterSignals(our_cable, list(COMSIG_CABLE_ADDED_TO_POWERNET, COMSIG_CABLE_REMOVED_FROM_POWERNET), PROC_REF(check_connection))

	if (powernet_changed)
		var/last_powernet = last_powernet_ref?.resolve()
		if (!isnull(last_powernet))
			UnregisterSignal(last_powernet_ref.resolve(), list(COMSIG_POWERNET_ADDED_CABLE, COMSIG_POWERNET_REMOVED_CABLE))

		last_powernet_ref = WEAKREF(our_cable.powernet)
		RegisterSignals(our_cable.powernet, list(COMSIG_POWERNET_ADDED_CABLE, COMSIG_POWERNET_REMOVED_CABLE), PROC_REF(check_connection))

/datum/component/connects_to_singularity_console/proc/disconnect_computer()
	var/obj/machinery/computer/singularity/current_connected_computer = current_connected_computer_ref?.resolve()
	current_connected_computer?.disconnect_machine(parent)
	current_connected_computer_ref = null

	var/atom/atom_parent = parent
	REMOVE_TRAIT(atom_parent, TRAIT_CONNECTED_TO_SINGULARITY_CONSOLE, "[type]")
	connected = FALSE
	update_machine_power()

/datum/component/connects_to_singularity_console/proc/disconnect_cable()
	var/obj/structure/cable/last_cable = last_cable_ref?.resolve()
	if (!isnull(last_cable))
		UnregisterSignal(last_cable, list(COMSIG_CABLE_ADDED_TO_POWERNET, COMSIG_CABLE_REMOVED_FROM_POWERNET))

	var/datum/powernet/last_powernet = last_powernet_ref?.resolve()
	if (!isnull(last_powernet))
		UnregisterSignal(last_powernet, list(COMSIG_POWERNET_ADDED_CABLE, COMSIG_POWERNET_REMOVED_CABLE))

/datum/component/connects_to_singularity_console/proc/update_machine_power()
	if (!ismachinery(parent))
		return

	var/obj/machinery/machine_parent = parent
	machine_parent.power_change()
