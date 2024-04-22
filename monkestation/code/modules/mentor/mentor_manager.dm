/// Verb for opening the requests manager panel
/client/proc/mentor_requests()
	set name = "Mentor Manager"
	set desc = "Open the mentor manager panel to view all requests during this round"
	set category = "Mentor"
	SSblackbox.record_feedback("tally", "mentor_verb", 1, "Mentor Manager") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	GLOB.mentor_requests.ui_interact(usr)

GLOBAL_DATUM_INIT(mentor_requests, /datum/request_manager/mentor, new)

/datum/request_manager/mentor/ui_state(mob/user)
	return GLOB.always_state

/datum/request_manager/mentor/pray(client/C, message, is_chaplain)
	return

/datum/request_manager/mentor/message_centcom(client/C, message)
	return

/datum/request_manager/mentor/message_syndicate(client/C, message)
	return

/datum/request_manager/mentor/nuke_request(client/C, message)
	return

/datum/request_manager/mentor/proc/mentorhelp(client/C, message)
	var/msg = copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN)
	request_for_client(C, REQUEST_MENTORHELP, msg)

/datum/request_manager/mentor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "RequestManagerMonke")
		ui.open()

/datum/request_manager/mentor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	// Only admins should be sending actions
	if (!(usr.client in GLOB.mentors))
		to_chat(usr, "You do not have permission to do this.", confidential = TRUE)
		return

	// Get the request this relates to
	var/id = params["id"] != null ? num2text(params["id"]) : null
	if (!id)
		to_chat(usr, "Failed to find a request ID in your action, please report this", confidential = TRUE)
		CRASH("Received an action without a request ID, this shouldn't happen!")
	var/datum/request/request = !id ? null : requests_by_id[id]
	if(isnull(request))
		return

	switch(action)
		if ("reply")
			var/mob/M = request.owner?.mob
			usr.client.cmd_mentor_pm(M)
			return TRUE
		if ("follow")
			var/mob/M = request.owner?.mob
			usr.client.mentor_follow(M)
			return TRUE
	return ..()

/datum/request_manager/mentor/ui_data(mob/user)
	. = list(
		"requests" = list()
	)
	for (var/ckey in requests)
		for (var/datum/request/request as anything in requests[ckey])
			if(request.req_type != REQUEST_MENTORHELP)
				continue
			var/list/data = list(
				"id" = request.id,
				"req_type" = request.req_type,
				"owner" = request.owner ? "[REF(request.owner)]" : null,
				"owner_ckey" = request.owner_ckey,
				"owner_name" = request.owner_name,
				"message" = request.message,
				"timestamp" = request.timestamp,
				"timestamp_str" = gameTimestamp(wtime = request.timestamp)
			)
			.["requests"] += list(data)
