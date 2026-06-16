/*!
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
	/// Each client notifies on protected playback, so this prevents spamming admins.
	var/static/admins_warned = FALSE

/datum/tgui_panel/New(client/client, id)
	src.client = client
	window = new(client, id)
	window.subscribe(src, PROC_REF(on_message))

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
	// Minimal sleep to defer initialization to after client constructor
	sleep(1 TICKS)
	initialized_at = world.time
	// Perform a clean initialization
	window.initialize(
		strict_mode = TRUE,
		assets = list(
			get_asset_datum(/datum/asset/simple/tgui_panel),
		))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/fontawesome))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/tgfont))
	window.send_asset(get_asset_datum(/datum/asset/spritesheet_batched/chat))
	// Other setup
	request_telemetry()
	addtimer(CALLBACK(src, PROC_REF(on_initialize_timed_out)), 5 SECONDS)
	window.send_message("testTelemetryCommand")

/**
 * private
 *
 * Called when initialization has timed out.
 */
/datum/tgui_panel/proc/on_initialize_timed_out()
	// Currently does nothing but sending a message to old chat.
	SEND_TEXT(client, span_userdanger("Failed to load fancy chat, click <a href='byond://?src=[REF(src)];reload_tguipanel=1'>HERE</a> to attempt to reload it."))

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
					"locked" = FALSE,
				),
			),
		))
		return TRUE

	if(type == "audio/setAdminMusicVolume")
		client.admin_music_volume = payload["volume"]
		return TRUE

	if(type == "audio/protected")
		if(!admins_warned)
			message_admins(span_notice("Audio returned a protected playback error, likely due to being copyrighted."))
			admins_warned = TRUE
			addtimer(VARSET_CALLBACK(src, admins_warned, FALSE), 10 SECONDS)
		return TRUE

	if(type == "telemetry")
		analyze_telemetry(payload)
		return TRUE

	if(type == "requestMetadata")
		send_metadata()
		return TRUE

/**
 * public
 *
 * Sends a round restart notification.
 */
/datum/tgui_panel/proc/send_roundrestart()
	window.send_message("roundrestart")

/**
 * private
 *
 * Sent when a client requests metadata - used for websocket stuff.
 */
/datum/tgui_panel/proc/send_metadata()
	var/static/list/webroot_asset_urls

	var/list/metadata = list(
		"game_version" = GLOB.game_version,
		"server_name" = CONFIG_GET(string/servername),
		"round_id" = GLOB.round_id,
		"map_name" = SSmapping.current_map?.map_name,
		"round_duration" = round(STATION_TIME_PASSED() / 10, 1),
		"gamestate" = SSticker.current_state,
	)
	// if we're using webroot - also pass along the webroot url and such, so we can embed chat logs with the proper styles/images if desired
	if(istype(SSassets.transport, /datum/asset_transport/webroot))
		if(isnull(webroot_asset_urls))
			webroot_asset_urls = list()
			for(var/asset_type in list(/datum/asset/simple/tgui_panel, /datum/asset/simple/namespaced/fontawesome, /datum/asset/simple/namespaced/tgfont, /datum/asset/spritesheet_batched/chat))
				var/datum/asset/asset = get_asset_datum(asset_type)
				webroot_asset_urls += asset.get_url_mappings()
		metadata["webroot"] = list(
			"base_url" = CONFIG_GET(string/asset_cdn_url),
			"assets" = webroot_asset_urls,
		)
	window.send_message("metadata", metadata)
