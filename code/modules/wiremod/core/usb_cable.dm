/// A cable that can connect integrated circuits to anything with a USB port, such as computers and machines.
/obj/item/usb_cable
	name = "usb cable"
	desc = "A cable that can connect integrated circuits to anything with a USB port, such as computers and machines."
	icon = 'icons/obj/science/circuits.dmi'
	icon_state = "usb_cable"
	inhand_icon_state = "coil_yellow"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	base_icon_state = "coil"
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*0.75)

	/// The currently connected circuit
	var/obj/item/integrated_circuit/attached_circuit

/obj/item/usb_cable/Destroy()
	attached_circuit = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/usb_cable/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/obj/item/usb_cable/examine(mob/user)
	. = ..()

	if (!isnull(attached_circuit))
		. += span_notice("It is attached to [attached_circuit.shell || attached_circuit].")

// Look, I'm not happy about this either, but moving an object doesn't call Moved if it's inside something else.
// There's good reason for this, but there's no element or similar yet to track it as far as I know.
// SSobj runs infrequently, this is only ran while there's an attached circuit, its performance cost is negligible.
/obj/item/usb_cable/process(seconds_per_tick)
	if (!check_in_range())
		return PROCESS_KILL

/obj/item/usb_cable/pre_attack(atom/target, mob/living/user, params)
	. = ..()
	if (.)
		return

	if (prob(1))
		balloon_alert(user, "wrong way, god damnit")
		return TRUE

	var/signal_result = SEND_SIGNAL(target, COMSIG_ATOM_USB_CABLE_TRY_ATTACH, src, user)

	var/last_attached_circuit = attached_circuit
	if (signal_result & COMSIG_USB_CABLE_CONNECTED_TO_CIRCUIT)
		if (isnull(attached_circuit))
			CRASH("Producers of COMSIG_USB_CABLE_CONNECTED_TO_CIRCUIT must set attached_circuit")
		balloon_alert(user, "connected to circuit\nconnect to a port")

		playsound(src, 'sound/machines/pda_button/pda_button1.ogg', 20, TRUE)

		if (last_attached_circuit != attached_circuit)
			if (!isnull(last_attached_circuit))
				unregister_circuit_signals(last_attached_circuit)
			register_circuit_signals()

		START_PROCESSING(SSobj, src)

		return TRUE

	if (signal_result & COMSIG_USB_CABLE_ATTACHED)
		// Short messages are better to read
		var/connection_description = "port"
		if (istype(target, /obj/machinery/computer))
			connection_description = "computer"
		else if (ismachinery(target))
			connection_description = "machine"

		balloon_alert(user, "connected to [connection_description]")
		playsound(src, 'sound/items/tools/screwdriver2.ogg', 20, TRUE)

		return TRUE

	if (signal_result & COMSIG_CANCEL_USB_CABLE_ATTACK)
		return TRUE

	return FALSE

/obj/item/usb_cable/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is wrapping [src] around [user.p_their()] neck! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/usb_cable/proc/register_circuit_signals()
	RegisterSignal(attached_circuit, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(attached_circuit, COMSIG_QDELETING, PROC_REF(on_circuit_qdeling))
	RegisterSignal(attached_circuit.shell, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/obj/item/usb_cable/proc/unregister_circuit_signals(obj/item/integrated_circuit/old_circuit)
	UnregisterSignal(attached_circuit, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_QDELETING,
	))

	UnregisterSignal(attached_circuit.shell, COMSIG_MOVABLE_MOVED)

/obj/item/usb_cable/proc/on_moved()
	SIGNAL_HANDLER

	check_in_range()

/obj/item/usb_cable/proc/check_in_range()
	if (isnull(attached_circuit))
		STOP_PROCESSING(SSobj, src)
		return FALSE

	if (!IN_GIVEN_RANGE(attached_circuit, src, USB_CABLE_MAX_RANGE))
		balloon_alert_to_viewers("detached, too far away")
		unregister_circuit_signals(attached_circuit)
		attached_circuit = null
		STOP_PROCESSING(SSobj, src)
		return FALSE

	return TRUE

/obj/item/usb_cable/proc/on_circuit_qdeling()
	SIGNAL_HANDLER

	attached_circuit = null
	STOP_PROCESSING(SSobj, src)
