/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * Maximum number of connection records allowed to analyze.
 * Should match the value set in the browser.
 */
#define TGUI_ANALYZE_MAX_RECORDS 5

/**
 * Maximum time allocated for sending analysis data.
 */
#define TGUI_ANALYZE_TIME_WINDOW 30 SECONDS

/**
 * tgui_panel datum. Hosts tgchat and other nice features.
 */
/datum/tgui_panel
	var/client/client
	var/datum/tgui_window/window
	var/broken = FALSE
	var/initialized_at
	var/connections_analyzed_at
	var/list/connection_history
	var/list/admin_music_volume

/datum/tgui_panel/New(client/client)
	src.client = client
	window = new(client, "browseroutput")
	window.subscribe(src, .proc/on_message)

/datum/tgui_panel/Del()
	window.unsubscribe(src)
	window.close()
	return ..()

/**
 * TRUE if panel is initialized and ready to receive messages
 */
/datum/tgui_panel/proc/is_ready()
	return !broken && window.is_ready()

/datum/tgui_panel/proc/initialize(force = FALSE)
	set waitfor = FALSE
	// Skin is broken
	if(!winexists(client, "browseroutput"))
		broken = TRUE
		message_admins("Couldn't start chat for [key_name_admin(client)]!")
		alert(client.mob, "Updated chat window does not exist. If you are using a custom skin file please allow the game to update.")
		return
	initialized_at = world.time
	connections_analyzed_at = null
	// Browser was initialized
	if(!force && winget(client, "browseroutput", "is-visible") == "true")
		// Short-circuit initialization.
		// Should be a proper method on the window.
		window.status = TGUI_WINDOW_LOADING
		window.send_message("ping")
		return
	window.initialize(inline_assets = list(
		get_asset_datum(/datum/asset/simple/tgui_common),
		get_asset_datum(/datum/asset/simple/tgui_panel),
	))
	window.send_asset(get_asset_datum(/datum/asset/simple/fontawesome))
	addtimer(CALLBACK(src, .proc/on_initialize_timed_out), 2 SECONDS)

/datum/tgui_panel/proc/on_initialize_timed_out()
	SEND_TEXT(client, "<span class=\"userdanger\">Failed to load fancy chat, reverting to old chat. Certain features won't work.</span>")

/datum/tgui_panel/proc/on_message(type, payload)
	if(type == "ready")
		broken = FALSE
		window.send_message("update", list(
			"config" = list(
				"client" = list(
					"ckey" = client.ckey,
					"address" = client.address,
					"computer_id" = client.computer_id,
				),
				"window" = list(
					"fancy" = FALSE,
					"locked" = FALSE,
				),
			),
		))
		return TRUE
	if(type == "changeTheme")
		if(payload["name"] == "dark")
			client.force_dark_theme()
		if(payload["name"] == "light")
			client.force_white_theme()
		return TRUE
	if(type == "audio/setAdminMusicVolume")
		client.admin_music_volume = payload["volume"]
		return TRUE
	if(type == "analyzeClientData")
		analyze_client_data(payload)
		return TRUE

/datum/tgui_panel/proc/send_roundrestart()
	window.send_message("roundrestart")

/**
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
	var/list/payload = list(
		"url" = url,
	)
	if(length(extra_data) > 0)
		payload["pitch"] = extra_data["pitch"]
		payload["start"] = extra_data["start"]
		payload["end"] = extra_data["end"]
	window.send_message("audio/playMusic", payload)

/**
 * Stops playing music through the browser.
 */
/datum/tgui_panel/proc/stop_music()
	if(!is_ready())
		return
	window.send_message("audio/stopMusic")

/**
 * Used to dynamically add regexes to the browser output.
 * Currently only used by the IC filter.
 */
/datum/tgui_panel/proc/sync_chat_regexes()
	var/list/regexes = list()
	if (config.ic_filter_regex)
		regexes["show_filtered_ic_chat"] = list(
			config.ic_filter_regex.name,
			"ig",
			"<span class='boldwarning'>$1</span>"
		)
	if (regexes.len)
		window.send_message("syncRegex", regexes)

/datum/tgui_panel/proc/analyze_client_data(payload)
	if(initialized_at + TGUI_ANALYZE_TIME_WINDOW > world.time)
		message_admins("[key_name(client)] called analyze_client_data outside of the allocated time window.")
		return
	if(connections_analyzed_at)
		message_admins("[key_name(client)] called analyze_client_data more than once.")
		return
	connections_analyzed_at = world.time
	if(!payload)
		return
	connection_history = payload["connections"]
	var/len = length(connection_history)
	if(len == 0)
		return
	if(len > TGUI_ANALYZE_MAX_RECORDS)
		message_admins("[key_name(src.client)] was kicked for sending a huge payload to analyze_client_data")
		qdel(client)
		return
	var/list/found
	for(var/i in 1 to len)
		if(QDELETED(client))
			// He got cleaned up before we were done
			return
		var/list/row = connection_history[i]
		// Check for a malformed history object
		if (!row || row.len < 3 || (!row["ckey"] || !row["address"] || !row["computer_id"]))
			return
		if (world.IsBanned(row["ckey"], row["address"], row["computer_id"], real_bans_only = TRUE))
			found = row
			break
		CHECK_TICK
	// Uh oh this fucker has a history of playing on a banned account!!
	if(found)
		message_admins("[key_name(src.client)] has a cookie from a banned account! (Matched: [found["ckey"]], [found["address"]], [found["computer_id"]])")
		log_admin_private("[key_name(client)] has a cookie from a banned account! (Matched: [found["ckey"]], [found["address"]], [found["computer_id"]])")
