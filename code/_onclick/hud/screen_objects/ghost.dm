/atom/movable/screen/ghost
	icon = 'icons/hud/screen_ghost.dmi'
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/ghost/MouseEntered(location, control, params)
	. = ..()
	flick(icon_state + "_anim", src)

/atom/movable/screen/ghost/spawners_menu
	name = "Spawners menu"
	icon_state = "spawners"
	screen_loc = ui_ghost_spawners_menu

/atom/movable/screen/ghost/spawners_menu/Click()
	var/mob/dead/observer/observer = usr
	observer.open_spawners_menu()

/atom/movable/screen/ghost/orbit
	name = "Orbit"
	icon_state = "orbit"
	screen_loc = ui_ghost_orbit

/atom/movable/screen/ghost/orbit/Click()
	GLOB.orbit_menu.show(usr)

/atom/movable/screen/ghost/reenter_corpse
	name = "Reenter corpse"
	icon_state = "reenter_corpse"
	screen_loc = ui_ghost_reenter_corpse

/atom/movable/screen/ghost/reenter_corpse/Click()
	var/mob/dead/observer/G = usr
	G.reenter_corpse()

/atom/movable/screen/ghost/dnr
	name = "Do Not Resuscitate"
	icon_state = "dnr"
	screen_loc = ui_ghost_dnr

/atom/movable/screen/ghost/dnr/Click()
	var/mob/dead/observer/dnring = usr
	dnring.do_not_resuscitate()

/atom/movable/screen/ghost/teleport
	name = "Teleport"
	icon_state = "teleport"
	screen_loc = ui_ghost_teleport

/atom/movable/screen/ghost/teleport/Click()
	var/mob/dead/observer/G = usr
	G.dead_tele()

/atom/movable/screen/ghost/settings
	name = "Ghost Settings"
	icon_state = "settings"
	screen_loc = ui_ghost_settings

/atom/movable/screen/ghost/settings/MouseEntered(location, control, params)
	. = ..()
	flick(icon_state + "_anim", src)

/atom/movable/screen/ghost/settings/Click()
	GLOB.ghost_menu.ui_interact(usr)

/atom/movable/screen/ghost/minigames_menu
	name ="Minigames"
	icon_state = "minigames"
	screen_loc = ui_ghost_minigames

/atom/movable/screen/ghost/minigames_menu/Click()
	var/mob/dead/observer/observer = usr
	observer.open_minigames_menu()

/atom/movable/screen/ghost/hudbox
	icon_state = "smallbox"
	abstract_type = /atom/movable/screen/ghost/hudbox
	/// Icon state used for the overlay representing this hudbox
	var/hud_icon_state
	/// The flag this hudbox toggles
	var/relevant_flag

/atom/movable/screen/ghost/hudbox/update_overlays()
	. = ..()
	. += hud_icon_state

/atom/movable/screen/ghost/hudbox/update_icon_state()
	. = ..()
	var/mob/dead/observer/observer = hud?.mymob
	if(!istype(observer))
		return

	icon_state = "smallbox[is_active(observer) ? "_active" : ""]"

/atom/movable/screen/ghost/hudbox/proc/is_active(mob/dead/observer/observer)
	return (observer.ghost_hud_flags & relevant_flag)

/atom/movable/screen/ghost/hudbox/Click(location, control, params)
	var/mob/dead/observer/observer = usr
	switch(relevant_flag)
		if(GHOST_DARKNESS_LEVEL)
			observer.toggle_darkness()
		if(GHOST_TRAY)
			observer.tray_view()
		else
			observer.toggle_ghost_hud_flag(relevant_flag)

	update_appearance(UPDATE_ICON_STATE)

/atom/movable/screen/ghost/hudbox/health_scanner
	name = "Health Scanner"
	desc = "Toggles your ability to health scan mobs on click."
	hud_icon_state = "health_vision"
	relevant_flag = GHOST_HEALTH

/atom/movable/screen/ghost/hudbox/chem_scanner
	name = "Chem Scanner"
	desc = "Toggles your ability to chemical scan mobs on click."
	hud_icon_state = "chem_vision"
	relevant_flag = GHOST_CHEM

/atom/movable/screen/ghost/hudbox/gas_scanner
	name = "Gas Scanner"
	desc = "Toggles your ability to gas scan objects on click."
	hud_icon_state = "atmos_vision"
	relevant_flag = GHOST_GAS

/atom/movable/screen/ghost/hudbox/ghost
	name = "Ghost Vision"
	desc = "Toggles whether you can see other ghosts."
	hud_icon_state = "ghost_vision"
	relevant_flag = GHOST_VISION

/atom/movable/screen/ghost/hudbox/data_huds
	name = "Data HUDs"
	desc = "Toggles the display of data HUDs (health, security, diagnostics, etc)."
	hud_icon_state = "data_vision"
	relevant_flag = GHOST_DATA_HUDS

/atom/movable/screen/ghost/hudbox/tray_icon
	name = "Tray View"
	desc = "Shows the t-ray view of the area around your ghost."
	hud_icon_state = "tray_vision"
	relevant_flag = GHOST_TRAY

/atom/movable/screen/ghost/hudbox/darkness_level
	name = "Darkness Level"
	desc = "Cycles through different darkness levels for ghost vision."
	hud_icon_state = "darkness_vision"
	relevant_flag = GHOST_DARKNESS_LEVEL
