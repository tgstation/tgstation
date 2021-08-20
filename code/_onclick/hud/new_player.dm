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
	///Do we have a unique icon state when pressed
	var/has_pressed_state = TRUE
	///Is the button currently enabled?
	var/enabled = TRUE
	///Is the button currently being pressed?
	var/pressed = FALSE
	///Is the button currently being hovered over with the mouse?
	var/highlighted = FALSE

/atom/movable/screen/lobby/button/Click(location, control, params)
	. = ..()
	var/client/clicking_client = usr.client
	pressed = TRUE
	RegisterSignal(clicking_client, COMSIG_CLIENT_MOUSEUP, ./proc/check_if_pressed)
	update_appearance(UPDATE_ICON)




/atom/movable/screen/lobby/button/MouseEntered(location,control,params)
	. = ..()
	highlighted = TRUE
	update_appearance(UPDATE_ICON)

/atom/movable/screen/lobby/button/MouseExited()
	. = ..()
	highlighted = FALSE
	update_appearance(UPDATE_ICON)

/atom/movable/screen/lobby/button/update_icon(updates)
	. = ..()
	if(!enabled)
		icon_state = "[base_icon_state]_disabled"
	else if(pressed && has_pressed_state)
		icon_state = "[base_icon_state]_pressed"
	else if(highlighted)
		icon_state = "[base_icon_state]_highlighted"

/atom/movable/screen/lobby/button/proc/set_button_status(status)
	if(status == enabled)
		return
	enabled = status
	update_appearance(UPDATE_ICON)

/atom/movable/screen/lobby/button/proc/check_if_pressed(client/clicker, atom/object, turf/location, control, params)
	if(object == src)
		Pressed(clicker)
	pressed = FALSE
	update_appearance(UPDATE_ICON)
	UnregisterSignal(clicker, COMSIG_CLIENT_MOUSEUP)

/atom/movable/screen/lobby/button/proc/Pressed()
	return

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
	has_pressed_state = FALSE
	var/ready = FALSE

/atom/movable/screen/lobby/button/ready/Pressed(client/clicker)
	. = ..()
	ready = !ready
	flick("[base_icon_state]_pressed", src)
	if(ready)
		base_icon_state = "ready"
	else
		base_icon_state = "not_ready"
	update_appearance(UPDATE_ICON)

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
	enabled = FALSE

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
