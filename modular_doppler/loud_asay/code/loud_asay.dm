ADMIN_VERB(cmd_loud_admin_say, R_NONE, "loudAsay", "Send a message to other admins (loudly).", ADMIN_CATEGORY_MAIN, message as text)
	message = emoji_parse(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message)
		return

	user.mob.log_talk(message, LOG_ASAY)
	message = keywords_lookup(message)
	var/asay_color = user.prefs.read_preference(/datum/preference/color/asay_color)
	var/custom_asay_color = (CONFIG_GET(flag/allow_admin_asaycolor) && asay_color) ? "<font color=[asay_color]>" : "<font color='[DEFAULT_ASAY_COLOR]'>"
	message = "[span_command_headset("[span_adminsay("[span_prefix("ADMIN:")] <EM>[key_name_admin(user)]</EM> [ADMIN_FLW(user.mob)]: [custom_asay_color]<span class='message linkify'>[message]")]</span>[custom_asay_color ? "</font>":null]")]"
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINCHAT,
		html = message,
		confidential = TRUE)

	for(var/client/admin_client in GLOB.admins)
		if(admin_client?.prefs?.toggles & SOUND_ADMINHELP)
			SEND_SOUND(admin_client, sound('modular_doppler/loud_asay/sound/duckhonk.ogg')) //Stop using loud mode if you don't need to.
		window_flash(admin_client, ignorepref = TRUE)

	BLACKBOX_LOG_ADMIN_VERB("Loud Asay")
