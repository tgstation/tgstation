SUBSYSTEM_DEF(http)
	name = "HTTP"
	ss_flags = SS_TICKER | SS_BACKGROUND | SS_NO_INIT // Measure in ticks, but also only run if we have the spare CPU.
	init_stage = INITSTAGE_FIRST
	wait = 1
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY // All the time
	// Assuming for the worst, since only discord is hooked into this for now, but that may change
	/// List of all async HTTP requests in the processing chain
	var/list/datum/http_request/active_async_requests = list()
	/// Variable to define if logging is enabled or not. Disabled by default since we know the requests the server is making. Enable with VV if you need to debug requests
	var/logging_enabled = FALSE
	/// Total requests the SS has processed in a round
	var/total_requests

/datum/controller/subsystem/http/PreInit()
	. = ..()
	rustg_create_async_http_client() // Open the door

/datum/controller/subsystem/http/stat_entry(msg)
	return "[..()] P:[length(active_async_requests)] T:[total_requests]"

/datum/controller/subsystem/http/fire(resumed)
	for(var/r in active_async_requests)
		var/datum/http_request/req = r
		// Check if we are complete
		if(req.is_complete())
			// If so, take it out the processing list
			active_async_requests -= req
			var/datum/http_response/res = req.into_response()

			// If the request has a callback, invoke it.Async of course to avoid choking the SS
			if(req.cb)
				req.cb.InvokeAsync(res)

			// And log the result
			log_response(res, req.id)

/datum/controller/subsystem/http/vv_edit_var(var_name, var_value)
	if(var_name == "logging_enabled" && !check_rights(R_EVERYTHING))
		return FALSE

	. = ..()

/**
 * Async request creator
 *
 * Generates an async request, and adds it to the subsystem's processing list
 * These should be used as they do not lock the entire DD process up as they execute inside their own thread pool inside RUSTG
 */
/datum/controller/subsystem/http/proc/create_async_request(method, url, body = "", list/headers, datum/callback/proc_callback)
	var/datum/http_request/req = new()
	req.prepare(method, url, body, headers)
	if(proc_callback)
		req.cb = proc_callback

	// Begin it and add it to the SS active list
	req.begin_async()
	active_async_requests += req
	total_requests++

	log_request(req)

/**
 * Blocking request creator
 *
 * Generates a blocking request, executes it, logs the info then cleanly returns the response
 * Uses UNTIL, so is VERY dangerous to use.
 */
/datum/controller/subsystem/http/proc/make_sync_request(method, url, body = "", list/headers)
	var/datum/http_request/req = new()
	req.prepare(method, url, body, headers)
	req.begin_async()
	active_async_requests += req
	total_requests++
	log_request(req)

	UNTIL(req.is_complete())
	active_async_requests -= req
	var/datum/http_response/res = req.into_response()
	log_response(res, req.id)
	return res

/datum/http_request
	/// Callback for executing after async requests. Will be called with an argument of [/datum/http_response] as first argument
	var/datum/callback/cb

/datum/controller/subsystem/http/proc/log_request(datum/http_request/req, type = "ASYNC")
	if(!logging_enabled)
		return

	var/list/log_data = list()
	log_data += "REQUEST (ID: [req.id]) ([type])"
	log_data += "\t[uppertext(req.method)] [req.url]"
	log_data += "\tRequest body: [req.body]"
	log_data += "\tRequest headers: [req.headers]"
	logger.Log(LOG_CATEGORY_DEBUG, log_data.Join("\n"))

/datum/controller/subsystem/http/proc/log_response(datum/http_response/res, id)
	if(!logging_enabled)
		return

	var/list/log_data = list()
	log_data += "RESPONSE (ID: [id])"
	if(res.errored)
		log_data += "\t ----- RESPONSE ERROR -----"
		log_data += "\t [res.error]"
	else
		log_data += "\tResponse status code: [res.status_code]"
		log_data += "\tResponse body: [res.body]"
		log_data += "\tResponse headers: [json_encode(res.headers)]"
	logger.Log(LOG_CATEGORY_DEBUG, log_data.Join("\n"))
