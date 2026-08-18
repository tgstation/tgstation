/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/// Admin music volume, from 0 to 1.
/client/var/admin_music_volume = 1

/**
 * public
 *
 * Sends music data to the browser.
 *
 * Optional settings:
 * - pitch: the playback rate
 * - start: the start time of the sound
 * - end: when the musics stops playing
 *
 * required url string Must be an https URL.
 * optional extra_data list Optional settings.
 */
/datum/tgui_panel/proc/play_music(url, extra_data)
	if(!is_ready())
		return
	if(!findtext(url, GLOB.is_http_protocol))
		return
	var/list/payload = list()
	if(length(extra_data) > 0)
		for(var/key in extra_data)
			payload[key] = extra_data[key]
	payload["url"] = url
	window.send_message("audio/playMusic", payload)

/**
 * public
 *
 * Stops playing music through the browser.
 */
/datum/tgui_panel/proc/stop_music()
	if(!is_ready())
		return
	window.send_message("audio/stopMusic")

/**
 * Chat Hightlight Sounds
 * --------------------------------
 * This is a dummy list to be used for loading chat highlight sounds into the client.
 * This is used for sounds which are only mentioned in the UI and are not in any DM files,
 * Otherwise they won't be loaded and will not play when the client tries to play them.
 */
var/static/list/_chat_highlight_sounds = list('sound/misc/highlight_sounds/Beep.ogg')
