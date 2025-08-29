/datum/escape_menu/proc/show_home_page()
	page_holder.give_protected_screen_object(give_escape_menu_title())
	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text/clickable(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "Resume",
			/* offset = */ list(-136, 30),
			/* font_size = */ 24,
			/* on_click_callback = */ CALLBACK(src, PROC_REF(home_resume)),
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text/clickable(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "Character",
			/* offset = */ list(-171, 28),
			/* font_size = */ 24,
			/* on_click_callback = */ CALLBACK(src, PROC_REF(home_open_character_settings)),
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text/clickable(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "Settings",
			/* offset = */ list(-206, 30),
			/* font_size = */ 24,
			/* on_click_callback = */ CALLBACK(src, PROC_REF(home_open_game_settings)),
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text/clickable/admin_help(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "Admin Help",
			/* offset = */ list(-241, 30),
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text/clickable/leave_body(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "Leave Body",
			/* offset = */ list(-276, 30),
			/* font_size = */ 24,
			/* on_click_callback = */ CALLBACK(src, PROC_REF(open_leave_body)),
		)
	)

	//Bottom right buttons, from right to left, starting with the button to open the list.
	page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small(
		null,
		/* hud_owner = */ null,
		"Resources",
		"Open/Close list of resources",
		/* button_screen_loc */ "BOTTOM:30,RIGHT:-20",
		CALLBACK(src, PROC_REF(toggle_resources)),
		/* button_overlay = */ "resources",
	))

/datum/escape_menu/proc/toggle_resources()
	show_resources = !show_resources
	if(!show_resources)
		//collapsing it
		for(var/atom/movable/screen/escape_menu/lobby_button/small/collapsible/button as anything in resource_panels)
			button.collapse(page_holder)
		resource_panels.Cut()
		return
	//list of offsets we give, so missing icons don't leave a random gap.
	var/list/offset_order = list(
		-60,
		-120,
		-180,
		-240,
		-300,
		-360,
		-420,
		-480,
	)
	resource_panels = list()

	var/githuburl = CONFIG_GET(string/githuburl)
	if(githuburl)
		resource_panels += page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small/collapsible(
			null,
			/* hud_owner = */ null,
			"Report Bug",
			"Report a bug/issue",
			/* button_screen_loc */ "BOTTOM:30,RIGHT:-20",
			CALLBACK(client, TYPE_VERB_REF(/client, reportissue)),
			/* button_overlay = */ "bug",
			/* end_point */ offset_order[1],
		))
		offset_order -= offset_order[1]
		resource_panels += page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small/collapsible(
			null,
			/* hud_owner = */ null,
			"Github",
			"Open the repository for the game",
			/* button_screen_loc */ "BOTTOM:30,RIGHT:-20",
			CALLBACK(client, TYPE_VERB_REF(/client, github)),
			/* button_overlay = */ "github",
			/* end_point */ offset_order[1],
		))
		offset_order -= offset_order[1]

	var/forumurl = CONFIG_GET(string/forumurl)
	if(forumurl)
		resource_panels += page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small/collapsible(
			null,
			/* hud_owner = */ null,
			"Forums",
			"Visit the server's forums",
			/* button_screen_loc */ "BOTTOM:30,RIGHT:-20",
			CALLBACK(client, TYPE_VERB_REF(/client, forum)),
			/* button_overlay = */ "forums",
			/* end_point */ offset_order[1],
		))
		offset_order -= offset_order[1]

	var/rulesurl = CONFIG_GET(string/rulesurl)
	if(rulesurl)
		resource_panels += page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small/collapsible(
			null,
			/* hud_owner = */ null,
			"Rules",
			"View the server rules",
			/* button_screen_loc */ "BOTTOM:30,RIGHT:-20",
			CALLBACK(client, TYPE_VERB_REF(/client, rules)),
			/* button_overlay = */ "rules",
			/* end_point */ offset_order[1],
		))
		offset_order -= offset_order[1]

	var/wikiurl = CONFIG_GET(string/wikiurl)
	if(wikiurl)
		resource_panels += page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small/collapsible(
			null,
			/* hud_owner = */ null,
			"Wiki",
			"See the wiki for the game",
			/* button_screen_loc */ "BOTTOM:30,RIGHT:-20",
			CALLBACK(client, TYPE_VERB_REF(/client, wiki)),
			/* button_overlay = */ "wiki",
			/* end_point */ offset_order[1],
		))
		offset_order -= offset_order[1]

	resource_panels += page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small/collapsible(
		null,
		/* hud_owner = */ null,
		"Change Log",
		"See all changes to the server",
		/* button_screen_loc */ "BOTTOM:30,RIGHT:-20",
		CALLBACK(client, TYPE_VERB_REF(/client, changelog)),
		/* button_overlay = */ "changelog",
		/* end_point */ offset_order[1],
	))

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

