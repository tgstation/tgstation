/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox1"
	desc = "A display case for prized possessions. Hooked up with an anti-theft system."
	density = 1
	anchored = 1
	unacidable = 1//Dissolving the case would also delete the gun.
	var/health = 30
	var/occupied = 1
	var/destroyed = 0

/obj/structure/displaycase/ex_act(severity, target)
	switch(severity)
		if (1)
			new /obj/item/weapon/shard( src.loc )
			if (occupied)
				new /obj/item/weapon/gun/energy/laser/captain( src.loc )
				occupied = 0
			qdel(src)
		if (2)
			if (prob(50))
				src.health -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.health -= 5
				src.healthcheck()


/obj/structure/displaycase/bullet_act(var/obj/item/projectile/Proj)
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		health -= Proj.damage
	..()
	src.healthcheck()
	return


/obj/structure/displaycase/blob_act()
	if (prob(75))
		new /obj/item/weapon/shard( src.loc )
		if (occupied)
			new /obj/item/weapon/gun/energy/laser/captain( src.loc )
			occupied = 0
		qdel(src)


/obj/structure/displaycase/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.density = 0
			src.destroyed = 1
			new /obj/item/weapon/shard( src.loc )
			playsound(src, "shatter", 70, 1)
			update_icon()

			//Activate Anti-theft
			var/area/alarmed = get_area(src)
			alarmed.burglaralert(src)
			playsound(src, "sound/effects/alert.ogg", 50, 1)

	else
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
	return

/obj/structure/displaycase/update_icon()
	if(src.destroyed)
		src.icon_state = "glassboxb[src.occupied]"
	else
		src.icon_state = "glassbox[src.occupied]"
	return


/obj/structure/displaycase/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	user.changeNext_move(CLICK_CD_MELEE)
	src.health -= W.force
	src.healthcheck()
	..()
	return

/obj/structure/displaycase/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/displaycase/attack_hand(mob/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	if (src.destroyed && src.occupied)
		new /obj/item/weapon/gun/energy/laser/captain( src.loc )
		user << "<span class='notice'>You deactivate the hover field built into the case.</span>"
		src.occupied = 0
		src.add_fingerprint(user)
		update_icon()
		return
	else
		user.visible_message("<span class='danger'>[user] kicks the display case.</span>", \
						 "<span class='notice'>You kick the display case.</span>")
		src.health -= 2
		healthcheck()
		return


