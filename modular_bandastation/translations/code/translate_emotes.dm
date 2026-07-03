/proc/ru_emote_name(emote_name)
	return GLOB.ru_emote_names[LOWER_TEXT(emote_name)] || emote_name

/proc/ru_emote_message(emote_message)
	return GLOB.ru_emote_messages[emote_message] || emote_message

/datum/emote/proc/update_to_ru()
	name = ru_emote_name(name)
	message = ru_emote_message(message)
	message_mime = ru_emote_message(message_mime)
	message_alien = ru_emote_message(message_alien)
	message_larva = ru_emote_message(message_larva)
	message_robot = ru_emote_message(message_robot)
	message_AI = ru_emote_message(message_AI)
	message_monkey = ru_emote_message(message_monkey)
	message_animal_or_basic = ru_emote_message(message_animal_or_basic)
	message_param = ru_emote_message(message_param)

/datum/keybinding/emote
	var/datum/emote/faketype

/datum/keybinding/emote/link_to_emote(datum/emote/faketype)
	. = ..()
	src.faketype = faketype

/datum/keybinding/emote/proc/update_to_ru()
	full_name = capitalize(ru_emote_name(faketype::name || faketype::key))
