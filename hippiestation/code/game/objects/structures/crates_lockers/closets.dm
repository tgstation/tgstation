/*

Sorry for doing this, but apparently the Hippie community hates art and new things.
	-Amari

*/

/obj/structure/closet
	icon_hippie = 'hippiestation/icons/obj/closet.dmi'

/obj/structure/closet/update_icon()
	cut_overlays()
	if(!opened)
		layer = OBJ_LAYER
		if(icon_door)
			add_overlay("[icon_door]_door")
		else
			add_overlay("[icon_state]_door")
		if(welded)
			add_overlay("welded")
		if(secure)
			if(!broken)
				if(locked)
					add_overlay("locked")
				else
					add_overlay("unlocked")
			else
				add_overlay("off")

	else
		layer = BELOW_OBJ_LAYER
		if(icon_door_override)
			add_overlay("[icon_door]_open")
		else
			add_overlay("[icon_state]_open")