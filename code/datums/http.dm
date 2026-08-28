/datum/http_request
	var/id
	var/in_progress = FALSE

	var/method
	var/body
	var/headers
	var/url
	/// If present response body will be saved to this file.
	var/output_file

	/// If present request will timeout after this duration
	var/timeout_seconds

	var/_raw_response

/datum/http_request/proc/prepare(method, url, body = "", list/headers, output_file, timeout_seconds)
	if (!length(headers))
		headers = ""
	else
		headers = json_encode(headers)

	src.method = method
	src.url = url
	src.body = body
	src.headers = headers
	src.output_file = output_file
	src.timeout_seconds = timeout_seconds

/datum/http_request/proc/fire_and_forget()
	var/result = rustg_http_request_fire_and_forget(method, url, body, headers, build_options())
	if(result != "ok")
		CRASH("[result]")

/datum/http_request/proc/execute_blocking()
	_raw_response = rustg_http_request_blocking(method, url, body, headers, build_options())

/datum/http_request/proc/begin_async()
	if (in_progress)
		CRASH("Attempted to re-use a request object.")

	id = rustg_http_request_async(method, url, body, headers, build_options())

	if (isnull(text2num(id)))
		_raw_response = "Proc error: [id]"
		CRASH("Proc error: [id]")
	else
		in_progress = TRUE

/datum/http_request/proc/build_options()
	return json_encode(list(
		"output_filename" = output_file ? output_file : null,
		"body_filename" = null,
		"timeout_seconds" = timeout_seconds ? timeout_seconds : null,
	))

/datum/http_request/proc/is_complete()
	if (isnull(id))
		return TRUE

	if (!in_progress)
		return TRUE

	var/response = rustg_http_check_request(id)

	if (response == RUSTG_JOB_NO_RESULTS_YET)
		return FALSE
	else
		_raw_response = response
		in_progress = FALSE
		return TRUE

/datum/http_request/proc/into_response() as /datum/http_response
	var/datum/http_response/response = new

	try
		var/list/response_data = json_decode(_raw_response)
		response.status_code = response_data["status_code"]
		response.headers = response_data["headers"]
		response.body = response_data["body"]
	catch
		response.errored = TRUE
		response.error = _raw_response

	return response

/datum/http_response
	var/status_code
	var/body
	var/list/headers

	var/errored = FALSE
	var/error

/datum/http_response/serialize_list(list/options, list/semvers)
	. = ..()
	.["status_code"] = status_code
	.["body"] = body
	.["headers"] = headers

	.["errored"] = errored
	.["error"] = error
	return .
