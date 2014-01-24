/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox20"
	desc = "A display case for prized possessions. It taunts you to kick it."
	density = 1
	anchored = 1
	unacidable = 1//Dissolving the case would also delete the gun.
	var/health = 30
	var/obj/item/occupant = null
	var/destroyed = 0
	var/locked = 0
	var/ue=null
	var/icon/occupant_overlay=null

/obj/structure/displaycase/captains_laser/New()
	occupant=new /obj/item/weapon/gun/energy/laser/captain(src)
	locked=1
	req_access=list(access_captain)
	update_icon()

/obj/structure/displaycase/examine()
	..()
	usr << "\blue Peering through the glass, you see that it contains:"
	if(occupant)
		usr << "\icon[occupant] \blue \A [occupant]"
	else:
		usr << "Nothing."

/obj/structure/displaycase/proc/dump()
	occupant.loc=get_turf(src)
	occupant=null
	occupant_overlay=null

/obj/structure/displaycase/ex_act(severity)
	switch(severity)
		if (1)
			new /obj/item/weapon/shard( src.loc )
			if (occupant)
				dump()
			del(src)
		if (2)
			if (prob(50))
				src.health -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.health -= 5
				src.healthcheck()


/obj/structure/displaycase/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	src.healthcheck()
	return


/obj/structure/displaycase/blob_act()
	if (prob(75))
		new /obj/item/weapon/shard( src.loc )
		if(occupant) dump()
		del(src)


/obj/structure/displaycase/meteorhit(obj/O as obj)
		new /obj/item/weapon/shard( src.loc )
		if(occupant) dump()
		del(src)


/obj/structure/displaycase/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.density = 0
			src.destroyed = 1
			new /obj/item/weapon/shard( src.loc )
			playsound(src, "shatter", 70, 1)
			update_icon()
	else
		playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
	return

/obj/structure/displaycase/update_icon()
	if(src.destroyed)
		src.icon_state = "glassbox2b"
	else
		src.icon_state = "glassbox2[locked]"
	underlays.Cut()
	if(occupant)
		if(!occupant_overlay)
			occupant_overlay=getFlatIcon(occupant)
			occupant_overlay.Scale(16,16)
			occupant_overlay.Shift(NORTH, 8)
			occupant_overlay.Shift(EAST, 8)
		underlays += occupant_overlay
	return


/obj/structure/displaycase/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/card))
		var/obj/item/weapon/card/id/I=W
		if(!check_access(I))
			user << "\red Access denied."
			return
		locked = !locked
		if(!locked)
			user << "\icon[src] \blue \The [src] clicks as locks release, and it slowly opens for you."
		else
			user << "\icon[src] \blue You close \the [src] and swipe your card, locking it."
		update_icon()
		return
	if(user.a_intent == "harm")
		src.health -= W.force
		src.healthcheck()
		..()
	else
		if(locked)
			user << "\red It's locked, you can't put anything into it."
			return
		if(!occupant)
			user << "\blue You insert \the [W] into \the [src], and it floats as the hoverfield activates."
			user.drop_item()
			W.loc=src
			occupant=W
			update_icon()

/obj/structure/displaycase/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/displaycase/proc/getPrint(mob/user as mob)
	return md5(user:dna:uni_identity)

/obj/structure/displaycase/attack_hand(mob/user as mob)
	if (destroyed)
		if(occupant)
			dump()
			user << "\red You smash your fist into the delicate electronics at the bottom of the case, and deactivate the hover field permanently."
			src.add_fingerprint(user)
			update_icon()
	else
		if(user.a_intent == "harm")
			user.visible_message("\red [user.name] kicks \the [src]!", \
				"\red You kick \the [src]!", \
				"You hear glass crack.")
			src.health -= 2
			healthcheck()
		else if(!locked)
			if(ishuman(user))
				if(!ue)
					user << "\blue Your press your thumb against the fingerprint scanner, registering your identity with the case."
					ue = getPrint(user)
					return
				if(ue!=getPrint(user))
					user << "\red Access denied."
					return

				user << "\blue Your press your thumb against the fingerprint scanner, and deactivate the hover field built into the case."
				if(occupant)
					dump()
					update_icon()
				else
					src << "\icon[src] \red \The [src] is empty!"
		else
			user.visible_message("[user.name] gently runs his hands over \the [src] in appreciation of its contents.", \
				"You gently run your hands over \the [src] in appreciation of its contents.", \
				"You hear someone streaking glass with their greasy hands.")

