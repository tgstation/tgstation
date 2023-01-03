// This doesn't connect to new computers.
// For the purposes of the prototype, I don't care.
// It also doesn't disconnect when the computer is destroyed. Easily fixable, but I'm busy.
/datum/component/connects_to_singularity_console
	var/datum/weakref/current_connected_computer_ref
	var/datum/weakref/last_cable_ref
	var/datum/weakref/last_powernet_ref

/datum/component/connects_to_singularity_console/Initialize(...)
	. = ..()

	if (!isatom(parent))
		return ELEMENT_INCOMPATIBLE

/datum/component/connects_to_singularity_console/RegisterWithParent()
	var/atom/atom_parent = parent
	RegisterSignal(atom_parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

	if (isturf(atom_parent.loc))
		RegisterSignals(atom_parent.loc, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED), PROC_REF(check_connection))

	check_connection()

/datum/component/connects_to_singularity_console/UnregisterFromParent()
	disconnect_cable()
	disconnect_computer()

/datum/component/connects_to_singularity_console/proc/on_moved(atom/source, atom/old_loc)
	SIGNAL_HANDLER

	if (isturf(old_loc))
		UnregisterSignal(old_loc, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))

	if (isturf(source.loc))
		RegisterSignal(source.loc, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED), PROC_REF(check_connection))

/datum/component/connects_to_singularity_console/proc/check_connection()
	SIGNAL_HANDLER

	var/atom/atom_parent = parent
	atom_parent.balloon_alert_to_viewers("check_connection")

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
		if (isnull(computer_cable) || computer_cable.powernet != our_cable.powernet)
			disconnect_computer()

	if (!isnull(current_connected_computer_ref))
		return

	for (var/obj/machinery/computer/singularity/singularity_computer as anything in GLOB.singularity_computers)
		var/obj/structure/cable/computer_cable = locate() in get_turf(singularity_computer)
		if (isnull(computer_cable))
			continue

		if (computer_cable.powernet == our_cable.powernet)
			connect_computer(singularity_computer)
			return

/datum/component/connects_to_singularity_console/proc/connect_computer(obj/machinery/computer/singularity/singularity_computer)
	disconnect_computer()

	current_connected_computer_ref = WEAKREF(singularity_computer)

	singularity_computer.connected_machines += parent

	var/atom/atom_parent = parent
	ADD_TRAIT(atom_parent, TRAIT_CONNECTED_TO_SINGULARITY_CONSOLE, "[type]")
	atom_parent.maptext = MAPTEXT("O")

/datum/component/connects_to_singularity_console/proc/connect_cable(obj/structure/cable/our_cable)
	if (!IS_WEAKREF_OF(our_cable, last_cable_ref) || !IS_WEAKREF_OF(our_cable.powernet, last_powernet_ref))
		disconnect_cable()

	last_cable_ref = WEAKREF(our_cable)
	RegisterSignal(our_cable, COMSIG_CABLE_POWERNET_CHANGED, PROC_REF(check_connection))

	if (!isnull(our_cable.powernet))
		last_powernet_ref = WEAKREF(our_cable.powernet)
		RegisterSignals(our_cable.powernet, list(COMSIG_POWERNET_ADDED_CABLE, COMSIG_POWERNET_REMOVED_CABLE), PROC_REF(check_connection))

/datum/component/connects_to_singularity_console/proc/disconnect_computer()
	var/obj/machinery/computer/singularity/current_connected_computer = current_connected_computer_ref?.resolve()
	current_connected_computer?.connected_machines -= src
	current_connected_computer_ref = null

	var/atom/atom_parent = parent
	REMOVE_TRAIT(atom_parent, TRAIT_CONNECTED_TO_SINGULARITY_CONSOLE, "[type]")
	atom_parent.maptext = MAPTEXT("X")

/datum/component/connects_to_singularity_console/proc/disconnect_cable()
	var/obj/structure/cable/last_cable = last_cable_ref?.resolve()
	if (!isnull(last_cable))
		UnregisterSignal(last_cable, PROC_REF(check_connection))

	var/datum/powernet/last_powernet = last_powernet_ref?.resolve()
	if (!isnull(last_powernet))
		UnregisterSignal(last_powernet, list(COMSIG_POWERNET_ADDED_CABLE, COMSIG_POWERNET_REMOVED_CABLE))
