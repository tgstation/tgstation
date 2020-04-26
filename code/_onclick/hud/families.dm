/obj/screen/wanted
	name = "Space Police Alertness"
	desc = "Shows the current level of hostility the space police is planning to rain down on you. Better be careful."
	icon = 'icons/obj/gang/wanted_160x32.dmi'
	icon_state = "wanted_0"
	screen_loc = ui_wanted_lvl
	///Wanted level, affects the hud icon.
	var/level
	///Boolean, have the cops arrived? If so, the icon stops changing and remains the same.
	var/cops_arrived

/obj/screen/wanted/Initialize()
	. = ..()
	var/datum/game_mode/gang/F = SSticker.mode
	level = F.wanted_level
	cops_arrived = F.cops_arrived
	update_icon()

/obj/screen/wanted/MouseEntered(location,control,params)
	openToolTip(usr,src,params,title = name,content = desc, theme = "alerttooltipstyle")

/obj/screen/wanted/MouseExited()
	closeToolTip(usr)

/obj/screen/wanted/update_icon_state()
	. = ..()
	icon_state = "wanted_[level][cops_arrived ? "_active" : ""]"
