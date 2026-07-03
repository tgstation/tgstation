/**
 * Enables an admin to upload a new titlescreen image.
 */
ADMIN_VERB(change_title_screen, R_ADMIN, "Лобби: Изменить фон", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN)
	if(!check_rights(R_ADMIN))
		return

	switch(tgui_input_list(usr, "Что делаем с фоном лобби?", "Фон лобби", list("Меняем", "Сбрасываем", "Включаем YouTube", "Включаем RuTube", "Ничего")))
		if("Меняем")
			var/file = input(usr) as icon|null
			if(file)
				SStitle.set_title_image(usr, file)

		if("Сбрасываем")
			SStitle.set_title_image(usr)

		if("Включаем YouTube")
			var/link = tgui_input_text(usr, "Введи ссылку на видео:", "YouTube ссылка", max_length = 128)
			if(link)
				SStitle.play_youtube_video(usr, link)

		if("Включаем RuTube")
			var/link = tgui_input_text(usr, "Введи ссылку на видео:", "RuTube ссылка", max_length = 128)
			if(link)
				SStitle.play_rutube_video(usr, link)

/**
 * Sets a titlescreen notice, a big red text on the main screen.
 */
ADMIN_VERB(change_title_screen_notice, R_ADMIN, "Лобби: Изменить уведомление", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN)
	if(!check_rights(R_ADMIN))
		return

	var/new_notice = tgui_input_text(usr, "Введи то что должно отображаться в лобби:", "Уведомление в лобби", max_length = 2048)
	if(isnull(new_notice))
		return

	var/announce_text
	if(new_notice == "")
		announce_text = "УВЕДОМЛЕНИЕ В ЛОББИ УДАЛЕНО."
	else
		announce_text = "УВЕДОМЛЕНИЕ В ЛОББИ ОБНОВЛЕНО: [new_notice]"

	SStitle.set_notice(new_notice)
	log_admin("Title Screen: [key_name(usr)] setted the title screen notice, which contains: [new_notice]")
	message_admins("Title Screen: [key_name_admin(usr)] setted the title screen notice, which contains: [new_notice]")

	for(var/mob/dead/new_player/new_player as anything in GLOB.new_player_list)
		to_chat(new_player, span_boldannounce(emoji_parse(announce_text)))
		SEND_SOUND(new_player,  sound('sound/mobs/humanoids/moth/scream_moth.ogg'))

/**
 * An admin debug command that enables you to change the CSS on the go.
 */
ADMIN_VERB(change_title_screen_css, R_DEBUG, "Title Screen: Set CSS", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_DEBUG)
	if(!check_rights(R_DEBUG))
		to_chat(src, span_warning("Недостаточно прав! Необходимы права R_DEBUG."))
		return

	log_admin("Title Screen: [key_name(usr)] is setting the title screen CSS.")
	message_admins("Title Screen: [key_name_admin(usr)] is setting the title screen CSS.")

	SStitle.set_title_css()

/**
 * Reloads the titlescreen if it is bugged for someone.
 */
/client/verb/fix_title_screen()
	set name = "Fix Lobby Screen"
	set desc = "Lobbyscreen broke? Press this."
	set category = "Special"

	if(!isnewplayer(src.mob))
		SStitle.hide_title_screen_from(src)
		return

	SStitle.show_title_screen_to(src)

/client/open_escape_menu()
	if(isnewplayer(mob))
		return
	. = ..()

/client/proc/validate_job_restrictions()
	set waitfor = FALSE

	if(SSticker.current_state >= GAME_STATE_SETTING_UP)
		return

	if(locate(/datum/station_trait/xenobureaucracy_error) in GLOB.lobby_station_traits)
		return

	var/prefs_species = src.prefs.read_preference(/datum/preference/choiced/species)
	var/list/prefs_jobs = src.prefs.job_preferences
	var/list/job_restrictions = CONFIG_GET(str_list/job_restrictions)
	var/list/allowed_species = CONFIG_GET(str_list/allowed_species)

	if(!prefs_species)
		return

	if(allowed_species && length(allowed_species))
		if("[prefs_species]" in allowed_species)
			return

	for(var/job_id in prefs_jobs)
		if(job_id in job_restrictions)
			to_chat(src, span_alertwarning("Выбранная раса несовместима с одной или более выбранных профессий."))
			SStitle.title_output(src, FALSE, "toggleReady")
			if(!usr)
				return
			var/mob/dead/new_player/player = usr
			player.ready = PLAYER_NOT_READY
			return

/datum/client_interface/proc/validate_job_restrictions()
	return TRUE
