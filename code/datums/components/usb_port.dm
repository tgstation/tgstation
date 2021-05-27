/// Opens up a USB port that can be connected to by circuits, creating registerable circuit components
/datum/component/usb_port
	/// The component types to create when something plugs in
	var/list/circuit_component_types

	/// The currently connected circuit
	var/obj/item/integrated_circuit/attached_circuit

	/// The components inside the parent
	var/list/obj/item/circuit_component/circuit_components

/datum/component/usb_port/Initialize(list/circuit_component_types)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.circuit_component_types = circuit_component_types

/datum/component/usb_port/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(parent, COMSIG_ATOM_USB_CABLE_TRY_ATTACH, .proc/on_atom_usb_cable_try_attach)

/datum/component/usb_port/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_ATOM_USB_CABLE_TRY_ATTACH,
	))

/datum/component/usb_port/Destroy()
	QDEL_LAZYLIST(circuit_components)

	return ..()

/datum/component/usb_port/proc/create_circuit_components(obj/item/integrated_circuit/circuitboard)
	var/created_circuit_components = list()

	for(var/circuit_component_type in circuit_component_types)
		var/obj/item/circuit_component/circuit_component = new circuit_component_type(src)
		circuit_component.removable = FALSE
		circuitboard.add_component(circuit_component)
		created_circuit_components += circuit_component

	return created_circuit_components

/datum/component/usb_port/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	if (isnull(attached_circuit))
		examine_text += "<span class='notice'>There is a USB port on the front.</span>"
	else
		examine_text += "<span class='notice'>[attached_circuit.shell || attached_circuit] is connected to [parent.p_them()] to a USB port.</span>"

/datum/component/usb_port/proc/on_atom_usb_cable_try_attach(datum/source, obj/item/usb_cable/usb_cable, mob/user)
	SIGNAL_HANDLER

	var/atom/atom_parent = parent

	if (!isnull(attached_circuit))
		atom_parent.balloon_alert(user, "usb already connected")
		return COMSIG_CANCEL_USB_CABLE_ATTACK

	if (isnull(usb_cable.attached_circuit))
		usb_cable.balloon_alert(user, "connect to a shell first")
		return COMSIG_CANCEL_USB_CABLE_ATTACK

	atom_parent.balloon_alert(user, "usb connected")

	usb_cable.forceMove(usb_cable.attached_circuit)
	circuit_components = create_circuit_components(usb_cable.attached_circuit)
	usb_cable.attached_circuit.interact(user)
