/obj/screen/storage
	name = "storage"
	icon_state = "block"
	screen_loc = "7,7 to 10,8"
	layer = HUD_LAYER
	plane = HUD_PLANE

/obj/screen/storage/Initialize(mapload, new_master)
	. = ..()
	master = new_master

/obj/screen/storage/Click(location, control, params)
	if(world.time <= usr.next_move)
		return TRUE
	if(usr.stat || usr.IsUnconscious() || usr.IsKnockdown() || usr.IsStun())
		return TRUE
	if (ismecha(usr.loc)) // stops inventory actions in a mech
		return TRUE
	if(master)
		var/obj/item/I = usr.get_active_held_item()
		if(I)
			master.attackby(I, usr, params)
	return TRUE
