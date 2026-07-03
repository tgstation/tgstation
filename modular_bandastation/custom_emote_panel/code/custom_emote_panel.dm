#define TGUI_PANEL_MAX_EMOTES 45
#define TGUI_PANEL_MAX_EMOTE_LENGTH 128
#define TGUI_PANEL_MAX_EMOTE_NAME_LENGTH 32
#define SHORT_EMOTE_MAX_LENGTH 40
#define CUSTOM_SHORT_EMOTE_COOLDOWN 0.4 SECONDS
#define CUSTOM_EMOTE_COOLDOWN 1 SECONDS

#define DELETE_EMOTE "Удалить"
#define RENAME_EMOTE "Переименовать"
#define CUSTOMIZE_EMOTE "Кастомизировать"
#define CHANGE_EMOTE_TEXT "Изменить текст"
#define CANCEL_EMOTE_ADDITION "Добавление эмоции отменено."

/*
	Панель эмоутов была переделана, и теперь вместо простого ассоциативного списка `emotes["sigh"] = "вздох"`
	у нас будет один из вариантов:
	* `emotes["вздох"] = list("type" = 1, "key" = "sigh")`
	* `emotes["вздох"] = list("type" = 2, "key" = "sigh", "message_override" = "круто по-кастомну вздыхает")`
	* `emotes["вздох"] = list("type" = 3, "message" = "круто по-кастомну вздыхает")`
	Где 1, 2 и 3 - TGUI_PANEL_EMOTE_TYPE_DEFAULT, TGUI_PANEL_EMOTE_TYPE_CUSTOM и TGUI_PANEL_EMOTE_TYPE_ME соответственно.
	В чём отличие между вторым и третьим вариантом? Во втором варианте всё ещё будет звук от "sigh". Особенно актуально в
	случае эмоутов с особыми эффектами (щелчками, маниакальным смехом и т.д.)

	Если ты меняешь эту схему, не забудь сделать миграцию в code/modules/client/preferences_savefile.dm.

	Стоит заметить, что all_emotes под это всё не подпадает и всё ещё является ассоциативным списком
	 * all_emotes["sigh"] = объект класса /datum/emote/sound/human/sigh
*/

/mob/living
	var/next_sound_emote

/datum/tgui_panel
	var/static/list/all_emotes = list()
	var/list/blacklisted_emote_types = list(
		/datum/emote/help,
		/datum/emote/living/custom,
		/datum/emote/imaginary_friend,
		)


// russian emotes only in GLOB.emote_list
/datum/tgui_panel/proc/populate_all_emotes_list()
	if(length(all_emotes))
		return
	for(var/emote_key in GLOB.emote_list)
		var/list/emote_list = GLOB.emote_list[emote_key]
		for(var/datum/emote/emote in emote_list)
			if(is_type_in_list(emote, blacklisted_emote_types))
				continue

			if(emote_key != emote.key)
				continue

			all_emotes += emote

/datum/tgui_panel/New(client/client, id)
	. = ..()
	populate_all_emotes_list()

/datum/tgui_panel/on_message(type, payload)
	. = ..()

	if(!client?.prefs)
		return

	if(. && type == "ready")
		emotes_send_list()

	if(.)
		return


	switch(type)
		if("emotes/execute")
			if(!islist(payload))
				return

			var/emote_name = payload["name"]
			if(!emote_name || !istext(emote_name) || !length(emote_name))
				return

			if(isnull(client.prefs.custom_emote_panel[emote_name]))
				to_chat(client, span_warning("Эмоции [emote_name] нет в вашей панели!"))
				return FALSE

			if(isnull(client.prefs.custom_emote_panel[emote_name]["type"]))
				to_chat(client, span_warning("Эмоция [emote_name] не имеет типа!"))
				return FALSE

			var/emote_type = client.prefs.custom_emote_panel[emote_name]["type"]
			if(!isliving(client.mob))
				return TRUE

			var/mob/living/living = client.mob
			switch (emote_type)
				if(TGUI_PANEL_EMOTE_TYPE_DEFAULT)
					var/emote_key = client.prefs.custom_emote_panel[emote_name]["key"]
					living.emote(emote_key, intentional = TRUE)

				// Чтобы люди не спамили пастами из 128 символов со скоростью света
				if(TGUI_PANEL_EMOTE_TYPE_CUSTOM)
					if(living.next_sound_emote >= world.time)
						to_chat(living, span_warning("Не так быстро!"))
						return TRUE

					var/emote_key = client.prefs.custom_emote_panel[emote_name]["key"]
					var/message_override = client.prefs.custom_emote_panel[emote_name]["message_override"]
					living.emote(emote_key, intentional = TRUE, message_override = message_override)
					handle_panel_cooldown(living, message_override)

				if(TGUI_PANEL_EMOTE_TYPE_ME)
					if(living.next_sound_emote >= world.time)
						to_chat(living, span_warning("Не так быстро!"))
						return TRUE

					var/message = client.prefs.custom_emote_panel[emote_name]["message"]
					living.emote("me", intentional = TRUE, message = message)
					handle_panel_cooldown(living, message)

			return TRUE

		if("emotes/create")
			if(length(client.prefs.custom_emote_panel) > TGUI_PANEL_MAX_EMOTES)
				to_chat(client, span_warning("Достигнут максимум эмоций: [TGUI_PANEL_MAX_EMOTES]."))
				return

			var/list/emote = list()
			var/emote_type_string = tgui_alert(client.mob, "Какую эмоцию добавить в панель?", "Выбор типа эмоции", list("Обычная", "С кастомным текстом", "*me"))
			if(!emote_type_string)
				to_chat(client, span_warning(CANCEL_EMOTE_ADDITION))
				return

			var/suggested_name = ""
			switch (emote_type_string)
				if("Обычная")
					var/datum/emote/picked_emote = tgui_input_list(client.mob, "Какую эмоцию добавить в панель?", "Выбор эмоции", all_emotes)
					if(!picked_emote)
						to_chat(client, span_warning(CANCEL_EMOTE_ADDITION))
						return

					var/emote_key = picked_emote.key
					if(!(emote_key in GLOB.emote_list))
						to_chat(client, span_warning("Эмоция [emote_key] не существует!"))
						return

					suggested_name = picked_emote.name
					emote = list(
						"type" = TGUI_PANEL_EMOTE_TYPE_DEFAULT,
						"key" = emote_key,
					)

				if("С кастомным текстом")
					var/datum/emote/picked_emote = tgui_input_list(client.mob, "Какую эмоцию добавить в панель?", "Выбор эмоции", all_emotes)
					if(!picked_emote)
						to_chat(client, span_warning(CANCEL_EMOTE_ADDITION))
						return

					var/emote_key = picked_emote.key
					if(!(emote_key in GLOB.emote_list))
						to_chat(client, span_warning("Эмоция [emote_key] не существует!"))
						return

					var/message_override = tgui_input_text(client.mob, "Какой кастомный текст будет у эмоции? (максимум - [TGUI_PANEL_MAX_EMOTE_LENGTH] символов)", "Кастомный текст", picked_emote.name, TGUI_PANEL_MAX_EMOTE_LENGTH, TRUE, TRUE)
					if(!message_override)
						to_chat(client, span_warning(CANCEL_EMOTE_ADDITION))
						return

					suggested_name = picked_emote.name
					emote = list(
						"type" = TGUI_PANEL_EMOTE_TYPE_CUSTOM,
						"key" = emote_key,
						"message_override" = message_override,
					)

				if("*me")
					var/message = tgui_input_text(client.mob, "Какой текст будет у эмоции? (максимум - [TGUI_PANEL_MAX_EMOTE_LENGTH] символов)", "Кастомный текст", "", TGUI_PANEL_MAX_EMOTE_LENGTH, TRUE, TRUE)
					if(!message)
						to_chat(client, span_warning(CANCEL_EMOTE_ADDITION))
						return

					suggested_name = copytext_char(message, 1, TGUI_PANEL_MAX_EMOTE_NAME_LENGTH + 1)
					emote = list(
						"type" = TGUI_PANEL_EMOTE_TYPE_ME,
						"message" = message,
					)

			var/emote_name = tgui_input_text(client.mob, "Какое название эмоции будет в панели?", "Название эмоции", suggested_name, TGUI_PANEL_MAX_EMOTE_NAME_LENGTH, FALSE, TRUE)
			if(!emote_name)
				to_chat(client, span_warning(CANCEL_EMOTE_ADDITION))
				return

			if(emote_name in client.prefs.custom_emote_panel)
				to_chat(client, span_warning("Эмоция \"[emote_name]\" уже существует!"))
				return

			client.prefs.custom_emote_panel[emote_name] = emote
			client.prefs.save_preferences()
			emotes_send_list()

			return TRUE

		if("emotes/contextAction")
			if(!islist(payload))
				return

			var/emote_name = payload["name"]
			if(!emote_name || !istext(emote_name) || !length(emote_name))
				return

			if(isnull(client.prefs.custom_emote_panel[emote_name]))
				to_chat(client, span_warning("Эмоции [emote_name] нет в вашей панели!"))
				return FALSE

			var/emote_type = client.prefs.custom_emote_panel[emote_name]["type"] ? client.prefs.custom_emote_panel[emote_name]["type"] : TGUI_PANEL_EMOTE_TYPE_UNKNOWN
			var/list/actions = list()
			switch (emote_type)
				if(TGUI_PANEL_EMOTE_TYPE_DEFAULT)
					actions.Add(list(RENAME_EMOTE, CUSTOMIZE_EMOTE, DELETE_EMOTE))

				if(TGUI_PANEL_EMOTE_TYPE_CUSTOM)
					actions.Add(list(RENAME_EMOTE, CHANGE_EMOTE_TEXT, DELETE_EMOTE))

				if(TGUI_PANEL_EMOTE_TYPE_ME)
					actions.Add(list(RENAME_EMOTE, CHANGE_EMOTE_TEXT, DELETE_EMOTE))

				if(TGUI_PANEL_EMOTE_TYPE_UNKNOWN)
					to_chat(client, span_warning("Эмоция не имеет типа, поэтому её можно только удалить."))
					actions.Add(list(DELETE_EMOTE))

			var/action = tgui_alert(client.mob, "Что вы хотите сделать с эмоцией \"[emote_name]\"?", "Выбор действия", actions)

			switch (action)
				if(DELETE_EMOTE)
					if(emotes_remove(emote_name))
						client.prefs.save_preferences()
						emotes_send_list()
				if(RENAME_EMOTE)
					if(emotes_rename(emote_name))
						client.prefs.save_preferences()
						emotes_send_list()
				if(CUSTOMIZE_EMOTE)
					if(emotes_add_custom_text(emote_name))
						client.prefs.save_preferences()
						emotes_send_list()
				if(CHANGE_EMOTE_TEXT)
					if(emotes_change_custom_text(emote_name))
						client.prefs.save_preferences()
						emotes_send_list()

			return TRUE

/datum/tgui_panel/proc/handle_panel_cooldown(mob/living/living, message)
	if(length_char(message) > SHORT_EMOTE_MAX_LENGTH)
		living.next_sound_emote = max(living.next_sound_emote, world.time + CUSTOM_EMOTE_COOLDOWN)
	else
		living.next_sound_emote = max(living.next_sound_emote, world.time + CUSTOM_SHORT_EMOTE_COOLDOWN)

/datum/tgui_panel/proc/emotes_rename(emote_name)
	var/new_emote_name = tgui_input_text(client.mob, "Выберите новое название эмоции [emote_name]:", "Название эмоции", emote_name, TGUI_PANEL_MAX_EMOTE_NAME_LENGTH, FALSE, TRUE)
	if(!new_emote_name)
		return FALSE
	if(new_emote_name == emote_name)
		to_chat(client, span_notice("Переименование отменено"))
		return FALSE
	if(new_emote_name in client.prefs.custom_emote_panel)
		to_chat(client, span_warning("Эмоция \"[new_emote_name]\" уже существует!"))
		return FALSE

	var/list/emote = client.prefs.custom_emote_panel[emote_name]
	client.prefs.custom_emote_panel[new_emote_name] = emote
	client.prefs.custom_emote_panel.Remove(emote_name)

	return TRUE

/datum/tgui_panel/proc/emotes_remove(emote_name)
	var/confirmation = tgui_alert(client.mob, "Вы уверены что хотите удалить эмоцию \"[emote_name]\" из панели?", "Подтверждение", list(DELETE_EMOTE, "Отмена"))
	if(confirmation != DELETE_EMOTE)
		return FALSE

	client.prefs.custom_emote_panel.Remove(emote_name)

	return TRUE

/datum/tgui_panel/proc/emotes_add_custom_text(emote_name)
	if(isnull(client.prefs.custom_emote_panel[emote_name]))
		to_chat(client, span_warning("Эмоции [emote_name] нет в вашей панели!"))
		return FALSE

	var/emote_type = client.prefs.custom_emote_panel[emote_name]["type"]
	if(emote_type != TGUI_PANEL_EMOTE_TYPE_DEFAULT)
		to_chat(client, span_warning("Вы можете добавить текст только обычным эмоциям!"))
		return FALSE

	var/message_override = tgui_input_text(client.mob, "Выберите новый кастомный текст для эмоции [emote_name]:", "Кастомный текст", "", TGUI_PANEL_MAX_EMOTE_LENGTH, TRUE, TRUE)
	if(!message_override)
		return FALSE

	client.prefs.custom_emote_panel[emote_name]["type"] = TGUI_PANEL_EMOTE_TYPE_CUSTOM
	client.prefs.custom_emote_panel[emote_name]["message_override"] = message_override
	return TRUE

/datum/tgui_panel/proc/emotes_change_custom_text(emote_name)
	if(isnull(client.prefs.custom_emote_panel[emote_name]))
		to_chat(client, span_warning("Эмоции [emote_name] нет в вашей панели!"))
		return FALSE

	var/emote_type = client.prefs.custom_emote_panel[emote_name]["type"]
	var/old_message = "???"
	if(emote_type == TGUI_PANEL_EMOTE_TYPE_CUSTOM)
		old_message = client.prefs.custom_emote_panel[emote_name]["message_override"]
	else if(emote_type == TGUI_PANEL_EMOTE_TYPE_ME)
		old_message = client.prefs.custom_emote_panel[emote_name]["message"]
	else
		to_chat(client, span_warning("У этой эмоции ещё нет кастомного текста!"))
		return FALSE

	var/message_override = tgui_input_text(client.mob, "Выберите новый кастомный текст для эмоции [emote_name]:", "Кастомный текст", old_message, TGUI_PANEL_MAX_EMOTE_LENGTH, TRUE, TRUE)
	if(!message_override)
		return FALSE

	if(emote_type == TGUI_PANEL_EMOTE_TYPE_CUSTOM)
		client.prefs.custom_emote_panel[emote_name]["message_override"] = message_override
	else
		client.prefs.custom_emote_panel[emote_name]["message"] = message_override

	return TRUE

/datum/tgui_panel/proc/emotes_send_list()
	var/list/payload = client.prefs.custom_emote_panel
	window.send_message("emotes/setList", payload)

#undef TGUI_PANEL_MAX_EMOTES
#undef TGUI_PANEL_MAX_EMOTE_LENGTH
#undef TGUI_PANEL_MAX_EMOTE_NAME_LENGTH
#undef SHORT_EMOTE_MAX_LENGTH
#undef CUSTOM_SHORT_EMOTE_COOLDOWN
#undef CUSTOM_EMOTE_COOLDOWN

#undef DELETE_EMOTE
#undef RENAME_EMOTE
#undef CUSTOMIZE_EMOTE
#undef CHANGE_EMOTE_TEXT
#undef CANCEL_EMOTE_ADDITION
