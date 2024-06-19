/// A list of all active and visible messengers
GLOBAL_LIST_EMPTY_TYPED(pda_messengers, /datum/computer_file/program/messenger)

/// Registers an NTMessenger instance to the list of pda_messengers.
/proc/add_messenger(datum/computer_file/program/messenger/messenger)
	var/obj/item/modular_computer/messenger_device = messenger.computer
	// a bunch of empty PDAs are normally allocated, we don't want that clutter
	if(!messenger_device.saved_identification || !messenger_device.saved_job)
		return

	if(!istype(messenger))
		return

	var/messenger_ref = REF(messenger)
	if(messenger_ref in GLOB.pda_messengers)
		return

	GLOB.pda_messengers[messenger_ref] = messenger

/// Unregisters an NTMessenger instance from the pda_messengers table.
/proc/remove_messenger(datum/computer_file/program/messenger/messenger)
	if(!istype(messenger))
		return

	var/messenger_ref = REF(messenger)
	if(!(messenger_ref in GLOB.pda_messengers))
		return

	GLOB.pda_messengers.Remove(messenger_ref)

/// Gets all messengers, sorted by their name
/proc/get_messengers_sorted_by_name()
	return sortTim(GLOB.pda_messengers.Copy(), GLOBAL_PROC_REF(cmp_pdaname_asc), associative = TRUE)

/// Gets all messengers, sorted by their job
/proc/get_messengers_sorted_by_job()
	return sortTim(GLOB.pda_messengers.Copy(), GLOBAL_PROC_REF(cmp_pdajob_asc), associative = TRUE)

/// Get the display name of a messenger instance
/proc/get_messenger_name(datum/computer_file/program/messenger/messenger)
	if(!istype(messenger))
		return null
	var/obj/item/modular_computer/computer = messenger.computer
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
	var/list/datum/pda_message/messages = list()
	/// Used to determine if we should show this in recents
	var/visible_in_recents = FALSE
	/// Used to determine if you can talk in a chat
	var/can_reply = TRUE
	/// Saved draft of a message so the sender can leave and come back later
	var/message_draft = ""
	/// Number of unread messages in this chat
	var/unread_messages = 0

/datum/pda_chat/New(datum/computer_file/program/messenger/recipient)
	src.recipient = WEAKREF(recipient)
	src.can_reply = !isnull(recipient)

/// Adds a message to the chat log and optionally shows the chat in recents.
/// Call this instead of adding to messages directly.
/datum/pda_chat/proc/add_message(datum/pda_message/message, show_in_recents = TRUE)
	messages += message
	if(!visible_in_recents && show_in_recents)
		visible_in_recents = TRUE
	return message

/// Returns this datum as an associative list, used for ui_data calls.
/datum/pda_chat/proc/get_ui_data(mob/user)
	var/list/data = list()

	var/list/recipient_data = list()

	recipient_data["name"] = get_recipient_name()
	recipient_data["job"] = get_recipient_job()
	recipient_data["ref"] = recipient?.reference

	data["ref"] = REF(src)
	data["recipient"] = recipient_data

	var/list/messages_data = list()
	for(var/datum/pda_message/message as anything in messages)
		messages_data += list(message.get_ui_data(user))
	data["messages"] = messages_data
	data["message_draft"] = message_draft

	data["visible"] = visible_in_recents
	data["can_reply"] = can_reply
	data["unread_messages"] = unread_messages

	return data

/// Returns the messenger's name, caches the name in case the recipient becomes invalid later.
/datum/pda_chat/proc/get_recipient_name()
	var/datum/computer_file/program/messenger/messenger = recipient?.resolve()
	if(istype(messenger) && (recipient.reference in GLOB.pda_messengers))
		cached_name = messenger.computer.saved_identification
	return cached_name

/// Returns the messenger's job, caches the job in case the recipient becomes invalid later.
/datum/pda_chat/proc/get_recipient_job()
	var/datum/computer_file/program/messenger/messenger = recipient?.resolve()
	if(istype(messenger) && (recipient.reference in GLOB.pda_messengers))
		cached_job = messenger.computer.saved_job
	return cached_job

/**
 * Chat message data type, stores data about messages themselves.
 */
/datum/pda_message
	/// The message itself.
	var/message
	/// Whether the message is sent by the user or not.
	var/outgoing
	/// The name of the photo asset in the SSassets cache, the URL of which is sent to the client.
	var/photo_name
	/// Whether this message was sent to everyone.
	var/everyone
	/// The station time at which this message was made.
	var/timestamp

/datum/pda_message/New(message, outgoing, timestamp, photo_name = null, everyone = FALSE)
	src.message = message
	src.outgoing = outgoing
	src.timestamp = timestamp
	src.photo_name = photo_name
	src.everyone = everyone

/// Returns an associative list of the message's data, used for ui_data calls.
/datum/pda_message/proc/get_ui_data(mob/user)
	var/list/data = list()
	data["message"] = message
	data["outgoing"] = outgoing
	data["photo_path"] = photo_name ? SSassets.transport.get_asset_url(photo_name) : null
	data["everyone"] = everyone
	data["timestamp"] = timestamp
	return data
