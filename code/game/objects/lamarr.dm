/obj/structure/lamarr
	name = "Lab Cage"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "labcage1"
	desc = "A glass lab container for storing interesting creatures."
	density = 1
	anchored = 1
	unacidable = 1//Dissolving the case would also delete Lamarr
	var/health = 30
	var/occupied = 1
	var/destroyed = 0

/obj/structure/lamarr/ex_act(severity)
	switch(severity)
		if (1)
			new /obj/item/weapon/shard( src.loc )
			Break()
			del(src)
		if (2)
			if (prob(50))
				src.health -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.health -= 5
				src.healthcheck()


/obj/structure/lamarr/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	src.healthcheck()
	return


/obj/structure/lamarr/blob_act()
	if (prob(75))
		new /obj/item/weapon/shard( src.loc )
		Break()
		del(src)


/obj/structure/lamarr/meteorhit(obj/O as obj)
		new /obj/item/weapon/shard( src.loc )
		Break()
		del(src)


/obj/structure/lamarr/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.density = 0
			src.destroyed = 1
			new /obj/item/weapon/shard( src.loc )
			playsound(src, "shatter", 70, 1)
			Break()
	else
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
	return

/obj/structure/lamarr/update_icon()
	if(src.destroyed)
		src.icon_state = "labcageb[src.occupied]"
	else
		src.icon_state = "labcage[src.occupied]"
	return


/obj/structure/lamarr/attackby(obj/item/weapon/W as obj, mob/user as mob)
	src.health -= W.force
	src.healthcheck()
	..()
	return

/obj/structure/lamarr/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/lamarr/attack_hand(mob/user as mob)
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

/obj/structure/lamarr/proc/Break()
	if(occupied)
		var/obj/item/clothing/mask/facehugger/A = new /obj/item/clothing/mask/facehugger( src.loc )
		A.sterile = 1
		A.name = "Lamarr"
		occupied = 0
	update_icon()
	return