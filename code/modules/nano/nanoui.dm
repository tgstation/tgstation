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

// Debug Things
#define USE_MIN 0
#define USE_LESS 0

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
	var/on_close_logic = 1 // Enable legacy onclose() logic.
	var/atom/ref = null // An extra ref to use when the window is closed.
	var/window_options = "focus=0;can_close=1;can_minimize=1;can_maximize=0;can_resize=1;titlebar=1;" // Extra options to winset().
	var/list/stylesheets = list() // The list of CSS stylesheets to apply to the NanoUI..
	var/list/scripts = list() // The list of Javascript scripts to apply to the NanoUI.
	var/templates[0] // The list of NanoUI templates available to the NanoUI.
	var/layout = "default" // The layout used to load alternate layouts and CSS.
	var/auto_update = 1 // Update the NanoUI every MC tick.
	var/auto_update_layout = 0 // Re-render the layout every update.
	var/auto_update_content = 1 // Re-render the content every update.
	var/list/initial_data // The data (and datastructure) used to initialize the NanoUI
	var/status = NANO_INTERACTIVE // The status/visibility of the NanoUI.
	var/datum/topic_state/state = null // Topic state used to determine status. Topic states are in interactions/.
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
  * optional state datum/topic_state The state used to determine status.
  *
  * return datum/nanoui The requested NanoUI.
 **/
/datum/nanoui/New(mob/user, atom/movable/src_object, ui_key, template, \
					title = 0, width = 0, height = 0, \
					atom/ref = null, datum/nanoui/master_ui = null, \
					datum/topic_state/state = default_state)
	src.user = user
	src.src_object = src_object
	src.ui_key = ui_key
	src.window_id = "[ui_key]\ref[src_object]"

	add_template("main", template)

	if (title)
		src.title = sanitize(title)
	if (width)
		src.width = width
	if (height)
		src.height = height

	if (ref)
		src.ref = ref

	src.master_ui = master_ui
	if(master_ui)
		master_ui.children += src
	src.state = state

	add_common_assets()

	var/datum/asset/assets = get_asset_datum(/datum/asset/nanoui)
	assets.send(user, template)

 /**
  * private
  *
  * Add the assets required by all NanoUIs.
 **/
/datum/nanoui/proc/add_common_assets()
	add_script("nanoui")
	add_script("nanoui.util")
	add_script("nanoui.template")
	add_script("nanoui.helpers")
	add_script("nanoui.handlers")

	add_stylesheet("nanoui")

 /**
  * private
  *
  * Set the status/visibility of the NanoUI.
  *
  * required state int The status to set (NANO_CLOSE/NANO_DISABLED/NANO_UPDATE/NANO_INTERACTIVE).
  * optional push_update bool Push an update to the UI (an update is always sent for NANO_DISABLED).
 **/
/datum/nanoui/proc/set_status(state, push_update = 0)
	if (state != status) // Only update if status has changed.
		if (status == NANO_DISABLED)
			status = state
			if (push_update)
				update()
		else
			status = state
			if (push_update || status == 0) // Force an update if NANO_DISABLED.
				push_data(null, 1)

 /**
  * private
  *
  * Update the status/visibility of the NanoUI for its user.
  *
  * optional push_update bool Push an update to the UI (an update is always sent for NANO_DISABLED).
 **/
/datum/nanoui/proc/update_status(push_update = 0)
	var/new_status = src_object.CanUseTopic(user, state)
	if(master_ui)
		new_status = min(new_status, master_ui.status)

	set_status(new_status, push_update)
	if(new_status == NANO_CLOSE)
		close()

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
  * Get the config data/datastructure to initialize the NanoUI with.
  *
  * return list The config data.
 **/
/datum/nanoui/proc/get_config_data()
	var/list/config_data = list(
			"title" = title,
			"srcObject" = list(
				"name" = src_object.name
			),
			"status" = status,
			"autoUpdateLayout" = auto_update_layout,
			"autoUpdateContent" = auto_update_content,
			"user" = list(
				"name" = user.name
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
	if (!isnull(data))
		send_data["data"] = data

	return send_data

 /**
  * public
  *
  * Sets the browse() window options for this NanoUI.
  *
  * required window_options string The window options to set.
 **/
/datum/nanoui/proc/set_window_options(window_options)
	src.window_options = window_options

 /**
  * public
  *
  * Add a template to the NanoUI.
  * This must be called before the NanoUI is opened.
  *
  * required key string The key used to reference this file in the frontend.
  * required file string The path of the template file to add.
 **/
/datum/nanoui/proc/add_template(key, file)
	templates[key] = "[file].dot"

 /**
  * public
  *
  * Add a script to the NanoUI.
  * This must be called before the NanoUI is opened.
  *
  * required file string The path of the script file to add.
 **/
/datum/nanoui/proc/add_script(file)
	scripts.Add("[file].js")

 /**
  * public
  *
  * Add a stylesheet to the NanoUI.
  * This must be called before the NanoUI is opened.
  *
  * required file string The path of the stylesheet file to add.
 **/
/datum/nanoui/proc/add_stylesheet(file)
	if(USE_LESS)
		stylesheets.Add("[file].less")
	else
		stylesheets.Add("[file].css")

 /**
  * public
  *
  * Set the layout for this NanoUI.
  * This loads custom layout styles and templates for this NanoUI.
  *
  * required layout_key string The new layout key.
 **/
/datum/nanoui/proc/set_layout(layout)
	src.layout = lowertext(layout)

 /**
  * public
  *
  * Enable/disable auto-updating of the NanoUI layout.
  *
  * required state bool Enable/disable auto-updating of the layout.
 **/
/datum/nanoui/proc/set_auto_update_layout(state)
	auto_update_layout = state

 /**
  * public
  *
  * Enable/disable auto-updating of the NanoUI content.
  *
  * required state bool Enable/disable auto-updating of the content.
 **/
/datum/nanoui/proc/set_auto_update_content(state)
	auto_update_content = state

 /**
  * public
  *
  * Enable/disable legacy on_close logic.
  *
  * required state bool Enable/disable the logic.
 **/
/datum/nanoui/proc/use_on_close_logic(state)
	on_close_logic = state

 /**
  * private
  *
  * Generate HTML for this NanoUI.
  *
  * return string NanoUI HTML output.
 **/
/datum/nanoui/proc/get_html()
	// Add files based on the layout key.
	add_template("layout", "layout_[layout]")
	add_stylesheet("layout_[layout]")

	// Some string hacks for .less/.min.js.
	var/less = ""
	var/less_html = ""
	var/min = ""
	if(USE_LESS)
		less = "/less"
		less_html = "<script type='text/javascript' src='https://cdnjs.cloudflare.com/ajax/libs/less.js/2.5.3/less.[min]js'></script>"
	if(USE_MIN)
		min = "min."

	// Generate <script> and <link> tags.
	var/script_html = ""
	for (var/script in scripts)
		script_html += "<script type='text/javascript' src='[script]'></script>"
	var/stylesheet_html = ""
	for (var/stylesheet in stylesheets)
		stylesheet_html += "<link rel='stylesheet[less]' type='text/css' href='[stylesheet]' />"

	// Generate template JSON.
	var/template_data_json = "{}"
	if (templates.len > 0)
		template_data_json = list2json(templates)

	// Generate data JSON.
	var/list/send_data = get_send_data(initial_data)
	var/initial_data_json = replacetext(replacetext(list2json_usecache(send_data), "&#34;", "&amp;#34;"), "'", "&#39;")

	// Generate URL parameters JSON.
	var/url_parameters_json = list2json(list("src" = "\ref[src]"))

	return {"
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv='X-UA-Compatible' content='IE=edge'>
		<script type='text/javascript'>
			function receiveUpdate(dataString) {
				"use strict";
				if (typeof nanoui !== 'undefined') {
					nanoui.emit('serverUpdate', dataString);
				}
			};
		</script>
		<link rel='stylesheet' type='text/css' href='https://cdnjs.cloudflare.com/ajax/libs/normalize/3.0.3/normalize.[min]css' />
		<link rel='stylesheet' type='text/css' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.5.0/css/font-awesome.[min]css' />
		[stylesheet_html]
		<!--\[if IE 8]>
		<script type='text/javascript' src='https://cdnjs.cloudflare.com/ajax/libs/html5shiv/3.7.3/html5shiv.[min]js'></script>
		<script type='text/javascript' src='https//cdnjs.cloudflare.com/ajax/libs/ie8/0.2.6/ie8.js'></script>
		<!\[endif]-->
		<script type='text/javascript' src='https://cdnjs.cloudflare.com/ajax/libs/dom4/1.5.2/dom4.js'></script>
		<script type='text/javascript' src='https://cdnjs.cloudflare.com/ajax/libs/es5-shim/4.3.1/es5-shim.[min]js'></script>
		<script type='text/javascript' src='https://cdnjs.cloudflare.com/ajax/libs/json3/3.3.2/json3.[min]js'></script>
		<script type='text/javascript' src='https://cdnjs.cloudflare.com/ajax/libs/eddy/0.7.0/eddy.dom.js'></script>
		<script type='text/javascript' src='https://cdn.rawgit.com/Mikhus/jsurl/master/url.[min]js'></script>
		<script type='text/javascript' src='https://cdnjs.cloudflare.com/ajax/libs/dot/1.0.3/doT.[min]js'></script>
		[less_html]
		[script_html]
	</head>
	<body id='body' data-template-data='[template_data_json]' data-initial-data='[initial_data_json]' data-url-parameters='[url_parameters_json]'>
		<div id='layout'></div>
		<noscript>
			<div id='noscript'>
				<h1>Javascript Required</h1>
				<hr />
				<p>Javascript is required in order to use this NanoUI interface.</p>
				<p>Please enable Javascript in Internet Explorer, and restart your game.</p>
			</div>
		</noscript>
	</body>
</html>
	"}

 /**
  * public
  *
  * Open this NanoUI (and initialize it with data).
  *
  * optional data list The data to intialize the UI with.
 **/
/datum/nanoui/proc/open(list/data = null)
	if(!user.client) return

	if (!initial_data)
		if (!data) // If we don't have initial_data and data was not passed, get data from the src_object.
			data = src_object.get_ui_data(user)
		set_initial_data(data) // Otherwise use the passed data.

	var/window_size = ""
	if (width && height) // If we have a width and height, use them.
		window_size = "size=[width]x[height];"
	update_status(push_update = 0) // Update the window state.
	if (status == NANO_CLOSE)
		return // Bail if we should close.

	user << browse(get_html(), "window=[window_id];[window_size][window_options]") // Open the window.
	winset(user, "mapwindow.map", "focus=true") // Return keyboard focus to map.
	winset(user, window_id, "on-close=\"nanoclose \ref[src]\"") // Instruct the client to signal NanoUI when the window is closed.
	SSnano.ui_opened(src) // Call the opened handler.

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
		add_template("main", template) // Replace the 'main' template.
	if(data)
		set_initial_data(data) // Replace the initial_data.
	open()

 /**
  * public
  *
  * Close the NanoUI, and all its children.
 **/
/datum/nanoui/proc/close()
	set_auto_update(0) // Disable auto-updates.
	user << browse(null, "window=[window_id]") // Close the window.
	SSnano.ui_closed(src) // Call the closed handler.
	for(var/datum/nanoui/child in children) // Loop through and close all children.
		child.close()

 /**
  * private
  *
  * Push data to an already open NanoUI.
  *
  * required data list The data to send.
  * optional force_push bool If the update should be sent regardless of state.
 **/
/datum/nanoui/proc/push_data(data, force_push = 0)
	update_status(push_update = 0) // Update the window state.
	if (status == NANO_DISABLED && !force_push)
		return // Cannot update UI, we have no visibility.

	var/list/send_data = get_send_data(data) // Get the data to send.

	// Send the new data to the recieveUpdate() Javascript function.
	user << output(list2params(list(list2json_usecache(send_data))),"[window_id].browser:receiveUpdate")

 /**
  * private
  *
  * Handle clicks from the NanoUI.
  * Call the src_object's Topic() if status is NANO_INTERACTIVE.
  * If the src_object's Topic() returns 1, update all UIs attacked to it.
 **/
/datum/nanoui/Topic(href, href_list)
	update_status(push_update = 0) // Update the window state.
	if (status != NANO_INTERACTIVE || user != usr)
		return // If UI is not interactive or usr calling Topic is not the UI user.

	var/update = src_object.Topic(href, href_list, 0, state) // Call Topic() on the src_object.

	if (src_object && update)
		SSnano.update_uis(src_object) // If we have a src_object and its Topic() told us to update.

 /**
  * private
  *
  * Update the NanoUI. Only updates the contents/layout if update is true,
  * otherwise only updates the status.
  *
  * optional update bool If the UI should be updated (or just the status).
 **/
/datum/nanoui/process(update = 0)
	if (!src_object || !user) // If the object or user died (or something else), abort.
		close()
		return

	if (status && (update || auto_update))
		update() // Update the UI if the status and update settings allow it.
	else
		update_status(push_update = 1) // Otherwise only update status.

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
