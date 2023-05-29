/datum/tgs_api/v5/proc/GenerateChunks(payload, bridge)
	var/limit = bridge ? DMAPI5_BRIDGE_REQUEST_LIMIT : DMAPI5_TOPIC_RESPONSE_LIMIT

	var/payload_id = ++chunked_requests
	var/data_length = length(payload)

	var/chunk_count
	var/list/chunk_requests
	for(chunk_count = 2; !chunk_requests; ++chunk_count)
		var/max_chunk_size = -round(-(data_length / chunk_count))
		if(max_chunk_size > limit)
			continue

		chunk_requests = list()
		for(var/i in 1 to chunk_count)
			var/start_index = 1 + ((i - 1) * max_chunk_size)
			if (start_index > data_length)
				break

			var/end_index = min(1 + (i * max_chunk_size), data_length + 1)

			var/chunk_payload = copytext(payload, start_index, end_index)

			// sequence IDs in interop chunking are always zero indexed
			var/list/chunk = list(DMAPI5_CHUNK_PAYLOAD_ID = payload_id, DMAPI5_CHUNK_SEQUENCE_ID = (i - 1), DMAPI5_CHUNK_TOTAL = chunk_count, DMAPI5_CHUNK_PAYLOAD = chunk_payload)

			var/chunk_request = list(DMAPI5_CHUNK = chunk)
			var/chunk_length
			if(bridge)
				chunk_request = CreateBridgeRequest(DMAPI5_BRIDGE_COMMAND_CHUNK, chunk_request)
				chunk_length = length(chunk_request)
			else
				chunk_request = list(chunk_request) // wrap for adding to list
				chunk_length = length(json_encode(chunk_request))

			if(chunk_length > limit)
				// Screwed by encoding, no way to preempt it though
				chunk_requests = null
				break

			chunk_requests += chunk_request

	return chunk_requests
