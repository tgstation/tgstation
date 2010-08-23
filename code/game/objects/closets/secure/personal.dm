/obj/secure_closet/personal/var/registered = null
/obj/secure_closet/personal/req_access = list(access_all_personal_lockers)

/obj/secure_closet/personal/New()
	..()
	spawn(2)
		new /obj/item/device/radio/signaler( src )
		new /obj/item/weapon/pen( src )
		new /obj/item/weapon/storage/backpack( src )
		new /obj/item/device/radio/headset( src )
	return

/obj/secure_closet/personal/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (src.opened)
		if (istype(W, /obj/item/weapon/grab))
			src.MouseDrop_T(W:affecting, user)      //act like they were dragged onto the closet
		user.drop_item()
		if (W) W.loc = src.loc
	else if (istype(W, /obj/item/weapon/card/id))
		if(src.broken)
			user << "\red It appears to be broken."
			return
		var/obj/item/weapon/card/id/I = W
		if (src.allowed(user) || !src.registered || (istype(W, /obj/item/weapon/card/id) && src.registered == I.registered))
			//they can open all lockers, or nobody owns this, or they own this locker
			src.locked = !( src.locked )
			for(var/mob/O in viewers(user, 3))
				if ((O.client && !( O.blinded )))
					O << text("\blue The locker has been []locked by [].", (src.locked ? null : "un"), user)
			if(src.locked)
				src.icon_state = src.icon_locked
			else
				src.icon_state = src.icon_closed
			if (!src.registered)
				src.registered = I.registered
				src.desc = "Owned by [I.registered]."
		else
			user << "\red Access Denied"
	else if(istype(W, /obj/item/weapon/card/emag) && !src.broken)
		src.broken = 1
		src.locked = 0
		src.desc = "It appears to be broken."
		src.icon = 'closet.dmi'
		src.icon_state = "securebroken"
		for(var/mob/O in viewers(user, 3))
			if ((O.client && !( O.blinded )))
				O << text("\blue The locker has been broken by [user] with an electromagnetic card!")
	else
		user << "\red Access Denied"
	return
