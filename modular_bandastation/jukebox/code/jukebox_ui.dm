/datum/jukebox
	/// Music start time.
	var/startTime = 0
	/// Whether the uploaded track will be saved on the server.
	var/save_track = FALSE

/datum/jukebox/start_music()
	. = ..()
	startTime = world.time

/datum/jukebox/unlisten_all()
	. = ..()
	startTime = 0

/obj/machinery/jukebox/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Jukebox220", name)
		ui.open()

/obj/machinery/jukebox/ui_data(mob/user)
	var/list/data = ..()
	music_player.get_ui_data(data)
	data["admin"] = check_rights_for(user.client, R_ADMIN)
	data["saveTrack"] = music_player.save_track
	data["startTime"] = music_player.startTime
	data["worldTime"] = world.time
	return data

/obj/machinery/jukebox/ui_act(action, list/params)
	. = ..()
	var/mob/user = usr
	switch(action)
		if("add_song")
			if(!check_rights_for(user.client, R_ADMIN))
				message_admins("[key_name(user)] попытался добавить трек, не имея прав администратора!")
				log_admin("[key_name(user)] попытался добавить трек, не имея прав администратора!")
				return FALSE
			var/track_name = params["track_name"]
			var/track_length = params["track_length"]
			var/track_beat = params["track_beat"]
			if(!track_name || !track_length || !track_beat)
				to_chat(user, span_warning("Ошибка: Имеются не заполненные поля."))
				return FALSE

			var/track_file = upload_file(user)
			upload_track(user, track_name, track_length, track_beat, track_file)
			try_save_file(user, track_name, track_length, track_beat, track_file)
			return TRUE

		if("save_song")
			if(!check_rights_for(user.client, R_ADMIN))
				message_admins("[key_name(user)] попытался включить сохранение трека, не имея прав администратора!")
				log_admin("[key_name(user)] попытался включить сохранение трека, не имея прав администратора!")
				return FALSE
			enable_saving(user)
			return TRUE

/obj/machinery/jukebox/proc/upload_file(mob/user)
	var/file = input(user, "Загрузите файл весом не более 5мб, поддерживается только формат .ogg", "Загрузка файла") as null|file
	if(isnull(file))
		to_chat(user, span_warning("Ошибка: Необходимо выбрать файл."))
		return
	if(copytext("[file]", -4) != ".ogg")
		to_chat(user, span_warning("Формат файла должен быть '.ogg': [file]"))
		return
	return file

/obj/machinery/jukebox/proc/upload_track(mob/user, name, length, beat, file)
	var/datum/track/new_track = new()
	new_track.song_name = name
	new_track.song_length = length
	new_track.song_beat = beat
	new_track.song_path = file(file)

	music_player.songs[name] = new_track
	say("Загружен новый трек: «[name]»")

/obj/machinery/jukebox/proc/try_save_file(mob/user, name, length, beat, file)
	if(!music_player.save_track)
		return
	if(tgui_alert(user, "ВНИМАНИЕ! Включено сохранение трека на сервер. <br> \
			Нажимая «Да» вы подтверждаете, что загружаемый трек не нарушает никаких авторских прав. <br> \
			Вы уверены, что хотите сохранить трек?", "Сохранение трека", list("Да", "Нет")) != "Да")
		music_player.save_track = !music_player.save_track
		to_chat(user, span_warning("Сохранение трека было отключено."))
		return

	var/config_file = "[name]" + "+" + "[length]" + "+" + "[beat]"
	if(!fcopy(file, "[global.config.directory]/jukebox_music/sounds/[config_file].ogg"))
		to_chat(user, span_warning("По какой-то причине, трек не был сохранён, попробуйте ещё раз. <br> Входной файл: [file] <br> Выходной файл: [config_file].ogg"))
		return
	to_chat(user, span_notice("Ваш трек успешно загружен на сервер под следующим названием: [config_file].ogg"))
	message_admins("[key_name(user)] загрузил трек [config_file].ogg с изначальным названием [file] на сервер")
	log_admin("[key_name(user)] загрузил трек [config_file].ogg с изначальным названием [file] на сервер")

/obj/machinery/jukebox/proc/enable_saving(mob/user)
	if(music_player.save_track)
		music_player.save_track = !music_player.save_track
		return
	if(tgui_alert(user, "Вы уверены, что хотите сохранить трек на сервере?", "Сохранение трека", list("Да", "Нет")) != "Да")
		return
	if(tgui_alert(user, "Внимание! Сохранённый трек сможет удалить ТОЛЬКО хост! Подойдите максимально ответственно к заполнению полей!", "Сохранение трека", list("Ок", "Я передумал")) != "Ок")
		return
	music_player.save_track = !music_player.save_track
