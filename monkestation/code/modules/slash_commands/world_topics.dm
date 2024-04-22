/datum/world_topic/status_webhook
	keyword = "status-webhook"
	require_comms_key = TRUE


/datum/world_topic/status_webhook/Run(list/input)
	. = ..()
	var/datum/discord_embed/embed = new()

	embed.title = "Status"
	embed.description = @"[Join Server!](http://play.monkestation.com:7420)"
	embed.author = "Round Controller"

	var/player_count = "**Total**: [length(GLOB.clients)]"
	var/round_state
	switch(SSticker.current_state)
		if(GAME_STATE_STARTUP, GAME_STATE_PREGAME, GAME_STATE_SETTING_UP)
			round_state = "Round has not started"
		if(GAME_STATE_PLAYING)
			round_state = "Round is ongoing."
			if(SSshuttle.emergency.getModeStr())
				round_state += "\n[SSshuttle.emergency.getModeStr()]: [SSshuttle.emergency.getTimerStr()]"
				if(SSticker.emergency_reason)
					round_state += ", Shuttle call reason: [SSticker.emergency_reason]"
		if(GAME_STATE_FINISHED)
			round_state = "Round has ended"

	embed.fields = list(
		"PLAYERS" = player_count,
		"ROUND STATE" = round_state,
		"ROUND ID" = GLOB.round_id,
		"ROUND TIME" = ROUND_TIME(),
	)
	send_bot_webhook(embed)

/proc/send_bot_webhook(message_or_embed)
	var/webhook_url = CONFIG_GET(string/bot_dump_url)
	if(!webhook_url)
		return
	var/list/webhook_info = list()
	if(istext(message_or_embed))
		var/message_content = replacetext(replacetext(message_or_embed, "\proper", ""), "\improper", "")
		message_content = GLOB.has_discord_embeddable_links.Replace(replacetext(message_content, "`", ""), " ```$1``` ")
		webhook_info["content"] = message_content
	else
		var/datum/discord_embed/embed = message_or_embed
		webhook_info["embeds"] = list(embed.convert_to_list())
		if(embed.content)
			webhook_info["content"] = embed.content
	// Uncomment when servers are moved to TGS4
	// send2chat(new /datum/tgs_message_conent("[initiator_ckey] | [message_content]"), "ahelp", TRUE)
	var/list/headers = list()
	headers["Content-Type"] = "application/json"
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, webhook_url, json_encode(webhook_info), headers, "tmp/response.json")
	request.begin_async()

/datum/world_topic/reply_mentor
	keyword = "mentor_reply"
	require_comms_key = TRUE

/datum/world_topic/reply_mentor/Run(list/input)
	var/id = input["ID"]
	logger.Log(LOG_CATEGORY_DEBUG, "ID: [id]", input)
	if(!id)
		logger.Log(LOG_CATEGORY_DEBUG, "NO MENTOR REPLY ID", input)
		return

	var/datum/request_manager/mentor/mentor = GLOB.mentor_requests
	var/datum/request/retrieved = !id ? null : mentor.requests_by_id[id]

	if(!retrieved)
		logger.Log(LOG_CATEGORY_DEBUG, "NO MENTOR DATUM FOUND", input)
		return
	var/mob/M = retrieved.owner?.mob
	webhook_mentor_pm(M, input["from"], id, input["reply_contents"])

/datum/world_topic/reply_mentor/proc/webhook_mentor_pm(mob/reply, from, id, msg)
	if(!reply)
		logger.Log(LOG_CATEGORY_DEBUG, "NO REPLIER FOUND")
		return
	var/client/chosen_client = reply.client
	if(!chosen_client)
		logger.Log(LOG_CATEGORY_DEBUG, "NO REPLY CLIENT FOUND")
		return

	to_chat(chosen_client, "<font color='purple'>Mentor PM from-<b>[key_name_mentor(from, chosen_client, TRUE, FALSE, FALSE)]</b>: [msg]</font>")

	var/regular_webhook_url = CONFIG_GET(string/regular_mentorhelp_webhook_url)
	if(regular_webhook_url)
		var/datum/discord_embed/embed = format_mhelp_embed_simple(msg, id, from)
		if(!embed)
			return
		send2mentorchat_webhook(embed, from)
