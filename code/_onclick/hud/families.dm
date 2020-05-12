/obj/screen/wanted
	name = "Space Police Alertness"
	desc = "Shows the current level of hostility the space police is planning to rain down on you. Better be careful."
	icon = 'icons/obj/gang/wanted_160x32.dmi'
	icon_state = "wanted_0"
	screen_loc = ui_wanted_lvl
	///Wanted level, affects the hud icon.
	var/level = 0
	///Boolean, have the cops arrived? If so, the icon stops changing and remains the same.
	var/cops_arrived
	///Storage var for the gang handler datum so that it can receive information from it
	var/datum/gang_handler/handler

/obj/screen/wanted/New(datum/gang_handler/given_handler)
	handler = given_handler
	return ..()

/obj/screen/wanted/Initialize()
	. = ..()
	level = handler.wanted_level
	cops_arrived = handler.cops_arrived
	update_icon()

/obj/screen/wanted/MouseEntered(location,control,params)
	openToolTip(usr,src,params,title = name,content = desc, theme = "alerttooltipstyle")

/obj/screen/wanted/MouseExited()
	closeToolTip(usr)

/obj/screen/wanted/update_icon_state()
	. = ..()
	icon_state = "wanted_[level][cops_arrived ? "_active" : ""]"
