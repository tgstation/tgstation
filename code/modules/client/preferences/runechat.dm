/datum/preference/toggle/enable_runechat
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "chat_on_map"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/enable_runechat_non_mobs
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "see_chat_non_mob"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/see_rc_emotes
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "see_rc_emotes"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/numeric/max_chat_length
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "max_chat_length"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 1
	maximum = CHAT_MESSAGE_MAX_LENGTH

/datum/preference/numeric/max_chat_length/create_default_value()
	return CHAT_MESSAGE_MAX_LENGTH



/datum/preference/color/runechat_color
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "runechat_color"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/color/runechat_color/create_default_value()
	return sanitize_hexcolor(COLOR_BLACK)

/datum/preference/color/runechat_color/apply_to_human(mob/living/carbon/human/target, value)
	if(value != sanitize_hexcolor(COLOR_BLACK))
		target.chat_color = value
		target.chat_color_darkened = value
		var/r = hex2num(copytext(value, 2, 4))
		var/g = hex2num(copytext(value, 4, 6))
		var/b = hex2num(copytext(value, 6, 8))
		r = r * 0.85
		g = g * 0.85
		b = b * 0.85
		r = round(r, 1)
		g = round(g, 1)
		b = round(b, 1)
		target.chat_color_darkened = "#[num2hex(r, 2)][num2hex(g, 2)][num2hex(b, 2)]"