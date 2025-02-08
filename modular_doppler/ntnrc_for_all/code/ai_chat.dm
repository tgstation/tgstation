
/// Conversation subtype that doesn't allow for the addition of any single operator. Netadmin mode can still override.
/datum/ntnet_conversation/ai

/// Override to make the AI an operator
/datum/ntnet_conversation/ai/changeop(datum/computer_file/program/chatclient/newop, silent = FALSE)
	var/mob/living/silicon/ai/station_ai

	for(var/mob/living/silicon/ai/ai_player in GLOB.alive_player_list)
		if(!is_station_level(ai_player.z))
			continue
		station_ai = ai_player

	if(!station_ai)
		return // no one to pass operator to

	var/obj/item/modular_computer/pda/silicon/ai_pda = station_ai.modularInterface
	var/datum/computer_file/program/chatclient/ai_chat
	for(var/datum/computer_file/program/chatclient/app_in_stored_files in ai_pda.stored_files)
		ai_chat = app_in_stored_files

	channel_operator = ai_chat
	add_status_message("[ai_chat.username] is the station AI and channel operator.")

/// make the chat app update operators when a new AI is spawned
/datum/job/ai/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	var/datum/ntnet_conversation/ai_channel = SSmodular_computers.get_chat_channel_by_id(1) // the ai channel is loaded on ID '1'
	ai_channel.changeop()
