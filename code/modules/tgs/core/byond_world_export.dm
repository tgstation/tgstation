/datum/tgs_http_handler/byond_world_export

/datum/tgs_http_handler/byond_world_export/PerformGet(url)
	// This is an infinite sleep until we get a response
	var/export_response = world.Export(url)
	TGS_DEBUG_LOG("byond_world_export: Export complete")

	if(!export_response)
		TGS_ERROR_LOG("byond_world_export: Failed request: [url]")
		return new /datum/tgs_http_result(null, FALSE)

	var/content = export_response["CONTENT"]
	if(!content)
		TGS_ERROR_LOG("byond_world_export: Failed request, missing content!")
		return new /datum/tgs_http_result(null, FALSE)

	var/response_json = TGS_FILE2TEXT_NATIVE(content)
	if(!response_json)
		TGS_ERROR_LOG("byond_world_export: Failed request, failed to load content!")
		return new /datum/tgs_http_result(null, FALSE)

	return new /datum/tgs_http_result(response_json, TRUE)
