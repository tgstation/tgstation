/obj/item/mcobject/led
	name = "LED component"
	base_icon_state = "comp_led"
	icon_state = "comp_led"

	light_on = FALSE
	light_power = 0.75

/obj/item/mcobject/led/Initialize(mapload)
	. = ..()
	MC_ADD_INPUT("activate", activate)
	MC_ADD_INPUT("deactivate", deactivate)
	MC_ADD_INPUT("set color", set_color)
	MC_ADD_CONFIG("Set Color", set_color_config)
	MC_ADD_CONFIG("Set Range", set_range_config)

/obj/item/mcobject/led/proc/activate(datum/mcmessage/input)
	set_light(l_on = TRUE)

/obj/item/mcobject/led/proc/deactivate(datum/mcmessage/input)
	set_light(l_on = FALSE)

/obj/item/mcobject/led/proc/set_color(datum/mcmessage/input)
	var/col = input.cmd
	if(length(col) != 7 || copytext(col, 1, 2) != "#")
		return

	set_light(l_color = col)

/obj/item/mcobject/led/proc/set_color_config(mob/user, obj/item/tool)
	var/col = input(user, "Select a color", "Configure Component", light_color) as null|color
	if(!col)
		return

	set_light(l_color = col)
	to_chat(user, span_notice("You set [src] to the color [light_color]."))
	return TRUE

/obj/item/mcobject/led/proc/set_range_config(mob/user, obj/item/tool)
	var/range = input(user, "Input a brightness (1-5)", "Configure Component", light_range) as null|num
	if(!range)
		return
	range = clamp(range, 1, 5)

	set_light(range)
	to_chat(user, span_notice("You set the range of [src] to [range]."))
	return TRUE
