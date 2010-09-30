/obj/lamarr
	name = "Lab Cage"
	icon = 'stationobjs.dmi'
	icon_state = "labcage1"
	desc = "A glass lab container for storing interesting creatures."
	density = 1
	anchored = 1
	var/health = 30
	var/occupied = 1
	var/destroyed = 0

/obj/lamarr/ex_act(severity)
	switch(severity)
		if (1)
			new /obj/item/weapon/shard( src.loc )
			if (occupied)
				var/obj/alien/facehugger/A = new /obj/alien/facehugger( src.loc )
				A.lamarr = 1
				A.name = "Lamarr"
				occupied = 0
			del(src)
		if (2)
			if (prob(50))
				src.health -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.health -= 5
				src.healthcheck()

/obj/lamarr/bullet_act(flag)

	if (flag == PROJECTILE_BULLET)
		src.health -= 10
		src.healthcheck()
		return
	if (flag != PROJECTILE_LASER) //lasers aren't particularly good at breaking glass
		src.health -= 2
		src.healthcheck()
		return
	else
		src.health -= 5
		src.healthcheck()
		return


/obj/lamarr/blob_act()
	if (prob(75))
		new /obj/item/weapon/shard( src.loc )
		if (occupied)
			var/obj/alien/facehugger/A = new /obj/alien/facehugger( src.loc )
			A.lamarr = 1
			A.name = "Lamarr"
			occupied = 0
		del(src)


/obj/lamarr/meteorhit(obj/O as obj)
		new /obj/item/weapon/shard( src.loc )
		var/obj/alien/facehugger/A = new /obj/alien/facehugger( src.loc )
		A.lamarr = 1
		A.name = "Lamarr"
		del(src)


/obj/lamarr/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.density = 0
			src.destroyed = 1
			new /obj/item/weapon/shard( src.loc )
			playsound(src, "shatter", 70, 1)
			var/obj/alien/facehugger/A = new /obj/alien/facehugger( src.loc )
			A.lamarr = 1
			A.name = "Lamarr"
			occupied = 0
			update_icon()
	else
		playsound(src.loc, 'Glasshit.ogg', 75, 1)
	return

/obj/lamarr/proc/update_icon()
	if(src.destroyed)
		src.icon_state = "labcageb[src.occupied]"
	else
		src.icon_state = "labcage[src.occupied]"
	return


/obj/lamarr/attackby(obj/item/weapon/W as obj, mob/user as mob)
	src.health -= W.force
	src.healthcheck()
	..()
	return

/obj/lamarr/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/lamarr/attack_hand(mob/user as mob)
	if (src.destroyed)
		return
	else
		usr << text("\blue You kick the lab cage.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] kicks the lab cage.", usr)
		src.health -= 2
		healthcheck()
		return