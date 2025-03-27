/datum/computer_file/program/maintenance/modsuit_control
	filename = "modsuit_control"
	filedesc = "MODsuit Control"
	program_open_overlay = "modsuit_control"
	downloader_category = PROGRAM_CATEGORY_EQUIPMENT
	extended_desc = "This program allows people to connect a MODsuit to it, allowing remote control."
	size = 2
	tgui_id = "NtosMODsuit"
	program_icon = "user-astronaut"
	circuit_comp_type = /obj/item/circuit_component/mod_program/modsuit_control

	///The suit we have control over.
	var/obj/item/mod/control/controlled_suit

/datum/computer_file/program/maintenance/modsuit_control/Destroy()
	if(controlled_suit)
		unsync_modsuit()
	return ..()

/datum/computer_file/program/maintenance/modsuit_control/application_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/mod/control))
		sync_modsuit(tool, user)
		return ITEM_INTERACT_SUCCESS

/datum/computer_file/program/maintenance/modsuit_control/proc/sync_modsuit(obj/item/mod/control/new_modsuit, mob/living/user)
	if(controlled_suit)
		unsync_modsuit()
	controlled_suit = new_modsuit
	RegisterSignal(controlled_suit, COMSIG_QDELETING, PROC_REF(unsync_modsuit))
	user?.balloon_alert(user, "suit updated")

/datum/computer_file/program/maintenance/modsuit_control/proc/unsync_modsuit(atom/source)
	SIGNAL_HANDLER
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
	. = ..()
	return controlled_suit?.ui_act(action, params, ui, state)


/obj/item/circuit_component/mod_program/modsuit_control
	associated_program = /datum/computer_file/program/maintenance/modsuit_control

	///Circuit port for loading a new suit to control
	var/datum/port/input/suit_port

/obj/item/circuit_component/mod_program/modsuit_control/populate_ports()
	. = ..()
	suit_port = add_input_port("MODsuit Controlled", PORT_TYPE_ATOM)

/obj/item/circuit_component/mod_program/modsuit_control/input_received(datum/port/port)
	var/datum/computer_file/program/maintenance/modsuit_control/control = associated_program
	var/obj/item/mod/control/mod = suit_port.value
	if(isnull(mod) && control.controlled_suit)
		control.unsync_modsuit()
		return
	if(!istype(mod))
		return
	control.sync_modsuit(mod)
