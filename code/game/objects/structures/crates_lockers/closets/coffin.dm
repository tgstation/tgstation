/obj/structure/closet/coffin
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon_state = "coffin"
	icon_closed = "coffin"
	icon_opened = "coffin_open"

/obj/structure/closet/coffin/update_icon()
	if(!opened)
		icon_state = icon_closed
	else
		icon_state = icon_opened