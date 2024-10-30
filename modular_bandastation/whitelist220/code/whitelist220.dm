#define CKEY_HAS_VALID_WHITELIST_QUERY {"
			SELECT ckey FROM ckey_whitelist WHERE ckey=:ckey AND
			is_valid=1 AND port=:port AND date_start<=NOW() AND
			(date_end IS NULL OR NOW()<date_end)
	"}

/datum/config_entry/flag/whitelist220
	default = FALSE
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/interview_webhook_url

/world/IsBanned(key, address, computer_id, type, real_bans_only)
	. = ..()
	if(.)
		return .

	if(!CONFIG_GET(flag/whitelist220))
		return null

	/// If interviews are enabled, the player will be processed in `/mob/dead/new_player/Login()`
	/// as `client` is not created on this stage
	if(CONFIG_GET(flag/panic_bunker_interview))
		return null

	var/ckey = ckey(key)
	var/deny_message = list(
		"reason"="whitelist",
		"desc"="\nПричина: Вас ([key]) нет в вайтлисте этого сервера. Приобрести доступ возможно у одного из стримеров Банды за баллы канала или записаться самостоятельно с помощью команды в дискорде, доступной сабам бусти, начиная со второго тира.")

	return is_ckey_whitelisted(ckey) ? null : deny_message

/mob/dead/new_player/proc/check_whitelist_or_make_interviewee()
	if(client.interviewee)
		return

	if(!CONFIG_GET(flag/panic_bunker_interview))
		return

	if(!CONFIG_GET(flag/whitelist220))
		return

	if(is_ckey_whitelisted(ckey))
		return

	client.interviewee = TRUE

/datum/interview/approve(client/approved_by)
	add_owner_to_whitelist(approved_by)
	send_interview_webhook(src, "[approved_by.ckey] approved:")
	. = ..()

/datum/interview_manager/enqueue(datum/interview/to_queue)
	. = ..()
	send_interview_webhook(to_queue, "New interview enqueued:")

/datum/interview/deny(client/denied_by)
	. = ..()
	send_interview_webhook(src, "[denied_by.ckey] denied:")

/datum/interview/proc/serialize_embed()
	. = list(
		"fields" = list(),
		"author" = list(
			"name" = owner_ckey
			)
	)
	for(var/question_id in 1 to length(questions))
		var/list/question_data = list(
			"name" = "[questions[question_id]]",
			"value" = "[isnull(responses[question_id]) ? "N/A" : responses[question_id]]"
		)
		.["fields"] += list(question_data)
	return .

/proc/send_interview_webhook(datum/interview/interview, additional_msg)
	var/webhook = CONFIG_GET(string/interview_webhook_url)
	if(!webhook || !interview)
		return
	var/list/webhook_info = list()
	webhook_info["content"] = additional_msg
	webhook_info["embeds"] = list(interview.serialize_embed())
	var/list/headers = list()
	headers["Content-Type"] = "application/json"
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, webhook, json_encode(webhook_info), headers, "tmp/response.json")
	request.begin_async()

/datum/interview/proc/add_owner_to_whitelist(client/added_by)
	PRIVATE_PROC(TRUE)

	ASSERT(!isnull(added_by), "added_by should not be `null`")

	if(!owner_ckey || !SSdbcore.IsConnected())
		return

	var/datum/db_query/whitelist_query = SSdbcore.NewQuery(
		{"
			INSERT INTO ckey_whitelist (ckey, adminwho, port)
			SELECT :ckey, :adminwho, :port
			WHERE NOT EXISTS ([CKEY_HAS_VALID_WHITELIST_QUERY])
		"},
		list("ckey" = owner_ckey, "adminwho" = added_by?.ckey, "port" = "[world.port]")
	)

	whitelist_query.warn_execute()
	qdel(whitelist_query)

/proc/is_ckey_whitelisted(ckey_to_check)
	if(!ckey_to_check || !SSdbcore.IsConnected())
		return FALSE

	var/datum/db_query/whitelist_query = SSdbcore.NewQuery(
		CKEY_HAS_VALID_WHITELIST_QUERY,
		list("ckey" = ckey_to_check, "port" = "[world.port]")
	)

	if(!whitelist_query.warn_execute())
		qdel(whitelist_query)
		return FALSE

	while(whitelist_query.NextRow())
		if(whitelist_query.item[1])
			qdel(whitelist_query)
			return TRUE

	qdel(whitelist_query)
	return FALSE

#undef CKEY_HAS_VALID_WHITELIST_QUERY
