/datum/escape_menu/proc/show_admin_page()
	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/lobby_button/small(
			null,
			/* hud_owner = */ null,
			"Back",
			/* tooltip_text = */ null,
			/* pixel_offset = */ list(-260, 190),
			CALLBACK(src, PROC_REF(open_home_page)),
			/* button_overlay = */ "back",
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/home_button/admin_help(
			null,
			/* hud_owner = */ null,
			src,
			/* button_text = */ "Create Admin Ticket",
			/* offset = */ 1,
			CALLBACK(src, PROC_REF(create_ticket)),
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/home_button/admin_ticket_notification(
			null,
			/* hud_owner = */ null,
			src,
			/* button_text = */ "View Latest Ticket",
			/* offset = */ 2,
			CALLBACK(src, PROC_REF(view_latest_ticket)),
		)
	)
	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/home_button(
			null,
			/* hud_owner = */ null,
			src,
			/* button_text = */ "See Admin Notices",
			/* offset = */ 3,
			CALLBACK(src, PROC_REF(admin_notice)),
		)
	)

///Opens your latest admin ticket.
/datum/escape_menu/proc/view_latest_ticket()
	client?.view_latest_ticket()

///Checks for any admin notices.
/datum/escape_menu/proc/admin_notice()
	client?.admin_notice()

/datum/escape_menu/proc/create_ticket()
	if(!(/client/verb/adminhelp in client?.verbs))
		return
	client?.adminhelp()
	qdel(src)
