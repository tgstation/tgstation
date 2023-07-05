/datum/hud/new_player
	inventory_shown = TRUE

/datum/hud/new_player/New(mob/owner)
	..()

	if(!owner || !owner.client)
		return

	if (owner.client.interviewee)
		return

	var/list/buttons = subtypesof(/atom/movable/screen/lobby)
	for(var/button_type in buttons)
		var/atom/movable/screen/lobby/lobbyscreen = new button_type()
		lobbyscreen.SlowInit()
		lobbyscreen.hud = src
		if(lobbyscreen.always_shown)
			static_inventory += lobbyscreen
		else
			toggleable_inventory += lobbyscreen
		if(istype(lobbyscreen, /atom/movable/screen/lobby/button))
			var/atom/movable/screen/lobby/button/lobby_button = lobbyscreen
			lobby_button.owner = REF(owner)

/atom/movable/screen/lobby
	plane = SPLASHSCREEN_PLANE
	layer = LOBBY_BUTTON_LAYER
	screen_loc = "TOP,CENTER"
	///Whether this HUD element is toggleable or not (show/hide)
	var/always_shown = FALSE

/// Run sleeping actions after initialize
/atom/movable/screen/lobby/proc/SlowInit()
	return

/atom/movable/screen/lobby/background
	layer = LOBBY_BACKGROUND_LAYER
	icon = 'icons/hud/lobby/background.dmi'
	icon_state = "background"
	screen_loc = "TOP,CENTER:-61"

/atom/movable/screen/lobby/button
	///Is the button currently enabled?
	var/enabled = TRUE
	///Is the button currently being hovered over with the mouse?
	var/highlighted = FALSE
	/// The ref of the mob that owns this button. Only the owner can click on it.
	var/owner

/atom/movable/screen/lobby/button/Click(location, control, params)
	if(owner != REF(usr))
		return

	if(!usr.client || usr.client.interviewee)
		return

	. = ..()

	if(!enabled)
		return
	flick("[base_icon_state]_pressed", src)
	update_appearance(UPDATE_ICON)
	return TRUE

/atom/movable/screen/lobby/button/MouseEntered(location,control,params)
	if(owner != REF(usr))
		return

	if(!usr.client || usr.client.interviewee)
		return

	. = ..()
	highlighted = TRUE
	update_appearance(UPDATE_ICON)

/atom/movable/screen/lobby/button/MouseExited()
	if(owner != REF(usr))
		return

	if(!usr.client || usr.client.interviewee)
		return

	. = ..()
	highlighted = FALSE
	update_appearance(UPDATE_ICON)

/atom/movable/screen/lobby/button/update_icon(updates)
	. = ..()
	if(!enabled)
		icon_state = "[base_icon_state]_disabled"
		return
	else if(highlighted)
		icon_state = "[base_icon_state]_highlighted"
		return
	icon_state = base_icon_state

///Updates the button's status: TRUE to enable interaction with the button, FALSE to disable
/atom/movable/screen/lobby/button/proc/set_button_status(status)
	if(status == enabled)
		return FALSE
	enabled = status
	update_appearance(UPDATE_ICON)
	return TRUE

///Prefs menu
/atom/movable/screen/lobby/button/character_setup
	name = "View Character Setup"
	screen_loc = "TOP:-70,CENTER:-54"
	icon = 'icons/hud/lobby/character_setup.dmi'
	icon_state = "character_setup"
	base_icon_state = "character_setup"

/atom/movable/screen/lobby/button/character_setup/Click(location, control, params)
	. = ..()
	if(!.)
		return

	var/datum/preferences/preferences = hud.mymob.client.prefs
	preferences.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
	preferences.update_static_data(usr)
	preferences.ui_interact(usr)

///Button that appears before the game has started
/atom/movable/screen/lobby/button/ready
	name = "Toggle Readiness"
	screen_loc = "TOP:-8,CENTER:-65"
	icon = 'icons/hud/lobby/ready.dmi'
	icon_state = "not_ready"
	base_icon_state = "not_ready"
	var/ready = FALSE

/atom/movable/screen/lobby/button/ready/Initialize(mapload)
	. = ..()
	switch(SSticker.current_state)
		if(GAME_STATE_PREGAME, GAME_STATE_STARTUP)
			RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(hide_ready_button))
		if(GAME_STATE_SETTING_UP)
			set_button_status(FALSE)
			RegisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP, PROC_REF(show_ready_button))
		else
			set_button_status(FALSE)

/atom/movable/screen/lobby/button/ready/proc/hide_ready_button()
	SIGNAL_HANDLER
	set_button_status(FALSE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP)
	RegisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP, PROC_REF(show_ready_button))

/atom/movable/screen/lobby/button/ready/proc/show_ready_button()
	SIGNAL_HANDLER
	set_button_status(TRUE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP)
	RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(hide_ready_button))

/atom/movable/screen/lobby/button/ready/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	ready = !ready
	if(ready)
		new_player.ready = PLAYER_READY_TO_PLAY
		base_icon_state = "ready"
	else
		new_player.ready = PLAYER_NOT_READY
		base_icon_state = "not_ready"
	update_appearance(UPDATE_ICON)

///Shown when the game has started
/atom/movable/screen/lobby/button/join
	name = "Join Game"
	screen_loc = "TOP:-13,CENTER:-58"
	icon = 'icons/hud/lobby/join.dmi'
	icon_state = "" //Default to not visible
	base_icon_state = "join_game"
	enabled = FALSE

/atom/movable/screen/lobby/button/join/Initialize(mapload)
	. = ..()
	switch(SSticker.current_state)
		if(GAME_STATE_PREGAME, GAME_STATE_STARTUP)
			RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(show_join_button))
		if(GAME_STATE_SETTING_UP)
			set_button_status(TRUE)
			RegisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP, PROC_REF(hide_join_button))
		else
			set_button_status(TRUE)

/atom/movable/screen/lobby/button/join/Click(location, control, params)
	. = ..()
	if(!.)
		return

	if(!SSticker?.IsRoundInProgress())
		to_chat(hud.mymob, span_boldwarning("The round is either not ready, or has already finished..."))
		return

	//Determines Relevent Population Cap
	var/relevant_cap
	var/hard_popcap = CONFIG_GET(number/hard_popcap)
	var/extreme_popcap = CONFIG_GET(number/extreme_popcap)
	if(hard_popcap && extreme_popcap)
		relevant_cap = min(hard_popcap, extreme_popcap)
	else
		relevant_cap = max(hard_popcap, extreme_popcap)

	var/mob/dead/new_player/new_player = hud.mymob

	if(SSticker.queued_players.len || (relevant_cap && living_player_count() >= relevant_cap && !(ckey(new_player.key) in GLOB.admin_datums)))
		to_chat(new_player, span_danger("[CONFIG_GET(string/hard_popcap_message)]"))

		var/queue_position = SSticker.queued_players.Find(new_player)
		if(queue_position == 1)
			to_chat(new_player, span_notice("You are next in line to join the game. You will be notified when a slot opens up."))
		else if(queue_position)
			to_chat(new_player, span_notice("There are [queue_position-1] players in front of you in the queue to join the game."))
		else
			SSticker.queued_players += new_player
			to_chat(new_player, span_notice("You have been added to the queue to join the game. Your position in queue is [SSticker.queued_players.len]."))
		return

	if(!LAZYACCESS(params2list(params), CTRL_CLICK))
		GLOB.latejoin_menu.ui_interact(new_player)
	else
		to_chat(new_player, span_warning("Opening emergency fallback late join menu! If THIS doesn't show, ahelp immediately!"))
		GLOB.latejoin_menu.fallback_ui(new_player)


/atom/movable/screen/lobby/button/join/proc/show_join_button()
	SIGNAL_HANDLER
	set_button_status(TRUE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP)
	RegisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP, PROC_REF(hide_join_button))

/atom/movable/screen/lobby/button/join/proc/hide_join_button()
	SIGNAL_HANDLER
	set_button_status(FALSE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP)
	RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(show_join_button))

/atom/movable/screen/lobby/button/observe
	name = "Observe"
	screen_loc = "TOP:-40,CENTER:-54"
	icon = 'icons/hud/lobby/observe.dmi'
	icon_state = "observe_disabled"
	base_icon_state = "observe"
	enabled = FALSE

/atom/movable/screen/lobby/button/observe/Initialize(mapload)
	. = ..()
	if(SSticker.current_state > GAME_STATE_STARTUP)
		set_button_status(TRUE)
	else
		RegisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME, PROC_REF(enable_observing))

/atom/movable/screen/lobby/button/observe/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	new_player.make_me_an_observer()

/atom/movable/screen/lobby/button/observe/proc/enable_observing()
	SIGNAL_HANDLER
	flick("[base_icon_state]_enabled", src)
	set_button_status(TRUE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME)

//Subtype the bottom buttons away so the collapse/expand shutter goes behind them
/atom/movable/screen/lobby/button/bottom
	layer = LOBBY_BOTTOM_BUTTON_LAYER
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	always_shown = TRUE
	var/matrix/button_matrix = matrix()

/atom/movable/screen/lobby/button/bottom/SlowInit()
	. = ..()
	transform = button_matrix

/atom/movable/screen/lobby/button/bottom/settings
	name = "View Game Preferences"
	icon_state = "settings"
	base_icon_state = "settings"
	screen_loc = "TOP:-122,CENTER:+29"

/atom/movable/screen/lobby/button/bottom/settings/Click(location, control, params)
	. = ..()
	if(!.)
		return

	var/datum/preferences/preferences = hud.mymob.client.prefs
	preferences.current_window = PREFERENCE_TAB_GAME_PREFERENCES
	preferences.update_static_data(usr)
	preferences.ui_interact(usr)

/atom/movable/screen/lobby/button/bottom/changelog_button
	name = "View Changelog"
	icon_state = "changelog"
	base_icon_state = "changelog"
	screen_loc ="TOP:-122,CENTER:+57"

/atom/movable/screen/lobby/button/bottom/changelog_button/Click(location, control, params)
	. = ..()
	usr.client?.changelog()

/atom/movable/screen/lobby/button/bottom/crew_manifest
	name = "View Crew Manifest"
	icon_state = "crew_manifest"
	base_icon_state = "crew_manifest"
	screen_loc = "TOP:-122,CENTER:+2"

/atom/movable/screen/lobby/button/bottom/crew_manifest/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	new_player.ViewManifest()

/atom/movable/screen/lobby/button/bottom/poll
	name = "View Available Polls"
	icon_state = "poll"
	base_icon_state = "poll"
	screen_loc = "TOP:-122,CENTER:-26"
	///Whether the button should have a New Poll notification overlay
	var/new_poll = FALSE

/atom/movable/screen/lobby/button/bottom/poll/SlowInit(mapload)
	. = ..()
	if(!usr)
		return
	var/mob/dead/new_player/new_player = usr
	if(is_guest_key(new_player.key))
		set_button_status(FALSE)
		return
	if(!SSdbcore.Connect())
		set_button_status(FALSE)
		return
	var/isadmin = FALSE
	if(new_player.client?.holder)
		isadmin = TRUE
	var/datum/db_query/query_get_new_polls = SSdbcore.NewQuery({"
		SELECT id FROM [format_table_name("poll_question")]
		WHERE (adminonly = 0 OR :isadmin = 1)
		AND Now() BETWEEN starttime AND endtime
		AND deleted = 0
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_vote")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_textreply")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
	"}, list("isadmin" = isadmin, "ckey" = new_player.ckey))
	if(!query_get_new_polls.Execute())
		qdel(query_get_new_polls)
		set_button_status(FALSE)
		return
	if(query_get_new_polls.NextRow())
		new_poll = TRUE
	else
		new_poll = FALSE
	update_appearance(UPDATE_OVERLAYS)
	qdel(query_get_new_polls)
	if(QDELETED(new_player))
		set_button_status(FALSE)
		return

/atom/movable/screen/lobby/button/bottom/poll/update_overlays()
	. = ..()
	if(new_poll)
		. += mutable_appearance('icons/hud/lobby/poll_overlay.dmi', "new_poll")

/atom/movable/screen/lobby/button/bottom/poll/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	new_player.handle_player_polling()

#define SHUTTER_MOVEMENT_DURATION 0.4 SECONDS
#define SHUTTER_WAIT_DURATION 0.2 SECONDS

/atom/movable/screen/lobby/button/collapse
	name = "Collapse Lobby Menu"
	icon = 'icons/hud/lobby/collapse_expand.dmi'
	icon_state = "collapse"
	base_icon_state = "collapse"
	layer = LOBBY_COLLAPSE_BUTTON_LAYER
	screen_loc = "TOP:-82,CENTER:-54"
	always_shown = TRUE
	var/matrix/ce_button_matrix = matrix()

/atom/movable/screen/lobby/button/collapse/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	base_icon_state = new_player.hud_used.inventory_shown ? "expand" : "collapse"
	name = "[new_player.hud_used.inventory_shown ? "Collapse" : "Expand"] Lobby Menu"
	set_button_status(FALSE)
	//re-enable clicking the button when the shutter animation finishes
	addtimer(CALLBACK(src, PROC_REF(set_button_status), TRUE), (2 * SHUTTER_MOVEMENT_DURATION + SHUTTER_WAIT_DURATION))

	var/atom/movable/screen/lobby/shutter/menu_shutter = locate(/atom/movable/screen/lobby/shutter) in hud.static_inventory
	//build a list of bottom buttons for the shutter if it's empty
	if(!length(menu_shutter.bottom_buttons))
		for(var/atom/movable/screen/lobby/button/bottom/lobbyscreen in new_player.hud_used.static_inventory)
			menu_shutter.bottom_buttons += lobbyscreen

	addtimer(CALLBACK(src, PROC_REF(toggle_menu), new_player), SHUTTER_MOVEMENT_DURATION + 1) //ever so slightly after the shutter pulls down
	//animate the shutter
	menu_shutter.setup_shutter_animation()
	//animate bottom buttons' movement
	if(new_player.hud_used.inventory_shown)
		menu_shutter.collapse_bottom_buttons(new_player)
		collapse_button()
	else
		menu_shutter.expand_bottom_buttons(new_player)
		expand_button()

///Moves the button to the top of the screen, leaving only the screen part in view
/atom/movable/screen/lobby/button/collapse/proc/collapse_button()
	ce_button_matrix = matrix()
	//wait for the shutter to come down
	animate(src, transform = ce_button_matrix, time = SHUTTER_MOVEMENT_DURATION + SHUTTER_WAIT_DURATION)
	//then pull the button up with the shutter and leave it on the edge of the screen
	animate(transform = ce_button_matrix.Translate(x = 0, y = 134), time = SHUTTER_MOVEMENT_DURATION, easing = CUBIC_EASING|EASE_OUT)

///Extends the button back to its usual spot
/atom/movable/screen/lobby/button/collapse/proc/expand_button()
	animate(src, transform = ce_button_matrix.Translate(x = 0, y = -134), time = SHUTTER_MOVEMENT_DURATION, easing = CUBIC_EASING|EASE_IN)
	ce_button_matrix = matrix()

///Disables/enables menu buttons on the client's screen
/atom/movable/screen/lobby/button/collapse/proc/toggle_menu(mob/dead/new_player/new_player)
	if(new_player.hud_used.inventory_shown)
		new_player.client.screen -= new_player.hud_used.toggleable_inventory
	else
		new_player.client.screen += new_player.hud_used.toggleable_inventory
	new_player.hud_used.inventory_shown = !new_player.hud_used.inventory_shown

/atom/movable/screen/lobby/shutter
	icon = 'icons/hud/lobby/shutter.dmi'
	icon_state = "shutter"
	base_icon_state = "shutter"
	screen_loc = "TOP,CENTER:-73"
	layer = LOBBY_SHUTTER_LAYER
	always_shown = TRUE
	///List of bottom buttons on the UI; these are animated such as they appear to attach to the shutter
	///when it moves
	var/list/bottom_buttons = list()
	var/matrix/shutter_matrix = matrix()

/atom/movable/screen/lobby/shutter/SlowInit()
	. = ..()
	//screen_loc is initialized right above the main UI(the big three buttons), so we use
	//matrix transform to shift it up to be off-screen
	shutter_matrix.Translate(x = 0, y = 143) //the shutter moves just a wee bit shorter than the bottom buttons
	transform = shutter_matrix

///This animates moving the bottom buttons off-screen, disabling them
/atom/movable/screen/lobby/shutter/proc/collapse_bottom_buttons(mob/dead/new_player/new_player)
	for(var/atom/movable/screen/lobby/button/bottom/button_to_scroll_up in bottom_buttons)
		button_to_scroll_up.button_matrix = matrix()
		//wait for the shutter to come down
		animate(button_to_scroll_up, transform = button_to_scroll_up.button_matrix, time = SHUTTER_MOVEMENT_DURATION + SHUTTER_WAIT_DURATION)
		//then pull the buttons up with the shutter
		animate(transform = button_to_scroll_up.button_matrix.Translate(x = 0, y = 146), time = SHUTTER_MOVEMENT_DURATION, easing = CUBIC_EASING|EASE_OUT)
		if(istype(button_to_scroll_up, /atom/movable/screen/lobby/button/bottom/poll))
			var/atom/movable/screen/lobby/button/bottom/poll/poll_button = button_to_scroll_up
			if(!poll_button.new_poll) //don't deactivate the poll button unless a poll is up (it's already inactive)
				continue
		button_to_scroll_up.set_button_status(FALSE)

///This animates moving the bottom buttons back into place, re-enabling them
/atom/movable/screen/lobby/shutter/proc/expand_bottom_buttons(mob/dead/new_player/new_player)
	for(var/atom/movable/screen/lobby/button/bottom/button_to_scroll_down in bottom_buttons)
		//the buttons are off-screen, so we sync them up to come down with the shutter
		animate(button_to_scroll_down, transform = button_to_scroll_down.button_matrix.Translate(x = 0, y = -146), time = SHUTTER_MOVEMENT_DURATION, easing = CUBIC_EASING|EASE_IN)
		button_to_scroll_down.button_matrix = matrix()
		if(istype(button_to_scroll_down, /atom/movable/screen/lobby/button/bottom/poll))
			var/atom/movable/screen/lobby/button/bottom/poll/poll_button = button_to_scroll_down
			if(!poll_button.new_poll) //don't activate the poll button unless a poll is up
				continue
		button_to_scroll_down.set_button_status(TRUE)

///Sets up the shutter pulling down and up. It's the same animation for both collapsing and expanding the menu.
/atom/movable/screen/lobby/shutter/proc/setup_shutter_animation()
	//bring down the shutter
	animate(src, transform = matrix(), time = SHUTTER_MOVEMENT_DURATION, easing = CUBIC_EASING|EASE_IN)

	//wait a little bit before bringing the shutter up
	animate(transform = matrix(), time = SHUTTER_WAIT_DURATION)

	//pull the shutter back off-screen
	shutter_matrix = matrix()
	animate(transform = shutter_matrix.Translate(x = 0, y = 143), time = SHUTTER_MOVEMENT_DURATION, easing = CUBIC_EASING|EASE_OUT)

#undef SHUTTER_MOVEMENT_DURATION
#undef SHUTTER_WAIT_DURATION
