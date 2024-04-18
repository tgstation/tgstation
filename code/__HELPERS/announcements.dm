/**
 * Sends a div formatted chat box announcement
 *
 * Formatted like:
 *
 * " Server Announcement " (or sender_override)
 *
 * " Title "
 *
 * " Text "
 *
 * Arguments
 * * text - required, the text to announce
 * * title - optional, the title of the announcement.
 * * players - optional, a list of all players to send the message to. defaults to the entire world
 * * play_sound - if TRUE, play a sound with the announcement (based on player option)
 * * sound_override - optional, override the default announcement sound
 * * sender_override - optional, modifies the sender of the announcement
 * * encode_title - if TRUE, the title will be HTML encoded (escaped)
 * * encode_text - if TRUE, the text will be HTML encoded (escaped)
 */

/proc/send_ooc_announcement(
	text,
	title = "",
	players,
	play_sound = TRUE,
	sound_override = 'sound/misc/bloop.ogg',
	sender_override = "Server Admin Announcement",
	encode_title = TRUE,
	encode_text = FALSE,
)
	if(isnull(text))
		return

	var/list/announcement_strings = list()

	if(encode_title && title && length(title) > 0)
		title = html_encode(title)
		if(encode_text)
			text = html_encode(text)
			if(!length(text))
				return

	announcement_strings += span_major_announcement_title(sender_override)
	announcement_strings += span_subheader_announcement_text(title)
	announcement_strings += span_ooc_announcement_text(text)
	var/finalized_announcement = create_ooc_announcement_div(jointext(announcement_strings, ""))

	if(islist(players))
		for(var/mob/target in players)
			to_chat(target, finalized_announcement)
			if(play_sound && target.client?.prefs.read_preference(/datum/preference/toggle/sound_announcements))
				SEND_SOUND(target, sound(sound_override))
	else
		to_chat(world, finalized_announcement)

		if(!play_sound)
			return

		for(var/mob/player in GLOB.player_list)
			if(player.client?.prefs.read_preference(/datum/preference/toggle/sound_announcements))
				SEND_SOUND(player, sound(sound_override))

/**
 * Inserts a span styled message into an alert box div
 *
 *
 * Arguments
 * * message - required, the message contents
 * * color - optional, set a div color other than default
 */
/proc/create_announcement_div(message, color = "default")
	return "<div class='chat_alert_[color]'>[message]</div>"

/**
 * Inserts a span styled message into an OOC alert style div
 *
 *
 * Arguments
 * * message - required, the message contents
 */
/proc/create_ooc_announcement_div(message)
	return "<div class='ooc_alert'>[message]</div>"
