/client/proc/cmd_loud_admin_say(msg as text)
	set category = "Admin"
	set name = "Loud Asay"
	set hidden = TRUE
	if(!check_rights(0))
		return

	msg = emoji_parse(copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	msg = emoji_parse(msg)
	mob.log_talk(msg, LOG_ASAY)

	msg = keywords_lookup(msg)
	var/custom_asay_color = (CONFIG_GET(flag/allow_admin_asaycolor) && prefs.asaycolor) ? "<font color=[prefs.asaycolor]>" : "<font color='#FF4500'>"
	msg = "<span class='command_headset'> <span class='adminsay'><span class='prefix'>ADMIN:</span> <EM>[key_name(usr, 1)]</EM> [ADMIN_FLW(mob)]: [custom_asay_color]<span class='message linkify'>[msg]</span></span></span>[custom_asay_color ? "</font>":null]"
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINCHAT,
		html = msg,
		confidential = TRUE)

	for(var/client/I in GLOB.admins)
		if(I.prefs.toggles & SOUND_ADMINHELP)
			SEND_SOUND(I, sound('modular_skyrat/modules/admin/sound/duckhonk.ogg')) //Stop using loud mode if you don't need to.
		window_flash(I, ignorepref = TRUE)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "loudAsay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

