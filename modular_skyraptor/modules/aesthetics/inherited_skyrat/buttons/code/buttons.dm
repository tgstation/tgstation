/// SKYRAPTOR AESTHETICS MODULE: BUTTONS
/// there is a unique agony to looking through code that could perfectly well have been modularized
/// and seeing that it WASN'T.
/// this is an attempt to restore Skyrat-style buttons without having to edit the original buttons.dm

/obj/machinery/button
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/buttons/icons/buttons.dmi'
	base_icon_state = "doorctrl"
	skin = ""
	icon_state = "doorctrl"
	light_color = "#FFFF00"

	var/skin_raptsys = "doorctrl"
	///The light mask used in the icon file for emissive layer
	var/light_mask = "button-light-mask"

/obj/machinery/button/update_icon_state()
	. = ..()
	if(panel_open)
		icon_state = "button-open"
		return ..()
	if(machine_stat & (NOPOWER|BROKEN))
		icon_state = "[skin_raptsys]-p"
		return ..()
	icon_state = skin_raptsys
	return ..()

/obj/machinery/button/update_overlays()
	. = ..()
	if(light_mask && !(machine_stat & (NOPOWER|BROKEN)) && !panel_open)
		. += emissive_appearance(icon, light_mask, src, alpha = alpha)
	if(!panel_open)
		return
	if(device)
		. += "button-device"
	if(board)
		. += "button-board"

/obj/machinery/button/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(panel_open)
		if(device || board)
			update_appearance()
		else
			if(skin_raptsys == "doorctrl")
				skin_raptsys = "launcher"
				base_icon_state = "launcher"
				light_mask = "launch-light-mask"
			else
				skin_raptsys = "doorctrl"
				base_icon_state = "doorctrl"
				light_mask = "button-light-mask"
			balloon_alert(user, "swapped button style")
			to_chat(user, span_notice("You change the button frame's front panel."))

	if(!allowed(user))
		to_chat(user, span_alert("Access Denied."))
		flick("[skin_raptsys]-denied", src)
		return

	icon_state = "[skin_raptsys]1"

	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/, update_appearance)), 15)



/// OTHER BUTTON TYPES GWUH
/obj/machinery/button/massdriver
	base_icon_state = "launcher"
	icon_state = "launcher"
	skin_raptsys = "launcher"
	light_mask = "launch-light-mask"
	skin = ""
	light_color = "#FFFF00"

/obj/machinery/button/ignition
	base_icon_state = "launcher"
	icon_state = "launcher"
	skin_raptsys = "launcher"
	light_mask = "launch-light-mask"
	skin = ""
	light_color = "#FFFF00"

/obj/machinery/button/flasher
	base_icon_state = "launcher"
	icon_state = "launcher"
	skin_raptsys = "launcher"
	light_mask = "launch-light-mask"
	skin = ""
	light_color = "#FFFF00"

/obj/machinery/button/curtain
	base_icon_state = "launcher"
	icon_state = "launcher"
	skin_raptsys = "launcher"
	light_mask = "launch-light-mask"
	skin = ""
	light_color = "#FFFF00"

/obj/machinery/button/crematorium
	base_icon_state = "launcher"
	icon_state = "launcher"
	skin_raptsys = "launcher"
	light_mask = "launch-light-mask"
	skin = ""
	light_color = "#FFFF00"



/// GIMMICK MAP BUTTONS (SCREAM)
/obj/machinery/button/elevator
	base_icon_state = "tramctrl"
	icon_state = "tramctrl"
	skin_raptsys = "tramctrl"
	light_mask = "tram-light-mask"
	skin = ""
	light_color = "#FFFF00"

/obj/machinery/button/tram
	base_icon_state = "tramctrl"
	icon_state = "tramctrl"
	skin_raptsys = "tramctrl"
	light_mask = "tram-light-mask"
	skin = ""
	light_color = "#FFFF00"

/obj/machinery/elevator_control_panel
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/buttons/icons/buttons.dmi'
	icon_state = "elevpanel_fixed"
	base_icon_state = "elevpanel"
