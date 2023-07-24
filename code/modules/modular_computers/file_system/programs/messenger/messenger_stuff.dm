/**
 * I'll come up with a better file name later
 */

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

/// Gets all messengers, sorted by their job or name
/proc/get_messengers_sorted(sort_by_job = FALSE)
	var/sortmode
	if(sort_by_job)
		sortmode = GLOBAL_PROC_REF(cmp_pdajob_asc)
	else
		sortmode = GLOBAL_PROC_REF(cmp_pdaname_asc)

	return sortTim(GLOB.TabletMessengers.Copy(), sortmode, associative = TRUE)

/// Get the display name of a messenger instance
/proc/get_messenger_name(datum/computer_file/program/messenger/msgr)
	if(!istype(msgr))
		return null
	var/obj/item/modular_computer/computer = msgr.computer
	if(!istype(computer))
		return null
	return STRINGIFY_PDA_TARGET(computer.saved_identification, computer.saved_job)

/**
 * Chat log data type, stores information about the recipient,
 * the messages themselves and other metadata.
 */
/datum/pda_chat
	/// The cached name of the recipient, so we can
	/// identify this chat even after the recipient is deleted
	var/cached_name = "Unknown"
	/// The cached job of the recipient
	var/cached_job = "Unknown"
	/// Weakref to the recipient messenger
	var/datum/weakref/recipient = null
	/// A list of messages in this chat
	var/list/datum/pda_msg/messages = list()
	/// Used to determine if we should show this in recents
	var/visible_in_recents = FALSE
	/// Used to determine if you can talk in a chat
	var/can_reply = TRUE
	/// Saved draft of a message so the sender can leave and come back later
	var/message_draft = ""
	/// Number of unread messages in this chat
	var/unread_messages = 0

/datum/pda_chat/New(datum/computer_file/program/messenger/recp)
	recipient = WEAKREF(recp)
	can_reply = !isnull(recipient)

/// Adds a message to the chat log and optionally shows the chat in recents.
/// Call this instead of adding to messages directly.
/datum/pda_chat/proc/add_msg(datum/pda_msg/message, show_in_recents = TRUE)
	messages += message
	if(!visible_in_recents && show_in_recents)
		visible_in_recents = TRUE
	return message

/// Returns this datum as an associative list, used for ui_data calls.
/datum/pda_chat/proc/get_ui_data(mob/user)
	var/list/data = list()

	var/list/recp_data = list()

	recp_data["name"] = get_recp_name()
	recp_data["job"] = get_recp_job()
	recp_data["ref"] = recipient?.reference

	data["ref"] = REF(src)
	data["recp"] = recp_data

	var/list/messages_data = list()
	for(var/datum/pda_msg/message as anything in messages)
		messages_data += list(message.get_ui_data(user))
	data["messages"] = messages_data
	data["message_draft"] = message_draft

	data["visible"] = visible_in_recents
	data["can_reply"] = can_reply
	data["unread_messages"] = unread_messages

	return data

/datum/pda_chat/proc/get_recp_name()
	var/datum/computer_file/program/messenger/recp = recipient?.resolve()
	if(istype(recp) && (recipient.reference in GLOB.TabletMessengers))
		cached_name = recp.computer.saved_identification
	return cached_name

/datum/pda_chat/proc/get_recp_job()
	var/datum/computer_file/program/messenger/recp = recipient?.resolve()
	if(istype(recp) && (recipient.reference in GLOB.TabletMessengers))
		cached_job = recp.computer.saved_job
	return cached_job

/**
 * Chat message data type, stores data about messages themselves.
 */
/datum/pda_msg
	var/message
	var/outgoing
	var/photo_asset_name
	var/everyone

/datum/pda_msg/New(message, outgoing, photo_asset_name = null, everyone = FALSE)
	src.message = message
	src.outgoing = outgoing
	src.photo_asset_name = photo_asset_name
	src.everyone = everyone

/// Returns an associative list of the message's data, used for ui_data calls.
/datum/pda_msg/proc/get_ui_data(mob/user)
	var/list/data = list()
	data["message"] = message
	data["outgoing"] = outgoing
	data["photo_path"] = photo_asset_name ? SSassets.transport.get_asset_url(photo_asset_name) : null
	data["everyone"] = everyone
	return data
