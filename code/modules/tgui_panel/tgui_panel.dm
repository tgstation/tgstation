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

	if(type == "verbs/request_verbs")
		client.init_verbs()
		return TRUE

	if(type == "verbs/request_typepaths")
		var/parent_text = payload["parent"]
		var/parent_type = text2path(parent_text)
		if(isnull(parent_type))
			parent_type = /datum
		var/list/children = list()
		for(var/child_type in typesof(parent_type))
			if(child_type == parent_type)
				continue
			// Only include direct children (one level deeper)
			var/child_text = "[child_type]"
			var/parent_len = length(parent_text || "/datum")
			var/remainder = copytext(child_text, parent_len + 1)
			if(findtext(remainder, "/", 2))
				continue
			children += child_text
		window.send_message("verbs/typepaths", list("parent" = parent_text, "paths" = children))
		return TRUE

	if(type == "verbs/request_targets")
		var/verb_path = text2path(payload["verb_type"])
		if(!verb_path)
			return TRUE
		if(!(verb_path in client.verbs) && !(client.mob && (verb_path in client.mob.verbs)))
			return TRUE
		// Check game verbs first, then admin verbs
		var/list/arg_list
		var/datum/verb_metadata/meta = SSverbs.verbs_by_verb_path[verb_path]
		if(meta)
			arg_list = meta.arguments
		else
			var/datum/admin_verb/av = SSadmin_verbs.admin_verbs_by_verb_path[verb_path]
			if(av)
				arg_list = av.metadata?.arguments
		if(!length(arg_list))
			return TRUE
		var/datum/verb_arg_metadata/entity_arg
		for(var/datum/verb_arg_metadata/arg in arg_list)
			if(arg.arg_type & (VERB_ARG_TYPE_MOB | VERB_ARG_TYPE_OBJ | VERB_ARG_TYPE_TURF | VERB_ARG_TYPE_AREA | VERB_ARG_TYPE_DATUM | VERB_ARG_TYPE_ATOM))
				entity_arg = arg
				break
		if(!entity_arg)
			return TRUE
		var/list/target_data = list()
		var/list/source_atoms = get_targets_for_arg(entity_arg)
		for(var/atom/target in source_atoms)
			target_data += list(list("name" = "[target]", "ref" = REF(target)))
		window.send_message("verbs/targets", list("targets" = target_data))
		return TRUE

	if(type == "verbs/invoke")
		var/verb_path = text2path(payload["verb_type"])
		if(!verb_path)
			return TRUE
		var/datum/verb_metadata/meta = SSverbs.verbs_by_verb_path[verb_path]
		// Check admin verbs too
		var/datum/admin_verb/admin_meta = SSadmin_verbs.admin_verbs_by_verb_path[verb_path]
		if(admin_meta)
			var/list/raw_args = payload["args"]
			if(!islist(raw_args))
				raw_args = list()
			var/list/resolved_args = list()
			for(var/key in raw_args)
				var/value = raw_args[key]
				if(istext(value))
					var/located = locate(value)
					if(located)
						value = located
				resolved_args[key] = value
			SSadmin_verbs.dynamic_invoke_verb(client, admin_meta.type, resolved_args)
			return TRUE
		if(!meta)
			return TRUE
		var/target = resolve_verb_target(verb_path)
		if(!target)
			return TRUE
		var/list/raw_args = payload["args"]
		if(!islist(raw_args))
			raw_args = list()
		var/list/resolved_args = list()
		for(var/key in raw_args)
			var/value = raw_args[key]
			if(istext(value))
				var/located = locate(value)
				if(located)
					value = located
			resolved_args[key] = value
		call(target, meta.body_path)(arglist(resolved_args))
		return TRUE

	if(type == "requestMetadata")
		send_metadata()
		return TRUE

/datum/tgui_panel/proc/resolve_verb_target(verb_path)
	if(verb_path in client.verbs)
		return client
	if(client.mob && (verb_path in client.mob.verbs))
		return client.mob
	return null

/datum/tgui_panel/proc/get_targets_for_arg(datum/verb_arg_metadata/arg)
	var/list/targets = list()
	switch(arg.source)
		if(VERB_ARG_SOURCE_WORLD)
			if(arg.arg_type & VERB_ARG_TYPE_MOB)
				return GLOB.mob_list
			if(arg.arg_type & VERB_ARG_TYPE_AREA)
				return get_sorted_areas()
			if(arg.arg_type & VERB_ARG_TYPE_TURF)
				for(var/mob/player in GLOB.player_list)
					var/turf/player_turf = get_turf(player)
					if(player_turf)
						targets |= player_turf
				return targets
			if(arg.arg_type & (VERB_ARG_TYPE_OBJ | VERB_ARG_TYPE_DATUM | VERB_ARG_TYPE_ATOM))
				if(client.mob)
					return view(client.view, client.mob)
		if(VERB_ARG_SOURCE_VIEW)
			if(!client.mob)
				return targets
			var/list/visible = view(client.view, client.mob)
			if(arg.arg_type & VERB_ARG_TYPE_MOB)
				for(var/mob/target in visible)
					targets += target
			else if(arg.arg_type & VERB_ARG_TYPE_OBJ)
				for(var/obj/target in visible)
					targets += target
			else if(arg.arg_type & VERB_ARG_TYPE_TURF)
				for(var/turf/target in visible)
					targets += target
			else
				return visible
	return targets

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
