/datum/escape_menu/proc/show_home_page()
	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/home_button(
			null,
			/* hud_owner = */ src,
			src,
			"Resume",
			/* offset = */ 1,
			CALLBACK(src, PROC_REF(home_resume)),
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/home_button(
			null,
			/* hud_owner = */ null,
			src,
			"Character",
			/* offset = */ 2,
			CALLBACK(src, PROC_REF(home_open_character_settings)),
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/home_button(
			null,
			/* hud_owner = */ null,
			src,
			"Settings",
			/* offset = */ 3,
			CALLBACK(src, PROC_REF(home_open_game_settings)),
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/home_button/admin_help(
			null,
			/* hud_owner = */ src,
			src,
			"Admin Help",
			/* offset = */ 4,
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/home_button/leave_body(
			null,
			/* hud_owner = */ src,
			src,
			"Leave Body",
			/* offset = */ 5,
			CALLBACK(src, PROC_REF(open_leave_body)),
		)
	)

/datum/escape_menu/proc/home_resume()
	qdel(src)

/datum/escape_menu/proc/home_open_character_settings()
	client?.prefs.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
	client?.prefs.update_static_data(client?.mob)
	client?.prefs.ui_interact(client?.mob)
	qdel(src)

/datum/escape_menu/proc/home_open_game_settings()
	client?.prefs.current_window = PREFERENCE_TAB_GAME_PREFERENCES
	client?.prefs.update_static_data(client?.mob)
	client?.prefs.ui_interact(client?.mob)
	qdel(src)

/atom/movable/screen/escape_menu/home_button
	mouse_opacity = MOUSE_OPACITY_OPAQUE

	VAR_PRIVATE
		atom/movable/screen/escape_menu/home_button_text/home_button_text
		datum/escape_menu/escape_menu
		datum/callback/on_click_callback

/atom/movable/screen/escape_menu/home_button/Initialize(
	mapload,
	datum/hud/hud_owner,
	datum/escape_menu/escape_menu,
	button_text,
	offset,
	on_click_callback,
)
	. = ..()

	src.escape_menu = escape_menu
	src.on_click_callback = on_click_callback

	home_button_text = new /atom/movable/screen/escape_menu/home_button_text(
		src,
		/* hud_owner = */ src,
		button_text,
	)

	vis_contents += home_button_text

	screen_loc = "NORTH:-[100 + (32 * offset)],WEST:110"
	transform = transform.Scale(6, 1)

/atom/movable/screen/escape_menu/home_button/Destroy()
	escape_menu = null
	on_click_callback = null

	return ..()

/atom/movable/screen/escape_menu/home_button/Click(location, control, params)
	if (!enabled())
		return

	on_click_callback.InvokeAsync()

/atom/movable/screen/escape_menu/home_button/MouseEntered(location, control, params)
	home_button_text.set_hovered(TRUE)

/atom/movable/screen/escape_menu/home_button/MouseExited(location, control, params)
	home_button_text.set_hovered(FALSE)

/atom/movable/screen/escape_menu/home_button/proc/text_color()
	return enabled() ? "white" : "gray"

/atom/movable/screen/escape_menu/home_button/proc/enabled()
	return TRUE

// Needs to be separated so it doesn't scale
/atom/movable/screen/escape_menu/home_button_text
	maptext_width = 200
	maptext_height = 50
	pixel_x = -80

	VAR_PRIVATE
		button_text
		hovered = FALSE

/atom/movable/screen/escape_menu/home_button_text/Initialize(mapload, datum/hud/hud_owner, button_text)
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
	var/atom/movable/screen/escape_menu/home_button/escape_menu_loc = loc

	maptext = MAPTEXT_VCR_OSD_MONO("<span style='font-size: 24px; color: [istype(escape_menu_loc) ? escape_menu_loc.text_color() : "white"]'>[button_text]</span>")

	if (hovered)
		maptext = "<u>[maptext]</u>"

/atom/movable/screen/escape_menu/home_button/admin_help
	VAR_PRIVATE
		current_blink = FALSE
		is_blinking = FALSE
		last_blink_time = 0

		blink_interval = 0.4 SECONDS

/atom/movable/screen/escape_menu/home_button/admin_help/Initialize(
	mapload,
	datum/escape_menu/escape_menu,
	button_text,
	offset,
	on_click_callback,
)
	. = ..()

	RegisterSignal(escape_menu.client, COMSIG_ADMIN_HELP_RECEIVED, PROC_REF(on_admin_help_received))
	RegisterSignals(escape_menu.client, list(COMSIG_CLIENT_VERB_ADDED, COMSIG_CLIENT_VERB_REMOVED), PROC_REF(on_client_verb_changed))

	var/datum/admin_help/current_ticket = escape_menu.client?.current_ticket
	if (!isnull(current_ticket))
		connect_ticket(current_ticket)
		if (!current_ticket?.player_replied)
			begin_processing()

/atom/movable/screen/escape_menu/home_button/admin_help/Click(location, control, params)
	if (!enabled())
		return

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

/atom/movable/screen/escape_menu/home_button/admin_help/proc/on_admin_help_received()
	SIGNAL_HANDLER

	begin_processing()

/atom/movable/screen/escape_menu/home_button/admin_help/proc/on_client_verb_changed(client/source, list/verbs_changed)
	SIGNAL_HANDLER

	if (/client/verb/adminhelp in verbs_changed)
		home_button_text.update_text()

/atom/movable/screen/escape_menu/home_button/admin_help/proc/begin_processing()
	if (is_blinking)
		return

	is_blinking = TRUE
	current_blink = TRUE
	START_PROCESSING(SSescape_menu, src)
	home_button_text.update_text()

/atom/movable/screen/escape_menu/home_button/admin_help/proc/end_processing()
	if (!is_blinking)
		return

	is_blinking = FALSE
	current_blink = FALSE
	STOP_PROCESSING(SSescape_menu, src)
	home_button_text.update_text()

/atom/movable/screen/escape_menu/home_button/admin_help/proc/connect_ticket(datum/admin_help/admin_help)
	ASSERT(istype(admin_help))

	RegisterSignal(admin_help, COMSIG_ADMIN_HELP_REPLIED, PROC_REF(on_admin_help_replied))

/atom/movable/screen/escape_menu/home_button/admin_help/proc/on_admin_help_replied()
	SIGNAL_HANDLER

	end_processing()

/atom/movable/screen/escape_menu/home_button/admin_help/enabled()
	if (!..())
		return FALSE

	if (!has_open_adminhelp())
		return /client/verb/adminhelp in escape_menu.client?.verbs

	return TRUE

/atom/movable/screen/escape_menu/home_button/admin_help/process(seconds_per_tick)
	if (world.time - last_blink_time < blink_interval)
		return

	current_blink = !current_blink
	last_blink_time = world.time
	home_button_text.update_text()

/atom/movable/screen/escape_menu/home_button/admin_help/text_color()
	if (!enabled())
		return ..()

	return current_blink ? "red" : ..()

/atom/movable/screen/escape_menu/home_button/admin_help/MouseEntered(location, control, params)
	. = ..()

	if (is_blinking)
		openToolTip(usr, src, params, content = "An admin is trying to talk to you!")

/atom/movable/screen/escape_menu/home_button/admin_help/MouseExited(location, control, params)
	. = ..()

	closeToolTip(usr)

/atom/movable/screen/escape_menu/home_button/leave_body

/atom/movable/screen/escape_menu/home_button/leave_body/Initialize(
	mapload,
	datum/escape_menu/escape_menu,
	button_text,
	offset,
	on_click_callback,
)
	. = ..()

	RegisterSignal(escape_menu.client, COMSIG_CLIENT_MOB_LOGIN, PROC_REF(on_client_mob_login))

/atom/movable/screen/escape_menu/home_button/leave_body/enabled()
	if (!..())
		return FALSE

	return isliving(escape_menu.client?.mob)

/atom/movable/screen/escape_menu/home_button/leave_body/proc/on_client_mob_login()
	SIGNAL_HANDLER

	home_button_text.update_text()
