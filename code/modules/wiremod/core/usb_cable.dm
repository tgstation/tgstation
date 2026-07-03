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

	/// Used to prevent range checking during shuttle movement, which moves atoms en-masse.
	var/defer_range_checks = FALSE

/obj/item/usb_cable/Destroy()
	attached_circuit = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/usb_cable/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	var/static/list/connections = list(
		COMSIG_MOVABLE_MOVED = PROC_REF(on_moved),
		COMSIG_ATOM_BEFORE_SHUTTLE_MOVE = PROC_REF(before_shuttle_move),
		COMSIG_ATOM_AFTER_SHUTTLE_MOVE = PROC_REF(after_shuttle_move),
	)
	AddComponent(/datum/component/connect_containers, src, connections)

/obj/item/usb_cable/examine(mob/user)
	. = ..()

	if (!isnull(attached_circuit))
		. += span_notice("It is attached to [attached_circuit.shell || attached_circuit].")

/obj/item/usb_cable/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if (.)
		return

	if (prob(1))
		balloon_alert(user, "wrong way, god damnit")
		return TRUE

	var/signal_result = SEND_SIGNAL(target, COMSIG_ATOM_USB_CABLE_TRY_ATTACH, src, user)

	if (signal_result & COMSIG_USB_CABLE_CONNECTED_TO_CIRCUIT)
		if (isnull(attached_circuit))
			CRASH("Producers of COMSIG_USB_CABLE_CONNECTED_TO_CIRCUIT must set attached_circuit")
		balloon_alert(user, "connected to circuit\nconnect to a port")

		playsound(src, 'sound/machines/pda_button/pda_button1.ogg', 20, TRUE)

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
	user.visible_message(span_suicide("[user] is wrapping [src] around [user.p_their()] neck! Кажется, [user.ru_p_they()] пытается совершить самоубийство!"))
	return OXYLOSS

/obj/item/usb_cable/proc/on_moved()
	SIGNAL_HANDLER

	if(defer_range_checks)
		return
	check_in_range()

/obj/item/usb_cable/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	. = ..()
	before_shuttle_move()

/obj/item/usb_cable/proc/before_shuttle_move()
	SIGNAL_HANDLER

	defer_range_checks = TRUE

/obj/item/usb_cable/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	after_shuttle_move()

/obj/item/usb_cable/proc/after_shuttle_move()
	SIGNAL_HANDLER

	defer_range_checks = FALSE
	check_in_range()

/obj/item/usb_cable/proc/check_in_range()
	if (isnull(attached_circuit))
		return FALSE

	if (!IN_GIVEN_RANGE(attached_circuit, src, USB_CABLE_MAX_RANGE))
		balloon_alert_to_viewers("detached, too far away")
		attached_circuit = null
		return FALSE

	return TRUE

/obj/item/usb_cable/proc/on_circuit_qdeling()
	SIGNAL_HANDLER

	attached_circuit = null
