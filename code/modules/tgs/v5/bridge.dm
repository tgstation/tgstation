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

	var/url = "http://127.0.0.1:[server_port]/Bridge?[DMAPI5_BRIDGE_DATA]=[encoded_json]"
	return url

/datum/tgs_api/v5/proc/CreateBridgeData(command, list/data, needs_auth)
	data[DMAPI5_BRIDGE_PARAMETER_COMMAND_TYPE] = command
	if(needs_auth)
		data[DMAPI5_PARAMETER_ACCESS_IDENTIFIER] = access_identifier

	var/json = json_encode(data)
	return json

/datum/tgs_api/v5/proc/PerformBridgeRequest(bridge_request)
	if(detached)
		// Wait up to one minute
		for(var/i in 1 to 600)
			sleep(1)
			if(!detached)
				break

			// dad went out for milk cigarettes 20 years ago...
			if(i == 600)
				detached = FALSE

	// This is an infinite sleep until we get a response
	var/export_response = world.Export(bridge_request)
	if(!export_response)
		TGS_ERROR_LOG("Failed bridge request: [bridge_request]")
		return

	var/response_json = file2text(export_response["CONTENT"])
	if(!response_json)
		TGS_ERROR_LOG("Failed bridge request, missing content!")
		return

	var/list/bridge_response = json_decode(response_json)
	if(!bridge_response)
		TGS_ERROR_LOG("Failed bridge request, bad json: [response_json]")
		return

	var/error = bridge_response[DMAPI5_RESPONSE_ERROR_MESSAGE]
	if(error)
		TGS_ERROR_LOG("Failed bridge request, bad request: [error]")
		return

	return bridge_response
