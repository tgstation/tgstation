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

	var/initialized = FALSE

/datum/tgs_api/v5/ApiVersion()
	return new /datum/tgs_version(
		#include "interop_version.dm"
	)

/datum/tgs_api/v5/OnWorldNew(minimum_required_security_level)
	server_port = world.params[DMAPI5_PARAM_SERVER_PORT]
	access_identifier = world.params[DMAPI5_PARAM_ACCESS_IDENTIFIER]

	var/datum/tgs_version/api_version = ApiVersion()
	version = null
	var/list/bridge_response = Bridge(DMAPI5_BRIDGE_COMMAND_STARTUP, list(DMAPI5_BRIDGE_PARAMETER_MINIMUM_SECURITY_LEVEL = minimum_required_security_level, DMAPI5_BRIDGE_PARAMETER_VERSION = api_version.raw_parameter, DMAPI5_PARAMETER_CUSTOM_COMMANDS = ListCustomCommands()))
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

	version = new /datum/tgs_version(runtime_information[DMAPI5_RUNTIME_INFORMATION_SERVER_VERSION])
	security_level = runtime_information[DMAPI5_RUNTIME_INFORMATION_SECURITY_LEVEL]
	instance_name = runtime_information[DMAPI5_RUNTIME_INFORMATION_INSTANCE_NAME]

	var/list/revisionData = runtime_information[DMAPI5_RUNTIME_INFORMATION_REVISION]
	if(istype(revisionData))
		revision = new
		revision.commit = revisionData[DMAPI5_REVISION_INFORMATION_COMMIT_SHA]
		revision.timestamp = revisionData[DMAPI5_REVISION_INFORMATION_TIMESTAMP]
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
				tm.timestamp = entry[DMAPI5_REVISION_INFORMATION_TIMESTAMP]
			else
				TGS_WARNING_LOG("Failed to decode [DMAPI5_TEST_MERGE_REVISION] from test merge #[tm.number]!")

			if(!tm.timestamp)
				tm.timestamp = entry[DMAPI5_TEST_MERGE_TIME_MERGED]

			tm.title = entry[DMAPI5_TEST_MERGE_TITLE_AT_MERGE]
			tm.body = entry[DMAPI5_TEST_MERGE_BODY_AT_MERGE]
			tm.url = entry[DMAPI5_TEST_MERGE_URL]
			tm.author = entry[DMAPI5_TEST_MERGE_AUTHOR]
			tm.head_commit = entry[DMAPI5_TEST_MERGE_PULL_REQUEST_REVISION]
			tm.comment = entry[DMAPI5_TEST_MERGE_COMMENT]

			test_merges += tm
	else
		TGS_WARNING_LOG("Failed to decode [DMAPI5_RUNTIME_INFORMATION_TEST_MERGES] from runtime information!")

	chat_channels = list()
	DecodeChannels(runtime_information)

	initialized = TRUE
	return TRUE

/datum/tgs_api/v5/proc/RequireInitialBridgeResponse()
	while(!version)
		sleep(1)

/datum/tgs_api/v5/OnInitializationComplete()
	Bridge(DMAPI5_BRIDGE_COMMAND_PRIME)

/datum/tgs_api/v5/proc/TopicResponse(error_message = null)
	var/list/response = list()
	response[DMAPI5_RESPONSE_ERROR_MESSAGE] = error_message

	return json_encode(response)

/datum/tgs_api/v5/OnTopic(T)
	var/list/params = params2list(T)
	var/json = params[DMAPI5_TOPIC_DATA]
	if(!json)
		return FALSE // continue to /world/Topic

	var/list/topic_parameters = json_decode(json)
	if(!topic_parameters)
		return TopicResponse("Invalid topic parameters json!");

	if(!initialized)
		TGS_WARNING_LOG("Missed topic due to not being initialized: [T]")
		return TRUE	// too early to handle, but it's still our responsibility

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
				return TopicResponse("Invalid [DMAPI5_TOPIC_PARAMETER_EVENT_NOTIFICATION]!")

			var/event_type = event_notification[DMAPI5_EVENT_NOTIFICATION_TYPE]
			if(!isnum(event_type))
				return TopicResponse("Invalid or missing [DMAPI5_EVENT_NOTIFICATION_TYPE]!")

			var/list/event_parameters = event_notification[DMAPI5_EVENT_NOTIFICATION_PARAMETERS]
			if(event_parameters && !istype(event_parameters))
				return TopicResponse("Invalid or missing [DMAPI5_EVENT_NOTIFICATION_PARAMETERS]!")

			var/list/event_call = list(event_type)
			if(event_parameters)
				event_call += event_parameters

			if(event_handler != null)
				event_handler.HandleEvent(arglist(event_call))

			var/list/response = list()
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

			if(event_handler != null)
				event_handler.HandleEvent(TGS_EVENT_INSTANCE_RENAMED, new_instance_name)

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
		if(DMAPI5_TOPIC_COMMAND_HEARTBEAT)
			return TopicResponse()
		if(DMAPI5_TOPIC_COMMAND_WATCHDOG_REATTACH)
			var/new_port = topic_parameters[DMAPI5_TOPIC_PARAMETER_NEW_PORT]
			var/error_message = null
			if (new_port != null)
				if (!isnum(new_port) || !(new_port > 0))
					error_message = "Invalid [DMAPI5_TOPIC_PARAMETER_NEW_PORT]]"
				else
					server_port = new_port

			var/new_version_string = topic_parameters[DMAPI5_TOPIC_PARAMETER_NEW_SERVER_VERSION]
			if (!istext(new_version_string))
				if(error_message != null)
					error_message += ", "
				error_message += "Invalid or missing [DMAPI5_TOPIC_PARAMETER_NEW_SERVER_VERSION]]"
			else
				var/datum/tgs_version/new_version = new(new_version_string)
				if (event_handler)
					event_handler.HandleEvent(TGS_EVENT_WATCHDOG_REATTACH, new_version)

				version = new_version

			return json_encode(list(DMAPI5_RESPONSE_ERROR_MESSAGE = error_message, DMAPI5_PARAMETER_CUSTOM_COMMANDS = ListCustomCommands()))

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
	RequireInitialBridgeResponse()
	return instance_name

/datum/tgs_api/v5/TestMerges()
	RequireInitialBridgeResponse()
	return test_merges.Copy()

/datum/tgs_api/v5/EndProcess()
	Bridge(DMAPI5_BRIDGE_COMMAND_KILL)

/datum/tgs_api/v5/Revision()
	RequireInitialBridgeResponse()
	return revision

/datum/tgs_api/v5/ChatBroadcast(message, list/channels)
	if(!length(channels))
		channels = ChatChannelInfo()

	var/list/ids = list()
	for(var/I in channels)
		var/datum/tgs_chat_channel/channel = I
		ids += channel.id

	message = list(DMAPI5_CHAT_MESSAGE_TEXT = message, DMAPI5_CHAT_MESSAGE_CHANNEL_IDS = ids)
	if(intercepted_message_queue)
		intercepted_message_queue += list(message)
	else
		Bridge(DMAPI5_BRIDGE_COMMAND_CHAT_SEND, list(DMAPI5_BRIDGE_PARAMETER_CHAT_MESSAGE = message))

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
		Bridge(DMAPI5_BRIDGE_COMMAND_CHAT_SEND, list(DMAPI5_BRIDGE_PARAMETER_CHAT_MESSAGE = message))

/datum/tgs_api/v5/ChatPrivateMessage(message, datum/tgs_chat_user/user)
	message = list(DMAPI5_CHAT_MESSAGE_TEXT = message, DMAPI5_CHAT_MESSAGE_CHANNEL_IDS = list(user.channel.id))
	if(intercepted_message_queue)
		intercepted_message_queue += list(message)
	else
		Bridge(DMAPI5_BRIDGE_COMMAND_CHAT_SEND, list(DMAPI5_BRIDGE_PARAMETER_CHAT_MESSAGE = message))

/datum/tgs_api/v5/ChatChannelInfo()
	RequireInitialBridgeResponse()
	return chat_channels.Copy()

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
	RequireInitialBridgeResponse()
	return security_level
