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
	screen_loc = "TOP,CENTER:-64"


/atom/movable/screen/lobby/background
	layer = LOBBY_BACKGROUND_LAYER
	icon = 'icons/hud/lobby/background.dmi'
	icon_state = "background"
