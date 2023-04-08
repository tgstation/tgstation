/datum/computer_file/program/maintenance/modsuit_control
	filename = "modsuit_control"
	filedesc = "MODsuit Control"
	program_icon_state = "modsuit_control"
	category = PROGRAM_CATEGORY_SCI
	extended_desc = "This program allows people to connect a MODsuit to it, allowing remote control."
	size = 2
	tgui_id = "NtosMODsuit"
	program_icon = "user-astronaut"

	///The suit we have control over.
	var/obj/item/mod/control/controlled_suit

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
	RegisterSignal(controlled_suit, COMSIG_PARENT_QDELETING, PROC_REF(unsync_modsuit))
	user.balloon_alert(user, "suit updated")
	return TRUE

/datum/computer_file/program/maintenance/modsuit_control/proc/unsync_modsuit(atom/source)
	UnregisterSignal(controlled_suit, COMSIG_PARENT_QDELETING)
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
	if(.)
		return
	controlled_suit.ui_act(action, params, ui, state)
