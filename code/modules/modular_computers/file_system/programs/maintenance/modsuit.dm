/datum/computer_file/program/maintenance/modsuit_control
	filename = "modsuit_control"
	filedesc = "MODsuit Control"
	program_open_overlay = "modsuit_control"
	downloader_category = PROGRAM_CATEGORY_EQUIPMENT
	extended_desc = "This program allows people to connect a MODsuit to it, allowing remote control."
	size = 2
	tgui_id = "NtosMODsuit"
	program_icon = "user-astronaut"

	///The suit we have control over.
	var/obj/item/mod/control/controlled_suit

	///Circuit port for loading a new suit to control
	var/datum/port/input/suit_port

/datum/computer_file/program/maintenance/modsuit_control/Destroy()
	if(controlled_suit)
		unsync_modsuit()
	return ..()

/datum/computer_file/program/maintenance/modsuit_control/application_attackby(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(!istype(attacking_item, /obj/item/mod/control))
		return FALSE
	if(controlled_suit)
		unsync_modsuit()
	controlled_suit = attacking_item
	RegisterSignal(controlled_suit, COMSIG_QDELETING, PROC_REF(unsync_modsuit))
	user.balloon_alert(user, "suit updated")
	return TRUE

/datum/computer_file/program/maintenance/modsuit_control/proc/unsync_modsuit(atom/source)
	UnregisterSignal(controlled_suit, COMSIG_QDELETING)
	controlled_suit = null

/datum/computer_file/program/maintenance/modsuit_control/ui_data(mob/user)
	var/list/data = list()
	data["has_suit"] = !!controlled_suit
	if(controlled_suit)
		data += controlled_suit.ui_data()
	return data

/datum/computer_file/program/maintenance/modsuit_control/ui_static_data(mob/user)
	return controlled_suit?.ui_static_data()

/datum/computer_file/program/maintenance/modsuit_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	return controlled_suit?.ui_act(action, params, ui, state)

/datum/computer_file/program/maintenance/modsuit_control/populate_modular_ports(obj/item/circuit_component/comp)
	. = ..()
	suit_port = comp.add_input_port("MODsuit Controlled", PORT_TYPE_ATOM)

/datum/computer_file/program/maintenance/modsuit_control/depopulate_modular_ports(obj/item/circuit_component/comp)
	. = ..()
	suit_port = comp.remove_input_port(suit_port)

/datum/computer_file/program/maintenance/modsuit_control/on_input_received(datum/port/port)
	if(!COMPONENT_TRIGGERED_BY(suit_port, port))
		return
	var/obj/item/mod/control/mod = suit_port.value
	if(isnull(mod) && controlled_suit)
		unsync_modsuit()
		return
	if(!istype(mod))
		return
	if(controlled_suit)
		unsync_modsuit()
	controlled_suit = mod
	RegisterSignal(controlled_suit, COMSIG_QDELETING, PROC_REF(unsync_modsuit))
