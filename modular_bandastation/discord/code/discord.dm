/datum/config_entry/string/discordurl
	default = "https://discord.gg/SS220"

//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/discord()
	set name = "discord"
	set desc = "Visit the discord."
	set hidden = TRUE
	var/discordurl = CONFIG_GET(string/discordurl)
	if(discordurl)
		if(tgui_alert(src, "Это откроет ссылку в вашем браузере. Вы уверены?", "Переход в наш Discord", list("Да", "Нет")) != "Да")
			return
		src << link(discordurl)
	else
		to_chat(src, span_danger("The discord URL is not set in the server configuration."))
	return

/datum/config_entry/string/round_end_webhook_url
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/round_end_webhook_name
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/round_end_webhook_avatar_url
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/round_end_webhook_ping_role_id
	protection = CONFIG_ENTRY_LOCKED

/proc/send_round_end_webhook()
	var/webhook = CONFIG_GET(string/round_end_webhook_url)
	if(!webhook)
		return

	var/role_id = CONFIG_GET(string/round_end_webhook_ping_role_id)
	var/content = role_id ? "<@&[role_id]>" : null

	var/message_content = GLOB.survivor_report

	message_content = rustutils_regex_replace(message_content, "<br>", "i", "\n")
	message_content = rustutils_regex_replace(message_content, "&nbsp;", "i", "")
	message_content = STRIP_HTML_FULL(message_content, 4096)

	var/list/lines = splittext(message_content, "\n")
	for(var/i in 1 to length(lines))
		var/line = lines[i]
		var/delimiter_pos = findtext(line, ": ")
		if(delimiter_pos)
			var/key = copytext(line, 1, delimiter_pos)
			var/value = copytext(line, delimiter_pos + 2)
			lines[i] = "[key]: **[value]**"
	message_content = lines.Join("\n")
	message_content = rustutils_regex_replace(message_content, "\n\n", "i", "\n")

	var/list/embed = list(
		"title" = "Раунд #[GLOB.round_id] закончился",
		"description" = message_content,
		"color" = 5814783, // light blue
		// "timestamp" = rustg_formatted_timestamp_tz("%Y-%m-%d %H:%M:%S%.3f", "+0"),
		"footer" = list(
			"text" = "Round End Report"
		)
	)

	var/list/webhook_info = list(
		"embeds" = list(embed)
	)

	if(content)
		webhook_info["content"] = content
	if(CONFIG_GET(string/round_end_webhook_name))
		webhook_info["username"] = CONFIG_GET(string/round_end_webhook_name)
	if(CONFIG_GET(string/round_end_webhook_avatar_url))
		webhook_info["avatar_url"] = CONFIG_GET(string/round_end_webhook_avatar_url)

	var/list/headers = list()
	headers["Content-Type"] = "application/json"
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, webhook, json_encode(webhook_info), headers, "tmp/response.json")
	request.begin_async()
