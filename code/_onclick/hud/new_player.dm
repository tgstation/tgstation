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
	icon = 'icons/hud/lobby/background.dmi'
	icon_state = "background"
	screen_loc = "TOP,CENTER:-64"


/atom/movable/screen/lobby/button

/atom/movable/screen/lobby/button/character_setup
	screen_loc = "TOP,CENTER:-68"
	icon = 'icons/hud/lobby/character_setup.dmi'
	icon_state = "character_setup"


/atom/movable/screen/lobby/button/crew_manifest_button
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "crew_manifest"


/atom/movable/screen/lobby/button/changelog_button
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "changelog"

/atom/movable/screen/lobby/button/settings_buttons
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "settings"
