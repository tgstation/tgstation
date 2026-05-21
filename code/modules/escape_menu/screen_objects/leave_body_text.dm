/atom/movable/screen/escape_menu/text/clickable/leave_body/Initialize(
	mapload,
	datum/hud/hud_owner,
	datum/escape_menu/escape_menu,
	button_text,
	list/offset,
	font_size = 24,
	on_click_callback,
)
	. = ..()
	RegisterSignal(escape_menu.client, COMSIG_CLIENT_MOB_LOGIN, PROC_REF(on_client_mob_login))

/atom/movable/screen/escape_menu/text/clickable/leave_body/enabled()
	if (!..())
		return FALSE

	return isliving(escape_menu.client?.mob)

/atom/movable/screen/escape_menu/text/clickable/leave_body/proc/on_client_mob_login()
	SIGNAL_HANDLER

	update_text()
