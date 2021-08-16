GLOBAL_DATUM_INIT(requests, /datum/request_manager, new)

/**
 * # Request Manager
 *
 * Handles all player requests (prayers, centcom requests, syndicate requests)
 * that occur in the duration of a round.
 */
/datum/request_manager
	/// Associative list of ckey -> list of requests
	var/list/requests = list()
	/// List where requests can be accessed by ID
	var/list/requests_by_id = list()

/datum/request_manager/Destroy(force, ...)
	QDEL_LIST(requests)
	return ..()

/datum/request_manager/proc/client_login(client/C)
	if (!requests[C.ckey])
		return
	for (var/datum/request/request as anything in requests[C.ckey])
		request.owner = C

/datum/request_manager/proc/client_logout(client/C)
	if (!requests[C.ckey])
		return
	for (var/datum/request/request as anything in requests[C.ckey])
		request.owner = null

/datum/request_manager/proc/pray(client/C, message, is_chaplain)
	request_for_client(C, REQUEST_PRAYER, message)
	for(var/client/C in GLOB.admins)
		if(is_chaplain && C.prefs.chat_toggles & CHAT_PRAYER && C.prefs.toggles & SOUND_PRAYERS)
			SEND_SOUND(C, sound('sound/effects/pray.ogg'))

/datum/request_manager/proc/message_centcom(client/C, message)
	request_for_client(C, REQUEST_CENTCOM, message)

/datum/request_manager/proc/message_syndicate(client/C, message)
	request_for_client(C, REQUEST_SYNDICATE, message)

/datum/request_manager/proc/nuke_request(client/C, message)
	request_for_client(C, REQUEST_NUKE, message)

/datum/request_manager/proc/request_for_client(client/C, type, message)
	var/datum/request/request = new(C, type, message)
	if (!requests[C.ckey])
		requests[C.ckey] = list()
	requests[C.ckey] += request
	requests_by_id.len++
	requests_by_id[request.id] = request

/datum/request_manager/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "RequestManager")
		ui.open()

/datum/request_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/request_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if (..())
		return

	// Only admins should be sending actions
	if (!check_rights(R_ADMIN))
		return

	// Get the request this relates to
	var/id = params["id"] != null ? text2num(params["id"]) : null
	if (!id)
		return
	var/datum/request/request = !id ? null : requests_by_id[id]

	switch(action)
		if ("pp")
			var/mob/M = request.owner?.mob
			usr.client.holder.show_player_panel(M)
		if ("vv")
			var/mob/M = request.owner?.mob
			usr.client.debug_variables(M)
		if ("sm")
			var/mob/M = request.owner?.mob
			usr.client.cmd_admin_subtle_message(M)
		if ("flw")
			var/mob/M = request.owner?.mob
			usr.client.admin_follow(M)
		if ("tp")
			if(!SSticker.HasRoundStarted())
				tgui_alert(usr,"The game hasn't started yet!")
				return
			var/mob/M = request.owner?.mob
			if(!ismob(M))
				var/datum/mind/D = M
				if(!istype(D))
					to_chat(usr, "This can only be used on instances of type /mob and /mind", confidential = TRUE)
					return
				else
					D.traitor_panel()
			else
				usr.client.holder.show_traitor_panel(M)
		if ("logs")
			var/mob/M = request.owner?.mob
			if(!ismob(M))
				to_chat(usr, "This can only be used on instances of type /mob.", confidential = TRUE)
				return
			show_individual_logging_panel(M, null, null)
		if ("smite")
			if(!check_rights(R_FUN))
				return
			var/mob/living/carbon/human/H = request.owner?.mob
			if (!H || !istype(H))
				to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human", confidential = TRUE)
				return
			usr.client.smite(H)
		if ("rply")
			if (request.req_type == REQUEST_PRAYER)
				return
			var/mob/M = request.owner?.mob
			usr.client.admin_headset_message(M, request.req_type == REQUEST_SYNDICATE ? RADIO_CHANNEL_SYNDICATE : RADIO_CHANNEL_CENTCOM)
		if ("setcode")
			if (request.req_type != REQUEST_NUKE)
				return
			var/code = random_nukecode()
			for(var/obj/machinery/nuclearbomb/selfdestruct/SD in GLOB.nuke_list)
				SD.r_code = code
			message_admins("[key_name_admin(usr)] has set the self-destruct code to \"[code]\".")

/datum/request_manager/ui_data(mob/user)
	. = list(
		"requests" = list()
	)
	for (var/ckey in requests)
		for (var/datum/request/request as anything in requests[ckey])
			var/list/data = list(
				"id" = request.id,
				"req_type" = request.req_type,
				"owner" = "[REF(request.owner)]",
				"owner_ckey" = request.owner_ckey,
				"owner_name" = request.owner_name,
				"message" = request.message,
				"timestamp" = request.timestamp,
				"timestamp_str" = gameTimestamp(wtime = request.timestamp)
			)
			.["requests"] += list(data)
