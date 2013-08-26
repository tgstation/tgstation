#define STATUS_INTERACTIVE 2 // GREEN Visability
#define STATUS_UPDATE 1 // ORANGE Visability
#define STATUS_DISABLED 0 // RED Visability

/datum/nanoui
	var/mob/user
	var/atom/movable/src_object
	var/title
	var/ui_key
	var/window_id // window_id is used as the window name for browse and onclose
	var/width = 0
	var/height = 0
	var/atom/ref = null
	var/on_close_logic = 1
	var/window_options = "focus=0;can_close=1;can_minimize=1;can_maximize=0;can_resize=1;titlebar=1;" // window option is set using window_id
	var/list/stylesheets = list()
	var/list/scripts = list()
	var/templates[0]
	var/title_image
	var/head_elements
	var/body_elements
	var/head_content = ""
	var/content = "<div id='mainTemplate'></div>" // the #mainTemplate div will contain the compiled "main" template html
	var/list/initial_data[0]
	var/is_auto_updating = 0
	var/status = STATUS_INTERACTIVE
	
	// Only allow users with a certain user.stat to get updates. Defaults to 0 (concious)
	var/allowed_user_stat = 0 // -1 = ignore, 0 = alive, 1 = unconcious or alive, 2 = dead concious or alive


/datum/nanoui/New(nuser, nsrc_object, nui_key, ntemplate, ntitle = 0, nwidth = 0, nheight = 0, var/atom/nref = null)
	user = nuser
	src_object = nsrc_object
	ui_key = nui_key
	window_id = "[ui_key]\ref[src_object]"

	add_template("main", ntemplate)

	if (ntitle)
		title = ntitle
	if (nwidth)
		width = nwidth
	if (nheight)
		height = nheight
	if (nref)
		ref = nref

	add_common_assets()	

/datum/nanoui/proc/add_common_assets()
	add_script("libraries.min.js") // The jQuery library
	add_script("nano_update.js") // The NanoUpdate JS, this is used to receive updates and apply them.
	add_script("nano_config.js") // The NanoUpdate JS, this is used to receive updates and apply them.
	add_script("nano_base_helpers.js") // The NanoBaseHelpers JS, this is used to set up template helpers which are common to all templates
	add_stylesheet("shared.css") // this CSS sheet is common to all UIs
	add_stylesheet("icons.css") // this CSS sheet is common to all UIs

/datum/nanoui/proc/set_status(state, push_update)
	if (state != status)
		status = state
		if (push_update || !status)
			push_data(list(), 1) // Update the UI, force the update in case the status is 0
	else
		status = state

/datum/nanoui/proc/update_status(push_update = 0)
	if (istype(user, /mob/living/silicon/ai))
		set_status(STATUS_INTERACTIVE, push_update) // interactive (green visibility)
	else if (istype(user, /mob/living/silicon/robot))
		if (src_object in view(7, user)) // robots can see and interact with things they can see within 7 tiles
			set_status(STATUS_INTERACTIVE, push_update) // interactive (green visibility)
		else
			set_status(STATUS_DISABLED, push_update) // no updates, completely disabled (red visibility)
	else
		var/dist = get_dist(src_object, user)
		
		if (dist > 4)
			close()
			return
			
		if ((allowed_user_stat > -1) && (user.stat > allowed_user_stat))
			set_status(STATUS_DISABLED, push_update) // no updates, completely disabled (red visibility)
		else if (user.restrained() || user.lying)
			set_status(STATUS_UPDATE, push_update) // update only (orange visibility)
		else if (!(src_object in view(4, user))) // If the src object is not in visable, set status to 0
			set_status(STATUS_DISABLED, push_update) // interactive (green visibility)			
		else if (dist <= 1)
			set_status(STATUS_INTERACTIVE, push_update) // interactive (green visibility)
		else if (dist <= 2)
			set_status(STATUS_UPDATE, push_update) // update only (orange visibility)
		else if (dist <= 4)
			set_status(STATUS_DISABLED, push_update) // no updates, completely disabled (red visibility)

/datum/nanoui/proc/set_auto_update(state = 1)
	is_auto_updating = state

/datum/nanoui/proc/set_initial_data(data)
	initial_data = modify_data(data)

/datum/nanoui/proc/add_head_content(nhead_content)
	head_content = nhead_content

/datum/nanoui/proc/set_window_options(nwindow_options)
	window_options = nwindow_options

/datum/nanoui/proc/set_title_image(ntitle_image)
	//title_image = ntitle_image

/datum/nanoui/proc/add_stylesheet(file)
	stylesheets.Add(file)

/datum/nanoui/proc/add_script(file)
	scripts.Add(file)

/datum/nanoui/proc/add_template(name, file)
	templates[name] = file

/datum/nanoui/proc/set_content(ncontent)
	content = ncontent

/datum/nanoui/proc/add_content(ncontent)
	content += ncontent

/datum/nanoui/proc/use_on_close_logic(nsetting)
	on_close_logic = nsetting

/datum/nanoui/proc/get_header()
	for (var/filename in stylesheets)
		head_content += "<link rel='stylesheet' type='text/css' href='[filename]'>"

	var/title_attributes = "id='uiTitle'"
	if (title_image)
		title_attributes = "id='uiTitle icon' style='background-image: url([title_image]);'"

	var/templatel_data[0]
	for (var/key in templates)
		templatel_data[key] = templates[key];

	var/template_data_json = "{}" // An empty JSON object
	if (templatel_data.len > 0)
		template_data_json = list2json(templatel_data)

	var/initial_data_json = "{}" // An empty JSON object
	if (initial_data.len > 0)
		initial_data_json = list2json(initial_data)

	var/url_parameters_json = list2json(list("src" = "\ref[src]"))

	return {"<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<head>
		[head_content]
	</head>
	<body scroll=auto data-url-parameters='[url_parameters_json]' data-template-data='[template_data_json]' data-initial-data='[initial_data_json]'>
		<script type='text/javascript'>
			function receiveUpdateData(jsonString)
			{
				// We need both jQuery and NanoUpdate to be able to recieve data
				if (typeof NanoUpdate != 'undefined' && typeof jQuery != 'undefined')
				{
					NanoUpdate.receiveUpdateData(jsonString);
				}
				else
				{
					alert('receiveUpdateData error: something is not defined!');
					if (typeof NanoUpdate == 'undefined')
					{
						alert('NanoUpdate not defined!');
					}
					if (typeof jQuery == 'undefined')
					{
						alert('jQuery not defined!');
					}
				}
				// At the moment any data received before those libraries are loaded will be lost
			}
		</script>
		<div id='uiWrapper'>
			[title ? "<div id='uiTitleWrapper'><div id='uiStatusIcon' class='icon24 uiStatusGood'></div><div [title_attributes]>[title]</div><div id='uiTitleFluff'></div></div>" : ""]
			<div id='uiContent'>
	"}
	
/datum/nanoui/Topic(href, href_list)
	update_status(0) // update the status
	if (status != STATUS_INTERACTIVE || user != usr) // If UI is not interactive or usr calling Topic is not the UI user
		return
		
	if (src_object.Topic(href, href_list))
		nanomanager.update_uis(src_object) // update all UIs attached to src_object	

/datum/nanoui/proc/get_footer()
	var/scriptsContent = ""

	for (var/filename in scripts)
		scriptsContent += "<script type='text/javascript' src='[filename]'></script>"

	return {"
				[scriptsContent]
			</div>
		</div>
	</body>
</html>"}

/datum/nanoui/proc/get_content()
	return {"
	[get_header()]
	[content]
	[get_footer()]
	"}

/datum/nanoui/proc/open()
	var/window_size = ""
	if (width && height)
		window_size = "size=[width]x[height];"
	update_status(0)
	user << browse(get_content(), "window=[window_id];[window_size][window_options]")
	on_close_winset()
	//onclose(user, window_id)
	nanomanager.ui_opened(src)

/datum/nanoui/proc/close()
	is_auto_updating = 0
	nanomanager.ui_closed(src)
	user << browse(null, "window=[window_id]")

/datum/nanoui/proc/on_close_winset()
	if(!user.client)
		world << "ERROR: No user.client!?"
		return
	var/params = "\ref[src]"

	winset(user, window_id, "on-close=\"nanoclose [params]\"")

/datum/nanoui/proc/process(update = 0)	
	if (status && (update || is_auto_updating))
		src_object.ui_interact(user, ui_key) // Update the UI (update_status() is called whenever a UI is updated)
	else
		update_status(1) // Not updating UI, so lets check here if status has changed

/datum/nanoui/proc/modify_data(data)
	data["ui"] = list(
			"status" = status,
			"user" = list("name" = user.name)
		)
	//user << list2json(data)
	return data

/datum/nanoui/proc/push_data(data, force_push = 0)
	update_status(0)
	if (status == STATUS_DISABLED && !force_push)
		return // Cannot update UI, no visibility

	data = modify_data(data)

	user << output(list2params(list(list2json(data))),"[window_id].browser:receiveUpdateData")
	on_close_winset()

/client/verb/nanoclose(var/uiref as text)
	set hidden = 1						// hide this verb from the user's panel
	set name = "nanoclose"			// no autocomplete on cmd line

	//world << "world [src] looking for [uiref]"

	var/datum/nanoui/ui = locate(uiref)

	if (ui)
		//world << "[src] UI found [ui.window_id]"
		ui.close()

		if (ui.on_close_logic)
			if(ui.ref)
				var/href = "close=1"
				//world << "[src] Topic [href] [ui.ref]"
				src.Topic(href, params2list(href), ui.ref)	// this will direct to the atom's
														// Topic() proc via client.Topic()
			else
				// no atomref specified (or not found)
				// so just reset the user mob's machine var
				if(src && src.mob)
					//world << "[src] was [src.mob.machine], setting to null"
					src.mob.unset_machine()
	else
		world << "[src] UI not found"
	return