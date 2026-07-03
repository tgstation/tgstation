/// Doesnt need the panic bunker to work
/mob/dead/new_player/proc/check_whitelist_or_make_interviewee()
	if(!CONFIG_GET(flag/panic_bunker_interview))
		return

	if(!SScentral.can_run())
		stack_trace("Using whitelists and interviews without SS Central is not supported")
		return

	if(SScentral.is_player_whitelisted(ckey))
		client.interviewee = FALSE
		return

	client.interviewee = TRUE

/datum/config_entry/string/interview_webhook_url
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/interview/approve(client/approved_by)
	if(!SScentral.is_player_discord_linked(owner_ckey))
		to_chat(approved_by, span_warning("У игрока не привязана своя учетная запись Discord!"))
		to_chat(owner, span_warning("Ваше интервью не удалось принять по причине: У вас не привязана учетная запись Discord!"))
		log_admin("[key_name(approved_by)] попытался безуспешно принять интервью [owner_ckey]. Причина: Дискорд игрока не привязан.")
		return
	. = ..()
	add_owner_to_whitelist(approved_by)
	send_interview_webhook("[approved_by.ckey] принял:")

/datum/interview_manager/enqueue(datum/interview/to_queue)
	. = ..()
	to_queue.send_interview_webhook("Новое интервью в очереди:")

/datum/interview/deny(client/denied_by)
	. = ..()
	send_interview_webhook("[denied_by.ckey] отказал:")

/datum/interview/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(action != "submit")
		return ..()
	if(!isnull(owner.persistent_client.discord_id))
		return ..()
	SScentral.update_player_discord_async(owner.ckey)
	return TRUE

/datum/interview/proc/serialize_embed()
	. = list(
		"fields" = list(),
		"author" = list(
			"name" = owner_ckey
			),
		"title" = "Интервью",
		"description" = "Дискорд: <@[GLOB.persistent_clients_by_ckey[owner_ckey].discord_id]>"
	)
	for(var/question_id in 1 to length(questions))
		var/list/question_data = list(
			"name" = "[questions[question_id]]",
			"value" = "[isnull(responses[question_id]) ? "N/A" : responses[question_id]]"
		)
		.["fields"] += list(question_data)
	return .

/datum/interview/proc/send_interview_webhook(additional_msg)
	var/webhook = CONFIG_GET(string/interview_webhook_url)
	if(!webhook)
		return
	var/list/webhook_info = list()
	webhook_info["content"] = additional_msg
	webhook_info["embeds"] = list(serialize_embed())
	var/list/headers = list()
	headers["Content-Type"] = "application/json"
	SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, webhook, json_encode(webhook_info), headers)

/datum/interview/proc/add_owner_to_whitelist(client/added_by)
	SScentral.add_to_whitelist(owner_ckey, added_by.ckey, 365)
