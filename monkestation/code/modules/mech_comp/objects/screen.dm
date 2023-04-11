/obj/item/mcobject/screen
	name = "screen component"
	base_icon_state = "comp_screen"
	icon_state = "comp_screen"

	var/index = 1
	var/display = ""

/obj/item/mcobject/screen/Initialize(mapload)
	. = ..()
	MC_ADD_INPUT("input", set_letter)
	MC_ADD_CONFIG("Set Letter Index", set_index)

/obj/item/mcobject/screen/update_icon_state()
	. = ..()
	if(!anchored)
		return

	switch(display)
		if("!")
			icon_state = "comp_screen_exclamation_mark"

		if(" ")
			icon_state = "comp_screen_blank"

		else
			var/ascii = text2ascii(display)
			if((ascii >= text2ascii("A") && ascii <= text2ascii("Z")) || (ascii >= text2ascii("0") && ascii <= text2ascii("9")))
				icon_state = "comp_screen_[display]"
			else
				icon_state = "comp_screen_question_mark"

/obj/item/mcobject/screen/proc/set_index(mob/user, obj/item/tool)
	var/idx = input(user, "Set index", "Configure Component", index) as null|num
	if(isnull(idx))
		return

	index = idx
	to_chat(span_notice("You set [src]'s index to [index]."))
	return TRUE

/obj/item/mcobject/screen/proc/set_letter(datum/mcmessage/input)
	if(length(input.cmd) < index)
		display = " "
		update_icon_state()
		return

	var/letter = copytext(input.cmd, index, index+1)

	display = letter
	update_icon_state()

/obj/item/mcobject/screen/proc/update_screen(letter)
	letter = uppertext(letter)
	switch(letter)
		if(" ")
