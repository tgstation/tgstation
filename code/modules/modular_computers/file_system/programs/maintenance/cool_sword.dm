/datum/computer_file/program/maintenance/cool_sword
	filename = "cool_sword"
	filedesc = "NtOS Cursor Replacer"
	power_cell_use = 0
	downloader_category = PROGRAM_CATEGORY_DEVICE
	extended_desc = "This program allows you to customize your computer's mouse cursor, \
		but there's only one option, let's be honest. \
		Wear your PDA in your ID slot for it to take effect."
	can_run_on_flags = PROGRAM_PDA
	tgui_id = "NtosCursor"
	program_open_overlay = "generic"

	/// What icon to use for the mouse pointer?
	var/sword_icon = 'icons/effects/mouse_pointers/cool_sword.dmi'

/datum/computer_file/program/maintenance/cool_sword/New()
	. = ..()
	RegisterSignal(src, COMSIG_COMPUTER_FILE_DELETE, PROC_REF(on_delete))

/datum/computer_file/program/maintenance/cool_sword/on_install(datum/computer_file/source, obj/item/modular_computer/computer_installing)
	. = ..()
	RegisterSignal(computer_installing, COMSIG_ITEM_EQUIPPED, PROC_REF(host_equipped))
	RegisterSignal(computer_installing, COMSIG_ITEM_DROPPED, PROC_REF(host_dropped))

	if(ismob(computer_installing.loc))
		var/mob/living/computer_guy = computer_installing.loc
		var/current_slot = computer_guy.get_slot_by_item(computer_installing)
		host_equipped(computer_installing, computer_guy, current_slot)

/datum/computer_file/program/maintenance/cool_sword/proc/on_delete(datum/source, obj/item/modular_computer/computer_uninstalling)
	SIGNAL_HANDLER

	if(ismob(computer_uninstalling.loc))
		host_dropped(computer_uninstalling, computer_uninstalling.loc)

/datum/computer_file/program/maintenance/cool_sword/proc/host_equipped(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(slot & ITEM_SLOT_ID)
		user.client?.mouse_override_icon = sword_icon
		RegisterSignal(user, COMSIG_MOB_LOGIN, PROC_REF(update_mouse), override = TRUE)
		RegisterSignal(user, COMSIG_MOB_LOGOUT, PROC_REF(stop_mouse), override = TRUE)
	else
		// Shouldn't be necessary w/ dropped but just to be safe
		user.client?.mouse_override_icon = null
		UnregisterSignal(user, list(COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT))
	user.update_mouse_pointer()

/datum/computer_file/program/maintenance/cool_sword/proc/host_dropped(datum/source, mob/user)
	SIGNAL_HANDLER

	user.client?.mouse_override_icon = null
	UnregisterSignal(user, list(COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT))
	user.update_mouse_pointer()

/datum/computer_file/program/maintenance/cool_sword/proc/update_mouse(mob/source)
	SIGNAL_HANDLER

	source.client?.mouse_override_icon = sword_icon
	source.update_mouse_pointer()

/datum/computer_file/program/maintenance/cool_sword/proc/stop_mouse(mob/source)
	SIGNAL_HANDLER

	source.canon_client?.mouse_override_icon = null
	source.canon_client?.mob?.update_mouse_pointer()

/datum/computer_file/program/maintenance/cool_sword/ui_static_data(mob/user)
	var/list/data = list()
	data["dmi"] = list("icon" = sword_icon, "icon_state" = "")
	return data
