/atom/movable/screen/escape_menu/home_button/leave_body

/atom/movable/screen/escape_menu/home_button/leave_body/Initialize(
	mapload,
	datum/hud/hud_owner,
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
