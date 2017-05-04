/datum/browser
	var/mob/user
	var/title
	var/window_id // window_id is used as the window name for browse and onclose
	var/width = 0
	var/height = 0
	var/atom/ref = null
	var/window_options = "can_close=1;can_minimize=1;can_maximize=0;can_resize=1;titlebar=1;" // window option is set using window_id
	var/stylesheets[0]
	var/scripts[0]
	var/title_image
	var/head_elements
	var/body_elements
	var/head_content = ""
	var/content = ""


/datum/browser/New(nuser, nwindow_id, ntitle = 0, nwidth = 0, nheight = 0, var/atom/nref = null)

	user = nuser
	window_id = nwindow_id
	if (ntitle)
		title = format_text(ntitle)
	if (nwidth)
		width = nwidth
	if (nheight)
		height = nheight
	if (nref)
		ref = nref
	add_stylesheet("common", 'html/browser/common.css') // this CSS sheet is common to all UIs

/datum/browser/proc/add_head_content(nhead_content)
	head_content = nhead_content

/datum/browser/proc/set_window_options(nwindow_options)
	window_options = nwindow_options

/datum/browser/proc/set_title_image(ntitle_image)
	//title_image = ntitle_image

/datum/browser/proc/add_stylesheet(name, file)
	stylesheets["[ckey(name)].css"] = file
	register_asset("[ckey(name)].css", file)

/datum/browser/proc/add_script(name, file)
	scripts["[ckey(name)].js"] = file
	register_asset("[ckey(name)].js", file)

/datum/browser/proc/set_content(ncontent)
	content = ncontent

/datum/browser/proc/add_content(ncontent)
	content += ncontent

/datum/browser/proc/get_header()
	var/file
	for (file in stylesheets)
		head_content += "<link rel='stylesheet' type='text/css' href='[file]'>"

	for (file in scripts)
		head_content += "<script type='text/javascript' src='[file]'></script>"

	var/title_attributes = "class='uiTitle'"
	if (title_image)
		title_attributes = "class='uiTitle icon' style='background-image: url([title_image]);'"

	return {"<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<head>
		[head_content]
	</head>
	<body scroll=auto>
		<div class='uiWrapper'>
			[title ? "<div class='uiTitleWrapper'><div [title_attributes]><tt>[title]</tt></div></div>" : ""]
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

/datum/browser/proc/open(use_onclose = 1)
	var/window_size = ""
	if (width && height)
		window_size = "size=[width]x[height];"
	if (stylesheets.len)
		send_asset_list(user, stylesheets, verify=FALSE)
	if (scripts.len)
		send_asset_list(user, scripts, verify=FALSE)
	user << browse(get_content(), "window=[window_id];[window_size][window_options]")
	if (use_onclose)
		setup_onclose()

/datum/browser/proc/setup_onclose()
	set waitfor = 0 //winexists sleeps, so we don't need to.
	for (var/i in 1 to 10)
		if (user && winexists(user, window_id))
			onclose(user, window_id, ref)
			break

/datum/browser/proc/close()
	user << browse(null, "window=[window_id]")

/datum/browser/alert
	var/selectedbutton = 0
	var/opentime = 0
	var/timeout
	var/stealfocus

/datum/browser/alert/New(User,Message,Title,Button1="Ok",Button2,Button3,StealFocus = 1,Timeout=6000)
	if (!User)
		return

	var/output =  {"<center><b>[Message]</b></center><br />
		<div style="text-align:center">
		<a style="font-size:large;float:[( Button2 ? "left" : "right" )]" href="?src=\ref[src];button=1">[Button1]</a>"}

	if (Button2)
		output += {"<a style="font-size:large;[( Button3 ? "" : "float:right" )]" href="?src=\ref[src];button=2">[Button2]</a>"}

	if (Button3)
		output += {"<a style="font-size:large;float:right" href="?src=\ref[src];button=3">[Button3]</a>"}

	output += {"</div>"}

	..(User, ckey("[User]-[Message]-[Title]-[world.time]-[rand(1,10000)]"), Title, 350, 150, src)
	set_content(output)
	stealfocus = StealFocus
	if (!StealFocus)
		window_options += "focus=false;"
	timeout = Timeout

/datum/browser/alert/open()
	set waitfor = 0
	opentime = world.time

	if (stealfocus)
		. = ..(use_onclose = 1)
	else
		var/focusedwindow = winget(user, null, "focus")
		. = ..(use_onclose = 1)

		//waits for the window to show up client side before attempting to un-focus it
		//winexists sleeps until it gets a reply from the client, so we don't need to bother sleeping
		for (var/i in 1 to 10)
			if (user && winexists(user, window_id))
				if (focusedwindow)
					winset(user, focusedwindow, "focus=true")
				else
					winset(user, "mapwindow", "focus=true")
				break
	if (timeout)
		addtimer(CALLBACK(src, .proc/close), timeout)

/datum/browser/alert/close()
	.=..()
	opentime = 0

/datum/browser/alert/proc/wait()
	while (opentime && selectedbutton <= 0 && (!timeout || opentime+timeout >= world.time))
		stoplag()

/datum/browser/alert/Topic(href,href_list)
	if (href_list["close"] || !user || !user.client)
		opentime = 0
		return
	if (href_list["button"])
		var/button = text2num(href_list["button"])
		if (button <= 3 && button >= 1)
			selectedbutton = button
	opentime = 0
	close()

//designed as a drop in replacement for alert(); functions the same. (outside of needing User specified)
/proc/tgalert(var/mob/User, Message, Title, Button1="Ok", Button2, Button3, StealFocus = 1, Timeout = 6000)
	if (!User)
		User = usr
	switch(askuser(User, Message, Title, Button1, Button2, Button3, StealFocus, Timeout))
		if (1)
			return Button1
		if (2)
			return Button2
		if (3)
			return Button3

//Same shit, but it returns the button number, could at some point support unlimited button amounts.
/proc/askuser(var/mob/User,Message, Title, Button1="Ok", Button2, Button3, StealFocus = 1, Timeout = 6000)
	if (!istype(User))
		if (istype(User, /client/))
			var/client/C = User
			User = C.mob
		else
			return
	var/datum/browser/alert/A = new(User, Message, Title, Button1, Button2, Button3, StealFocus, Timeout)
	A.open()
	A.wait()
	if (A.selectedbutton)
		return A.selectedbutton

// This will allow you to show an icon in the browse window
// This is added to mob so that it can be used without a reference to the browser object
// There is probably a better place for this...
/mob/proc/browse_rsc_icon(icon, icon_state, dir = -1)
	/*
	var/icon/I
	if (dir >= 0)
		I = new /icon(icon, icon_state, dir)
	else
		I = new /icon(icon, icon_state)
		setDir("default")

	var/filename = "[ckey("[icon]_[icon_state]_[dir]")].png"
	src << browse_rsc(I, filename)
	return filename
	*/


// Registers the on-close verb for a browse window (client/verb/.windowclose)
// this will be called when the close-button of a window is pressed.
//
// This is usually only needed for devices that regularly update the browse window,
// e.g. canisters, timers, etc.
//
// windowid should be the specified window name
// e.g. code is	: user << browse(text, "window=fred")
// then use 	: onclose(user, "fred")
//
// Optionally, specify the "ref" parameter as the controlled atom (usually src)
// to pass a "close=1" parameter to the atom's Topic() proc for special handling.
// Otherwise, the user mob's machine var will be reset directly.
//
/proc/onclose(mob/user, windowid, atom/ref=null)
	if(!user.client) return
	var/param = "null"
	if(ref)
		param = "\ref[ref]"

	winset(user, windowid, "on-close=\".windowclose [param]\"")

	//to_chat(world, "OnClose [user]: [windowid] : ["on-close=\".windowclose [param]\""]")


// the on-close client verb
// called when a browser popup window is closed after registering with proc/onclose()
// if a valid atom reference is supplied, call the atom's Topic() with "close=1"
// otherwise, just reset the client mob's machine var.
//
/client/verb/windowclose(atomref as text)
	set hidden = 1						// hide this verb from the user's panel
	set name = ".windowclose"			// no autocomplete on cmd line

	//to_chat(world, "windowclose: [atomref]")
	if(atomref!="null")				// if passed a real atomref
		var/hsrc = locate(atomref)	// find the reffed atom
		var/href = "close=1"
		if(hsrc)
			//to_chat(world, "[src] Topic [href] [hsrc]")
			usr = src.mob
			src.Topic(href, params2list(href), hsrc)	// this will direct to the atom's
			return										// Topic() proc via client.Topic()

	// no atomref specified (or not found)
	// so just reset the user mob's machine var
	if(src && src.mob)
		//to_chat(world, "[src] was [src.mob.machine], setting to null")
		src.mob.unset_machine()
	return
