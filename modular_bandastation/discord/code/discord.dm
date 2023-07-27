/datum/config_entry/string/discordurl
	default = "https://discord.gg/SS220"

/client/New()
	. = ..()
	prefs.discord_id = SSdiscord.lookup_id(ckey)

/datum/preferences
	var/discord_id

// IF you have linked your account, this will trigger a verify of the user
/client/verify_in_discord()
	// Safety checks
	if(!CONFIG_GET(flag/sql_enabled))
		to_chat(src, span_warning("This feature requires the SQL backend to be running."))
		return

	// Why this would ever be unset, who knows
	var/prefix = CONFIG_GET(string/discordbotcommandprefix)
	if(!prefix)
		to_chat(src, span_warning("Нет префикса для discord verification"))

	if(!SSdiscord || !SSdiscord.reverify_cache)
		to_chat(src, span_warning("Wait for the Discord subsystem to finish initialising"))
		return
	var/message = ""
	// Simple sanity check to prevent a user doing this too often
	var/cached_one_time_token = SSdiscord.reverify_cache[usr.ckey]
	if(cached_one_time_token && cached_one_time_token != "")
		message = "Вы уже сгенерировали токен <br/> [cached_one_time_token] <br/> В канале дом-бота используйте команду <br/> <span class='warning'>[prefix]привязать</span>"


	else
		// Will generate one if an expired one doesn't exist already, otherwise will grab existing token
		var/one_time_token = SSdiscord.get_or_generate_one_time_token_for_ckey(ckey)
		SSdiscord.reverify_cache[usr.ckey] = one_time_token
		message = "В канале дом-бота используйте команду <br/> <span class='warning'>[prefix]привязать</span> и введите туда свой токен <br/> [one_time_token]"

	//Now give them a browse window so they can't miss whatever we told them
	var/datum/browser/window = new/datum/browser(usr, "discordverification", "Discord verification")
	window.set_content("<span>[message]</span>")
	window.open()

//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/discord()
	set name = "discord"
	set desc = "Visit the discord."
	set hidden = TRUE
	var/discordurl = CONFIG_GET(string/discordurl)
	if(discordurl)
		if(tgui_alert(src, "This will open the discord in your browser. Are you sure?",, list("Yes","No"))!="Yes")
			return
		src << link(discordurl)
	else
		to_chat(src, span_danger("The discord URL is not set in the server configuration."))
	return

/mob/dead/new_player/Topic(href, href_list[])
	if(src != usr)
		return

	if(!client)
		return

	if(client.interviewee)
		return FALSE

	if(href_list["observe"] || href_list["toggle_ready"] || href_list["late_join"])
		if (!!CONFIG_GET(flag/sql_enabled) && !client.prefs.discord_id)
			to_chat(usr, "<span class='danger'>Вам необходимо привязать дискорд-профиль к аккаунту!</span>")
			to_chat(usr, "<span class='warning'>Нажмите 'Verify Discord Account' во вкладке 'OOC' для получения инструкций.</span>")
			return FALSE

	. = ..()
