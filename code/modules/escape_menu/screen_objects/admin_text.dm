/atom/movable/screen/escape_menu/text/clickable/admin_help
	VAR_PRIVATE
		current_blink = FALSE
		is_blinking = FALSE
		last_blink_time = 0

		blink_interval = 0.4 SECONDS

/atom/movable/screen/escape_menu/text/clickable/admin_help/Initialize(
	mapload,
	datum/hud/hud_owner,
	datum/escape_menu/escape_menu,
	button_text,
	list/offset,
	font_size = 24,
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

/atom/movable/screen/escape_menu/text/clickable/admin_help/Click(location, control, params)
	if (!enabled())
		return

	QDEL_IN(escape_menu, 0)

	var/client/client = escape_menu.client

	if (has_open_adminhelp())
		client?.view_latest_ticket()
	else
		client?.adminhelp()

/atom/movable/screen/escape_menu/text/clickable/admin_help/proc/has_open_adminhelp()
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

/atom/movable/screen/escape_menu/text/clickable/admin_help/proc/on_admin_help_received()
	SIGNAL_HANDLER

	begin_processing()

/atom/movable/screen/escape_menu/text/clickable/admin_help/proc/on_client_verb_changed(client/source, list/verbs_changed)
	SIGNAL_HANDLER

	if (/client/verb/adminhelp in verbs_changed)
		update_text()

/atom/movable/screen/escape_menu/text/clickable/admin_help/proc/begin_processing()
	if (is_blinking)
		return

	is_blinking = TRUE
	current_blink = TRUE
	START_PROCESSING(SSescape_menu, src)
	update_text()

/atom/movable/screen/escape_menu/text/clickable/admin_help/proc/end_processing()
	if (!is_blinking)
		return

	is_blinking = FALSE
	current_blink = FALSE
	STOP_PROCESSING(SSescape_menu, src)
	update_text()

/atom/movable/screen/escape_menu/text/clickable/admin_help/proc/connect_ticket(datum/admin_help/admin_help)
	ASSERT(istype(admin_help))

	RegisterSignal(admin_help, COMSIG_ADMIN_HELP_REPLIED, PROC_REF(on_admin_help_replied))

/atom/movable/screen/escape_menu/text/clickable/admin_help/proc/on_admin_help_replied()
	SIGNAL_HANDLER

	end_processing()

/atom/movable/screen/escape_menu/text/clickable/admin_help/enabled()
	if (!..())
		return FALSE

	if (!has_open_adminhelp())
		return /client/verb/adminhelp in escape_menu.client?.verbs

	return TRUE

/atom/movable/screen/escape_menu/text/clickable/admin_help/process(seconds_per_tick)
	if (world.time - last_blink_time < blink_interval)
		return

	current_blink = !current_blink
	last_blink_time = world.time
	update_text()

/atom/movable/screen/escape_menu/text/clickable/admin_help/text_color()
	if (!enabled())
		return ..()

	return current_blink ? "red" : ..()

/atom/movable/screen/escape_menu/text/clickable/admin_help/MouseEntered(location, control, params)
	. = ..()

	if (is_blinking)
		openToolTip(usr, src, params, content = "An admin is trying to talk to you!")

/atom/movable/screen/escape_menu/text/clickable/admin_help/MouseExited(location, control, params)
	. = ..()

	closeToolTip(usr)
