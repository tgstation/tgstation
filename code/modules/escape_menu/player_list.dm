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

	if(length(GLOB.admins))
		page_holder.give_screen_object(
			new /atom/movable/screen/escape_menu/text(
				null,
				/* hud_owner = */ null,
				"Admins",
				/* offset = */ list(-10, 80),
			)
		)

	var/vertical_amount = -30 //we start at -50, add -10 each time we go down.
	var/horizontal_amount = -170 //increasing by 150, we fit 3 per line this way.
	for(var/client/admin as anything in GLOB.admins)// - client) //we list admins first
		if(horizontal_amount >= 280)
			horizontal_amount = -170
			vertical_amount -= 30 //admins push you further down for their feedback links
		page_holder.give_screen_object(
			new /atom/movable/screen/escape_menu/home_button/player_list/admin(
				null,
				/* hud_owner = */ null,
				/* escape_menu = */ src,
				/* button_text = */ admin.ckey,
				/* offset = */ "NORTH:[vertical_amount],CENTER:[horizontal_amount]",
				CALLBACK(src, PROC_REF(ignore_or_unignore), admin.ckey),
				/* font_size = */ 12,
				/* admin_rank = */ "Maintainer+Coder",//admin.holder.rank_names(),
				/* feedback_link = */ "https://github.com/tgstation/tgstation/pull/89250/",//admin.holder.feedback_link(),
			)
		)
		horizontal_amount += 150

	vertical_amount -= 30
	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text(
			null,
			/* hud_owner = */ null,
			"Players",
			/* offset = */ list("[vertical_amount]", 80),
		)
	)
	vertical_amount -= 20
	horizontal_amount = -250 //players will get 4 ckeys per line so we can fit more.
	for(var/client/player as anything in GLOB.clients)// - GLOB.admins - client)
		if(horizontal_amount >= 350)
			horizontal_amount = -250
			vertical_amount -= 20
		page_holder.give_screen_object(
			new /atom/movable/screen/escape_menu/home_button/player_list(
				null,
				/* hud_owner = */ null,
				/* escape_menu = */ src,
				/* button_text = */ player.ckey,
				/* offset = */ "NORTH:[vertical_amount],CENTER:[horizontal_amount]",
				CALLBACK(src, PROC_REF(ignore_or_unignore), player.ckey),
				/* font_size = */ 12,
			)
		)
		horizontal_amount += 150

	vertical_amount -= 30
	if(length(client.prefs.ignoring))
		page_holder.give_screen_object(
			new /atom/movable/screen/escape_menu/text(
				null,
				/* hud_owner = */ null,
				"Ignored",
				/* offset = */ list("[vertical_amount]", 80),
			)
		)
	vertical_amount -= 20
	horizontal_amount = -250 //players will get 4 ckeys per line so we can fit more.
	for(var/ignored_key in client.prefs.ignoring - GLOB.directory) //ignored offline people
		if(horizontal_amount >= 350)
			horizontal_amount = -250
			vertical_amount -= 20
		page_holder.give_screen_object(
			new /atom/movable/screen/escape_menu/home_button/player_list/offline(
				null,
				/* hud_owner = */ null,
				/* escape_menu = */ src,
				/* button_text = */ ignored_key,
				/* offset = */ "NORTH:[vertical_amount],CENTER:[horizontal_amount]",
				CALLBACK(src, PROC_REF(ignore_or_unignore), ignored_key),
				/* font_size = */ 12,
			)
		)
		horizontal_amount += 150

/datum/escape_menu/proc/ignore_or_unignore(ckey, atom/movable/screen/escape_menu/home_button/player_list/source)
	var/adding = FALSE
	if(ckey in client?.prefs.ignoring)
		client?.prefs.ignoring.Remove(ckey)
	else
		client?.prefs.ignoring.Add(ckey)
		adding = TRUE
	client?.prefs.save_preferences()
	source.update_text()
	to_chat(client, span_notice("[ckey] has been [adding ? "ignored" : "unignored"] in OOC."))

/atom/movable/screen/escape_menu/home_button/player_list
	var/player_ckey

/atom/movable/screen/escape_menu/home_button/player_list/Initialize(
	mapload,
	datum/hud/hud_owner,
	datum/escape_menu/escape_menu,
	button_text,
	offset,
	on_click_callback,
	font_size,
)

	src.player_ckey = button_text
	. = ..()
	home_button_text.pixel_x = 5 //let's move the highlighted text to where we are.
	screen_loc = offset

/atom/movable/screen/escape_menu/home_button/player_list/text_color()
	return (player_ckey in escape_menu.client?.prefs.ignoring) ? "grey" : "white"

/atom/movable/screen/escape_menu/home_button/player_list/admin
	var/atom/movable/screen/escape_menu/home_button_text/admin_button_text

/atom/movable/screen/escape_menu/home_button/player_list/admin/Initialize(
	mapload,
	datum/hud/hud_owner,
	datum/escape_menu/escape_menu,
	button_text,
	offset,
	on_click_callback,
	font_size,
	admin_rank,
	feedback_link,
)
	. = ..()
	admin_button_text = new /atom/movable/screen/escape_menu/home_button_text(
		src,
		/* hud_owner = */ src,
		feedback_link ? "<a href='[feedback_link]'>[admin_rank]</a>" : "[admin_rank]",
		/* maptext_font_size = */ "[(font_size / 1.5)]px",
	)
	admin_button_text.maptext_x = 60
	admin_button_text.maptext_y = -15
	vis_contents += admin_button_text

/atom/movable/screen/escape_menu/home_button/player_list/offline/update_text()
	qdel(src)
