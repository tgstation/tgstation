/datum/tgs_api/v5/proc/Bridge(command, list/data)
	if(!data)
		data = list()

	var/single_bridge_request = CreateBridgeRequest(command, data)
	if(length(single_bridge_request) <= DMAPI5_BRIDGE_REQUEST_LIMIT)
		return PerformBridgeRequest(single_bridge_request)

	// chunking required
	var/payload_id = ++chunked_requests

	var/raw_data = CreateBridgeData(command, data, FALSE)

	var/list/chunk_requests = GenerateChunks(raw_data, TRUE)

	var/list/response
	for(var/bridge_request in chunk_requests)
		response = PerformBridgeRequest(bridge_request)
		if(!response)
			// Abort
			return

	var/list/missing_sequence_ids = response[DMAPI5_MISSING_CHUNKS]
	if(length(missing_sequence_ids))
		do
			TGS_WARNING_LOG("Server is still missing some chunks of bridge P[payload_id]! Sending missing chunks...")
			if(!istype(missing_sequence_ids))
				TGS_ERROR_LOG("Did not receive a list() for [DMAPI5_MISSING_CHUNKS]!")
				return

			for(var/missing_sequence_id in missing_sequence_ids)
				if(!isnum(missing_sequence_id))
					TGS_ERROR_LOG("Did not receive a num in [DMAPI5_MISSING_CHUNKS]!")
					return

				var/missing_chunk_request = chunk_requests[missing_sequence_id + 1]
				response = PerformBridgeRequest(missing_chunk_request)
				if(!response)
					// Abort
					return

			missing_sequence_ids = response[DMAPI5_MISSING_CHUNKS]
		while(length(missing_sequence_ids))

	return response

/datum/tgs_api/v5/proc/CreateBridgeRequest(command, list/data)
	var/json = CreateBridgeData(command, data, TRUE)
	var/encoded_json = url_encode(json)

	var/api_prefix = interop_version.minor >= 8 ? "api/" : ""

	var/url = "http://127.0.0.1:[server_port]/[api_prefix]Bridge?[DMAPI5_BRIDGE_DATA]=[encoded_json]"
	return url

/datum/tgs_api/v5/proc/CreateBridgeData(command, list/data, needs_auth)
	data[DMAPI5_BRIDGE_PARAMETER_COMMAND_TYPE] = command
	if(needs_auth)
		data[DMAPI5_PARAMETER_ACCESS_IDENTIFIER] = access_identifier

	var/json = json_encode(data)
	return json

/datum/tgs_api/v5/proc/WaitForReattach(require_channels = FALSE)
	if(detached)
		// Wait up to one minute
		for(var/i in 1 to 600)
			sleep(world.tick_lag)
			if(!detached && (!require_channels || length(chat_channels)))
				break

			// dad went out for milk and cigarettes 20 years ago...
			// yes, this affects all other waiters, intentional
			if(i == 600)
				detached = FALSE

/datum/tgs_api/v5/proc/PerformBridgeRequest(bridge_request)
	WaitForReattach(FALSE)

	TGS_DEBUG_LOG("Bridge request start")
	var/datum/tgs_http_result/result = http_handler.PerformGet(bridge_request)
	TGS_DEBUG_LOG("Bridge request complete")

	if(isnull(result))
		TGS_ERROR_LOG("Failed bridge request, handler returned null!")
		return

	if(!istype(result) || result.type != /datum/tgs_http_result)
		TGS_ERROR_LOG("Failed bridge request, handler returned non-[/datum/tgs_http_result]!")
		return

	if(!result.success)
		TGS_DEBUG_LOG("Failed bridge request, HTTP request failed!")
		return

	var/list/bridge_response = json_decode(result.response_text)
	if(!bridge_response)
		TGS_ERROR_LOG("Failed bridge request, bad json: [result.response_text]")
		return

	var/error = bridge_response[DMAPI5_RESPONSE_ERROR_MESSAGE]
	if(error)
		TGS_ERROR_LOG("Failed bridge request, bad request: [error]")
		return

	return bridge_response
