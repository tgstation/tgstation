#define SHUTTER_MOVEMENT_DURATION 0.4 SECONDS
#define SHUTTER_WAIT_DURATION 0.2 SECONDS
/// Maximum number of station trait buttons we will display, please think hard before creating scenarios where there are more than this
#define MAX_STATION_TRAIT_BUTTONS_VERTICAL 3

/datum/hud/new_player
	///Whether the menu is currently on the client's screen or not
	var/menu_hud_status = TRUE
	var/list/shown_station_trait_buttons

/datum/hud/new_player/New(mob/owner)
	. = ..()

	if (!owner || !owner.client)
		return

	if (owner.client.interviewee)
		return

	var/list/buttons = subtypesof(/atom/movable/screen/lobby)
	for (var/atom/movable/screen/lobby/lobbyscreen as anything in buttons)
		if (!initial(lobbyscreen.always_available))
			continue
		lobbyscreen = new lobbyscreen(our_hud = src)
		lobbyscreen.SlowInit()
		static_inventory += lobbyscreen
		if (!lobbyscreen.always_shown)
			lobbyscreen.RegisterSignal(src, COMSIG_HUD_LOBBY_COLLAPSED, TYPE_PROC_REF(/atom/movable/screen/lobby, collapse_button))
			lobbyscreen.RegisterSignal(src, COMSIG_HUD_LOBBY_EXPANDED, TYPE_PROC_REF(/atom/movable/screen/lobby, expand_button))

	if (!owner.client.is_localhost())
		return

	var/atom/movable/screen/lobby/button/start_now/start_button = new(our_hud = src)
	start_button.SlowInit()
	static_inventory += start_button
	start_button.RegisterSignal(src, COMSIG_HUD_LOBBY_COLLAPSED, TYPE_PROC_REF(/atom/movable/screen/lobby, collapse_button))
	start_button.RegisterSignal(src, COMSIG_HUD_LOBBY_EXPANDED, TYPE_PROC_REF(/atom/movable/screen/lobby, expand_button))

/// Load and then display the buttons for relevant station traits
/datum/hud/new_player/proc/show_station_trait_buttons()
	if (!mymob?.client || mymob.client.interviewee || !length(GLOB.lobby_station_traits))
		return
	for (var/datum/station_trait/trait as anything in GLOB.lobby_station_traits)
		if (QDELETED(trait) || !trait.can_display_lobby_button(mymob.client))
			remove_station_trait_button(trait)
			continue
		if(LAZYACCESS(shown_station_trait_buttons, trait))
			continue
		var/atom/movable/screen/lobby/button/sign_up/sign_up_button = new(our_hud = src)
		trait.setup_lobby_button(sign_up_button)
		static_inventory |= sign_up_button
		LAZYSET(shown_station_trait_buttons, trait, sign_up_button)
		RegisterSignal(trait, COMSIG_QDELETING, PROC_REF(remove_station_trait_button))

	place_station_trait_buttons()

/// Display the buttosn for relevant station traits.
/datum/hud/new_player/proc/place_station_trait_buttons()
	if(hud_version != HUD_STYLE_STANDARD || !mymob?.client)
		return

	var/y_offset = 397
	var/x_offset = 233
	var/y_button_offset = 27
	var/x_button_offset = -27
	var/iteration = 0
	for(var/trait in shown_station_trait_buttons)
		var/atom/movable/screen/lobby/button/sign_up/sign_up_button = shown_station_trait_buttons[trait]
		iteration++
		sign_up_button.screen_loc = offset_to_screen_loc(x_offset, y_offset, mymob.client.view)
		mymob.client.screen |= sign_up_button
		if (iteration >= MAX_STATION_TRAIT_BUTTONS_VERTICAL)
			iteration = 0
			y_offset = 397
			x_offset += x_button_offset
		else
			y_offset += y_button_offset

/// Remove a station trait button, then re-order the rest.
/datum/hud/new_player/proc/remove_station_trait_button(datum/station_trait/trait)
	SIGNAL_HANDLER
	var/atom/movable/screen/lobby/button/sign_up/button = LAZYACCESS(shown_station_trait_buttons, trait)
	if(!button)
		return
	LAZYREMOVE(shown_station_trait_buttons, trait)
	UnregisterSignal(trait, COMSIG_QDELETING)
	static_inventory -= button
	qdel(button)
	place_station_trait_buttons()

/atom/movable/screen/lobby
	plane = SPLASHSCREEN_PLANE
	layer = LOBBY_MENU_LAYER
	screen_loc = "TOP,CENTER"
	/// Whether this HUD element can be hidden from the client's "screen" (moved off-screen) or not
	var/always_shown = FALSE
	/// If true we will create this button every time the HUD is generated
	var/always_available = TRUE

///Set the HUD in New, as lobby screens are made before Atoms are Initialized.
/atom/movable/screen/lobby/New(loc, datum/hud/our_hud, ...)
	set_new_hud(our_hud)
	return ..()

///Run sleeping actions after initialize
/atom/movable/screen/lobby/proc/SlowInit()
	return

///Animates moving the button off-screen
/atom/movable/screen/lobby/proc/collapse_button()
	SIGNAL_HANDLER
	//wait for the shutter to come down
	animate(src, transform = transform, time = SHUTTER_MOVEMENT_DURATION + SHUTTER_WAIT_DURATION)
	//then pull the buttons up with the shutter
	animate(transform = transform.Translate(x = 0, y = 146), time = SHUTTER_MOVEMENT_DURATION, easing = CUBIC_EASING|EASE_IN)

///Animates moving the button back into place
/atom/movable/screen/lobby/proc/expand_button()
	SIGNAL_HANDLER
	//the buttons are off-screen, so we sync them up to come down with the shutter
	animate(src, transform = matrix(), time = SHUTTER_MOVEMENT_DURATION, easing = CUBIC_EASING|EASE_OUT)

/atom/movable/screen/lobby/background
	icon = 'icons/hud/lobby/background.dmi'
	icon_state = "background"
	screen_loc = "TOP,CENTER:-61"

/atom/movable/screen/lobby/button
	mouse_over_pointer = MOUSE_HAND_POINTER
	///Is the button currently enabled?
	VAR_PROTECTED/enabled = TRUE
	///Is the button currently being hovered over with the mouse?
	var/highlighted = FALSE
	///Should this button play the select sound?
	var/select_sound_play = TRUE

/atom/movable/screen/lobby/button/Click(location, control, params)
	if(usr != get_mob())
		return

	if(!usr.client || usr.client.interviewee)
		return

	. = ..()

	if(!enabled)
		return
	flick("[base_icon_state]_pressed", src)
	if(select_sound_play)
		var/sound/ui_select_sound = sound('sound/misc/menu/ui_select1.ogg')
		ui_select_sound.frequency = get_rand_frequency_low_range()
		SEND_SOUND(hud.mymob, ui_select_sound)
	update_appearance(UPDATE_ICON)
	return TRUE

/atom/movable/screen/lobby/button/MouseEntered(location,control,params)
	if(usr != get_mob())
		return

	if(!usr.client || usr.client.interviewee)
		return

	. = ..()
	highlighted = TRUE
	update_appearance(UPDATE_ICON)

/atom/movable/screen/lobby/button/MouseExited()
	if(usr != get_mob())
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
	mouse_over_pointer = enabled ? MOUSE_HAND_POINTER : MOUSE_INACTIVE_POINTER
	return TRUE

///Prefs menu
/atom/movable/screen/lobby/button/character_setup
	name = "View Character Setup"
	screen_loc = "TOP:-70,CENTER:-54"
	icon = 'icons/hud/lobby/character_setup.dmi'
	icon_state = "character_setup_disabled"
	base_icon_state = "character_setup"
	enabled = FALSE

/atom/movable/screen/lobby/button/character_setup/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	// We need IconForge and the assets to be ready before allowing the menu to open
	if(SSearly_assets.initialized == INITIALIZATION_INNEW_REGULAR || SSatoms.initialized == INITIALIZATION_INNEW_REGULAR)
		flick("[base_icon_state]_enabled", src)
		set_button_status(TRUE)
	else
		set_button_status(FALSE)
		RegisterSignal(SSearly_assets, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(enable_character_setup))
		RegisterSignal(SSatoms, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(enable_character_setup))

/atom/movable/screen/lobby/button/character_setup/Click(location, control, params)
	. = ..()
	if(!.)
		return

	var/datum/preferences/preferences = hud.mymob.canon_client.prefs
	preferences.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
	preferences.update_static_data(usr)
	preferences.ui_interact(usr)

/atom/movable/screen/lobby/button/character_setup/proc/enable_character_setup()
	SIGNAL_HANDLER
	flick("[base_icon_state]_enabled", src)
	set_button_status(TRUE)
	UnregisterSignal(SSearly_assets, COMSIG_SUBSYSTEM_POST_INITIALIZE)
	UnregisterSignal(SSatoms, COMSIG_SUBSYSTEM_POST_INITIALIZE)

///Button that appears before the game has started
/atom/movable/screen/lobby/button/ready
	name = "Toggle Readiness"
	screen_loc = "TOP:-8,CENTER:-65"
	icon = 'icons/hud/lobby/ready.dmi'
	icon_state = "not_ready"
	base_icon_state = "not_ready"
	///Whether we are readied up for the round or not
	var/ready = FALSE

/atom/movable/screen/lobby/button/ready/Initialize(mapload, datum/hud/hud_owner)
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
		new_player.auto_deadmin_on_ready_or_latejoin()
		new_player.ready = PLAYER_READY_TO_PLAY
		base_icon_state = "ready"
	else
		new_player.ready = PLAYER_NOT_READY
		base_icon_state = "not_ready"
	update_appearance(UPDATE_ICON)
	SEND_SIGNAL(hud, COMSIG_HUD_PLAYER_READY_TOGGLE)

///Shown when the game has started
/atom/movable/screen/lobby/button/join
	name = "Join Game"
	screen_loc = "TOP:-13,CENTER:-58"
	icon = 'icons/hud/lobby/join.dmi'
	icon_state = "" //Default to not visible
	base_icon_state = "join_game"
	enabled = null // set in init

/atom/movable/screen/lobby/button/join/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	switch(SSticker.current_state)
		if(GAME_STATE_PREGAME, GAME_STATE_STARTUP)
			set_button_status(FALSE)
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

	new_player.auto_deadmin_on_ready_or_latejoin()

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
	enabled = null // set in init

/atom/movable/screen/lobby/button/observe/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	if(SSticker.current_state > GAME_STATE_STARTUP)
		set_button_status(TRUE)
	else
		set_button_status(FALSE)
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

/atom/movable/screen/lobby/button/bottom/settings
	name = "View Game Preferences"
	icon_state = "settings_disabled"
	base_icon_state = "settings"
	screen_loc = "TOP:-122,CENTER:+29"
	enabled = FALSE

/atom/movable/screen/lobby/button/bottom/settings/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	// We need IconForge and the assets to be ready before allowing the menu to open
	if(SSearly_assets.initialized == INITIALIZATION_INNEW_REGULAR || SSatoms.initialized == INITIALIZATION_INNEW_REGULAR)
		set_button_status(TRUE)
	else
		set_button_status(FALSE)
		RegisterSignal(SSearly_assets, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(enable_settings))
		RegisterSignal(SSatoms, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(enable_settings))

/atom/movable/screen/lobby/button/bottom/settings/Click(location, control, params)
	. = ..()
	if(!.)
		return

	var/datum/preferences/preferences = hud.mymob.canon_client.prefs
	preferences.current_window = PREFERENCE_TAB_GAME_PREFERENCES
	preferences.update_static_data(usr)
	preferences.ui_interact(usr)

/atom/movable/screen/lobby/button/bottom/settings/proc/enable_settings()
	SIGNAL_HANDLER
	set_button_status(TRUE)
	UnregisterSignal(SSearly_assets, COMSIG_SUBSYSTEM_POST_INITIALIZE)
	UnregisterSignal(SSatoms, COMSIG_SUBSYSTEM_POST_INITIALIZE)

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

/// A generic "sign up" button used by station traits
/atom/movable/screen/lobby/button/sign_up
	icon = 'icons/hud/lobby/signup_button.dmi'
	icon_state = "signup"
	base_icon_state = "signup"
	always_available = FALSE

/atom/movable/screen/lobby/button/sign_up/MouseEntered(location, control, params)
	. = ..()
	if(QDELETED(src) || !desc)
		return
	openToolTip(usr, tip_src = src, params = params, title = name, content = desc,)

/atom/movable/screen/lobby/button/sign_up/MouseExited()
	. = ..()
	closeToolTip(usr)

/atom/movable/screen/lobby/button/collapse
	name = "Collapse Lobby Menu"
	icon = 'icons/hud/lobby/collapse_expand.dmi'
	icon_state = "collapse"
	base_icon_state = "collapse"
	layer = LOBBY_BELOW_MENU_LAYER
	screen_loc = "TOP:-82,CENTER:-54"
	always_shown = TRUE

	var/blip_enabled = TRUE

/atom/movable/screen/lobby/button/collapse/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	switch(SSticker.current_state)
		if(GAME_STATE_PREGAME, GAME_STATE_STARTUP)
			RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(disable_blip))
			RegisterSignal(hud, COMSIG_HUD_PLAYER_READY_TOGGLE, PROC_REF(on_player_ready_toggle))
		if(GAME_STATE_SETTING_UP)
			blip_enabled = FALSE
			RegisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP, PROC_REF(enable_blip))
		else
			blip_enabled = FALSE

	add_overlay(get_blip_overlay())
	update_icon(UPDATE_OVERLAYS)

/atom/movable/screen/lobby/button/collapse/update_overlays()
	. = ..()
	. += get_blip_overlay()

/atom/movable/screen/lobby/button/collapse/Click(location, control, params)
	. = ..()
	if(!.)
		return

	if(!istype(hud, /datum/hud/new_player))
		return
	var/datum/hud/new_player/our_hud = hud
	base_icon_state = our_hud.menu_hud_status ? "expand" : "collapse"
	name = "[our_hud.menu_hud_status ? "Expand" : "Collapse"] Lobby Menu"
	set_button_status(FALSE)

	//get the shutter object used by our hud
	var/atom/movable/screen/lobby/shutter/menu_shutter = locate(/atom/movable/screen/lobby/shutter) in hud.static_inventory

	//animate the shutter
	menu_shutter.setup_shutter_animation()
	//animate bottom buttons' movement
	if(our_hud.menu_hud_status)
		collapse_menu()
	else
		expand_menu()
	our_hud.menu_hud_status = !our_hud.menu_hud_status

	//re-enable clicking the button when the shutter animation finishes
	//we use sleep here so it can work during game setup, as addtimer would not work until the game would finish setting up
	sleep(2 * SHUTTER_MOVEMENT_DURATION + SHUTTER_WAIT_DURATION)
	set_button_status(TRUE)

///Proc to update the ready blip state upon new player's ready status change
/atom/movable/screen/lobby/button/collapse/proc/on_player_ready_toggle()
	SIGNAL_HANDLER
	update_appearance(UPDATE_ICON)

///Returns a ready blip overlay depending on the player's ready state
/atom/movable/screen/lobby/button/collapse/proc/get_blip_overlay()
	var/blip_icon_state = "ready_blip"
	if(blip_enabled && hud)
		var/mob/dead/new_player/new_player = hud.mymob
		blip_icon_state += "_[new_player.ready ? "" : "not_"]ready"
	else
		blip_icon_state += "_disabled"
	var/mutable_appearance/ready_blip = mutable_appearance(icon, blip_icon_state)
	return ready_blip

///Disables the ready blip; makes us listen for the setup error to re-enable the blip
/atom/movable/screen/lobby/button/collapse/proc/disable_blip()
	SIGNAL_HANDLER
	blip_enabled = FALSE
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP)
	RegisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP, PROC_REF(enable_blip))
	update_appearance(UPDATE_ICON)

///Enables the ready blip; makes us listen for the setup completion and game start to disable the blip
/atom/movable/screen/lobby/button/collapse/proc/enable_blip()
	SIGNAL_HANDLER
	blip_enabled = TRUE
	UnregisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP)
	RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(disable_blip))
	update_appearance(UPDATE_ICON)

///Moves the button to the top of the screen, leaving only the screen part in view
///Sends a signal on the hud for the menu hud elements to listen to
/atom/movable/screen/lobby/button/collapse/proc/collapse_menu()
	SEND_SIGNAL(hud, COMSIG_HUD_LOBBY_COLLAPSED)
	//wait for the shutter to come down
	animate(src, transform = transform, time = SHUTTER_MOVEMENT_DURATION + SHUTTER_WAIT_DURATION)
	//then pull the button up with the shutter and leave it on the edge of the screen
	animate(transform = transform.Translate(x = 0, y = 134), time = SHUTTER_MOVEMENT_DURATION, easing = CUBIC_EASING|EASE_IN)
	SEND_SOUND(hud.mymob, sound('sound/misc/menu/menu_rollup1.ogg'))

///Extends the button back to its usual spot
///Sends a signal on the hud for the menu hud elements to listen to
/atom/movable/screen/lobby/button/collapse/proc/expand_menu()
	SEND_SIGNAL(hud, COMSIG_HUD_LOBBY_EXPANDED)
	animate(src, transform = matrix(), time = SHUTTER_MOVEMENT_DURATION, easing = CUBIC_EASING|EASE_OUT)
	SEND_SOUND(hud.mymob, sound('sound/misc/menu/menu_rolldown1.ogg'))

/atom/movable/screen/lobby/shutter
	icon = 'icons/hud/lobby/shutter.dmi'
	icon_state = "shutter"
	base_icon_state = "shutter"
	screen_loc = "TOP:+143,CENTER:-73" //"home" position is off-screen
	layer = LOBBY_SHUTTER_LAYER
	always_shown = TRUE

///Sets up the shutter pulling down and up. It's the same animation for both collapsing and expanding the menu.
/atom/movable/screen/lobby/shutter/proc/setup_shutter_animation()
	//bring down the shutter
	animate(src, transform = transform.Translate(x = 0, y = -143), time = SHUTTER_MOVEMENT_DURATION, easing = CUBIC_EASING|EASE_OUT)

	//wait a little bit before bringing the shutter up
	animate(transform = transform, time = SHUTTER_WAIT_DURATION)

	//pull the shutter back off-screen
	animate(transform = matrix(), time = SHUTTER_MOVEMENT_DURATION, easing = CUBIC_EASING|EASE_IN)

/// LOCALHOST ONLY - Start Now button
/atom/movable/screen/lobby/button/start_now
	name = "Start Now (LOCALHOST ONLY)"
	screen_loc = "TOP:-146,CENTER:-54"
	icon = 'icons/hud/lobby/start_now.dmi'
	icon_state = "start_now"
	base_icon_state = "start_now"
	always_available = FALSE
	select_sound_play = FALSE

/atom/movable/screen/lobby/button/start_now/Click(location, control, params)
	. = ..()
	if(!. || !usr.client.is_localhost() || !check_rights_for(usr.client, R_SERVER))
		return
	SEND_SOUND(hud.mymob, sound('sound/effects/splat.ogg', volume = 50))
	SSticker.start_immediately = TRUE
	if(SSticker.current_state == GAME_STATE_STARTUP)
		to_chat(usr, span_admin("The server is still setting up, but the round will be started as soon as possible."))

#define OVERLAY_X_DIFF 12
#define OVERLAY_Y_DIFF 5

///Lobby screen that appears before the game has started showing how many players there are and who is ready.
/atom/movable/screen/lobby/new_player_info
	name = "New Player Info"
	screen_loc = "EAST-3,CENTER:140"
	icon = 'icons/hud/lobby/newplayer.dmi'
	icon_state = null //we only show up when we get update appearance called, cause we need our overlay to not look bad.
	base_icon_state = "newplayer"
	maptext_height = 75
	maptext_width = 80
	maptext_x = OVERLAY_X_DIFF
	maptext_y = OVERLAY_Y_DIFF

	///Boolean on whether or not we should have our static overlay, so we 'turn' the TV off when collapsing.
	var/show_static = TRUE

/atom/movable/screen/lobby/new_player_info/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	START_PROCESSING(SSnewplayer_info, src)
	update_text()
	update_appearance(UPDATE_ICON)

/atom/movable/screen/lobby/new_player_info/Destroy()
	STOP_PROCESSING(SSnewplayer_info, src)
	return ..()

/atom/movable/screen/lobby/new_player_info/update_icon_state()
	. = ..()
	icon_state = base_icon_state

/atom/movable/screen/lobby/new_player_info/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "[base_icon_state]_overlay", layer = src.layer+0.03)
	if(!show_static)
		return .
	. += mutable_appearance(icon, "static_base", alpha = 20, layer = src.layer+0.01)
	//we have this in a separate file because `generate_icon_alpha_mask` puts lighting even on non-existent pixels,
	//giving the icon a weird background color.
	var/mutable_appearance/scanline = mutable_appearance(generate_icon_alpha_mask('icons/hud/lobby/newplayer_scanline.dmi', "scanline"), alpha = 20, layer = src.layer+0.02)
	scanline.pixel_y = OVERLAY_X_DIFF
	scanline.pixel_x = OVERLAY_Y_DIFF
	. += scanline

/atom/movable/screen/lobby/new_player_info/process(seconds_per_tick)
	update_text()

/atom/movable/screen/lobby/new_player_info/collapse_button()
	show_static = FALSE
	update_text()
	//to be in sync with parent, we'll turn the TV off in this time instead.
	animate(src, appearance = update_appearance(UPDATE_ICON), time = SHUTTER_MOVEMENT_DURATION + SHUTTER_WAIT_DURATION)
	//we go to the right, not up
	animate(transform = transform.Translate(x = 146, y = 0), time = SHUTTER_MOVEMENT_DURATION, easing = CUBIC_EASING|EASE_IN)

/atom/movable/screen/lobby/new_player_info/expand_button()
	. = ..()
	show_static = TRUE
	update_appearance(UPDATE_ICON)
	update_text()

/atom/movable/screen/lobby/new_player_info/proc/update_text()
	if(!hud || !show_static)
		maptext = null
		return
	if(!MC_RUNNING())
		maptext = MAPTEXT("<span style='text-align: center; vertical-align: middle'>Loading...</span>")
		return
	if(SSticker.IsPostgame())
		maptext = MAPTEXT("<span style='text-align: center; vertical-align: middle'>Game ended, <br /> \
			restart soon</span>")
		return

	var/new_maptext
	var/round_started = SSticker.HasRoundStarted()
	if(round_started)
		new_maptext = "<span style='text-align: center; vertical-align: middle'>[SSmapping.current_map.map_name]<br /> \
			[LAZYLEN(GLOB.clients)] player\s online<br /> \
			[ROUND_TIME()] in<br />"
		var/datum/station_trait/overflow_job_bureaucracy/overflow = locate() in SSstation.station_traits
		if(overflow)
			new_maptext += "[overflow.chosen_job_name] overflow"
		new_maptext += "</span>"
	else
		var/time_remaining = SSticker.GetTimeLeft()
		if(time_remaining > 0)
			time_remaining = "[round(time_remaining/10)]s"
		else if(time_remaining == -10)
			time_remaining = "DELAYED"
		else
			time_remaining = "SOON"

		if(hud.mymob.client.holder)
			new_maptext = "<span style='text-align: center; vertical-align: middle'>Starting in [time_remaining]<br /> \
				[LAZYLEN(GLOB.clients)] player\s<br /> \
				[SSticker.totalPlayersReady] players ready<br /> \
				[SSticker.total_admins_ready] / [length(GLOB.admins)] admins ready</span>"
		else
			new_maptext = "<span style='text-align: center; vertical-align: middle; font-size: 18px'>[time_remaining]</span><br /> \
				<span style='text-align: center; vertical-align: middle'>[LAZYLEN(GLOB.clients)] player\s</span>"

	maptext = MAPTEXT(new_maptext)

#undef OVERLAY_X_DIFF
#undef OVERLAY_Y_DIFF

#undef SHUTTER_MOVEMENT_DURATION
#undef SHUTTER_WAIT_DURATION
#undef MAX_STATION_TRAIT_BUTTONS_VERTICAL
