 /**
  * tgui
  *
  * /tg/station user interface library
 **/

 /**
  * tgui datum (represents a UI).
 **/
/datum/tgui
	var/mob/user // The mob who opened/is using the UI.
	var/datum/src_object // The object which owns the UI.
	var/title // The title of te UI.
	var/ui_key // The ui_key of the UI. This allows multiple UIs for one src_object.
	var/window_id // The window_id for browse() and onclose().
	var/width = 0 // The window width.
	var/height = 0 // The window height
	var/window_options = list( // Extra options to winset().
	  "focus" = FALSE,
	  "titlebar" = TRUE,
	  "can_resize" = TRUE,
	  "can_minimize" = TRUE,
	  "can_maximize" = FALSE,
	  "can_close" = TRUE,
	  "auto_format" = FALSE
	)
	var/style = "nanotrasen" // The style to be used for this UI.
	var/interface // The interface (template) to be used for this UI.
	var/autoupdate = TRUE // Update the UI every MC tick.
	var/initialized = FALSE // If the UI has been initialized yet.
	var/list/initial_data // The data (and datastructure) used to initialize the UI.
	var/status = UI_INTERACTIVE // The status/visibility of the UI.
	var/datum/ui_state/state = null // Topic state used to determine status/interactability.
	var/datum/tgui/master_ui // The parent UI.
	var/list/datum/tgui/children = list() // Children of this UI.
	var/titlebar = TRUE
	var/custom_browser_id = FALSE

 /**
  * public
  *
  * Create a new UI.
  *
  * required user mob The mob who opened/is using the UI.
  * required src_object datum The object or datum which owns the UI.
  * required ui_key string The ui_key of the UI.
  * required interface string The interface used to render the UI.
  * optional title string The title of the UI.
  * optional width int The window width.
  * optional height int The window height.
  * optional master_ui datum/tgui The parent UI.
  * optional state datum/ui_state The state used to determine status.
  *
  * return datum/tgui The requested UI.
 **/
/datum/tgui/New(mob/user, datum/src_object, ui_key, interface, title, width = 0, height = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state, browser_id = null)
	src.user = user
	src.src_object = src_object
	src.ui_key = ui_key
	src.window_id = browser_id ? browser_id : "\ref[src_object]-[ui_key]"
	src.custom_browser_id = browser_id ? TRUE : FALSE

	set_interface(interface)

	if(title)
		src.title = sanitize(title)
	if(width)
		src.width = width
	if(height)
		src.height = height

	src.master_ui = master_ui
	if(master_ui)
		master_ui.children += src
	src.state = state

	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/tgui)
	assets.send(user)

 /**
  * public
  *
  * Open this UI (and initialize it with data).
 **/
/datum/tgui/proc/open()
	if(!user.client)
		return // Bail if there is no client.

	update_status(push = 0) // Update the window status.
	if(status < UI_UPDATE)
		return // Bail if we're not supposed to open.

	if(!initial_data)
		set_initial_data(src_object.ui_data(user)) // Get the UI data.

	var/window_size = ""
	if(width && height) // If we have a width and height, use them.
		window_size = "size=[width]x[height];"

	var/debugable = check_rights_for(user.client, R_DEBUG)
	user << browse(get_html(debugable), "window=[window_id];[window_size][list2params(window_options)]") // Open the window.
	if (!custom_browser_id)
		winset(user, window_id, "on-close=\"uiclose \ref[src]\"") // Instruct the client to signal UI when the window is closed.
	SStgui.on_open(src)

 /**
  * public
  *
  * Reinitialize the UI.
  * (Possibly with a new interface and/or data).
  *
  * optional template string The name of the new interface.
  * optional data list The new initial data.
 **/
/datum/tgui/proc/reinitialize(interface, list/data)
	if(interface)
		set_interface(interface) // Set a new interface.
	if(data)
		set_initial_data(data) // Replace the initial_data.
	open()

 /**
  * public
  *
  * Close the UI, and all its children.
 **/
/datum/tgui/proc/close()
	user << browse(null, "window=[window_id]") // Close the window.
	SStgui.on_close(src)
	for(var/datum/tgui/child in children) // Loop through and close all children.
		child.close()
	children.Cut()
	state = null
	master_ui = null
	qdel(src)

 /**
  * public
  *
  * Sets the browse() window options for this UI.
  *
  * required window_options list The window options to set.
 **/
/datum/tgui/proc/set_window_options(list/window_options)
	src.window_options = window_options

 /**
  * public
  *
  * Set the style for this UI.
  *
  * required style string The new UI style.
 **/
/datum/tgui/proc/set_style(style)
	src.style = lowertext(style)

 /**
  * public
  *
  * Set the interface (template) for this UI.
  *
  * required interface string The new UI interface.
 **/
/datum/tgui/proc/set_interface(interface)
	src.interface = lowertext(interface)

 /**
  * public
  *
  * Enable/disable auto-updating of the UI.
  *
  * required state bool Enable/disable auto-updating.
 **/
/datum/tgui/proc/set_autoupdate(state = 1)
	autoupdate = state

 /**
  * private
  *
  * Set the data to initialize the UI with.
  * The datastructure cannot be changed by subsequent updates.
  *
  * optional data list The data/datastructure to initialize the UI with.
 **/
/datum/tgui/proc/set_initial_data(list/data)
	initial_data = data

 /**
  * private
  *
  * Generate HTML for this UI.
  *
  * optional bool inline If the JSON should be inlined into the HTML (for debugging).
  *
  * return string UI HTML output.
 **/
/datum/tgui/proc/get_html(var/inline)
	var/html
	// Poplate HTML with JSON if we're supposed to inline.
	if(inline)
		html = replacetextEx(SStgui.basehtml, "{}", get_json(initial_data))
	else
		html = SStgui.basehtml
	html = replacetextEx(html, "\[ref]", "\ref[src]")
	html = replacetextEx(html, "\[style]", style)
	return html

 /**
  * private
  *
  * Get the config data/datastructure to initialize the UI with.
  *
  * return list The config data.
 **/
/datum/tgui/proc/get_config_data()
	var/list/config_data = list(
			"title"     = title,
			"status"    = status,
			"screen"	= src_object.ui_screen,
			"style"     = style,
			"interface" = interface,
			"fancy"     = user.client.prefs.tgui_fancy,
			"locked"    = user.client.prefs.tgui_lock && !custom_browser_id,
			"window"    = window_id,
			"ref"       = "\ref[src]",
			"user"      = list(
				"name"  = user.name,
				"ref"   = "\ref[user]"
			),
			"srcObject" = list(
				"name" = "[src_object]",
				"ref"  = "\ref[src_object]"
			),
			"titlebar" = titlebar
		)
	return config_data

 /**
  * private
  *
  * Package the data to send to the UI, as JSON.
  * This includes the UI data and config_data.
  *
  * return string The packaged JSON.
 **/
/datum/tgui/proc/get_json(list/data)
	var/list/json_data = list()

	json_data["config"] = get_config_data()
	if(!isnull(data))
		json_data["data"] = data

	// Generate the JSON.
	var/json = json_encode(json_data)
	// Strip #255/improper.
	json = replacetext(json, "\proper", "")
	json = replacetext(json, "\improper", "")
	return json

 /**
  * private
  *
  * Handle clicks from the UI.
  * Call the src_object's ui_act() if status is UI_INTERACTIVE.
  * If the src_object's ui_act() returns 1, update all UIs attacked to it.
 **/
/datum/tgui/Topic(href, href_list)
	if(user != usr)
		return // Something is not right here.

	var/action = href_list["action"]
	var/params = href_list; params -= "action"

	switch(action)
		if("tgui:initialize")
			user << output(url_encode(get_json(initial_data)), "[custom_browser_id ? window_id : "[window_id].browser"]:initialize")
			initialized = TRUE
		if("tgui:view")
			if(params["screen"])
				src_object.ui_screen = params["screen"]
			SStgui.update_uis(src_object)
		if("tgui:link")
			user << link(params["url"])
		if("tgui:fancy")
			user.client.prefs.tgui_fancy = TRUE
		if("tgui:nofrills")
			user.client.prefs.tgui_fancy = FALSE
		else
			update_status(push = 0) // Update the window state.
			if(src_object.ui_act(action, params, src, state)) // Call ui_act() on the src_object.
				SStgui.update_uis(src_object) // Update if the object requested it.

 /**
  * private
  *
  * Update the UI.
  * Only updates the data if update is true, otherwise only updates the status.
  *
  * optional force bool If the UI should be forced to update.
 **/
/datum/tgui/process(force = 0)
	var/datum/host = src_object.ui_host()
	if(!src_object || !host || !user) // If the object or user died (or something else), abort.
		close()
		return

	if(status && (force || autoupdate))
		update() // Update the UI if the status and update settings allow it.
	else
		update_status(push = 1) // Otherwise only update status.

 /**
  * private
  *
  * Push data to an already open UI.
  *
  * required data list The data to send.
  * optional force bool If the update should be sent regardless of state.
 **/
/datum/tgui/proc/push_data(data, force = 0)
	update_status(push = 0) // Update the window state.
	if(!initialized)
		return // Cannot update UI if it is not set up yet.
	if(status <= UI_DISABLED && !force)
		return // Cannot update UI, we have no visibility.

	// Send the new JSON to the update() Javascript function.
	user << output(url_encode(get_json(data)), "[custom_browser_id ? window_id : "[window_id].browser"]:update")

 /**
  * private
  *
  * Updates the UI by interacting with the src_object again, which will hopefully
  * call try_ui_update on it.
  *
  * optional force_open bool If force_open should be passed to ui_interact.
 **/
/datum/tgui/proc/update(force_open = 0)
	src_object.ui_interact(user, ui_key, src, force_open, master_ui, state)

 /**
  * private
  *
  * Update the status/visibility of the UI for its user.
  *
  * optional push bool Push an update to the UI (an update is always sent for UI_DISABLED).
 **/
/datum/tgui/proc/update_status(push = 0)
	var/status = src_object.ui_status(user, state)
	if(master_ui)
		status = min(status, master_ui.status)

	set_status(status, push)
	if(status == UI_CLOSE)
		close()

 /**
  * private
  *
  * Set the status/visibility of the UI.
  *
  * required status int The status to set (UI_CLOSE/UI_DISABLED/UI_UPDATE/UI_INTERACTIVE).
  * optional push bool Push an update to the UI (an update is always sent for UI_DISABLED).
 **/
/datum/tgui/proc/set_status(status, push = 0)
	if(src.status != status) // Only update if status has changed.
		if(src.status == UI_DISABLED)
			src.status = status
			if(push)
				update()
		else
			src.status = status
			if(status == UI_DISABLED || push) // Update if the UI just because disabled, or a push is requested.
				push_data(null, force = 1)

/datum/tgui/proc/set_titlebar(value)
	titlebar = value
