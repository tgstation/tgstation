/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui_panel datum
 * Hosts tgchat and other nice features.
 */
/datum/tgui_panel
	var/client/client
	var/datum/tgui_window/window
	var/broken = FALSE
	var/initialized_at

/datum/tgui_panel/New(client/client)
	src.client = client
	window = new(client, "browseroutput")
	window.subscribe(src, .proc/on_message)

/datum/tgui_panel/Del()
	window.unsubscribe(src)
	window.close()
	return ..()

/**
 * public
 *
 * TRUE if panel is initialized and ready to receive messages.
 */
/datum/tgui_panel/proc/is_ready()
	return !broken && window.is_ready()

/**
 * public
 *
 * Initializes tgui panel.
 */
/datum/tgui_panel/proc/initialize(force = FALSE)
	set waitfor = FALSE
	// BYOND skin is broken
	if(!winexists(client, "browseroutput"))
		broken = TRUE
		message_admins("Couldn't start chat for [key_name_admin(client)]!")
		alert(client.mob, "Updated chat window does not exist. If you are using a custom skin file please allow the game to update.")
		return
	initialized_at = world.time
	// Perform a clean initialization
	window.initialize(inline_assets = list(
		get_asset_datum(/datum/asset/simple/tgui_common),
		get_asset_datum(/datum/asset/simple/tgui_panel),
	))
	window.send_asset(get_asset_datum(/datum/asset/simple/fontawesome))
	window.send_asset(get_asset_datum(/datum/asset/spritesheet/chat))
	request_telemetry()
	addtimer(CALLBACK(src, .proc/on_initialize_timed_out), 2 SECONDS)

/**
 * private
 *
 * Called when initialization has timed out.
 */
/datum/tgui_panel/proc/on_initialize_timed_out()
	// Currently does nothing but sending a message to old chat.
	SEND_TEXT(client, "<span class=\"userdanger\">Failed to load fancy chat, reverting to old chat. Certain features won't work.</span>")

/**
 * private
 *
 * Callback for handling incoming tgui messages.
 */
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
	if(type == "telemetry")
		analyze_telemetry(payload)
		return TRUE

/**
 * public
 *
 * Sends a round restart notification.
 */
/datum/tgui_panel/proc/send_roundrestart()
	window.send_message("roundrestart")

/**
 * public
 *
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
