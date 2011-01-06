/*
CONTAINS:
CIG PACKET
ZIPPO


*/
/obj/item/weapon/cigpacket/update_icon()
	src.icon_state = text("cigpacket[]", src.cigcount)
	src.desc = text("There are [] cigs\s left!", src.cigcount)
	return

/obj/item/weapon/cigpacket/attack_hand(mob/user as mob)
	if(user.r_hand == src || user.l_hand == src)
		if(src.cigcount == 0)
			user << "\red You're out of cigs, shit! How you gonna get through the rest of the day..."
			return
		else
			src.cigcount--
			var/obj/item/clothing/mask/cigarette/W = new /obj/item/clothing/mask/cigarette(user)
			if(user.hand)
				user.l_hand = W
			else
				user.r_hand = W
			W.layer = 20
	else
		return ..()
	src.update_icon()
	return


#define ZIPPO_LUM 2

/obj/item/weapon/zippo/attack_self(mob/user)
	if(user.r_hand == src || user.l_hand == src)
		if(!src.lit)
			src.lit = 1
			src.icon_state = "zippoon"
			src.item_state = "zippoon"
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red Without even breaking stride, [] flips open and lights the [] in one smooth movement.", user, src), 1)

			user.sd_SetLuminosity(user.luminosity + ZIPPO_LUM)
			spawn(0)
				process()
		else
			src.lit = 0
			src.icon_state = "zippo"
			src.item_state = "zippo"
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red You hear a quiet click, as [] shuts off the [] without even looking what they're doing. Wow.", user, src), 1)

			user.sd_SetLuminosity(user.luminosity - ZIPPO_LUM)
	else
		return ..()
	return


/obj/item/weapon/zippo/process()

	while(src.lit)
		var/turf/location = src.loc

		if(istype(location, /mob/))
			var/mob/M = location
			if(M.l_hand == src || M.r_hand == src)
				location = M.loc
		if (istype(location, /turf))
			location.hotspot_expose(700, 5)
		sleep(10)


/obj/item/weapon/zippo/pickup(mob/user)
	if(lit)
		src.sd_SetLuminosity(0)
		user.sd_SetLuminosity(user.luminosity + ZIPPO_LUM)



/obj/item/weapon/zippo/dropped(mob/user)
	if(lit)
		user.sd_SetLuminosity(user.luminosity - ZIPPO_LUM)
		src.sd_SetLuminosity(ZIPPO_LUM)