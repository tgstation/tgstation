/*
Author: NullQuery
Created on: 2014-09-24

	** CAUTION - A WORD OF WARNING **

If there is no getter or setter available and you aren't extending my code with a sub-type, DO NOT ACCESS VARIABLES DIRECTLY!

Add a getter/setter instead, even if it does nothing but return or set the variable. Thank you for your patience with me. -NQ

	** Public API **

	var/datum/html_interface/hi = new/datum/html_interface(ref, title, width = 700, height = 480, head = "")

Creates a new HTML interface object with [ref] as the object and [title] as the initial title of the page. [width] and [height] is the initial width and height
of the window. The text in [head] is added just before the end </head> tag.

	hi.setTitle(title)

Changes the title of the page.

	hi.getTitle()

Returns the current title of the page.

	hi.updateLayout(layout)

Updates the overall layout of the page (the HTML code between the body tags).

This should be used sparingly.

	hi.updateContent(id, content, ignore_cache = FALSE)

Updates a portion of the page, i.e., the DOM element with the appropriate ID. The contents of the element are replaced with the provided HTML.

The content is cached on the server-side to minimize network traffic when the client "should have" the same HTML. The client may not have
the same HTML if scripts cause the content to change. In this case set the ignore_cache parameter.

	hi.executeJavaScript(jscript, client = null)

Executes Javascript on the browser.

The client is optional and may be a /mob, /client or /html_interface_client object. If not specified the code is executed on all clients.

	hi.show(client)

Shows the HTML interface to the provided client. This will create a window, apply the current layout and contents. It will then wait for events.

	hi.hide(client)

Hides the HTML interface from the provided client. This will close the browser window.

	hi.isUsed()

Returns TRUE if the interface is being used (has an active client) or FALSE if not.

	** Additional notes **

When working with byond:// links make sure to reference the HTML interface object and NOT the original object. Topic() will still be called on
your object, but it will pass through the HTML interface first allowing interception at a higher level.


	** Sample code **

mob/var/datum/html_interface/hi

mob/verb/test()
	if (!hi) hi = new/datum/html_interface(src, "[src.key]")

	hi.updateLayout("<div id=\"content\"></div>")
	hi.updateContent("content", "<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque porttitor, leo nec facilisis aliquam, elit ligula iaculis sapien, non vulputate neque metus id quam. Cras mauris nisl, pharetra malesuada massa nec, volutpat feugiat metus. Duis sed condimentum purus. In ex leo, laoreet ac rhoncus quis, volutpat ac risus. Ut et tempus magna. Vestibulum in nisl vitae metus commodo tempus et dapibus urna. Integer nec vestibulum lacus. Donec quis metus non lacus bibendum lacinia. Aenean tincidunt libero vestibulum metus blandit pharetra. Nunc quis magna volutpat, bibendum nulla in, sagittis risus. Sed id velit sodales, bibendum purus accumsan, eleifend purus.</p><p>Suspendisse potenti. Proin lorem orci, euismod at elit in, molestie dapibus leo. Nulla lacinia vel urna nec vulputate. Praesent non enim metus. Quisque non pharetra justo. Integer efficitur massa orci, vitae placerat libero eleifend sit amet. Fusce in placerat quam. Praesent quis lectus turpis. Aenean mattis lacus sed laoreet sagittis. Aliquam efficitur nisl at tellus ultrices auctor. Quisque hendrerit, mi quis suscipit interdum, justo magna gravida libero, et venenatis sapien ante quis odio.</p><p>Etiam ullamcorper condimentum lacus, eu laoreet ipsum gravida et. Fusce odio libero, iaculis euismod finibus sit amet, condimentum ac ante. Etiam pretium lorem mauris, sit amet varius tortor efficitur eget. Pellentesque at lacinia lectus. Integer tristique nibh hendrerit purus placerat dapibus. Cras elementum est elementum, bibendum orci nec, consequat elit. Fusce porttitor neque quis libero placerat, vel varius arcu aliquet. Aenean vitae rhoncus nunc, non tempus magna. Aliquam lacinia sit amet dolor id maximus. Curabitur eget eleifend nisl. Mauris interdum nibh feugiat lectus lacinia fringilla. Aliquam nec magna vel leo ultricies dignissim. Duis eu luctus odio, finibus dictum nulla.</p>Mauris fringilla a lorem vel euismod. Sed auctor eget lorem sed lacinia. Maecenas vel posuere sapien. In lobortis odio non tincidunt ultricies. Sed consequat molestie orci et pharetra. Suspendisse potenti. Vestibulum vitae ornare risus, nec semper arcu. Duis et interdum lacus.</p><p>Etiam urna nulla, pulvinar at est auctor, varius feugiat orci. Vestibulum efficitur maximus imperdiet. Donec vehicula, leo sit amet condimentum pulvinar, urna felis aliquet velit, bibendum placerat dui libero sed tortor. Vivamus ac diam commodo nisi facilisis lacinia. Aenean a rhoncus risus, venenatis efficitur arcu. Curabitur tincidunt nulla eget augue malesuada imperdiet. Quisque ligula purus, dictum a imperdiet eget, eleifend eu leo. Phasellus massa ipsum, molestie nec pellentesque eu, scelerisque et mi. Vivamus at libero varius, lacinia magna non, imperdiet tortor. Donec scelerisque ipsum sollicitudin justo ornare accumsan. In velit orci, lobortis eget maximus et, scelerisque ut nulla. Cras sit amet finibus sapien. Aenean metus lorem, gravida a rutrum quis, varius eu arcu. Integer ac hendrerit purus. Aliquam cursus ultricies tortor. Fusce scelerisque, arcu id pellentesque accumsan, nulla turpis tempus lectus, tincidunt blandit mi nisi non metus.</p>")

	hi.show(src)

*/

/datum/html_interface
	// The atom we should report to.
	var/atom/ref

	// The current title of the browser window.
	var/title

	// A list of content elements that have been changed. This is necessary when showing the browser control to new clients.
	var/list/content_elements = new/list()

	// The HTML layout, typically what's in-between the <body></body> tag. May be overridden by extensions.
	var/layout

	// An associative list of clients currently viewing this screen. The key is the /client object, the value is the /datum/html_interface_client object.
	var/list/clients

	// This goes just before the closing HEAD tag. I haven't exposed any getters/setters for it because it's only being used by extensions.
	var/head = ""

	// The initial width of the browser control, used when the window is first shown to a client.
	var/width

	// The initial height of the browser control, used when the window is first shown to a client.
	var/height

/datum/html_interface/New(atom/ref, title, width = 700, height = 480, head = "")
	. = ..()

	src.ref            = ref
	src.title          = title
	src.width          = width
	src.height         = height
	src.head           = head

/datum/html_interface/Destroy()
	if (src.clients)
		for (var/client in src.clients)
			src.hide(src.clients[client])

	return ..()

/*                 * Hooks */
/datum/html_interface/proc/specificRenderTitle(datum/html_interface_client/hclient, ignore_cache = FALSE)

/datum/html_interface/proc/sendResources(client/client)
	client << browse_rsc('jquery.min.js')
	client << browse_rsc('bootstrap.min.js')
	client << browse_rsc('bootstrap.min.css')
	client << browse_rsc('html_interface.css')
	client << browse_rsc('html_interface.js')

/datum/html_interface/proc/createWindow(datum/html_interface_client/hclient)
	winclone(hclient.client, "window", "browser_\ref[src]")

	var/list/params = list(
		"size"        = "[width]x[height]",
		"statusbar"   = "false",
		"on-close"    = "byond://?src=\ref[src]&html_interface_action=onclose"
	)

	if (hclient.client.hi_last_pos) params["pos"] = "[hclient.client.hi_last_pos]"

	winset(hclient.client, "browser_\ref[src]", list2params(params))

	winset(hclient.client, "browser_\ref[src].browser", list2params(list("parent" = "browser_\ref[src]", "type" = "browser", "pos" = "0,0", "size" = "[width]x[height]", "anchor1" = "0,0", "anchor2" = "100,100", "use-title" = "true", "auto-format" = "false")))

/*                 * Public API */
/datum/html_interface/proc/getTitle() return src.title

/datum/html_interface/proc/setTitle(title, ignore_cache = FALSE)
	src.title = title

	var/datum/html_interface_client/hclient

	for (var/client in src.clients)
		hclient = src._getClient(src.clients[client])

		if (hclient && hclient.active) src._renderTitle(src.clients[client], ignore_cache)

/datum/html_interface/proc/executeJavaScript(jscript, datum/html_interface_client/hclient = null)
	if (hclient)
		hclient = getClient(hclient)

		if (istype(hclient))
			if (hclient.is_loaded) hclient.client << output(list2params(list(jscript)), "browser_\ref[src].browser:eval")
	else
		for (var/client in src.clients) src.executeJavaScript(jscript, src.clients[client])

/datum/html_interface/proc/updateLayout(layout)
	src.layout = layout

	var/datum/html_interface_client/hclient

	for (var/client in src.clients)
		hclient = src._getClient(src.clients[client])

		if (hclient && hclient.active) src._renderLayout(hclient)

/datum/html_interface/proc/updateContent(id, content, ignore_cache = FALSE)
	src.content_elements[id] = content

	var/datum/html_interface_client/hclient

	for (var/client in src.clients)
		hclient = src._getClient(src.clients[client])

		if (hclient && hclient.active) src._renderContent(id, hclient, ignore_cache)

/datum/html_interface/proc/show(datum/html_interface_client/hclient)
	hclient = getClient(hclient, TRUE)

	if (istype(hclient))
		// This needs to be commented out due to BYOND bug http://www.byond.com/forum/?post=1487244
		// /client/proc/send_resources() executes this per client to avoid the bug, but by using it here files may be deleted just as the HTML is loaded,
		// causing file not found errors.
//		src.sendResources(hclient.client)

		if (winexists(hclient.client, "browser_\ref[src]"))
			src._renderTitle(hclient, TRUE)
			src._renderLayout(hclient)
		else
			src.createWindow(hclient)
			hclient.is_loaded = FALSE
			hclient.client << output(replacetextEx(replacetextEx(file2text('html_interface.html'), "\[hsrc\]", "\ref[src]"), "</head>", "[head]</head>"), "browser_\ref[src].browser")
			winshow(hclient.client, "browser_\ref[src]", TRUE)

/datum/html_interface/proc/hide(datum/html_interface_client/hclient)
	hclient = getClient(hclient)

	if (istype(hclient))
		if (src.clients)
			src.clients.Remove(hclient.client)

			if (!src.clients.len) src.clients = null

		hclient.client.hi_last_pos = winget(hclient.client, "browser_\ref[src]" ,"pos")

		winshow(hclient.client, "browser_\ref[src]", FALSE)
		winset(hclient.client, "browser_\ref[src]", "parent=none")

		if (hascall(src.ref, "hiOnHide")) call(src.ref, "hiOnHide")(hclient)

// Convert a /mob to /client, and /client to /datum/html_interface_client
/datum/html_interface/proc/getClient(client, create_if_not_exist = FALSE)
	if (istype(client, /datum/html_interface_client)) return src._getClient(client)
	else if (ismob(client))
		var/mob/mob = client
		client      = mob.client

	if (istype(client, /client))
		if (create_if_not_exist && (!src.clients || !(client in src.clients)))
			if (!src.clients)             src.clients = new/list()
			if (!(client in src.clients)) src.clients[client] = new/datum/html_interface_client(client)

		if (src.clients && (client in src.clients)) return src._getClient(src.clients[client])
		else                                        return null
	else                                            return null

/datum/html_interface/proc/enableFor(datum/html_interface_client/hclient)
	hclient.active = TRUE

	src.show(hclient)

/datum/html_interface/proc/disableFor(datum/html_interface_client/hclient)
	hclient.active = FALSE

/datum/html_interface/proc/isUsed()
	if (src.clients && src.clients.len > 0)
		var/datum/html_interface_client/hclient
		for (var/key in clients)
			hclient = clients[key]
			if (hclient.active) return TRUE

	return FALSE

/*                 * Danger Zone */

/datum/html_interface/proc/_getClient(datum/html_interface_client/hclient)
	if (hclient)
		if (hclient.client)
			if (hascall(src.ref, "hiIsValidClient"))
				var/res = call(src.ref, "hiIsValidClient")(hclient)

				if (res)
					if (!hclient.active) src.enableFor(hclient)
				else
					if (hclient.active)  src.disableFor(hclient)

			return hclient
		else
			return null
	else
		return null

/datum/html_interface/proc/_renderTitle(datum/html_interface_client/hclient, ignore_cache = FALSE)
	if (hclient && hclient.is_loaded)
		// Only render if we have new content.

		if (ignore_cache || src.title != hclient.title)
			hclient.title = title

			src.specificRenderTitle(hclient)

			hclient.client << output(list2params(list(title)), "browser_\ref[src].browser:setTitle")

/datum/html_interface/proc/_renderLayout(datum/html_interface_client/hclient)
	if (hclient && hclient.is_loaded)
		var/html   = src.layout

		// Only render if we have new content.
		if (html != hclient.layout)
			hclient.layout = html

			hclient.client << output(list2params(list(html)), "browser_\ref[src].browser:updateLayout")

			for (var/id in src.content_elements) src._renderContent(id, hclient)

/datum/html_interface/proc/_renderContent(id, datum/html_interface_client/hclient, ignore_cache = FALSE)
	if (hclient && hclient.is_loaded)
		var/html   = src.content_elements[id]

		// Only render if we have new content.
		if (ignore_cache || !(id in hclient.content_elements) || html != hclient.content_elements[id])
			hclient.content_elements[id] = html

			hclient.client << output(list2params(list(id, html)), "browser_\ref[src].browser:updateContent")

/datum/html_interface/Topic(href, href_list[])
	var/datum/html_interface_client/hclient = getClient(usr.client)

	if (istype(hclient))
		if ("html_interface_action" in href_list)
			switch (href_list["html_interface_action"])

				if ("onload")
					hclient.layout = null
					hclient.content_elements.len = 0
					hclient.is_loaded = TRUE

					src._renderTitle(hclient, TRUE)
					src._renderLayout(hclient)

				if ("onclose")
					src.hide(hclient)
		else if (src.ref && hclient.active) src.ref.Topic(href, href_list, hclient)