/mob/living/silicon/ai/Initialize(mapload, datum/ai_laws/L, mob/target_ai)
	. = ..()
	if(isnewplayer(target_ai))
		SStitle.hide_title_screen_from(client)

/mob/dead/new_player/Topic(href, href_list)
	if(src != usr || !client)
		return

	if(href_list["focus"])
		winset(client, "map", "focus=true")

	if(href_list["discord_oauth"])
		client?.verify_in_discord_central()

	else if(href_list["discord_oauth_close"])
		client << browse("", "window=authwindow;")
		SScentral.update_player_discord_async(client.ckey, client)

	else if(href_list["changelog"])
		client?.changelog()

	else if(href_list["wiki"])
		client?.wiki()

	else if(href_list["discord"])
		client?.discord()

	else if(href_list["github"])
		client?.github()

	else if(href_list["bug"])
		client?.reportissue()

	if(CONFIG_GET(flag/force_discord_verification) && (href_list["toggle_ready"] || href_list["late_join"] || href_list["observe"]))
		if(!SScentral.can_run() || !SScentral.is_player_discord_linked(ckey))
			return

	if(client.interviewee)
		if(href_list["interview"])
			open_interview()
		return

	if(href_list["toggle_ready"])
		if(SSticker.current_state >= GAME_STATE_SETTING_UP)
			to_chat(usr, span_warning("Игра уже начинается!"))
			return

		if(ready != PLAYER_NOT_READY)
			ready = PLAYER_NOT_READY
			SStitle.title_output(client, FALSE, "toggleReady")
			return

		var/prefs_specie = client.prefs.read_preference(/datum/preference/choiced/species)
		var/list/prefs_jobs = client.prefs.job_preferences
		if(!prefs_specie || !islist(prefs_jobs) || !length(prefs_jobs))
			to_chat(usr, span_boldwarning("Ошибка настроек персонажа. Выберите предпочитаемую должность."))
			return

		var/ignore_restrictions = locate(/datum/station_trait/xenobureaucracy_error) in GLOB.lobby_station_traits
		if(!ignore_restrictions)
			var/list/allowed_species = CONFIG_GET(str_list/allowed_species)
			var/list/job_restrictions = CONFIG_GET(str_list/job_restrictions)
			if(length(allowed_species) && !("[prefs_specie]" in allowed_species))
				for(var/job_id in prefs_jobs)
					if(job_id in job_restrictions)
						to_chat(usr, span_alertwarning("Выбранная раса несовместима с одной или более выбранных профессий."))
						return

		ready = PLAYER_READY_TO_PLAY
		SStitle.title_output(client, TRUE, "toggleReady")

	else if(href_list["late_join"])
		if(SSticker.current_state == GAME_STATE_FINISHED)
			to_chat(usr, span_warning("Невозможно присоединиться, игра уже окончена!"))
			return

		GLOB.latejoin_menu.ui_interact(usr)

	else if(href_list["observe"])
		if(!SSticker || SSticker.current_state <= GAME_STATE_STARTUP)
			to_chat(usr, span_warning("Сервер ещё не загрузился!"))
			return

		make_me_an_observer()

	else if(href_list["character_setup"])
		var/datum/preferences/preferences = client.prefs
		preferences.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
		preferences.update_static_data(src)
		preferences.ui_interact(src)

	else if(href_list["settings"])
		var/datum/preferences/preferences = client.prefs
		preferences.current_window = PREFERENCE_TAB_GAME_PREFERENCES
		preferences.update_static_data(usr)
		preferences.ui_interact(usr)

	else if(href_list["manifest"])
		ViewManifest()

	else if(href_list["trait_signup"])
		var/datum/station_trait/clicked_trait
		for(var/datum/station_trait/trait as anything in GLOB.lobby_station_traits)
			if(trait.name == href_list["trait_signup"])
				clicked_trait = trait

		clicked_trait.on_lobby_button_click(usr, href_list["id"])

	if((href_list["picture"] || href_list["notice"] || href_list["start_now"] || href_list["delay"]) && !check_rights_for(client, R_ADMIN|R_DEBUG))
		to_chat(client, span_warning("ТЫ пытаешься использовать <b>АДМИНСКИЕ</b> кнопки! У тебя ничего не выйдет, но мы оповестили администрацию."))
		log_admin("Title Screen: Possible href exploit attempt by [key_name(usr)]!")
		message_admins("Title Screen: Possible href exploit attempt by [key_name(usr)]!")
		return

	else if(href_list["picture"])
		SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/change_title_screen)

	else if(href_list["notice"])
		SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/change_title_screen_notice)

	else if(href_list["start_now"])
		SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/start_now)

	else if(href_list["delay"])
		if(SSticker.current_state > GAME_STATE_PREGAME)
			return tgui_alert(usr, "Слишком поздно... Игра уже началась!", "О нет...", timeout = 10 SECONDS)

		var/static/time = 1.5 MINUTES
		if(time == 1.5 MINUTES)
			time = 1984 DAYS
		else
			time = 1.5 MINUTES

		SSticker.SetTimeLeft(time)
		SSticker.start_immediately = FALSE
		to_chat(world, span_infoplain(span_bold("Игра начнётся через [DisplayTimeText(time)].")), confidential = TRUE)
		SEND_SOUND(world, sound('sound/announcer/default/attention.ogg'))
		log_admin("[key_name(usr)] set the pre-game delay to [DisplayTimeText(time)].")
		BLACKBOX_LOG_ADMIN_VERB("Delay Game Start")

	else if(href_list["titleReady"] && check_rights_for(client, R_ADMIN|R_DEBUG))
		SStitle.title_output(client, "true", "toggleAdmin")
