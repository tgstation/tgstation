/// A cable that can connect integrated circuits to anything with a USB port, such as computers and machines.
/obj/item/usb_cable
	name = "usb cable"
	desc = "A cable that can connect integrated circuits to anything with a USB port, such as computers and machines."
	icon = 'icons/obj/power.dmi'
	icon_state = "coil"
	inhand_icon_state = "coil"
	base_icon_state = "coil"
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron = 75)

	/// The currently connected circuit
	var/obj/item/integrated_circuit/attached_circuit

/obj/item/usb_cable/Destroy()
	attached_circuit = null
	return ..()

/obj/item/usb_cable/examine(mob/user)
	. = ..()

	if (!isnull(attached_circuit))
		. += "<span class='notice'>It is attached to [get_atom_on_turf(attached_circuit, /obj/structure)].</span>"

/obj/item/usb_cable/pre_attack(atom/target, mob/living/user, params)
	. = ..()
	if (.)
		return

	var/signal_result = SEND_SIGNAL(target, COMSIG_ATOM_USB_CABLE_TRY_ATTACH, src, user)

	var/last_attached_circuit = attached_circuit
	if (signal_result & COMSIG_USB_CABLE_CONNECTED_TO_CIRCUIT)
		if (isnull(attached_circuit))
			CRASH("Producers of COMSIG_USB_CABLE_CONNECTED_TO_CIRCUIT must set attached_circuit")
		balloon_alert(user, "connected to circuit")
		// MOTHBLOCKS TODO: Sound

		if (last_attached_circuit != attached_circuit)
			if (!isnull(last_attached_circuit))
				unregister_circuit_signals(last_attached_circuit)
			register_circuit_signals()

		return TRUE

	if (signal_result & COMSIG_USB_CABLE_ATTACHED)
		// Short messages are better to read
		var/connection_description = "port"
		if (istype(target, /obj/machinery/computer))
			connection_description = "computer"
		else if (ismachinery(target))
			connection_description = "machine"

		balloon_alert(user, "connected to [connection_description]")

		return TRUE

	if (signal_result & COMSIG_CANCEL_USB_CABLE_ATTACK)
		return TRUE

	return FALSE

/obj/item/usb_cable/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is wrapping [src] around [user.p_their()] neck! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return OXYLOSS

/obj/item/usb_cable/proc/register_circuit_signals()
	RegisterSignal(attached_circuit, COMSIG_MOVABLE_MOVED, .proc/on_circuit_moved)
	RegisterSignal(attached_circuit, COMSIG_PARENT_QDELETING, .proc/on_circuit_qdeling)

/obj/item/usb_cable/proc/unregister_circuit_signals(obj/item/integrated_circuit/old_circuit)
	UnregisterSignal(attached_circuit, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_PARENT_QDELETING,
	))

/obj/item/usb_cable/proc/on_circuit_moved()
	SIGNAL_HANDLER

	if (!Adjacent(attached_circuit))
		balloon_alert_to_viewers("detached, too far away")
		unregister_circuit_signals(attached_circuit)
		attached_circuit = null

/obj/item/usb_cable/proc/on_circuit_qdeling()
	SIGNAL_HANDLER

	attached_circuit = null
