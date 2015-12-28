 /**
  * NanoUI
  *
  * Contains the NanoUI datum, and its procs.
  *
  * /tg/station user interface library
  * thanks to baystation12
  *
  * modified by neersighted
 **/

 /**
  * NanoUI datum:
  *
  * Represents a NanoUI.
 **/
/datum/nanoui
	var/mob/user // The mob who opened/is using the NanoUI.
	var/atom/movable/src_object // The object which owns the NanoUI.
	var/title // The title of te NanoUI.
	var/ui_key // The ui_key of the NanoUI. This allows multiple UIs for one src_object.
	var/window_id // The window_id for browse() and onclose().
	var/width = 0 // The window width.
	var/height = 0 // The window height
	var/window_options = list( // Extra options to winset().
	  "focus" = 0,
	  "titlebar" = 1,
	  "can_resize" = 1,
	  "can_minimize" = 1,
	  "can_maximize" = 0,
	  "can_close" = 1,
	  "auto_format" = 0
	)
	var/atom/ref = null // An extra ref to call when the window is closed.
	var/layout = "nanotrasen" // The layout to be used for this UI.
	var/template // The template to be used for this UI.
	var/auto_update = 1 // Update the NanoUI every MC tick.
	var/list/initial_data // The data (and datastructure) used to initialize the NanoUI
	var/status = NANO_INTERACTIVE // The status/visibility of the NanoUI.
	var/datum/nano_state/state = null // Topic state used to determine status. Topic states are in interactions/.
	var/datum/nanoui/master_ui	 // The parent NanoUI.
	var/list/datum/nanoui/children = list() // Children of this NanoUI.

 /**
  * public
  *
  * Create a new NanoUI.
  *
  * required user mob The mob who opened/is using the NanoUI.
  * required src_object atom/movable The object which owns the NanoUI.
  * required ui_key string The ui_key of the NanoUI.
  * required template string The template to render the NanoUI content with.
  * optional title string The title of the NanoUI.
  * optional width int The window width.
  * optional height int The window height.
  * optional ref atom An extra ref to use when the window is closed.
  * optional master_ui datum/nanoui The parent NanoUI.
  * optional state datum/nano_state The state used to determine status.
  *
  * return datum/nanoui The requested NanoUI.
 **/
/datum/nanoui/New(mob/user, atom/movable/src_object, ui_key, template, \
					title = 0, width = 0, height = 0, \
					atom/ref = null, datum/nanoui/master_ui = null, \
					datum/nano_state/state = default_state)
	src.user = user
	src.src_object = src_object
	src.ui_key = ui_key
	src.window_id = "\ref[src_object]-[ui_key]"

	set_template(template)

	if(title)
		src.title = sanitize(title)
	if(width)
		src.width = width
	if(height)
		src.height = height

	if(ref)
		src.ref = ref

	src.master_ui = master_ui
	if(master_ui)
		master_ui.children += src
	src.state = state

	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/nanoui)
	assets.send(user)

 /**
  * public
  *
  * Open this NanoUI (and initialize it with data).
  *
  * optional data list The data to intialize the UI with.
 **/
/datum/nanoui/proc/open(list/data = null)
	if(!user.client)
		return // Bail if there is no client.

	update_status(push = 0) // Update the window status.
	if(status == NANO_CLOSE)
		return // Bail if we should close.

	if(!initial_data)
		if(!data) // If we don't have initial_data and data was not passed, get data from the src_object.
			data = src_object.get_ui_data(user)
		set_initial_data(data) // Otherwise use the passed data.

	var/window_size = ""
	if(width && height) // If we have a width and height, use them.
		window_size = "size=[width]x[height];"

	user << browse(get_html(), "window=[window_id];[window_size][list2params(window_options)]") // Open the window.
	winset(user, window_id, "on-close=\"nanoclose \ref[src]\"") // Instruct the client to signal NanoUI when the window is closed.
	SSnano.on_open(src)

 /**
  * public
  *
  * Reinitialize the NanoUI.
  * (Possibly with a new template and/or data).
  *
  * optional template string The filename of the new template.
  * optional data list The new initial data.
 **/
/datum/nanoui/proc/reinitialize(template, list/data)
	if(template)
		set_template(template) // Set a new template.
	if(data)
		set_initial_data(data) // Replace the initial_data.
	open()

 /**
  * public
  *
  * Close the NanoUI, and all its children.
 **/
/datum/nanoui/proc/close()
	user << browse(null, "window=[window_id]") // Close the window.
	SSnano.on_close(src)
	for(var/datum/nanoui/child in children) // Loop through and close all children.
		child.close()

 /**
  * public
  *
  * Sets the browse() window options for this NanoUI.
  *
  * required window_options list The window options to set.
 **/
/datum/nanoui/proc/set_window_options(list/window_options)
	src.window_options = window_options

 /**
  * public
  *
  * Set the layout for this NanoUI.
  * This loads custom layout styles and templates for this NanoUI.
  *
  * required layout string The new UI layout.
 **/
/datum/nanoui/proc/set_layout(layout)
	src.layout = lowertext(layout)

 /**
  * public
  *
  * Set the template for this NanoUI.
  *
  * required template string The new UI template.
 **/
/datum/nanoui/proc/set_template(template)
	src.template = lowertext(template)

 /**
  * public
  *
  * Enable/disable auto-updating of the NanoUI.
  *
  * required state bool Enable/disable auto-updating.
 **/
/datum/nanoui/proc/set_auto_update(state = 1)
	auto_update = state

 /**
  * private
  *
  * Set the data to initialize the NanoUI with.
  * The datastructure cannot be changed by subsequent updates.
  *
  * optional data list The data/datastructure to initialize the NanoUI with.
 **/
/datum/nanoui/proc/set_initial_data(list/data)
	initial_data = data

 /**
  * private
  *
  * Generate HTML for this NanoUI.
  *
  * return string NanoUI HTML output.
 **/
/datum/nanoui/proc/get_html()
	// Generate JSON.
	var/list/send_data = get_send_data(initial_data)
	var/send_data_json = JSON.stringify(send_data)
	// Strip junk.
	send_data_json = replacetext(send_data_json, "'", "&apos;")
	send_data_json = replacetext(send_data_json, "ÿ", "")

	// Populate it.
	var/send_html = replacetext(SSnano.html, "!!data!!", send_data_json)
	return send_html

 /**
  * private
  *
  * Get the config data/datastructure to initialize the NanoUI with.
  *
  * return list The config data.
 **/
/datum/nanoui/proc/get_config_data()
	var/list/config_data = list(
			"title" = title,
			"status" = status,
			"layout" = layout,
			"window" = window_id,
			"ref" = "\ref[src]",
			"user" = list(
				"name" = user.name,
				"fancy" = user.client.prefs.nanoui_fancy,
				"ref" = "\ref[user]"
			),
			"srcObject" = list(
				"name" = src_object.name,
				"ref" = "\ref[src_object]"
			),
			"templates" = list(
				"layout" = "_[layout]",
				"content" = "[template]"
			)
		)
	return config_data

 /**
  * private
  *
  * Package the data to send to the UI.
  * This is the (regular) data and config data, bundled together.
  *
  * return list The packaged data.
 **/
/datum/nanoui/proc/get_send_data(list/data)
	var/list/send_data = list()

	send_data["config"] = get_config_data()
	if(!isnull(data))
		send_data["data"] = data

	return send_data

 /**
  * private
  *
  * Handle clicks from the NanoUI.
  * Call the src_object's ui_act() if status is NANO_INTERACTIVE.
  * If the src_object's ui_act() returns 1, update all UIs attacked to it.
 **/
/datum/nanoui/Topic(href, href_list)
	update_status(push = 0) // Update the window state.
	if(status != NANO_INTERACTIVE || user != usr)
		return // If UI is not interactive or usr calling Topic is not the UI user.

	var/action = href_list["nano"] // Pull the action out.
	href_list -= "nano"

	var/update = src_object.ui_act(action, href_list, state) // Call ui_act() on the src_object.
	if(src_object && update)
		SSnano.update_uis(src_object) // If we have a src_object and its ui_act() told us to update.

 /**
  * private
  *
  * Update the NanoUI. Only updates the contents/layout if update is true,
  * otherwise only updates the status.
  *
  * optional force bool If the UI should be forced to update.
 **/
/datum/nanoui/process(force = 0)
	if(!src_object || !user) // If the object or user died (or something else), abort.
		close()
		return

	if(status && (force || auto_update))
		update() // Update the UI if the status and update settings allow it.
	else
		update_status(push = 1) // Otherwise only update status.

 /**
  * private
  *
  * Push data to an already open NanoUI.
  *
  * required data list The data to send.
  * optional force bool If the update should be sent regardless of state.
 **/
/datum/nanoui/proc/push_data(data, force = 0)
	update_status(push = 0) // Update the window state.
	if(status <= NANO_DISABLED && !force)
		return // Cannot update UI, we have no visibility.

	var/list/send_data = get_send_data(data) // Get the data to send.

	// Send the new data to the recieveUpdate() Javascript function.
	user << output(url_encode(JSON.stringify(send_data)), "[window_id].browser:receiveUpdate")


 /**
  * private
  *
  * Updates the UI by interacting with the src_object again, which will hopefully
  * call try_ui_update on it.
  *
  * optional force_open bool If force_open should be passed to ui_interact.
 **/
/datum/nanoui/proc/update(force_open = 0)
	src_object.ui_interact(user, ui_key, src, force_open, master_ui, state)

 /**
  * private
  *
  * Update the status/visibility of the NanoUI for its user.
  *
  * optional push bool Push an update to the UI (an update is always sent for NANO_DISABLED).
 **/
/datum/nanoui/proc/update_status(push = 0)
	var/new_status = src_object.nano_state(user, state)
	if(master_ui)
		new_status = min(new_status, master_ui.status)

	if(new_status == NANO_CLOSE)
		close()
	else
		set_status(new_status, push)

 /**
  * private
  *
  * Set the status/visibility of the NanoUI.
  *
  * required status int The status to set (NANO_CLOSE/NANO_DISABLED/NANO_UPDATE/NANO_INTERACTIVE).
  * optional push bool Push an update to the UI (an update is always sent for NANO_DISABLED).
 **/
/datum/nanoui/proc/set_status(status, push = 0)
	if(src.status != status) // Only update if status has changed.
		if(src.status == NANO_DISABLED)
			src.status = status
			if(push)
				update()
		else
			src.status = status
			if(status == NANO_DISABLED || push) // Update if the UI just because disabled, or a push is requested.
				push_data(null, force = 1)