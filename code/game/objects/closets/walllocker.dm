//added by cael from old bs12
//not sure if there's an immediate place for secure wall lockers, but i'm sure the players will think of something

/obj/structure/closet/walllocker
	desc = "A wall mounted storage locker."
	name = "Wall Locker"
	icon = 'icons/obj/walllocker.dmi'
	icon_state = "wall-locker"
	density = 0
	anchored = 1
	pick_up_stuff = 0 // #367 - Picks up stuff at src.loc, rather than the offset location.
	icon_closed = "wall-locker"
	icon_opened = "wall-lockeropen"

//spawns endless (3 sets) amounts of breathmask, emergency oxy tank and crowbar

/obj/structure/closet/walllocker/emerglocker
	name = "emergency locker"
	desc = "A wall mounted locker with emergency supplies"
	var/list/spawnitems = list(/obj/item/weapon/tank/emergency_oxygen,/obj/item/clothing/mask/breath,/obj/item/weapon/crowbar)
	var/amount = 3 // spawns each items X times.
	icon_state = "emerg"

/obj/structure/closet/walllocker/emerglocker/attack_hand(mob/user as mob)
	if (istype(user, /mob/living/silicon/ai))	//Added by Strumpetplaya - AI shouldn't be able to
		return									//activate emergency lockers.  This fixes that.  (Does this make sense, the AI can't call attack_hand, can it? --Mloc)
	if(!amount)
		usr << "<spawn class='notice'>It's empty."
		return
	if(amount)
		usr << "<spawn class='notice'>You take out some items from \the [src]."
		for(var/path in spawnitems)
			new path(src.loc)
		amount--
	return

/obj/structure/closet/walllocker/emerglocker/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker/emerglocker/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker/emerglocker/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker/emerglocker/east
	pixel_x = 32
	dir = EAST

/obj/structure/closet/walllocker/defiblocker/
	name = "emergency defibrillator locker"
	desc = "A wall mounted locker with a handheld defibrillator"
	icon = 'icons/obj/closet.dmi'
	icon_state = "medical_wall"
	icon_opened = "medical_wall_open"
	icon_closed = "medical_wall"
	var/amount = 1

/obj/structure/closet/walllocker/defiblocker/attack_hand(mob/user as mob)
	if(istype(user, /mob/living/silicon/ai)) return
	if(istype(user, /mob/living/silicon/robot))
		if(!amount)
			usr << "<spawn class='notice'>It's empty."
			return
		else
			usr << "<spawn class='notice'>You pull out an emergency defibrillator from \the [src]."
			new /obj/item/weapon/melee/defibrillator(src.loc)
			amount = 0
			update_icon()
	if(!amount)
		usr << "<spawn class='notice'>It's empty."
		return
	if(amount)
		usr << "<spawn class='notice'>You take out an emergency defibrillator from \the [src]."
		//new /obj/item/weapon/melee/defibrillator(src.loc)
		usr.put_in_hands(new /obj/item/weapon/melee/defibrillator())
		amount = 0
		update_icon()
	return

/obj/structure/closet/walllocker/defiblocker/attackby(obj/item/weapon/G as obj, mob/user as mob)
	if(istype(G, /obj/item/weapon/melee/defibrillator))
		if(amount)
			usr << "<spawn class='notice'>The locker is full."
			return
		else
			usr << "<spawn class='notice'>You put \the [G] in \the [src]."
			amount = 1
			update_icon()
			user.drop_item()
			del(G)
			return
	return


/obj/structure/closet/walllocker/defiblocker/update_icon()
	if(amount)
		icon_state = icon_closed
	else
		icon_state = icon_opened

/obj/structure/closet/walllocker/defiblocker/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker/defiblocker/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker/defiblocker/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker/defiblocker/east
	pixel_x = 32
	dir = EAST
