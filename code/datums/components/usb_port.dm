/// Opens up a USB port that can be connected to by circuits, creating registerable circuit components
/datum/component/usb_port
	/// The component types to create when something plugs in
	var/list/circuit_component_types

	/// The currently connected circuit
	var/obj/item/integrated_circuit/attached_circuit

	/// The currently connected USB cable
	var/datum/weakref/usb_cable_ref

	/// The components inside the parent
	var/list/obj/item/circuit_component/circuit_components

	/// The beam connecting the USB cable to the machine
	var/datum/beam/usb_cable_beam

/datum/component/usb_port/Initialize(list/circuit_component_types)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.circuit_component_types = circuit_component_types

/datum/component/usb_port/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_USB_CABLE_TRY_ATTACH, .proc/on_atom_usb_cable_try_attach)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/component/usb_port/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_USB_CABLE_TRY_ATTACH,
		COMSIG_MOVABLE_MOVED,
		COMSIG_PARENT_EXAMINE,
	))

	unregister_circuit_signals()

/datum/component/usb_port/Destroy()
	QDEL_LAZYLIST(circuit_components)
	QDEL_NULL(usb_cable_beam)

	attached_circuit = null
	usb_cable_ref = null

	return ..()

/datum/component/usb_port/proc/unregister_circuit_signals()
	if (isnull(attached_circuit))
		return

	UnregisterSignal(attached_circuit, list(
		COMSIG_CIRCUIT_SHELL_REMOVED,
		COMSIG_PARENT_QDELETING,
	))

	var/shell = attached_circuit.shell
	if (!isnull(shell))
		UnregisterSignal(shell, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(shell, COMSIG_PARENT_EXAMINE)

/datum/component/usb_port/proc/create_circuit_components(obj/item/integrated_circuit/circuitboard)
	var/created_circuit_components = list()

	for(var/circuit_component_type in circuit_component_types)
		var/obj/item/circuit_component/circuit_component = new circuit_component_type(parent)
		circuit_component.insertable_through_shells = TRUE
		circuitboard.add_component(circuit_component)
		created_circuit_components += circuit_component
		RegisterSignal(circuit_component, COMSIG_CIRCUIT_COMPONENT_REMOVED, .proc/on_circuit_component_removed)

	return created_circuit_components

/datum/component/usb_port/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	if (isnull(attached_circuit))
		examine_text += "<span class='notice'>There is a USB port on the front.</span>"
	else
		examine_text += "<span class='notice'>[attached_circuit.shell || attached_circuit] is connected to [parent.p_them()] to a USB port.</span>"

/datum/component/usb_port/proc/on_examine_shell(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	examine_text += "<span class='notice'>[source.p_they(TRUE)] [source.p_are()] attached to [parent] with a USB cable.</span>"

/datum/component/usb_port/proc/on_atom_usb_cable_try_attach(datum/source, obj/item/usb_cable/connecting_cable, mob/user)
	SIGNAL_HANDLER

	var/atom/atom_parent = parent

	if (!isnull(attached_circuit))
		atom_parent.balloon_alert(user, "usb already connected")
		return COMSIG_CANCEL_USB_CABLE_ATTACK

	if (isnull(connecting_cable.attached_circuit))
		connecting_cable.balloon_alert(user, "connect to a shell first")
		return COMSIG_CANCEL_USB_CABLE_ATTACK

	if (!IN_GIVEN_RANGE(connecting_cable.attached_circuit, parent, USB_CABLE_MAX_RANGE))
		connecting_cable.balloon_alert(user, "too far away")
		return COMSIG_CANCEL_USB_CABLE_ATTACK

	usb_cable_ref = WEAKREF(connecting_cable)
	attached_circuit = connecting_cable.attached_circuit

	connecting_cable.forceMove(attached_circuit)
	circuit_components = create_circuit_components(attached_circuit)
	attached_circuit.interact(user)

	usb_cable_beam = atom_parent.Beam(attached_circuit.shell, "usb_cable_beam", 'icons/obj/wiremod.dmi')

	RegisterSignal(attached_circuit, COMSIG_CIRCUIT_SHELL_REMOVED, .proc/on_circuit_shell_removed)
	RegisterSignal(attached_circuit, COMSIG_PARENT_QDELETING, .proc/on_circuit_deleting)
	RegisterSignal(attached_circuit.shell, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	RegisterSignal(attached_circuit.shell, COMSIG_PARENT_EXAMINE, .proc/on_examine_shell)

	return COMSIG_USB_CABLE_ATTACHED

/datum/component/usb_port/proc/on_moved()
	SIGNAL_HANDLER

	if (isnull(attached_circuit))
		return

	if (IN_GIVEN_RANGE(attached_circuit, parent, USB_CABLE_MAX_RANGE))
		return

	detach()

/datum/component/usb_port/proc/on_circuit_deleting()
	SIGNAL_HANDLER
	unregister_circuit_signals()
	attached_circuit = null
	qdel(usb_cable_ref)

/datum/component/usb_port/proc/on_circuit_component_removed(datum/source)
	SIGNAL_HANDLER

	qdel(source)
	detach()

/datum/component/usb_port/proc/on_circuit_shell_removed()
	SIGNAL_HANDLER

	detach()

/datum/component/usb_port/proc/detach()
	var/obj/item/usb_cable/usb_cable = usb_cable_ref?.resolve()
	if (isnull(usb_cable))
		return

	unregister_circuit_signals()

	var/atom/atom_parent = parent
	usb_cable.forceMove(atom_parent.drop_location())
	usb_cable.balloon_alert_to_viewers("snap")

	QDEL_LAZYLIST(circuit_components)

	attached_circuit = null
	usb_cable_ref = null

	QDEL_NULL(usb_cable_beam)
