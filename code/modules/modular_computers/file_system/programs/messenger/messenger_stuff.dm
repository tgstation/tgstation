/// A list of all active and visible messengers
GLOBAL_LIST_EMPTY_TYPED(TabletMessengers, /datum/computer_file/program/messenger)

/// Registers an NTMessenger instance to the list of TabletMessengers.
/proc/add_messenger(datum/computer_file/program/messenger/msgr)
	var/obj/item/modular_computer/messenger_device = msgr.computer
	// a bunch of empty PDAs are normally allocated, we don't want that clutter
	if(!messenger_device.saved_identification || !messenger_device.saved_job)
		return

	if(!istype(msgr))
		return

	var/msgr_ref = REF(msgr)
	if(msgr_ref in GLOB.TabletMessengers)
		return

	GLOB.TabletMessengers[msgr_ref] = msgr

/// Unregisters an NTMessenger instance from the TabletMessengers table.
/proc/remove_messenger(datum/computer_file/program/messenger/msgr)
	if(!istype(msgr))
		return

	var/msgr_ref = REF(msgr)
	if(!(msgr_ref in GLOB.TabletMessengers))
		return

	GLOB.TabletMessengers.Remove(msgr_ref)

/proc/get_messengers_sorted(sort_by_job = FALSE)
	var/sortmode
	if(sort_by_job)
		sortmode = GLOBAL_PROC_REF(cmp_pdajob_asc)
	else
		sortmode = GLOBAL_PROC_REF(cmp_pdaname_asc)

	return sortTim(GLOB.TabletMessengers.Copy(), sortmode, associative = TRUE)

// Why do we have this?
/proc/get_messenger_name(datum/computer_file/program/messenger/msgr)
	if(!istype(msgr))
		return null
	var/obj/item/modular_computer/computer = msgr.computer
	if(!istype(computer))
		return null
	return STRINGIFY_PDA_TARGET(computer.saved_identification, computer.saved_job)

/datum/pda_chat
	/// The cached name of the recipient, so we can
	/// identify this chat even after the recipient is deleted
	var/cached_name = null
	/// Weakref to the recipient messenger
	var/datum/weakref/recipient = null
	/// A list of messages in this chat
	var/list/datum/pda_msg/messages = list()
	/// Used to determine if we should show this in recents
	var/visible_in_recents = FALSE
	/// Used to label chats where the owner is no longer available
	var/owner_deleted = FALSE
	/// Used to determine if you can talk in a chat
	var/can_reply = TRUE

/datum/pda_chat/New(datum/computer_file/program/messenger/recp)
	recipient = WEAKREF(recp)

/datum/pda_chat/proc/add_msg(datum/pda_msg/message, show_in_recents = TRUE)
	messages += message
	if(!visible_in_recents || show_in_recents)
		visible_in_recents = TRUE
	return message

/// Returns this datum as an associative list, used for ui_data calls.
/datum/pda_chat/proc/get_data()
	var/list/data = list()
	var/datum/computer_file/program/messenger/recp = recipient.resolve()
	if(recp)
		cached_name = get_messenger_name(recp)

	data["recipient_name"] = cached_name

	var/list/messages_data = list()
	for(var/datum/pda_msg/message in messages)
		messages_data += list(message.get_data())
	data["messages"] = messages

	data["visible"] = visible_in_recents
	data["owner_deleted"] = owner_deleted
	data["can_reply"] = can_reply

	return data

/datum/pda_msg
	var/message
	var/outgoing
	var/datum/picture/photo
	var/photo_path
	var/everyone

/datum/pda_msg/New(msg, out, datum/picture/pic = null, path = null, to_everyone = FALSE)
	message = msg
	outgoing = out
	photo = pic
	photo_path = path
	everyone = to_everyone

/datum/pda_msg/proc/copy()
	return new /datum/pda_msg(message, outgoing, photo, photo_path, everyone)

/datum/pda_msg/proc/get_data()
	var/list/data = list()
	data["message"] = message
	data["outgoing"] = outgoing
	data["photo_path"] = photo_path
	data["everyone"] = everyone
	return data
