/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/datum/tgui_window
	var/id
	var/client/client
	var/pooled
	var/pool_index
	var/is_browser = FALSE
	var/status = TGUI_WINDOW_CLOSED
	var/locked = FALSE
	var/datum/tgui/locked_by
	var/datum/subscriber_object
	var/subscriber_delegate
	var/fatally_errored = FALSE
	var/message_queue
	var/sent_assets = list()
	// Vars passed to initialize proc (and saved for later)
	var/inline_assets
	var/fancy

/**
 * public
 *
 * Create a new tgui window.
 *
 * required client /client
 * required id string A unique window identifier.
 */
/datum/tgui_window/New(client/client, id, pooled = FALSE)
	src.id = id
	src.client = client
	src.client.tgui_windows[id] = src
	src.pooled = pooled
	if(pooled)
		src.pool_index = TGUI_WINDOW_INDEX(id)

/**
 * public
 *
 * Initializes the window with a fresh page. Puts window into the "loading"
 * state. You can begin sending messages right after initializing. Messages
 * will be put into the queue until the window finishes loading.
 *
 * optional inline_assets list List of assets to inline into the html.
 * optional inline_html string Custom HTML to inject.
 * optional fancy bool If TRUE, will hide the window titlebar.
 */
/datum/tgui_window/proc/initialize(
		inline_assets = list(),
		inline_html = "",
		fancy = FALSE)
	log_tgui(client,
		context = "[id]/initialize",
		window = src)
	if(!client)
		return
	src.inline_assets = inline_assets
	src.fancy = fancy
	status = TGUI_WINDOW_LOADING
	fatally_errored = FALSE
	// Build window options
	var/options = "file=[id].html;can_minimize=0;auto_format=0;"
	// Remove titlebar and resize handles for a fancy window
	if(fancy)
		options += "titlebar=0;can_resize=0;"
	else
		options += "titlebar=1;can_resize=1;"
	// Generate page html
	var/html = SStgui.basehtml
	html = replacetextEx(html, "\[tgui:windowId]", id)
	// Process inline assets
	var/inline_styles = ""
	var/inline_scripts = ""
	for(var/datum/asset/asset in inline_assets)
		var/mappings = asset.get_url_mappings()
		for(var/name in mappings)
			var/url = mappings[name]
			// Not urlencoding since asset strings are considered safe
			if(copytext(name, -4) == ".css")
				inline_styles += "<link rel=\"stylesheet\" type=\"text/css\" href=\"[url]\">\n"
			else if(copytext(name, -3) == ".js")
				inline_scripts += "<script type=\"text/javascript\" defer src=\"[url]\"></script>\n"
		asset.send(client)
	html = replacetextEx(html, "<!-- tgui:styles -->\n", inline_styles)
	html = replacetextEx(html, "<!-- tgui:scripts -->\n", inline_scripts)
	// Inject custom HTML
	html = replacetextEx(html, "<!-- tgui:html -->\n", inline_html)
	// Open the window
	client << browse(html, "window=[id];[options]")
	// Instruct the client to signal UI when the window is closed.
	winset(client, id, "on-close=\"uiclose [id]\"")
	// Detect whether the control is a browser
	is_browser = winexists(client, id) == "BROWSER"

/**
 * public
 *
 * Checks if the window is ready to receive data.
 *
 * return bool
 */
/datum/tgui_window/proc/is_ready()
	return status == TGUI_WINDOW_READY

/**
 * public
 *
 * Checks if the window can be sanely suspended.
 *
 * return bool
 */
/datum/tgui_window/proc/can_be_suspended()
	return !fatally_errored \
		&& pooled \
		&& pool_index > 0 \
		&& pool_index <= TGUI_WINDOW_SOFT_LIMIT \
		&& status == TGUI_WINDOW_READY

/**
 * public
 *
 * Acquire the window lock. Pool will not be able to provide this window
 * to other UIs for the duration of the lock.
 *
 * Can be given an optional tgui datum, which will be automatically
 * subscribed to incoming messages via the on_message proc.
 *
 * optional ui /datum/tgui
 */
/datum/tgui_window/proc/acquire_lock(datum/tgui/ui)
	locked = TRUE
	locked_by = ui

/**
 * public
 *
 * Release the window lock.
 */
/datum/tgui_window/proc/release_lock()
	// Clean up assets sent by tgui datum which requested the lock
	if(locked)
		sent_assets = list()
	locked = FALSE
	locked_by = null

/**
 * public
 *
 * Subscribes the datum to consume window messages on a specified proc.
 *
 * Note, that this supports only one subscriber, because code for that
 * is simpler and therefore faster. If necessary, this can be rewritten
 * to support multiple subscribers.
 */
/datum/tgui_window/proc/subscribe(datum/object, delegate)
	subscriber_object = object
	subscriber_delegate = delegate

/**
 * public
 *
 * Unsubscribes the datum. Do not forget to call this when cleaning up.
 */
/datum/tgui_window/proc/unsubscribe(datum/object)
	subscriber_object = null
	subscriber_delegate = null

/**
 * public
 *
 * Close the UI.
 *
 * optional can_be_suspended bool
 */
/datum/tgui_window/proc/close(can_be_suspended = TRUE)
	if(!client)
		return
	if(can_be_suspended && can_be_suspended())
		log_tgui(client,
			context = "[id]/close (suspending)",
			window = src)
		status = TGUI_WINDOW_READY
		send_message("suspend")
		return
	log_tgui(client,
		context = "[id]/close",
		window = src)
	release_lock()
	status = TGUI_WINDOW_CLOSED
	message_queue = null
	// Do not close the window to give user some time
	// to read the error message.
	if(!fatally_errored)
		client << browse(null, "window=[id]")

/**
 * public
 *
 * Sends a message to tgui window.
 *
 * required type string Message type
 * required payload list Message payload
 * optional force bool Send regardless of the ready status.
 */
/datum/tgui_window/proc/send_message(type, payload, force)
	if(!client)
		return
	var/message = TGUI_CREATE_MESSAGE(type, payload)
	// Place into queue if window is still loading
	if(!force && status != TGUI_WINDOW_READY)
		if(!message_queue)
			message_queue = list()
		message_queue += list(message)
		return
	client << output(message, is_browser \
		? "[id]:update" \
		: "[id].browser:update")

/**
 * public
 *
 * Sends a raw payload to tgui window.
 *
 * required message string JSON+urlencoded blob to send.
 * optional force bool Send regardless of the ready status.
 */
/datum/tgui_window/proc/send_raw_message(message, force)
	if(!client)
		return
	// Place into queue if window is still loading
	if(!force && status != TGUI_WINDOW_READY)
		if(!message_queue)
			message_queue = list()
		message_queue += list(message)
		return
	client << output(message, is_browser \
		? "[id]:update" \
		: "[id].browser:update")

/**
 * public
 *
 * Makes an asset available to use in tgui.
 *
 * required asset datum/asset
 *
 * return bool - TRUE if any assets had to be sent to the client
 */
/datum/tgui_window/proc/send_asset(datum/asset/asset)
	if(!client || !asset)
		return
	sent_assets |= list(asset)
	. = asset.send(client)
	if(istype(asset, /datum/asset/spritesheet))
		var/datum/asset/spritesheet/spritesheet = asset
		send_message("asset/stylesheet", spritesheet.css_filename())
	send_message("asset/mappings", asset.get_url_mappings())

/**
 * private
 *
 * Sends queued messages if the queue wasn't empty.
 */
/datum/tgui_window/proc/flush_message_queue()
	if(!client || !message_queue)
		return
	for(var/message in message_queue)
		client << output(message, is_browser \
			? "[id]:update" \
			: "[id].browser:update")
	message_queue = null

/**
 * private
 *
 * Callback for handling incoming tgui messages.
 */
/datum/tgui_window/proc/on_message(type, payload, href_list)
	// Status can be READY if user has refreshed the window.
	if(type == "ready" && status == TGUI_WINDOW_READY)
		// Resend the assets
		for(var/asset in sent_assets)
			send_asset(asset)
	// Mark this window as fatally errored which prevents it from
	// being suspended.
	if(type == "log" && href_list["fatal"])
		fatally_errored = TRUE
	// Mark window as ready since we received this message from somewhere
	if(status != TGUI_WINDOW_READY)
		status = TGUI_WINDOW_READY
		flush_message_queue()
	// Pass message to UI that requested the lock
	if(locked && locked_by)
		var/prevent_default = locked_by.on_message(type, payload, href_list)
		if(prevent_default)
			return
	// Pass message to the subscriber
	else if(subscriber_object)
		var/prevent_default = call(
			subscriber_object,
			subscriber_delegate)(type, payload, href_list)
		if(prevent_default)
			return
	// If not locked, handle these message types
	switch(type)
		if("ping")
			send_message("pingReply", payload)
		if("suspend")
			close(can_be_suspended = TRUE)
		if("close")
			close(can_be_suspended = FALSE)
		if("openLink")
			client << link(href_list["url"])
		if("cacheReloaded")
			// Reinitialize
			initialize(inline_assets = inline_assets, fancy = fancy)
			// Resend the assets
			for(var/asset in sent_assets)
				send_asset(asset)
