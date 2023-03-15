/datum/hud/new_player

/datum/hud/new_player/New(mob/owner)
	..()
	var/list/buttons = subtypesof(/atom/movable/screen/lobby)
	for(var/button in buttons)
		var/atom/movable/screen/lobbyscreen = new button()
		lobbyscreen.hud = src
		static_inventory += lobbyscreen

/atom/movable/screen/lobby
	plane = SPLASHSCREEN_PLANE
	layer = LOBBY_BUTTON_LAYER
	screen_loc = "TOP,CENTER"

/atom/movable/screen/lobby/background
	layer = LOBBY_BACKGROUND_LAYER
	icon = 'monkestation/icons/hud/lobby/background.dmi'
	icon_state = "background"
	screen_loc = "TOP,CENTER:-61"

/atom/movable/screen/lobby/button
	///Is the button currently enabled?
	var/enabled = TRUE
	///Is the button currently being hovered over with the mouse?
	var/highlighted = FALSE
	base_icon_state = 'monkestation/icons/hud/lobby/background.dmi'

/atom/movable/screen/lobby/button/Click(location, control, params)
	. = ..()
	if(!enabled)
		return
	flick("[base_icon_state]_pressed", src)
	update_icon()
	return TRUE

/atom/movable/screen/lobby/button/MouseEntered(location,control,params)
	. = ..()
	highlighted = TRUE
	update_icon()

/atom/movable/screen/lobby/button/MouseExited()
	. = ..()
	highlighted = FALSE
	update_icon()

/atom/movable/screen/lobby/button/update_icon(updates)
	. = ..()
	if(!enabled)
		icon_state = "[base_icon_state]_disabled"
		return
	else if(highlighted)
		icon_state = "[base_icon_state]_highlighted"
		return
	icon_state = base_icon_state

/atom/movable/screen/lobby/button/proc/set_button_status(status)
	if(status == enabled)
		return FALSE
	enabled = status
	update_icon()
	return TRUE

///Prefs menu
/atom/movable/screen/lobby/button/character_setup
	screen_loc = "TOP:-87,CENTER:+100"
	icon = 'monkestation/icons/hud/lobby/character_setup.dmi'
	icon_state = "character_setup"
	base_icon_state = "character_setup"

/atom/movable/screen/lobby/button/character_setup/Click(location, control, params)
	. = ..()
	if(!.)
		return
	hud.mymob.client.prefs.ShowChoices(hud.mymob)

///Button that appears before the game has started
/atom/movable/screen/lobby/button/ready
	screen_loc = "TOP:-54,CENTER:-35"
	icon = 'monkestation/icons/hud/lobby/ready.dmi'
	icon_state = "not_ready"
	base_icon_state = "not_ready"
	var/ready = FALSE

/atom/movable/screen/lobby/button/ready/Initialize(mapload)
	. = ..()
	if(SSticker.current_state > GAME_STATE_PREGAME)
		set_button_status(FALSE)
	else
		RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, .proc/hide_ready_button)

/atom/movable/screen/lobby/button/ready/proc/hide_ready_button()
	SIGNAL_HANDLER
	set_button_status(FALSE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP)

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
	update_icon()

///Shown when the game has started
/atom/movable/screen/lobby/button/join
	screen_loc = "TOP:-54,CENTER:-35"
	icon = 'monkestation/icons/hud/lobby/join.dmi'
	icon_state = "" //Default to not visible
	base_icon_state = "join_game"
	enabled = FALSE

/atom/movable/screen/lobby/button/join/Initialize(mapload)
	. = ..()
	if(SSticker.current_state > GAME_STATE_PREGAME)
		set_button_status(TRUE)
	else
		RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, .proc/show_join_button)

/atom/movable/screen/lobby/button/join/Click(location, control, params)
	. = ..()
	if(!.)
		return
	if(!SSticker?.IsRoundInProgress())
		to_chat(hud.mymob,"<span class='boldwarning'>The round is either not ready, or has already finished...</span>")
		return
	//Determines Relevent Population Cap
	var/relevant_cap
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc && epc)
		relevant_cap = min(hpc, epc)
	else
		relevant_cap = max(hpc, epc)

	var/mob/dead/new_player/new_player = hud.mymob

	if(SSticker.queued_players.len || (relevant_cap && living_player_count() >= relevant_cap && !(ckey(new_player.key) in GLOB.admin_datums)))
		to_chat(new_player, "<span class='span_danger'>[CONFIG_GET(string/hard_popcap_message)]</span>")

		var/queue_position = SSticker.queued_players.Find(new_player)
		if(queue_position == 1)
			to_chat(new_player, "<span class='span_notice'>You are next in line to join the game. You will be notified when a slot opens up.</span>")
		else if(queue_position)
			to_chat(new_player, "<span class='span_notice'>There are [queue_position-1] players in front of you in the queue to join the game.</span>")
		else
			SSticker.queued_players += new_player
			to_chat(new_player, "<span class='span_notice'>You have been added to the queue to join the game. Your position in queue is [SSticker.queued_players.len].</span>")
		return
	new_player.LateChoices()

/atom/movable/screen/lobby/button/join/proc/show_join_button(status)
	SIGNAL_HANDLER
	set_button_status(TRUE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP)

/atom/movable/screen/lobby/button/observe
	screen_loc = "TOP:-54,CENTER:+82"
	icon = 'monkestation/icons/hud/lobby/observe.dmi'
	icon_state = "observe_disabled"
	base_icon_state = "observe"
	enabled = FALSE

/atom/movable/screen/lobby/button/observe/Initialize(mapload)
	. = ..()
	if(SSticker.current_state > GAME_STATE_STARTUP)
		set_button_status(TRUE)
	else
		RegisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME, .proc/enable_observing)

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
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME, .proc/enable_observing)

/atom/movable/screen/lobby/button/changelog_button
	icon = 'monkestation/icons/hud/lobby/changelog.dmi'
	icon_state = "changelog"
	base_icon_state = "changelog"
	screen_loc ="TOP:-98,CENTER:+45"


/atom/movable/screen/lobby/button/crew_manifest
	icon = 'monkestation/icons/hud/lobby/manifest.dmi'
	icon_state = "manifest"
	base_icon_state = "manifest"
	screen_loc = "TOP:-98,CENTER:-9"

/atom/movable/screen/lobby/button/crew_manifest/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	new_player.ViewManifest()

/atom/movable/screen/lobby/button/changelog_button/Click(location, control, params)
	. = ..()
	usr.client?.changelog()

/atom/movable/screen/lobby/button/poll
	icon = 'monkestation/icons/hud/lobby/poll.dmi'
	icon_state = "poll"
	base_icon_state = "poll"
	screen_loc = "TOP:-98,CENTER:-40"

/atom/movable/screen/lobby/button/poll/update_overlays()
	. = ..()
	if(GLOB.polls.len)
		. += mutable_appearance('monkestation/icons/hud/lobby/poll.dmi', "new_poll")

/atom/movable/screen/lobby/button/poll/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	new_player.handle_player_polling()
