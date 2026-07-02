/datum/computer_file/program/faxbond
	filename = "faxbond"
	filedesc = "FaxBond"
	can_run_on_flags = PROGRAM_PDA
	downloader_category = PROGRAM_CATEGORY_DEVICE
	program_open_overlay = "generic"
	extended_desc = "A lightweight piece of software designed to decrease fax response time. \
		Will send a notification as soon as one of connected faxes receives a message. \
		Recommended by 9 out of 10 CentCom officers."
	size = 1
	tgui_id = "NtosFaxBond"
	program_icon = "fa-fax"
	/// All relevant info of every connected fax, including weak ref for cleaning after ourself + name, area name and muted bool
	var/list/connected_faxes = list()

/**
 * Proc for subscribing to faxes. Registers needed signal and updates fax related vars for program. Includes type checking.
 * Arguments:
 * * target - [/datum/computer_file/program/proc/tap] proc target, can be anything
 */
/datum/computer_file/program/faxbond/proc/connect_fax(obj/machinery/fax/target)
	if(!istype(target))
		return FALSE

	var/our_id = target.fax_id

	if(!connected_faxes[our_id])
		RegisterSignal(target, COMSIG_FAX_MESSAGE_RECEIVED, PROC_REF(on_fax_message_received))

	var/list/fax_info = list()
	var/area/our_area = get_area(target)
	fax_info["ref"] = WEAKREF(target)
	fax_info["name"] = target.fax_name
	fax_info["area_name"] = our_area.name
	fax_info["muted"] = FALSE
	connected_faxes[our_id] += fax_info

	return TRUE

/**
 * Disconnects a fax given its ID (if it was connected before), removing it from a list and unregistering relevant signal
 * Arguments:
 * * fax_id - fax id to disconnect from our PDA
 */
/datum/computer_file/program/faxbond/proc/disconnect_fax(fax_id)
	if(!connected_faxes[fax_id])
		return

	var/list/fax_info = connected_faxes[fax_id]
	var/datum/weakref/fax_ref = fax_info["ref"]
	var/obj/machinery/fax/our_fax = fax_ref.resolve()
	if (our_fax)
		UnregisterSignal(our_fax, COMSIG_FAX_MESSAGE_RECEIVED)

	connected_faxes -= fax_id


/**
 * Signal handler for [COMSIG_FAX_MESSAGE_RECEIVED].
 * Arguments:
 * * receiver - [/obj/machinery/fax] that received a message
 * * message_source - name of a sender
 */
/datum/computer_file/program/faxbond/proc/on_fax_message_received(obj/machinery/fax/receiver, message_source)
	SIGNAL_HANDLER

	var/id = receiver.fax_id
	var/list/fax_info = connected_faxes[id]

	if (fax_info["muted"])
		return

	var/datum/computer_file/program/messenger/messenger = locate() in computer.stored_files
	var/datum/signal/subspace/messaging/tablet_message/signal = new(receiver, list(
		"fakename" = "Fax Notificator",
		"fakejob" = "PDA Program",
		"message" = "Your fax [receiver.fax_name] has received a new message from [message_source]",
		"targets" = list(messenger),
		"automated" = TRUE
	))
	INVOKE_ASYNC(signal, TYPE_PROC_REF(/datum/signal/subspace, send_to_receivers))

/datum/computer_file/program/faxbond/Destroy()
	. = ..()
	for(var/fax in connected_faxes)
		disconnect_fax(fax)

/datum/computer_file/program/faxbond/tap(atom/tapped_atom, mob/living/user, list/modifiers)
	return connect_fax(tapped_atom)

/datum/computer_file/program/faxbond/ui_data(mob/user)
	var/list/data = list()

	data["faxes_info"] = list()
	for(var/fax_id in connected_faxes)
		var/list/fax_info = connected_faxes[fax_id]
		var/list/fax_data = list(
			"id" = fax_id,
			"name" = fax_info["name"],
			"location" = fax_info["area_name"],
			"muted" = fax_info["muted"],
		)
		data["faxes_info"] += list(fax_data)
	return data

/datum/computer_file/program/faxbond/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("unsubscribe")
			disconnect_fax(params["id"])
			return TRUE
		if("mute")
			var/list/fax_info = connected_faxes[params["id"]]
			if (!fax_info)
				return FALSE
			fax_info["muted"] = !fax_info["muted"]
			return TRUE
