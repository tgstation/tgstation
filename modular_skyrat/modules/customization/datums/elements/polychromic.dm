/**
  * Polychromic element
  *
  * Add this to an R/G/B matrixed clothing to make it triple coloured and customizable!
  * Make sure the passed list is a list of three, 3-length colours without a hash i.e. list("FFF","EEE","621").
  */

/datum/element/polychromic
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 3

/datum/element/polychromic/Attach(datum/target, list/colors)
	. = ..()
	var/obj/item/our_thing = target
	var/list/finished_list = list()
	finished_list += ReadRGB("[colors[1]]0")
	finished_list += ReadRGB("[colors[2]]0")
	finished_list += ReadRGB("[colors[3]]0")
	finished_list += list(0,0,0,255)
	for(var/index in 1 to finished_list.len)
		finished_list[index] /= 255
	our_thing.color = finished_list
	if(!our_thing.actions_types)
		our_thing.actions_types = list()
	our_thing.actions_types += /datum/action/item_action/polychromic_change

/datum/action/item_action/polychromic_change
	name = "Change Colours"

/datum/action/item_action/polychromic_change/Trigger()
	if(!length(target.color)) //Something happened to our color and its no longer a matrix, uh oh
		return ..()
	var/list/choices = list("Primary" = 0, "Secondary" = 1, "Tertiary" = 2)
	var/choice = input(usr ,"Which color would you like to change?", "Polychromic") as null|anything in choices
	if(choice)
		var/color = input(usr, "Choose your new color:", "Polychromic") as color|null
		if(color && target && in_range(target, usr))
			var/list/color_list = ReadRGB(color)
			for(var/index in 1 to color_list.len)
				color_list[index] /= 255
			var/shift = (choices[choice] * 4)
			//Due to .color not being a list variable, but being a list
			//..and also being a native byond thing, we have to do this silly thing
			var/list/target_color_list = target.color
			var/list/new_list = target_color_list.Copy()
			for(var/i in 1 to 3)
				new_list[(i+shift)] = color_list[i]
			target.color = new_list
			var/obj/item/item_target = target
			item_target.update_slot_icon()
	..()
