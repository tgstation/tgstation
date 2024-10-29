
/// Apply our ntnrc client username prefs
/obj/item/modular_computer/pda/update_pda_prefs(client/owner_client)
	. = ..()
	if(isnull(owner_client))
		return

	var/datum/computer_file/program/chatclient/our_chat_client = locate() in stored_files
	if(isnull(our_chat_client))
		return

	var/default_username = owner_client.prefs.read_preference(/datum/preference/name/ntnrc_username)
	if(isnull(default_username))
		return

	our_chat_client.username = default_username
	SSmodular_computers.common_chat.add_client(our_chat_client)
	open_program(null, our_chat_client, FALSE)
	our_chat_client.active_channel = SSmodular_computers.common_chat.id
