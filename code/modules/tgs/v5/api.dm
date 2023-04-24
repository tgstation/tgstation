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

	var/chunked_requests = 0
	var/list/chunked_topics = list()

	var/detached = FALSE

/datum/tgs_api/v5/ApiVersion()
	return new /datum/tgs_version(
		#include "__interop_version.dm"
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

/datum/tgs_api/v5/OnTopic(T)
	RequireInitialBridgeResponse()
	var/list/params = params2list(T)
	var/json = params[DMAPI5_TOPIC_DATA]
	if(!json)
		return FALSE // continue to /world/Topic

	if(!initialized)
		TGS_WARNING_LOG("Missed topic due to not being initialized: [json]")
		return TRUE // too early to handle, but it's still our responsibility

	return ProcessTopicJson(json, TRUE)

/datum/tgs_api/v5/OnReboot()
	var/list/result = Bridge(DMAPI5_BRIDGE_COMMAND_REBOOT)
	if(!result)
		return

	//okay so the standard TGS proceedure is: right before rebooting change the port to whatever was sent to us in the above json's data parameter

	var/port = result[DMAPI5_BRIDGE_RESPONSE_NEW_PORT]
	if(!isnum(port))
		return //this is valid, server may just want use to reboot

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

// Common proc b/c it's used by the V3/V4 APIs
/datum/tgs_api/proc/UpgradeDeprecatedChatMessage(datum/tgs_message_content/message)
	if(!istext(message))
		return message

	TGS_WARNING_LOG("Received legacy string when a [/datum/tgs_message_content] was expected. Please audit all calls to TgsChatBroadcast, TgsChatTargetedBroadcast, and TgsChatPrivateMessage to ensure they use the new /datum.")
	return new /datum/tgs_message_content(message)

/datum/tgs_api/v5/ChatBroadcast(datum/tgs_message_content/message, list/channels)
	if(!length(channels))
		channels = ChatChannelInfo()

	var/list/ids = list()
	for(var/I in channels)
		var/datum/tgs_chat_channel/channel = I
		ids += channel.id

	message = UpgradeDeprecatedChatMessage(message)
	message = message._interop_serialize()
	message[DMAPI5_CHAT_MESSAGE_CHANNEL_IDS] = ids
	if(intercepted_message_queue)
		intercepted_message_queue += list(message)
	else
		Bridge(DMAPI5_BRIDGE_COMMAND_CHAT_SEND, list(DMAPI5_BRIDGE_PARAMETER_CHAT_MESSAGE = message))

/datum/tgs_api/v5/ChatTargetedBroadcast(datum/tgs_message_content/message, admin_only)
	var/list/channels = list()
	for(var/I in ChatChannelInfo())
		var/datum/tgs_chat_channel/channel = I
		if (!channel.is_private_channel && ((channel.is_admin_channel && admin_only) || (!channel.is_admin_channel && !admin_only)))
			channels += channel.id

	message = UpgradeDeprecatedChatMessage(message)
	message = message._interop_serialize()
	message[DMAPI5_CHAT_MESSAGE_CHANNEL_IDS] = channels
	if(intercepted_message_queue)
		intercepted_message_queue += list(message)
	else
		Bridge(DMAPI5_BRIDGE_COMMAND_CHAT_SEND, list(DMAPI5_BRIDGE_PARAMETER_CHAT_MESSAGE = message))

/datum/tgs_api/v5/ChatPrivateMessage(datum/tgs_message_content/message, datum/tgs_chat_user/user)
	message = UpgradeDeprecatedChatMessage(message)
	message = message._interop_serialize()
	message[DMAPI5_CHAT_MESSAGE_CHANNEL_IDS] = list(user.channel.id)
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
	channel.embeds_supported = channel_json[DMAPI5_CHAT_CHANNEL_EMBEDS_SUPPORTED]
	return channel

/datum/tgs_api/v5/SecurityLevel()
	RequireInitialBridgeResponse()
	return security_level
