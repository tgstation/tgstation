/// A cable that can connect integrated circuits to anything with a USB port, such as computers and machines.
// MOTHBLOCKS TODO: Say too far away when you move too far away
/obj/item/usb_cable
	name = "usb cable"
	desc = "A cable that can connect integrated circuits to anything with a USB port, such as computers and machines."
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "usb_cable"
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

	if (!IN_GIVEN_RANGE(attached_circuit, src, USB_CABLE_MAX_RANGE))
		balloon_alert_to_viewers("detached, too far away")
		unregister_circuit_signals(attached_circuit)
		attached_circuit = null

/obj/item/usb_cable/proc/on_circuit_qdeling()
	SIGNAL_HANDLER

	attached_circuit = null

// MOTHBLOCKS TODO: Remove this
/mob/proc/give_circuit_shit()
	var/turf/T = get_turf(src)
	new /obj/item/integrated_circuit/loaded/circuit_shit(T)
	new /obj/item/assembly/signaler(T)
	new /obj/item/screwdriver(T)
	new /obj/item/multitool(T)
	new /obj/structure/bot(T)
	new /obj/item/usb_cable(T)

// MOTHBLOCKS TODO: Remove this
/obj/item/integrated_circuit/loaded/circuit_shit/Initialize()
	. = ..()

	var/obj/item/circuit_component/radio/radio = new
	add_component(radio)
