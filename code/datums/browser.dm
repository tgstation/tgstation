/datum/browser
	var/mob/user
	var/title = ""
	/// window_id is used as the window name for browse and onclose
	var/window_id
	var/width = 0
	var/height = 0
	var/datum/weakref/source_ref = null
	/// window option is set using window_id
	var/window_options = "can_close=1;can_minimize=1;can_maximize=0;can_resize=1;titlebar=1;"
	var/list/stylesheets = list()
	var/list/scripts = list()
	var/head_elements
	var/body_elements
	var/head_content = ""
	var/content = ""

/datum/browser/New(mob/user, window_id, title = "", width = 0, height = 0, atom/source = null)
	if(IS_CLIENT_OR_MOCK(user))
		var/client/client_user = user
		user = client_user.mob
	src.user = user
	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(user_deleted))
	src.window_id = window_id
	if (title)
		src.title = format_text(title)
	if (width)
		src.width = width
	if (height)
		src.height = height
	if (source)
		src.source_ref = WEAKREF(source)

/datum/browser/proc/user_deleted(datum/source)
	SIGNAL_HANDLER
	user = null

/datum/browser/proc/add_head_content(head_content)
	src.head_content += head_content

/datum/browser/proc/set_head_content(head_content)
	src.head_content = head_content

/datum/browser/proc/set_window_options(window_options)
	src.window_options = window_options

/datum/browser/proc/add_stylesheet(name, file)
	if (istype(name, /datum/asset/spritesheet))
		var/datum/asset/spritesheet/sheet = name
		stylesheets["spritesheet_[sheet.name].css"] = "data/spritesheets/[sheet.name]"
	else if (istype(name, /datum/asset/spritesheet_batched))
		var/datum/asset/spritesheet_batched/sheet = name
		stylesheets["spritesheet_[sheet.name].css"] = "data/spritesheets/[sheet.name]"
	else
		var/asset_name = "[name].css"

		stylesheets[asset_name] = file

		if (!SSassets.cache[asset_name])
			SSassets.transport.register_asset(asset_name, file)

/datum/browser/proc/add_script(name, file)
	scripts["[ckey(name)].js"] = file
	SSassets.transport.register_asset("[ckey(name)].js", file)

/datum/browser/proc/set_content(content)
	src.content = content

/datum/browser/proc/add_content(content)
	src.content += content

/datum/browser/proc/get_header()
	var/datum/asset/simple/namespaced/common/common_asset = get_asset_datum(/datum/asset/simple/namespaced/common)
	var/list/new_head_content = list()
	new_head_content += "<link rel='stylesheet' type='text/css' href='[common_asset.get_url_mappings()["common.css"]]'>"
	for (var/file in stylesheets)
		new_head_content += "<link rel='stylesheet' type='text/css' href='[SSassets.transport.get_asset_url(file)]'>"

	if(user.client?.window_scaling && user.client?.window_scaling != 1 && !user.client?.prefs.read_preference(/datum/preference/toggle/ui_scale) && width && height)
		new_head_content += {"
			<style>
				body {
					zoom: [100 / user.client?.window_scaling]%;
				}
			</style>
			"}

	for (var/file in scripts)
		new_head_content += "<script type='text/javascript' src='[SSassets.transport.get_asset_url(file)]'></script>"

	head_content += new_head_content.Join()
	return {"<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
		<meta http-equiv='X-UA-Compatible' content='IE=edge'>
		[head_content]
	</head>
	<body scroll=auto>
		<div class='uiWrapper'>
			[title ? "<div class='uiTitleWrapper'><div class='uiTitle'><tt>[title]</tt></div></div>" : ""]
			<div class='uiContent'>
	"}

//" This is here because else the rest of the file looks like a string in notepad++.
/datum/browser/proc/get_footer()
	return {"
			</div>
		</div>
	</body>
</html>"}

/datum/browser/proc/get_content()
	return {"
		[get_header()]
		[content]
		[get_footer()]
	"}

/datum/browser/proc/open(use_on_close = TRUE)
	if(isnull(window_id)) //null check because this can potentially nuke goonchat
		WARNING("Browser [title] tried to open with a null ID")
		to_chat(user, span_userdanger("The [title] browser you tried to open failed a sanity check! Please report this on GitHub!"))
		return

	var/window_size = ""
	if(width && height)
		if(user.client?.prefs?.read_preference(/datum/preference/toggle/ui_scale))
			var/scaling = user.client.window_scaling
			window_size = "size=[width * scaling]x[height * scaling];"
		else
			window_size = "size=[width]x[height];"

	var/datum/asset/simple/namespaced/common/common_asset = get_asset_datum(/datum/asset/simple/namespaced/common)
	common_asset.send(user)
	if (length(stylesheets))
		SSassets.transport.send_assets(user, stylesheets)
	if (length(scripts))
		SSassets.transport.send_assets(user, scripts)
	DIRECT_OUTPUT(user, browse(get_content(), "window=[window_id];[window_size][window_options]"))
	if (use_on_close)
		setup_onclose()

/datum/browser/proc/setup_onclose()
	set waitfor = 0 //winexists sleeps, so we don't need to.
	for (var/i in 1 to 10)
		if (!user?.client || !winexists(user, window_id))
			continue
		var/atom/send_ref
		if(source_ref)
			send_ref = source_ref.resolve()
			if(!send_ref)
				source_ref = null
		onclose(user, window_id, send_ref)

/datum/browser/proc/close()
	if(!isnull(window_id))//null check because this can potentially nuke goonchat
		user << browse(null, "window=[window_id]")
	else
		WARNING("Browser [title] tried to close with a null ID")

/datum/browser/modal/alert/New(user, message, title, button_1 = "Ok", button_2, button_3, steal_focus = TRUE, timeout = 600 SECONDS)
	if (!user)
		return

	var/list/display_list = list()
	display_list += {"<center><b>[message]</b></center><br />
		<div style="text-align:center">
		<a style="font-size:large;float:[( button_2 ? "left" : "right" )]" href='byond://?src=[REF(src)];button=1'>[button_1]</a>"}

	if (button_2)
		display_list += {"<a style="font-size:large;[( button_3 ? "" : "float:right" )]" href='byond://?src=[REF(src)];button=2'>[button_2]</a>"}

	if (button_3)
		display_list += {"<a style="font-size:large;float:right" href='byond://?src=[REF(src)];button=3'>[button_3]</a>"}

	display_list += {"</div>"}

	..(user, ckey("[user]-[message]-[title]-[world.time]-[rand(1,10000)]"), title, 350, 150, src, steal_focus, timeout)
	set_content(display_list.Join())

/datum/browser/modal/alert/Topic(href,href_list)
	if (href_list["close"] || !user || !user.client)
		open_time = 0
		return
	if (href_list["button"])
		var/button = text2num(href_list["button"])
		if (button <= 3 && button >= 1)
			selected_button = button
	open_time = 0
	close()

/**
 * **DEPRECATED: USE tgui_alert(...) INSTEAD**
 *
 * Designed as a drop in replacement for alert(); functions the same. (outside of needing user specified)
 * Arguments:
 * * user - The user to show the alert to.
 * * message - The textual body of the alert.
 * * title - The title of the alert's window.
 * * button_1 - The first button option.
 * * button_2 - The second button option.
 * * button_3 - The third button option.
 * * steal_focus - Boolean operator controlling if the alert will steal the user's window focus.
 * * timeout - The timeout of the window, after which no responses will be valid.
 */
/proc/tg_alert(mob/user, message, title, button_1 = "Ok", button_2, button_3, steal_focus = TRUE, timeout = 600 SECONDS)
	if (!user)
		user = usr
	if (!ismob(user))
		if (!istype(user, /client))
			return
		var/client/user_client = user
		user = user_client.mob

	// Get user's response using a modal
	var/datum/browser/modal/alert/window = new(user, message, title, button_1, button_2, button_3, steal_focus, timeout)
	window.open()
	window.wait()
	switch(window.selected_button)
		if (1)
			return button_1
		if (2)
			return button_2
		if (3)
			return button_3

/datum/browser/modal
	var/open_time = 0
	var/timeout
	var/selected_button = 0
	var/steal_focus

/datum/browser/modal/New(user, window_id, title = 0, width = 0, height = 0, atom/source = null, steal_focus = TRUE, timeout = 600 SECONDS)
	..()
	src.steal_focus = steal_focus
	if (!src.steal_focus)
		window_options += "focus=false;"
	src.timeout = timeout

/datum/browser/modal/close()
	. = ..()
	open_time = 0

/datum/browser/modal/open(use_on_close)
	set waitfor = FALSE
	open_time = world.time
	use_on_close = TRUE

	if (steal_focus)
		. = ..()
	else
		var/focused_window = winget(user, null, "focus")
		. = ..()

		//waits for the window to show up client side before attempting to un-focus it
		//winexists sleeps until it gets a reply from the client, so we don't need to bother sleeping
		for (var/i in 1 to 10)
			if (user && winexists(user, window_id))
				if (focused_window)
					winset(user, focused_window, "focus=true")
				else
					winset(user, "mapwindow", "focus=true")
				break
	if (timeout)
		addtimer(CALLBACK(src, PROC_REF(close)), timeout)

/datum/browser/modal/proc/wait()
	while (open_time && selected_button <= 0 && (!timeout || open_time + timeout > world.time))
		stoplag(1)

/datum/browser/modal/list_picker
	var/values_list = list()

/datum/browser/modal/list_picker/New(user, message, title, button_1 = "Ok", button_2, button_3, steal_focus = TRUE, timeout = FALSE, list/values, input_type = "checkbox", width, height, slide_color)
	if (!user)
		return

	var/list/display_list = list()
	display_list += {"<form><input type="hidden" name="src" value="[REF(src)]"><ul class="sparse">"}
	if (input_type == "checkbox" || input_type == "radio")
		for (var/option in values)
			var/div_slider = slide_color
			if(!option["allowed_edit"])
				div_slider = "locked"
			display_list += {"<li>
						<label class="switch">
							<input type="[input_type]" value="1" name="[option["name"]]"[option["checked"] ? " checked" : ""][option["allowed_edit"] ? "" : " onclick='return false' onkeydown='return false'"]>
								<div class="slider [div_slider ? "[div_slider]" : ""]"></div>
									<span>[option["name"]]</span>
						</label>
						</li>"}
	else
		for (var/option in values)
			display_list += {"<li><input id="name="[option["name"]]"" style="width: 50px" type="[type]" name="[option["name"]]" value="[option["value"]]">
			<label for="[option["name"]]">[option["name"]]</label></li>"}
	display_list += {"</ul><div style="text-align:center">
		<button type="submit" name="button" value="1" style="font-size:large;float:[( button_2 ? "left" : "right" )]">[button_1]</button>"}

	if (button_2)
		display_list += {"<button type="submit" name="button" value="2" style="font-size:large;[( button_3 ? "" : "float:right" )]">[button_2]</button>"}

	if (button_3)
		display_list += {"<button type="submit" name="button" value="3" style="font-size:large;float:right">[button_3]</button>"}

	display_list += {"</form></div>"}
	..(user, ckey("[user]-[message]-[title]-[world.time]-[rand(1,10000)]"), title, width, height, src, steal_focus, timeout)
	set_content(display_list.Join())

/datum/browser/modal/list_picker/Topic(href, list/href_list)
	if (href_list["close"] || !user || !user.client)
		open_time = 0
		return
	if (href_list["button"])
		var/button = text2num(href_list["button"])
		if (button <= 3 && button >= 1)
			selected_button = button
	values_list = href_list.Copy()
	values_list -= list("close", "button", "src")
	open_time = 0
	close()

/proc/present_picker(mob/user, message, title, button_1 = "Ok", button_2, button_3, steal_focus = TRUE, timeout = 600 SECONDS, list/values, input_type = "checkbox", width, height, slide_color)
	if (!ismob(user))
		if (!istype(user, /client))
			return
		var/client/user_client = user
		user = user_client.mob
	var/datum/browser/modal/list_picker/window = new(user, message, title, button_1, button_2, button_3, steal_focus, timeout, values, input_type, width, height, slide_color)
	window.open()
	window.wait()
	if (window.selected_button)
		return list("button" = window.selected_button, "values" = window.values_list)

/proc/input_bitfield(mob/user, title, bitfield, current_value, width = 350, height = 350, slide_color, allowed_edit_field = ALL)
	var/list/bitflags = get_valid_bitflags(bitfield)
	if (!user || !length(bitflags))
		return
	var/list/picker_list = list()
	for (var/bit_name in bitflags)
		var/bit_value = bitflags[bit_name]
		// Gotta make it TRUE/FALSE sorry brother
		var/can_edit = !!(allowed_edit_field & bit_value)
		var/enabled = !!(current_value & bit_value)
		picker_list += list(list("checked" = enabled, "value" = bit_value, "name" = bit_name, "allowed_edit" = can_edit))

	var/list/result = present_picker(user, "", title, button_1 = "Save", button_2 = "Cancel", timeout = FALSE, values = picker_list, width = width, height = height, slide_color = slide_color)
	if (!islist(result))
		return
	if (result["button"] == 2) // If the user pressed the cancel button
		return

	var/result_bitfield = NONE
	for (var/flag_name in result["values"])
		result_bitfield |= bitflags[flag_name]
	return result_bitfield

/datum/browser/modal/pref_like_picker
	var/settings = list()
	var/icon/preview_icon = null
	var/datum/callback/preview_update

/datum/browser/modal/pref_like_picker/New(mob/user, message, title, steal_focus = TRUE, timeout = 600 SECONDS, list/settings, width, height)
	if (!user)
		return
	src.settings = settings

	..(user, ckey("[user]-[message]-[title]-[world.time]-[rand(1,10000)]"), title, width, height, src, steal_focus, timeout)
	set_content(show_choices(user))

/datum/browser/modal/pref_like_picker/proc/show_choices(mob/user)
	if (settings["preview_callback"])
		var/datum/callback/callback = settings["preview_callback"]
		preview_icon = callback.Invoke(settings)
		if (preview_icon)
			user << browse_rsc(preview_icon, "previewicon.png")

	var/list/display_list = list()
	for (var/name in settings["mainsettings"])
		var/setting = settings["mainsettings"][name]
		if (setting["type"] == "datum")
			if (setting["subtypesonly"])
				display_list += "<b>[setting["desc"]]:</b> <a href='byond://?src=[REF(src)];setting=[name];task=input;subtypesonly=1;type=datum;path=[setting["path"]]'>[setting["value"]]</a><BR>"
			else
				display_list += "<b>[setting["desc"]]:</b> <a href='byond://?src=[REF(src)];setting=[name];task=input;type=datum;path=[setting["path"]]'>[setting["value"]]</a><BR>"
		else
			display_list += "<b>[setting["desc"]]:</b> <a href='byond://?src=[REF(src)];setting=[name];task=input;type=[setting["type"]]'>[setting["value"]]</a><BR>"

	if (preview_icon)
		display_list += "<td valign='center'>"
		display_list += "<div class='statusDisplay'><center><img src=previewicon.png width=[preview_icon.Width()] height=[preview_icon.Height()]></center></div>"
		display_list += "</td>"

	display_list += "</tr></table>"
	display_list += "<hr><center><a href='byond://?src=[REF(src)];button=1'>Ok</a> "
	display_list += "</center>"

	return display_list.Join()

/datum/browser/modal/pref_like_picker/Topic(href,href_list)
	if (href_list["close"] || !user || !user.client)
		open_time = 0
		return

	if (href_list["task"] == "input")
		var/setting_key = href_list["setting"]
		var/list/setting = settings["mainsettings"][setting_key]
		switch (href_list["type"])
			if ("datum")
				var/parent_path = text2path(href_list["path"])
				var/list/paths
				if (href_list["subtypesonly"])
					paths = subtypesof(parent_path)
				else
					paths = typesof(parent_path)

				var/new_value = pick_closest_path(null, make_types_fancy(paths))
				if (!isnull(new_value))
					setting["value"] = new_value

			if ("string")
				setting["value"] = stripped_input(user, "Enter new value for [setting["desc"]]", "Enter new value for [setting["desc"]]", setting["value"])
			if ("number")
				setting["value"] = input(user, "Enter new value for [setting["desc"]]", "Enter new value for [setting["desc"]]") as num
			if ("color")
				setting["value"] = input(user, "Enter new value for [setting["desc"]]", "Enter new value for [setting["desc"]]", setting["value"]) as color
			if ("boolean")
				setting["value"] = (setting["value"] == "Yes") ? "No" : "Yes"
			if ("ckey")
				setting["value"] = input(user, "[setting["desc"]]?") in (list("none") + GLOB.directory)
		if (setting["callback"])
			var/datum/callback/callback = setting["callback"]
			settings = callback.Invoke(settings)

	if (href_list["button"])
		var/button = text2num(href_list["button"])
		if (button <= 3 && button >= 1)
			selected_button = button

	if (selected_button != 1)
		set_content(show_choices(user))
		open()
		return

	open_time = 0
	close()

/proc/present_pref_like_picker(mob/user, message, title, steal_focus = TRUE, timeout = 600 SECONDS, list/settings, width, height)
	if (!ismob(user))
		if (!istype(user, /client))
			return
		var/client/user_client = user
		user = user_client.mob
	var/datum/browser/modal/pref_like_picker/window = new(user, message, title, steal_focus, timeout, settings, width, height)
	window.open()
	window.wait()
	if (window.selected_button)
		return list("button" = window.selected_button, "settings" = window.settings)

/// Registers the on-close verb for a browse window (client/verb/windowclose)
/// this will be called when the close-button of a window is pressed.
///
/// This is usually only needed for devices that regularly update the browse window,
/// e.g. canisters, timers, etc.
///
/// windowid should be the specified window name
/// e.g. code is : user << browse(text, "window=fred")
/// then use : onclose(user, "fred")
///
/// Optionally, specify the "source" parameter as the controlled atom (usually src)
// to pass a "close=1" parameter to the atom's Topic() proc for special handling.
/// Otherwise, the user mob's machine var will be reset directly.
///
/proc/onclose(mob/user, windowid, atom/source = null)
	if(!user.client)
		return
	var/param = "null"
	if(source)
		param = "[REF(source)]"

	winset(user, windowid, "on-close=\".windowclose [param]\"")

/// the on-close client verb
/// called when a browser popup window is closed after registering with proc/onclose()
/// if a valid atom reference is supplied, call the atom's Topic() with "close=1"
/// otherwise, just reset the client mob's machine var.
/client/verb/windowclose(atomref as text)
	set hidden = TRUE // hide this verb from the user's panel
	set name = ".windowclose" // no autocomplete on cmd line

	if(atomref == "null")
		return
	// if passed a real atomref
	var/atom/hsrc = locate(atomref) // find the reffed atom
	var/href = "close=1"
	if(!hsrc)
		return
	usr = src.mob
	src.Topic(href, params2list(href), hsrc) // this will direct to the atom's

