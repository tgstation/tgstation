/atom/movable/screen/wanted
	name = "Space Police Alertness"
	desc = "Shows the current level of hostility the space police is planning to rain down on you. Better be careful."
	icon = 'icons/obj/gang/wanted_160x32.dmi'
	icon_state = "wanted_0"
	base_icon_state = "wanted"
	screen_loc = ui_wanted_lvl
	/// Wanted level, affects the hud icon. Level 0 is default, and the level 0 icon is blank, so in case of no families gamemode (and thus no wanted level), this HUD element will never appear.
	var/level = 0
	/// Boolean, have the cops arrived? If so, the icon stops changing and remains the same.
	var/cops_arrived = 0

/atom/movable/screen/wanted/Initialize(mapload)
	. = ..()
	update_appearance()

/atom/movable/screen/wanted/MouseEntered(location,control,params)
	. = ..()
	openToolTip(usr,src,params,title = name,content = desc, theme = "alerttooltipstyle")

/atom/movable/screen/wanted/MouseExited()
	closeToolTip(usr)

/atom/movable/screen/wanted/update_icon_state()
	icon_state = "[base_icon_state]_[level][cops_arrived ? "_active" : null]"
	return ..()
