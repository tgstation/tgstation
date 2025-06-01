/datum/escape_menu/proc/show_player_list()
	PRIVATE_PROC(TRUE)

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

	var/vertical_amount = -30 //we start at -50, add -10 each time we go down.
	var/horizontal_amount = -170 //increasing by 150, we fit 3 per line this way.
	if(length(GLOB.admins))
		page_holder.give_screen_object(
			new /atom/movable/screen/escape_menu/text(
				null,
				/* hud_owner = */ null,
				/* escape_menu = */ src,
				/* button_text = */ "Admins",
				/* offset = */ list(-10, 0),
			)
		)
		for(var/client/admin as anything in GLOB.admins) //we list admins first
			if(horizontal_amount >= 280)
				horizontal_amount = -170
				vertical_amount -= 30 //admins push further down for feedback links to fit
			page_holder.give_screen_object(
				new /atom/movable/screen/escape_menu/text/clickable/ignoring(
					null,
					/* hud_owner = */ null,
					/* escape_menu = */ src,
					/* button_text = */ admin.holder.fakekey ? admin.holder.fakekey : admin.ckey,
					/* offset = */ list(vertical_amount, horizontal_amount),
					/* font_size = */ 12,
					/* on_click_callback = */ CALLBACK(src, PROC_REF(ignore_or_unignore), admin.ckey),
					/* player_ckey = */ admin.ckey,
				)
			)
			var/ranks = admin.holder.rank_names()
			page_holder.give_screen_object(
				new /atom/movable/screen/escape_menu/text(
					null,
					/* hud_owner = */ null,
					/* escape_menu = */ src,
					/* button_text = */ admin.holder.feedback_link() ? "<a href='[feedback_link]'>[ranks]</a>" : "[ranks]",
					/* offset = */ list((vertical_amount - 15), horizontal_amount - 10),
					/* font_size = */ 10,
				)
			)
			horizontal_amount += 150
	else
		page_holder.give_screen_object(
			new /atom/movable/screen/escape_menu/text(
				null,
				/* hud_owner = */ null,
				/* escape_menu = */ src,
				/* button_text = */ "No Admins Online!",
				/* offset = */ list(-10, 0),
			)
		)

	vertical_amount -= 30
	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "Players",
			/* offset = */ list(vertical_amount, 0),
		)
	)
	vertical_amount -= 20
	horizontal_amount = -170
	for(var/client/player as anything in GLOB.clients - GLOB.admins)
		if(horizontal_amount >= 280)
			horizontal_amount = -170
			vertical_amount -= 20
		page_holder.give_screen_object(
			new /atom/movable/screen/escape_menu/text/clickable/ignoring(
				null,
				/* hud_owner = */ null,
				/* escape_menu = */ src,
				/* button_text = */ player.ckey,
				/* offset = */ list(vertical_amount, horizontal_amount),
				/* font_size = */ 12,
				/* on_click_callback = */ CALLBACK(src, PROC_REF(ignore_or_unignore), player.ckey),
			)
		)
		horizontal_amount += 150

	vertical_amount -= 30
	if(length(client.prefs.ignoring))
		page_holder.give_screen_object(
			new /atom/movable/screen/escape_menu/text(
				null,
				/* hud_owner = */ null,
				/* escape_menu = */ src,
				/* button_text = */ "Ignored",
				/* offset = */ list(vertical_amount, 0),
			)
		)
		vertical_amount -= 20
		horizontal_amount = -170
		for(var/ignored_key in client.prefs.ignoring - GLOB.directory) //ignored offline people
			if(horizontal_amount >= 280)
				horizontal_amount = -170
				vertical_amount -= 20
			page_holder.give_screen_object(
				new /atom/movable/screen/escape_menu/text/clickable/ignoring/offline(
					null,
					/* hud_owner = */ null,
					/* escape_menu = */ src,
					/* button_text = */ ignored_key,
					/* offset = */ list(vertical_amount, horizontal_amount),
					/* font_size = */ 12,
					/* on_click_callback = */ CALLBACK(src, PROC_REF(ignore_or_unignore), ignored_key),
				)
			)
			horizontal_amount += 150

	page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small(
		null,
		/* hud_owner = */ null,
		/* button_text = */ null,
		/* tooltip_text = */ null,
		/* pixel_offset = */ list(280, -150),
		CALLBACK(page_holder, TYPE_PROC_REF(/datum/screen_object_holder, scroll), TRUE),
		/* button_overlay = */ "scroll_up",
	))
	page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small(
		null,
		/* hud_owner = */ null,
		/* button_text = */ null,
		/* tooltip_text = */ null,
		/* pixel_offset = */ list(280, -220),
		CALLBACK(page_holder, TYPE_PROC_REF(/datum/screen_object_holder, scroll)),
		/* button_overlay = */ "scroll_down",
	))
	page_holder.lowest_point = vertical_amount

/datum/escape_menu/proc/ignore_or_unignore(ckey, atom/movable/screen/escape_menu/text/clickable/ignoring/source)
	var/adding = FALSE
	if(ckey in client?.prefs.ignoring)
		client?.prefs.ignoring.Remove(ckey)
	else
		client?.prefs.ignoring.Add(ckey)
		adding = TRUE
	client?.prefs.save_preferences()
	source.update_text()
	to_chat(client, span_notice("User has been [!adding ? "un" : ""]ignored in OOC."))
