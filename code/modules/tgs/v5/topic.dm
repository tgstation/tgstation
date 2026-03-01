/datum/tgs_api/v5/proc/TopicResponse(error_message = null)
	var/list/response = list()
	if(error_message)
		response[DMAPI5_RESPONSE_ERROR_MESSAGE] = error_message
	return response

/datum/tgs_api/v5/proc/ProcessTopicJson(json, check_access_identifier)
	TGS_DEBUG_LOG("ProcessTopicJson(..., [check_access_identifier])")
	var/list/result = ProcessRawTopic(json, check_access_identifier)
	if(!result)
		result = TopicResponse("Runtime error!")
	else if(!length(result))
		return "{}" // quirk of json_encode is an empty list returns "[]"

	var/response_json = json_encode(result)
	if(length(response_json) > DMAPI5_TOPIC_RESPONSE_LIMIT)
		// cache response chunks and send the first
		var/list/chunks = GenerateChunks(response_json, FALSE)
		var/payload_id = chunks[1][DMAPI5_CHUNK][DMAPI5_CHUNK_PAYLOAD_ID]
		var/cache_key = ResponseTopicChunkCacheKey(payload_id)

		chunked_topics[cache_key] = chunks

		response_json = json_encode(chunks[1])

	return response_json

/datum/tgs_api/v5/proc/ProcessRawTopic(json, check_access_identifier)
	TGS_DEBUG_LOG("ProcessRawTopic(..., [check_access_identifier])")
	var/list/topic_parameters = json_decode(json)
	if(!topic_parameters)
		TGS_DEBUG_LOG("ProcessRawTopic: json_decode failed")
		return TopicResponse("Invalid topic parameters json: [json]!");

	var/their_sCK = topic_parameters[DMAPI5_PARAMETER_ACCESS_IDENTIFIER]
	if(check_access_identifier && their_sCK != access_identifier)
		TGS_DEBUG_LOG("ProcessRawTopic: access identifier check failed")
		return TopicResponse("Failed to decode [DMAPI5_PARAMETER_ACCESS_IDENTIFIER] or it does not match!")

	var/command = topic_parameters[DMAPI5_TOPIC_PARAMETER_COMMAND_TYPE]
	if(!isnum(command))
		TGS_DEBUG_LOG("ProcessRawTopic: command type check failed")
		return TopicResponse("Failed to decode [DMAPI5_TOPIC_PARAMETER_COMMAND_TYPE]!")

	return ProcessTopicCommand(command, topic_parameters)

/datum/tgs_api/v5/proc/ResponseTopicChunkCacheKey(payload_id)
	return "response[payload_id]"

/datum/tgs_api/v5/proc/ProcessTopicCommand(command, list/topic_parameters)
	TGS_DEBUG_LOG("ProcessTopicCommand([command], ...)")
	switch(command)

		if(DMAPI5_TOPIC_COMMAND_CHAT_COMMAND)
			intercepted_message_queue = list()
			var/list/result = HandleCustomCommand(topic_parameters[DMAPI5_TOPIC_PARAMETER_CHAT_COMMAND])
			if(!result)
				result = TopicResponse("Error running chat command!")
			result[DMAPI5_TOPIC_RESPONSE_CHAT_RESPONSES] = intercepted_message_queue
			intercepted_message_queue = null
			return result

		if(DMAPI5_TOPIC_COMMAND_EVENT_NOTIFICATION)
			var/list/event_notification = topic_parameters[DMAPI5_TOPIC_PARAMETER_EVENT_NOTIFICATION]
			if(!istype(event_notification))
				return TopicResponse("Invalid [DMAPI5_TOPIC_PARAMETER_EVENT_NOTIFICATION]!")

			var/event_type = event_notification[DMAPI5_EVENT_NOTIFICATION_TYPE]
			if(!isnum(event_type))
				return TopicResponse("Invalid or missing [DMAPI5_EVENT_NOTIFICATION_TYPE]!")

			var/list/event_parameters = event_notification[DMAPI5_EVENT_NOTIFICATION_PARAMETERS]
			if(event_parameters && !istype(event_parameters))
				. = TopicResponse("Invalid or missing [DMAPI5_EVENT_NOTIFICATION_PARAMETERS]!")
			else
				var/list/response = TopicResponse()
				. = response
				if(event_handler != null)
					var/list/event_call = list(event_type)
					if(event_parameters)
						event_call += event_parameters

					intercepted_message_queue = list()
					event_handler.HandleEvent(arglist(event_call))
					response[DMAPI5_TOPIC_RESPONSE_CHAT_RESPONSES] = intercepted_message_queue
					intercepted_message_queue = null

			if (event_type == TGS_EVENT_WATCHDOG_DETACH)
				detached = TRUE
				chat_channels.Cut() // https://github.com/tgstation/tgstation-server/issues/1490

			return

		if(DMAPI5_TOPIC_COMMAND_CHANGE_PORT)
			var/new_port = topic_parameters[DMAPI5_TOPIC_PARAMETER_NEW_PORT]
			if (!isnum(new_port) || !(new_port > 0))
				return TopicResponse("Invalid or missing [DMAPI5_TOPIC_PARAMETER_NEW_PORT]")

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
			TGS_DEBUG_LOG("ProcessTopicCommand: It's a chat update")
			var/list/chat_update_json = topic_parameters[DMAPI5_TOPIC_PARAMETER_CHAT_UPDATE]
			if(!istype(chat_update_json))
				TGS_DEBUG_LOG("ProcessTopicCommand: failed \"[DMAPI5_TOPIC_PARAMETER_CHAT_UPDATE]\" check")
				return TopicResponse("Invalid or missing [DMAPI5_TOPIC_PARAMETER_CHAT_UPDATE]!")

			DecodeChannels(chat_update_json)
			return TopicResponse()

		if(DMAPI5_TOPIC_COMMAND_SERVER_PORT_UPDATE)
			var/new_port = topic_parameters[DMAPI5_TOPIC_PARAMETER_NEW_PORT]
			if (!isnum(new_port) || !(new_port > 0))
				return TopicResponse("Invalid or missing [DMAPI5_TOPIC_PARAMETER_NEW_PORT]")

			server_port = new_port
			return TopicResponse()

		if(DMAPI5_TOPIC_COMMAND_HEALTHCHECK)
			if(event_handler && event_handler.receive_health_checks)
				event_handler.HandleEvent(TGS_EVENT_HEALTH_CHECK)
			var/list/health_check_response = TopicResponse()
			health_check_response[DMAPI5_TOPIC_RESPONSE_CLIENT_COUNT] = TGS_CLIENT_COUNT
			return health_check_response;

		if(DMAPI5_TOPIC_COMMAND_WATCHDOG_REATTACH)
			detached = FALSE
			var/new_port = topic_parameters[DMAPI5_TOPIC_PARAMETER_NEW_PORT]
			var/error_message = null
			if (new_port != null)
				if (!isnum(new_port) || !(new_port > 0))
					error_message = "Invalid [DMAPI5_TOPIC_PARAMETER_NEW_PORT]"
				else
					server_port = new_port

			var/new_version_string = topic_parameters[DMAPI5_TOPIC_PARAMETER_NEW_SERVER_VERSION]
			if (!istext(new_version_string))
				if(error_message != null)
					error_message += ", "
				error_message += "Invalid or missing [DMAPI5_TOPIC_PARAMETER_NEW_SERVER_VERSION]"
			else
				var/datum/tgs_version/new_version = new(new_version_string)
				if (event_handler)
					event_handler.HandleEvent(TGS_EVENT_WATCHDOG_REATTACH, new_version)

				version = new_version

			var/list/reattach_response = TopicResponse(error_message)
			reattach_response[DMAPI5_PARAMETER_CUSTOM_COMMANDS] = ListCustomCommands()
			reattach_response[DMAPI5_PARAMETER_TOPIC_PORT] = GetTopicPort()

			for(var/eventId in pending_events)
				pending_events[eventId] = TRUE

			return reattach_response

		if(DMAPI5_TOPIC_COMMAND_SEND_CHUNK)
			var/list/chunk = topic_parameters[DMAPI5_CHUNK]
			if(!istype(chunk))
				return TopicResponse("Invalid [DMAPI5_CHUNK]!")

			var/payload_id = chunk[DMAPI5_CHUNK_PAYLOAD_ID]
			if(!isnum(payload_id))
				return TopicResponse("[DMAPI5_CHUNK_PAYLOAD_ID] is not a number!")

			// Always updated the highest known payload ID
			chunked_requests = max(chunked_requests, payload_id)

			var/sequence_id = chunk[DMAPI5_CHUNK_SEQUENCE_ID]
			if(!isnum(sequence_id))
				return TopicResponse("[DMAPI5_CHUNK_SEQUENCE_ID] is not a number!")

			var/total_chunks = chunk[DMAPI5_CHUNK_TOTAL]
			if(!isnum(total_chunks))
				return TopicResponse("[DMAPI5_CHUNK_TOTAL] is not a number!")

			if(total_chunks == 0)
				return TopicResponse("[DMAPI5_CHUNK_TOTAL] is zero!")

			var/payload = chunk[DMAPI5_CHUNK_PAYLOAD]
			if(!istext(payload))
				return TopicResponse("[DMAPI5_CHUNK_PAYLOAD] is not text!")

			var/cache_key = "request[payload_id]"
			var/payloads = chunked_topics[cache_key]

			if(!payloads)
				payloads = new /list(total_chunks)
				chunked_topics[cache_key] = payloads

			if(total_chunks != length(payloads))
				chunked_topics -= cache_key
				return TopicResponse("Received differing total chunks for same [DMAPI5_CHUNK_PAYLOAD_ID]! Invalidating [DMAPI5_CHUNK_PAYLOAD_ID]!")

			var/pre_existing_chunk = payloads[sequence_id + 1]
			if(pre_existing_chunk && pre_existing_chunk != payload)
				chunked_topics -= cache_key
				return TopicResponse("Received differing payload for same [DMAPI5_CHUNK_SEQUENCE_ID]! Invalidating [DMAPI5_CHUNK_PAYLOAD_ID]!")

			payloads[sequence_id + 1] = payload

			var/list/missing_sequence_ids = list()
			for(var/i in 1 to total_chunks)
				if(!payloads[i])
					missing_sequence_ids += i - 1

			if(length(missing_sequence_ids))
				return list(DMAPI5_MISSING_CHUNKS = missing_sequence_ids)

			chunked_topics -= cache_key
			var/full_json = jointext(payloads, "")

			return ProcessRawTopic(full_json, FALSE)

		if(DMAPI5_TOPIC_COMMAND_RECEIVE_CHUNK)
			var/payload_id = topic_parameters[DMAPI5_CHUNK_PAYLOAD_ID]
			if(!isnum(payload_id))
				return TopicResponse("[DMAPI5_CHUNK_PAYLOAD_ID] is not a number!")

			// Always updated the highest known payload ID
			chunked_requests = max(chunked_requests, payload_id)

			var/list/missing_chunks = topic_parameters[DMAPI5_MISSING_CHUNKS]
			if(!istype(missing_chunks) || !length(missing_chunks))
				return TopicResponse("Missing or empty [DMAPI5_MISSING_CHUNKS]!")

			var/sequence_id_to_send = missing_chunks[1]
			if(!isnum(sequence_id_to_send))
				return TopicResponse("[DMAPI5_MISSING_CHUNKS] contained a non-number!")

			var/cache_key = ResponseTopicChunkCacheKey(payload_id)
			var/list/chunks = chunked_topics[cache_key]
			if(!chunks)
				return TopicResponse("Unknown response chunk set: P[payload_id]!")

			// sequence IDs in interop chunking are always zero indexed
			var/chunk_to_send = chunks[sequence_id_to_send + 1]
			if(!chunk_to_send)
				return TopicResponse("Sequence ID [sequence_id_to_send] is not present in response chunk P[payload_id]!")

			if(length(missing_chunks) == 1)
				// sending last chunk, purge the cache
				chunked_topics -= cache_key

			return chunk_to_send

		if(DMAPI5_TOPIC_COMMAND_RECEIVE_BROADCAST)
			var/message = topic_parameters[DMAPI5_TOPIC_PARAMETER_BROADCAST_MESSAGE]
			if (!istext(message))
				return TopicResponse("Invalid or missing [DMAPI5_TOPIC_PARAMETER_BROADCAST_MESSAGE]")

			TGS_WORLD_ANNOUNCE(message)
			return TopicResponse()

		if(DMAPI5_TOPIC_COMMAND_COMPLETE_EVENT)
			var/event_id = topic_parameters[DMAPI5_EVENT_ID]
			if (!istext(event_id))
				return TopicResponse("Invalid or missing [DMAPI5_EVENT_ID]")

			TGS_DEBUG_LOG("Completing event ID [event_id]...")
			pending_events[event_id] = TRUE
			return TopicResponse()

	return TopicResponse("Unknown command: [command]")

/datum/tgs_api/v5/proc/WorldBroadcast(message)
	set waitfor = FALSE
	TGS_WORLD_ANNOUNCE(message)
