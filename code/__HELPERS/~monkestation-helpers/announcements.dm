/proc/send_formatted_admin_message(
	text,
	title = "Admin Alert",
	sound_override = 'sound/effects/adminhelp.ogg',
	color_override = "red"
)
	if(isnull(text))
		return
	var/list/announcement_strings = list()
	announcement_strings += SUBHEADER_ANNOUNCEMENT_TITLE(title)
	announcement_strings += span_major_announcement_text(text)
	var/finalized_announcement = create_announcement_div(jointext(announcement_strings, ""), color_override)
	SEND_ADMINCHAT_MESSAGE(finalized_announcement)
	if(sound_override)
		SEND_ADMINS_NOTFICATION_SOUND(sound_override)
