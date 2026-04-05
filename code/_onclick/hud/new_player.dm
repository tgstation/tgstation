/// Maximum number of station trait buttons we will display, please think hard before creating scenarios where there are more than this
#define MAX_STATION_TRAIT_BUTTONS_VERTICAL 3
#define TRAIT_BUTTON_Y_ORIGIN 397
#define TRAIT_BUTTON_X_ORIGIN 233
#define TRAIT_BUTTON_OFFSET 27
#define SQUARE_VIEWPORT_OFFSET 64

/datum/hud/new_player
	///Whether the menu is currently on the client's screen or not
	var/menu_hud_status = TRUE
	var/list/shown_station_trait_buttons

/datum/hud/new_player/New(mob/owner)
	. = ..()

	if (!owner?.client || owner.client.interviewee)
		return

	for (var/atom/movable/screen/lobby/lobbyscreen as anything in subtypesof(/atom/movable/screen/lobby))
		if (!initial(lobbyscreen.always_available))
			continue
		lobbyscreen = add_screen_object(lobbyscreen, HUD_KEY_NEW_PLAYER(lobbyscreen))
		lobbyscreen.SlowInit()
		if (!lobbyscreen.always_shown)
			lobbyscreen.RegisterSignal(src, COMSIG_HUD_LOBBY_COLLAPSED, TYPE_PROC_REF(/atom/movable/screen/lobby, collapse_button))
			lobbyscreen.RegisterSignal(src, COMSIG_HUD_LOBBY_EXPANDED, TYPE_PROC_REF(/atom/movable/screen/lobby, expand_button))

	if (!owner.client.is_localhost())
		return

	var/atom/movable/screen/lobby/button/start_now/start_button = add_screen_object(/atom/movable/screen/lobby/button/start_now, HUD_NEW_PLAYER_START_NOW)
	start_button.SlowInit()
	start_button.RegisterSignal(src, COMSIG_HUD_LOBBY_COLLAPSED, TYPE_PROC_REF(/atom/movable/screen/lobby, collapse_button))
	start_button.RegisterSignal(src, COMSIG_HUD_LOBBY_EXPANDED, TYPE_PROC_REF(/atom/movable/screen/lobby, expand_button))

/datum/hud/new_player/on_viewdata_update()
	. = ..()
	place_station_trait_buttons()

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
		var/atom/movable/screen/lobby/button/sign_up/sign_up_button = add_screen_object(/atom/movable/screen/lobby/button/sign_up, HUD_NEW_PLAYER_SIGN_UP)
		trait.setup_lobby_button(sign_up_button)
		LAZYSET(shown_station_trait_buttons, trait, sign_up_button)
		RegisterSignal(trait, COMSIG_QDELETING, PROC_REF(remove_station_trait_button))

	place_station_trait_buttons()

/// Display the buttosn for relevant station traits.
/datum/hud/new_player/proc/place_station_trait_buttons()
	SIGNAL_HANDLER
	if(hud_version != HUD_STYLE_STANDARD || !mymob?.client)
		return

	var/y_offset = TRAIT_BUTTON_Y_ORIGIN
	var/x_offset = TRAIT_BUTTON_X_ORIGIN
	var/y_button_offset = TRAIT_BUTTON_OFFSET
	var/x_button_offset = -TRAIT_BUTTON_OFFSET
	var/iteration = 0
	if(mymob.client.view == SQUARE_VIEWPORT_SIZE)
		x_offset -= SQUARE_VIEWPORT_OFFSET
	for(var/trait in shown_station_trait_buttons)
		var/atom/movable/screen/lobby/button/sign_up/sign_up_button = shown_station_trait_buttons[trait]
		iteration++
		sign_up_button.screen_loc = offset_to_screen_loc(x_offset, y_offset, mymob.client.view)
		mymob.client.screen |= sign_up_button
		if (iteration >= MAX_STATION_TRAIT_BUTTONS_VERTICAL)
			iteration = 0
			y_offset = TRAIT_BUTTON_Y_ORIGIN
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
	qdel(button)
	place_station_trait_buttons()

#undef MAX_STATION_TRAIT_BUTTONS_VERTICAL
#undef TRAIT_BUTTON_Y_ORIGIN
#undef TRAIT_BUTTON_X_ORIGIN
#undef TRAIT_BUTTON_OFFSET
#undef SQUARE_VIEWPORT_OFFSET
