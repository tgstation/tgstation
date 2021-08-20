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
	screen_loc = "TOP,CENTER:-61"

/atom/movable/screen/lobby/button
	var/has_press_anim = FALSE

/atom/movable/screen/lobby/button/MouseEntered(location,control,params)
	. = ..()
	icon_state = "[base_icon_state]_highlight"

/atom/movable/screen/lobby/button/MouseExited()
	. = ..()
	icon_state = base_icon_state

/atom/movable/screen/lobby/button/Click(location, control, params)
	. = ..()
	if(has_press_anim)
		flick("[base_icon_state]_pressed", src)


/atom/movable/screen/lobby/button/character_setup
	screen_loc = "TOP:-70,CENTER:-54"
	icon = 'icons/hud/lobby/character_setup.dmi'
	icon_state = "character_setup"
	base_icon_state = "character_setup"

/atom/movable/screen/lobby/button/ready
	screen_loc = "TOP:-8,CENTER:-65"
	icon = 'icons/hud/lobby/ready.dmi'
	icon_state = "not_ready"
	base_icon_state = "not_ready"
	has_press_anim = TRUE
	var/ready = FALSE

/atom/movable/screen/lobby/button/ready/Click(location, control, params)
	. = ..()
	ready = !ready
	if(ready)
		base_icon_state = "ready"
	else
		base_icon_state = "not_ready"
	icon_state = base_icon_state



/atom/movable/screen/lobby/button/join
	screen_loc = "TOP:-13,CENTER:-58"
	icon = 'icons/hud/lobby/join.dmi'
	icon_state = "character_setup"
	base_icon_state = "character_setup"

/atom/movable/screen/lobby/button/observe
	screen_loc = "TOP:-40,CENTER:-54"
	icon = 'icons/hud/lobby/observe.dmi'
	icon_state = "observe"
	base_icon_state = "observe"

/atom/movable/screen/lobby/button/crew_manifest_button
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "crew_manifest"
	base_icon_state = "crew_manifest"
	screen_loc ="TOP:-122,CENTER:+2"


/atom/movable/screen/lobby/button/changelog_button
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "changelog"
	base_icon_state = "changelog"
	screen_loc = "TOP:-122,CENTER:+30"

/atom/movable/screen/lobby/button/settings_buttons
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "settings"
	base_icon_state = "settings"
	screen_loc = "TOP:-122,CENTER:+58"
