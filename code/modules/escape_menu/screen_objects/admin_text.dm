///Text that gets highlighted when you have an admin ticket notification.
/atom/movable/screen/escape_menu/text/clickable/admin_ticket_notification
	VAR_PRIVATE
		current_blink = FALSE
		is_blinking = FALSE
		last_blink_time = 0
		blink_interval = 0.4 SECONDS

/atom/movable/screen/escape_menu/text/clickable/admin_ticket_notification/Initialize(
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

	var/datum/admin_help/current_ticket = escape_menu.client?.current_ticket
	if (!isnull(current_ticket))
		connect_ticket(current_ticket)
		if (!current_ticket?.player_replied)
			begin_processing()

/atom/movable/screen/escape_menu/text/clickable/admin_ticket_notification/proc/on_admin_help_received()
	SIGNAL_HANDLER

	begin_processing()

/atom/movable/screen/escape_menu/text/clickable/admin_ticket_notification/proc/begin_processing()
	if (is_blinking)
		return

	is_blinking = TRUE
	current_blink = TRUE
	START_PROCESSING(SSescape_menu, src)
	update_text()

/atom/movable/screen/escape_menu/text/clickable/admin_ticket_notification/proc/end_processing()
	if (!is_blinking)
		return

	is_blinking = FALSE
	current_blink = FALSE
	STOP_PROCESSING(SSescape_menu, src)
	update_text()

/atom/movable/screen/escape_menu/text/clickable/admin_ticket_notification/proc/connect_ticket(datum/admin_help/admin_help)
	ASSERT(istype(admin_help))

	RegisterSignal(admin_help, COMSIG_ADMIN_HELP_REPLIED, PROC_REF(on_admin_help_replied))

/atom/movable/screen/escape_menu/text/clickable/admin_ticket_notification/proc/on_admin_help_replied()
	SIGNAL_HANDLER

	end_processing()

/atom/movable/screen/escape_menu/text/clickable/admin_ticket_notification/process(seconds_per_tick)
	if (world.time - last_blink_time < blink_interval)
		return

	current_blink = !current_blink
	last_blink_time = world.time
	update_text()

/atom/movable/screen/escape_menu/text/clickable/admin_ticket_notification/text_color()
	if (!enabled())
		return ..()

	return current_blink ? "red" : ..()

/atom/movable/screen/escape_menu/text/clickable/admin_ticket_notification/MouseEntered(location, control, params)
	. = ..()

	if (is_blinking)
		openToolTip(usr, src, params, content = "An admin is trying to talk to you!")

/atom/movable/screen/escape_menu/text/clickable/admin_ticket_notification/MouseExited(location, control, params)
	. = ..()

	closeToolTip(usr)

///The button used for adminhelping, this is used to grey it out when you're on cooldown.
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

	RegisterSignals(escape_menu.client, list(COMSIG_CLIENT_VERB_ADDED, COMSIG_CLIENT_VERB_REMOVED), PROC_REF(on_client_verb_changed))

/atom/movable/screen/escape_menu/text/clickable/admin_help/proc/on_client_verb_changed(client/source, list/verbs_changed)
	SIGNAL_HANDLER

	if (/client/verb/adminhelp in verbs_changed)
		update_text()

/atom/movable/screen/escape_menu/text/clickable/admin_help/enabled()
	return (/client/verb/adminhelp in escape_menu.client?.verbs)
