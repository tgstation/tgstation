/datum/tgs_api/v5
	var/server_port
	var/access_identifier

	var/instance_name
	var/security_level

	var/reboot_mode = TGS_REBOOT_MODE_NORMAL

	var/list/intercepted_message_queue

	var/list/custom_commands

	var/list/test_merges
	var/datum/tgs_revision_information/revision
	var/list/chat_channels

	var/datum/tgs_event_handler/event_handler

/datum/tgs_api/v5/ApiVersion()
	return "5.0.0"

/datum/tgs_api/v5/OnWorldNew(datum/tgs_event_handler/event_handler, minimum_required_security_level)
	src.event_handler = event_handler

	server_port = world.params[DMAPI5_PARAM_SERVER_PORT]
	access_identifier = world.params[DMAPI5_PARAM_ACCESS_IDENTIFIER]

	var/list/bridge_response = Bridge(DMAPI5_BRIDGE_COMMAND_STARTUP, list(DMAPI5_BRIDGE_PARAMETER_MINIMUM_SECURITY_LEVEL = minimum_required_security_level, DMAPI5_BRIDGE_PARAMETER_VERSION = ApiVersion(), DMAPI5_BRIDGE_PARAMETER_CUSTOM_COMMANDS = ListCustomCommands()))
	if(!istype(bridge_response))
		TGS_ERROR_LOG("Failed initial bridge request!")
		return FALSE

	var/list/runtime_information = bridge_response[DMAPI5_BRIDGE_RESPONSE_RUNTIME_INFORMATION]
	if(!istype(runtime_information))
		TGS_ERROR_LOG("Failed to decode runtime information from bridge response: [json_encode(bridge_response)]!")
		return FALSE

	if(runtime_information[DMAPI5_RUNTIME_INFORMATION_API_VALIDATE_ONLY])
		TGS_INFO_LOG("DMAPI validation, exiting...")
		del(world)

	security_level = runtime_information[DMAPI5_RUNTIME_INFORMATION_SECURITY_LEVEL]
	instance_name = runtime_information[DMAPI5_RUNTIME_INFORMATION_INSTANCE_NAME]

	var/list/revisionData = runtime_information[DMAPI5_RUNTIME_INFORMATION_REVISION]
	if(istype(revisionData))
		revision = new
		revision.commit = revisionData[DMAPI5_REVISION_INFORMATION_COMMIT_SHA]
		revision.origin_commit = revisionData[DMAPI5_REVISION_INFORMATION_ORIGIN_COMMIT_SHA]
	else
		TGS_ERROR_LOG("Failed to decode [DMAPI5_RUNTIME_INFORMATION_REVISION] from runtime information!")

	test_merges = list()
	var/list/test_merge_json = runtime_information[DMAPI5_RUNTIME_INFORMATION_TEST_MERGES]
	if(istype(test_merge_json))
		for(var/entry in test_merge_json)
			var/datum/tgs_revision_information/test_merge/tm = new
			tm.number = entry[DMAPI5_TEST_MERGE_NUMBER]

			var/list/revInfo = entry[DMAPI5_TEST_MERGE_REVISION]
			if(revInfo)
				tm.commit = revisionData[DMAPI5_REVISION_INFORMATION_COMMIT_SHA]
				tm.origin_commit = revisionData[DMAPI5_REVISION_INFORMATION_ORIGIN_COMMIT_SHA]
			else
				TGS_WARNING_LOG("Failed to decode [DMAPI5_TEST_MERGE_REVISION] from test merge #[tm.number]!")

			tm.time_merged = text2num(entry[DMAPI5_TEST_MERGE_TIME_MERGED])
			tm.title = entry[DMAPI5_TEST_MERGE_TITLE_AT_MERGE]
			tm.body = entry[DMAPI5_TEST_MERGE_BODY_AT_MERGE]
			tm.url = entry[DMAPI5_TEST_MERGE_URL]
			tm.author = entry[DMAPI5_TEST_MERGE_AUTHOR]
			tm.pull_request_commit = entry[DMAPI5_TEST_MERGE_PULL_REQUEST_REVISION]
			tm.comment = entry[DMAPI5_TEST_MERGE_COMMENT]

			test_merges += tm
	else
		TGS_WARNING_LOG("Failed to decode [DMAPI5_RUNTIME_INFORMATION_TEST_MERGES] from runtime information!")

	chat_channels = list()
	DecodeChannels(runtime_information)

	return TRUE

/datum/tgs_api/v5/OnInitializationComplete()
	Bridge(DMAPI5_BRIDGE_COMMAND_PRIME)

	var/tgs4_secret_sleep_offline_sauce = 29051994
	var/old_sleep_offline = world.sleep_offline
	world.sleep_offline = tgs4_secret_sleep_offline_sauce
	sleep(1)
	if(world.sleep_offline == tgs4_secret_sleep_offline_sauce)	//if not someone changed it
		world.sleep_offline = old_sleep_offline

/datum/tgs_api/v5/proc/TopicResponse(error_message = null)
	var/list/response = list()
	if(error_message)
		response[DMAPI5_RESPONSE_ERROR_MESSAGE] = error_message

	return json_encode(response)

/datum/tgs_api/v5/OnTopic(T)
	var/list/params = params2list(T)
	var/json = params[DMAPI5_TOPIC_DATA]
	if(!json)
		return FALSE	//continue world/Topic

	var/list/topic_parameters = json_decode(json)
	if(!topic_parameters)
		return TopicResponse("Invalid topic parameters json!");

	var/their_sCK = topic_parameters[DMAPI5_PARAMETER_ACCESS_IDENTIFIER]
	if(their_sCK != access_identifier)
		return TopicResponse("Failed to decode [DMAPI5_PARAMETER_ACCESS_IDENTIFIER] from: [json]!");

	var/command = topic_parameters[DMAPI5_TOPIC_PARAMETER_COMMAND_TYPE]
	if(!isnum(command))
		return TopicResponse("Failed to decode [DMAPI5_TOPIC_PARAMETER_COMMAND_TYPE] from: [json]!")

	switch(command)
		if(DMAPI5_TOPIC_COMMAND_CHAT_COMMAND)
			var/result = HandleCustomCommand(topic_parameters[DMAPI5_TOPIC_PARAMETER_CHAT_COMMAND])
			if(!result)
				result = TopicResponse("Error running chat command!")
			return result
		if(DMAPI5_TOPIC_COMMAND_EVENT_NOTIFICATION)
			intercepted_message_queue = list()
			var/list/event_notification = topic_parameters[DMAPI5_TOPIC_PARAMETER_EVENT_NOTIFICATION]
			if(!istype(event_notification))
				return TopicResponse("Invalid or missing [DMAPI5_TOPIC_PARAMETER_EVENT_NOTIFICATION]!")

			var/event_type = event_notification[DMAPI5_EVENT_NOTIFICATION_TYPE]
			if(!isnum(event_type))
				return TopicResponse("Invalid or missing [DMAPI5_EVENT_NOTIFICATION_TYPE]!")

			var/list/event_parameters = event_notification[DMAPI5_EVENT_NOTIFICATION_PARAMETERS]
			if(!istype(event_parameters))
				return TopicResponse("Invalid or missing [DMAPI5_EVENT_NOTIFICATION_PARAMETERS]!")

			var/list/event_call = list(event_type)
			if(event_parameters)
				event_call += event_parameters

			if(event_handler != null)
				event_handler.HandleEvent(arglist(event_call))

			var/list/response = list()
			if(intercepted_message_queue.len)
				response[DMAPI5_TOPIC_RESPONSE_CHAT_RESPONSES] = intercepted_message_queue
			intercepted_message_queue = null
			return json_encode(response)
		if(DMAPI5_TOPIC_COMMAND_CHANGE_PORT)
			var/new_port = topic_parameters[DMAPI5_TOPIC_PARAMETER_NEW_PORT]
			if (!isnum(new_port) || !(new_port > 0))
				return TopicResponse("Invalid or missing [DMAPI5_TOPIC_PARAMETER_NEW_PORT]]")

			if(event_handler != null)
				event_handler.HandleEvent(TGS_EVENT_PORT_SWAP, new_port)

			//the topic still completes, miraculously
			//I honestly didn't believe byond could do it without exploding
			if(!world.OpenPort(new_port))
				return TopicResponse("Port change failed!")

			return TopicResponse()
		if(DMAPI5_TOPIC_COMMAND_CHANGE_REBOOT_STATE)
			var/new_reboot_mode = topic_parameters[DMAPI5_TOPIC_PARAMETER_NEW_REBOOT_STATE]
			if(!isnum(new_reboot_mode))
				return TopicResponse("Invalid or missing [DMAPI5_TOPIC_PARAMETER_NEW_REBOOT_STATE]!")

			if(event_handler != null)
				event_handler.HandleEvent(TGS_EVENT_REBOOT_MODE_CHANGE, reboot_mode, new_reboot_mode)

			reboot_mode = new_reboot_mode
			return TopicResponse()
		if(DMAPI5_TOPIC_COMMAND_INSTANCE_RENAMED)
			var/new_instance_name = topic_parameters[DMAPI5_TOPIC_PARAMETER_NEW_INSTANCE_NAME]
			if(!istext(new_instance_name))
				return TopicResponse("Invalid or missing [DMAPI5_TOPIC_PARAMETER_NEW_INSTANCE_NAME]!")

			instance_name = new_instance_name
			return TopicResponse()
		if(DMAPI5_TOPIC_COMMAND_CHAT_CHANNELS_UPDATE)
			var/list/chat_update_json = topic_parameters[DMAPI5_TOPIC_PARAMETER_CHAT_UPDATE]
			if(!istype(chat_update_json))
				return TopicResponse("Invalid or missing [DMAPI5_TOPIC_PARAMETER_CHAT_UPDATE]!")

			DecodeChannels(chat_update_json)
			return TopicResponse()
		if(DMAPI5_TOPIC_COMMAND_SERVER_PORT_UPDATE)
			var/new_port = topic_parameters[DMAPI5_TOPIC_PARAMETER_NEW_PORT]
			if (!isnum(new_port) || !(new_port > 0))
				return TopicResponse("Invalid or missing [DMAPI5_TOPIC_PARAMETER_NEW_PORT]]")

			server_port = new_port
			return TopicResponse()

	return TopicResponse("Unknown command: [command]")

/datum/tgs_api/v5/proc/Bridge(command, list/data)
	if(!data)
		data = list()

	data[DMAPI5_BRIDGE_PARAMETER_COMMAND_TYPE] = command
	data[DMAPI5_PARAMETER_ACCESS_IDENTIFIER] = access_identifier

	var/json = json_encode(data)
	var/encoded_json = url_encode(json)

	// This is an infinite sleep until we get a response
	var/export_response = world.Export("http://127.0.0.1:[server_port]/Bridge?[DMAPI5_BRIDGE_DATA]=[encoded_json]")
	if(!export_response)
		TGS_ERROR_LOG("Failed export request: [json]")
		return

	var/response_json = file2text(export_response["CONTENT"])
	if(!response_json)
		TGS_ERROR_LOG("Failed export request, missing content!")
		return

	var/list/bridge_response = json_decode(response_json)
	if(!bridge_response)
		TGS_ERROR_LOG("Failed export request, bad json: [response_json]")
		return

	var/error = bridge_response[DMAPI5_RESPONSE_ERROR_MESSAGE]
	if(error)
		TGS_ERROR_LOG("Failed export request, bad request: [error]")
		return

	return bridge_response

/datum/tgs_api/v5/OnReboot()
	var/list/result = Bridge(DMAPI5_BRIDGE_COMMAND_REBOOT)
	if(!result)
		return

	//okay so the standard TGS4 proceedure is: right before rebooting change the port to whatever was sent to us in the above json's data parameter

	var/port = result[DMAPI5_BRIDGE_RESPONSE_NEW_PORT]
	if(!isnum(port))
		return	//this is valid, server may just want use to reboot

	if(port == 0)
		//to byond 0 means any port and "none" means close vOv
		port = "none"

	if(!world.OpenPort(port))
		TGS_ERROR_LOG("Unable to set port to [port]!")

/datum/tgs_api/v5/InstanceName()
	return instance_name

/datum/tgs_api/v5/TestMerges()
	return test_merges

/datum/tgs_api/v5/EndProcess()
	Bridge(DMAPI5_BRIDGE_COMMAND_KILL)

/datum/tgs_api/v5/Revision()
	return revision

/datum/tgs_api/v5/ChatBroadcast(message, list/channels)
	var/list/ids
	if(length(channels))
		ids = list()
		for(var/I in channels)
			var/datum/tgs_chat_channel/channel = I
			ids += channel.id
	message = list(DMAPI5_CHAT_MESSAGE_TEXT = message, DMAPI5_CHAT_MESSAGE_CHANNEL_IDS = ids)
	if(intercepted_message_queue)
		intercepted_message_queue += list(message)
	else
		Bridge(DMAPI5_BRIDGE_PARAMETER_CHAT_MESSAGE, message)

/datum/tgs_api/v5/ChatTargetedBroadcast(message, admin_only)
	var/list/channels = list()
	for(var/I in ChatChannelInfo())
		var/datum/tgs_chat_channel/channel = I
		if (!channel.is_private_channel && ((channel.is_admin_channel && admin_only) || (!channel.is_admin_channel && !admin_only)))
			channels += channel.id
	message = list(DMAPI5_CHAT_MESSAGE_TEXT = message, DMAPI5_CHAT_MESSAGE_CHANNEL_IDS = channels)
	if(intercepted_message_queue)
		intercepted_message_queue += list(message)
	else
		Bridge(TGS4_COMM_CHAT, message)

/datum/tgs_api/v5/ChatPrivateMessage(message, datum/tgs_chat_user/user)
	message = list(DMAPI5_CHAT_MESSAGE_TEXT = message, DMAPI5_CHAT_MESSAGE_CHANNEL_IDS = list(user.channel.id))
	if(intercepted_message_queue)
		intercepted_message_queue += list(message)
	else
		Bridge(TGS4_COMM_CHAT, message)

/datum/tgs_api/v5/ChatChannelInfo()
	return chat_channels

/datum/tgs_api/v5/proc/DecodeChannels(chat_update_json)
	var/list/chat_channels_json = chat_update_json[DMAPI5_CHAT_UPDATE_CHANNELS]
	if(istype(chat_channels_json))
		chat_channels.Cut()
		for(var/channel_json in chat_channels_json)
			var/datum/tgs_chat_channel/channel = DecodeChannel(channel_json)
			if(channel)
				chat_channels += channel
	else
		TGS_WARNING_LOG("Failed to decode [DMAPI5_CHAT_UPDATE_CHANNELS] from channel update!")

/datum/tgs_api/v5/proc/DecodeChannel(channel_json)
	var/datum/tgs_chat_channel/channel = new
	channel.id = channel_json[DMAPI5_CHAT_CHANNEL_ID]
	channel.friendly_name = channel_json[DMAPI5_CHAT_CHANNEL_FRIENDLY_NAME]
	channel.connection_name = channel_json[DMAPI5_CHAT_CHANNEL_CONNECTION_NAME]
	channel.is_admin_channel = channel_json[DMAPI5_CHAT_CHANNEL_IS_ADMIN_CHANNEL]
	channel.is_private_channel = channel_json[DMAPI5_CHAT_CHANNEL_IS_PRIVATE_CHANNEL]
	channel.custom_tag = channel_json[DMAPI5_CHAT_CHANNEL_TAG]
	return channel

/datum/tgs_api/v5/SecurityLevel()
	return security_level

/*
The MIT License

Copyright (c) 2020 Jordan Brown

Permission is hereby granted, free of charge,
to any person obtaining a copy of this software and
associated documentation files (the "Software"), to
deal in the Software without restriction, including
without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom
the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice
shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
