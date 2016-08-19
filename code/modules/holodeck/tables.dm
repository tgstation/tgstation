/obj/structure/table/holo
	name = "table"
	frame = null
	buildstackamount = 0
	framestackamount = 0
	canSmoothWith = null

/obj/structure/table/holo/glass
	name = "glass table"
	icon = 'icons/obj/smooth_structures/glass_table.dmi'
	icon_state = "glass_table"

/obj/structure/table/holo/wood
	name = "wood table"
	icon = 'icons/obj/smooth_structures/wood_table.dmi'
	icon_state = "wood_table"
	canSmoothWith = list(/obj/structure/table/holo/wood, /obj/structure/table/holo/poker)

/obj/structure/table/holo/poker
	name = "poker table"
	icon = 'icons/obj/smooth_structures/poker_table.dmi'
	icon_state = "poker_table"
	canSmoothWith = list(/obj/structure/table/holo/wood, /obj/structure/table/holo/poker)

/obj/structure/table/holo/attack_paw(mob/user as mob)
	return

/obj/structure/table/holo/attack_alien(mob/user as mob)
	return

/obj/structure/table/holo/attack_animal(mob/living/simple_animal/user as mob)
	return

/obj/structure/table/holo/attack_hand(mob/user as mob)
	return
/obj/structure/table/holo/attack_hulk()
	return

/obj/structure/table/holo/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/weapon/grab))
		tablepush(I, user)
		return
	if (istype(I, /obj/item/weapon/storage/bag/tray))
		var/obj/item/weapon/storage/bag/tray/T = I
		if(T.contents.len > 0) // If the tray isn't empty
			var/list/obj/item/oldContents = T.contents.Copy()
			T.quick_empty()

			for(var/obj/item/C in oldContents)
				C.loc = src.loc

			user.visible_message("[user] empties [I] on [src].")
			return
		// If the tray IS empty, continue on (tray will be placed on the table like other items)

	if(isrobot(user))
		return

	if(!(I.flags & ABSTRACT)) //rip more parems rip in peace ;_;
		if(user.drop_item())
			I.Move(loc)
			var/list/click_params = params2list(params)
			//Center the icon where the user clicked.
			if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
				return
			//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
			I.pixel_x = Clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
			I.pixel_y = Clamp(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)
