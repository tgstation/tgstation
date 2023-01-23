/datum/escape_menu/proc/show_home_page()
	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/home_button(
			null,
			src,
			"Resume",
			/* offset = */ 0,
			CALLBACK(src, PROC_REF(home_resume)),
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/home_button(
			null,
			src,
			"Settings",
			/* offset = */ 1,
			CALLBACK(src, PROC_REF(home_open_settings)),
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/home_button/admin_help(
			null,
			src,
			"Admin Help",
			/* offset = */ 2,
		)
	)

	// MBTODO: Disable when not in a body
	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/home_button(
			null,
			src,
			"Leave Body",
			/* offset = */ 3,
			CALLBACK(src, PROC_REF(open_leave_body)),
		)
	)

/datum/escape_menu/proc/home_resume()
	qdel(src)

/datum/escape_menu/proc/home_open_settings()
	client?.prefs.ui_interact(client?.mob)
	qdel(src)

/atom/movable/screen/escape_menu/home_button
	mouse_opacity = MOUSE_OPACITY_OPAQUE

	VAR_PRIVATE
		atom/movable/screen/escape_menu/home_button_text/home_button_text
		datum/escape_menu/escape_menu
		datum/callback/on_click_callback

// MBTODO: escape_menu should have immediate shit on it
/atom/movable/screen/escape_menu/home_button/Initialize(
	mapload,
	escape_menu,
	button_text,
	offset,
	on_click_callback,
)
	. = ..()

	src.escape_menu = escape_menu
	src.on_click_callback = on_click_callback

	home_button_text = new /atom/movable/screen/escape_menu/home_button_text(
		src,
		button_text,
	)

	vis_contents += home_button_text

	screen_loc = "NORTH:-[100 + (32 * offset)],WEST:110"
	transform = transform.Scale(6, 1)

/atom/movable/screen/escape_menu/home_button/Destroy()
	escape_menu = null
	QDEL_NULL(on_click_callback)

	return ..()

/atom/movable/screen/escape_menu/home_button/Click(location, control, params)
	on_click_callback.InvokeAsync()

/atom/movable/screen/escape_menu/home_button/MouseEntered(location, control, params)
	home_button_text.set_hovered(TRUE)

/atom/movable/screen/escape_menu/home_button/MouseExited(location, control, params)
	home_button_text.set_hovered(FALSE)

// Needs to be separated so it doesn't scale
/atom/movable/screen/escape_menu/home_button_text
	maptext_width = 200
	maptext_height = 50
	pixel_x = -80

	VAR_PRIVATE
		button_text
		hovered = FALSE

/atom/movable/screen/escape_menu/home_button_text/Initialize(mapload, button_text)
	. = ..()

	src.button_text = button_text
	update_text()

/// Sets the hovered state of the button, and updates the text
/atom/movable/screen/escape_menu/home_button_text/proc/set_hovered(hovered)
	if (src.hovered == hovered)
		return

	src.hovered = hovered
	update_text()

/atom/movable/screen/escape_menu/home_button_text/proc/update_text()
	maptext = MAPTEXT_VCR_OSD_MONO("<span style='font-size: 24px'>[button_text]</span>")

	if (hovered)
		maptext = "<u>[maptext]</u>"

// MBTODO: Inactive when adminhelp() would fail, if there's no active ticket
/atom/movable/screen/escape_menu/home_button/admin_help

/atom/movable/screen/escape_menu/home_button/admin_help/Click(location, control, params)
	QDEL_IN(escape_menu, 0)

	var/client/client = escape_menu.client

	if (has_open_adminhelp())
		client?.view_latest_ticket()
	else
		client?.adminhelp()

/atom/movable/screen/escape_menu/home_button/admin_help/proc/has_open_adminhelp()
	var/client/client = escape_menu.client

	var/datum/admin_help/current_ticket = client?.current_ticket

	// This is null with a closed ticket.
	// This is okay since the View Latest Ticket panel already tells you if your ticket is closed,  intentionally.
	if (isnull(current_ticket))
		return FALSE

	// If we sent a ticket, but nobody has responded, send another one instead.
	// Not worth opening a menu when there's nothing to read, you're only going to want to send.
	if (length(current_ticket.admins_involved - client?.ckey) == 0)
		return FALSE

	return TRUE
