/*
Author: NullQuery
Created on: 2014-09-25

Extension to implement Nanotrasen styled windows.

Additional procs:

	hi.setEyeColor(color, client)

Use this to set the color of the 'eye' in the top-left corner of the window.

The client is optional and may be a /mob, /client or /html_interface_client object. It must be specified, since the eye icon is specific to a client.

*/

/datum/html_interface/nanotrasen/New()
	. = ..()

	// Add appropriate CSS and set the default layout.
	src.head = src.head + "<link rel=\"stylesheet\" type=\"text/css\" href=\"hi-nanotrasen.css\" />"
	src.updateLayout("")

/datum/html_interface/nanotrasen/updateLayout(layout)
	// Wrap the layout in our custom HTML
	return ..("<div id=\"ntbgcenter\"></div><div id=\"content\">[layout]</div>")

/datum/html_interface/specificRenderTitle(datum/html_interface_client/hclient, ignore_cache = FALSE)
	// Update the title in our custom header (in addition to default functionality)
	winset(hclient.client, "browser_\ref[src].uiTitle", list2params(list("text" = "[src.title]")))

/datum/html_interface/nanotrasen/registerResources(var/list/resources = list())
	resources["uiBg.png"] = 'uiBg.png'
	resources["uiBgcenter.png"] = 'uiBgcenter.png'
	resources["hi-nanotrasen.css"] = 'hi-nanotrasen.css'
	..(resources)

/datum/html_interface/nanotrasen/createWindow(datum/html_interface_client/hclient)
	. = ..() // we want the default window

	// Remove the titlebar
	winset(hclient.client, "browser_\ref[src]", list2params(list(
		"titlebar"    = "false"
	)))

	// Reposition the browser
	winset(hclient.client, "browser_\ref[src].browser", list2params(list(
		"pos"         = "0,35",
		"size"        = "[width]x[height - 35]"
	)))

	// Add top background image
	winset(hclient.client, "browser_\ref[src].topbg", list2params(list(
		"parent"      = "browser_\ref[src]",
		"type"        = "label",
		"pos"         = "0,0",
		"size"        = "[width]x35",
		"anchor1"     = "0,0",
		"anchor2"     = "100,0",
		"image"       = "['uiBgtop.png']",
		"image-mode"  = "tile",
		"is-disabled" = "true"
	)))

	// Add Nanotrasen logo
	winset(hclient.client, "browser_\ref[src].uiTitleFluff", list2params(list(
		"parent"      = "browser_\ref[src]",
		"type"        = "label",
		"pos"         = "[width - 42 - 4 - 24 - 4 - 24 - 4],5",
		"size"        = "42x24",
		"anchor1"     = "100,0",
		"anchor2"     = "100,0",
		"image"       = "['uiTitleFluff.png']",
		"image-mode"  = "tile",
		"is-disabled" = "true"
	)))

	// Add Eye picture
	winset(hclient.client, "browser_\ref[src].uiTitleEye", list2params(list(
		"parent"      = "browser_\ref[src]",
		"type"        = "label",
		"pos"         = "8,5",
		"size"        = "42x24",
		"anchor1"     = "0,0",
		"anchor2"     = "0,0",
		"image"       = "['uiEyeGreen.png']",
		"image-mode"  = "tile",
		"is-disabled" = "true"
	)))

	// Add title text
	winset(hclient.client, "browser_\ref[src].uiTitle", list2params(list(
		"parent"         = "browser_\ref[src]",
		"type"           = "label",
		"is-transparent" = "true",
		"pos"            = "64,0",
		"size"           = "580x35",
		"anchor1"        = "0,0",
		"anchor2"        = "100,0",
		"is-disabled"    = "true",
		"text"           = "[src.title]",
		"align"          = "left",
		"font-family"    = "verdana,Geneva,sans-serif",
		"font-size"      = "12", // ~ 16px
		"text-color"     = "#E9C183"
	)))

	// Add minimize button
	// TODO: Style the button (add image)
	winset(hclient.client, "browser_\ref[src].uiTitleMinimize", list2params(list(
		"parent"         = "browser_\ref[src]",
		"type"           = "button",
		"is-flat"        = "true",
		"background-color"="#383838", // should be unnecessary if image is used
		"text-color"     = "#FFFFFF", // should be unnecessary if image is used
		"is-transparent" = "true",
		"pos"            = "[width - 24 - 4 - 24 - 4],5",
		"size"           = "24x24",
		"anchor1"        = "100,0",
		"anchor2"        = "100,0",
		"text"           = "-",
		"font-family"    = "verdana,Geneva,sans-serif", // should be unnecessary if image is used
		"font-size"      = "12", // ~ 16px - should be unnecessary if image is used

		// Disable resizing (disables maximizing), minimize window, bind window.on-size to catch 'restore window' button to enable resizing if restored.
		"command"        = ".winset \"browser_\ref[src].can-resize=false;browser_\ref[src].is-minimized=true;browser_\ref[src].on-size=\".swinset \\\"browser_\ref[src].can-resize=true;browser_\ref[src].on-size=\\\"\"\""
	)))

	// Add close button
	// TODO: Style the button (add image)
	winset(hclient.client, "browser_\ref[src].uiTitleClose", list2params(list(
		"parent"         = "browser_\ref[src]",
		"type"           = "button",
		"is-flat"        = "true",
		"background-color"="#383838", // should be unnecessary if image is used
		"text-color"     = "#FFFFFF", // should be unnecessary if image is used
		"command"        = "byond://?src=\ref[src];html_interface_action=onclose",
		"is-transparent" = "true",
		"pos"            = "[width - 24 - 4],5",
		"size"           = "24x24",
		"anchor1"        = "100,0",
		"anchor2"        = "100,0",
		"text"           = "X",
		"font-family"    = "verdana,Geneva,sans-serif", // should be unnecessary if image is used
		"font-size"      = "12" // ~ 16px - should be unnecessary if image is used
	)))

/datum/html_interface/nanotrasen/enableFor(datum/html_interface_client/hclient)
	. = ..()

	src.setEyeColor("green", hclient)

/datum/html_interface/nanotrasen/disableFor(datum/html_interface_client/hclient)
	hclient.active = FALSE

	src.setEyeColor("red", hclient)

/datum/html_interface/nanotrasen/proc/setEyeColor(color, datum/html_interface_client/hclient)
	hclient = getClient(hclient)

	if (istype(hclient))
		var/resource
		switch (color)
			if ("green")  resource = 'uiEyeGreen.png'
			if ("orange") resource = 'uiEyeOrange.png'
			if ("red")    resource = 'uiEyeRed.png'
			else          CRASH("Invalid color: [color]")

		if (hclient.getExtraVar("eye_color") != color)
			hclient.putExtraVar("eye_color", color)

			winset(hclient.client, "browser_\ref[src].uiTitleEye", list2params(list("image" = "[resource]")))
	else
		WARNING("Invalid object passed to /datum/html_interface/nanotrasen/proc/setEyeColor")