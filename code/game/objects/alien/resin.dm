// Resin walls improved. /N

/*/obj/alien/resin/ex_act(severity)
	world << "[severity] - [health]"
	switch(severity)
		if(1.0)
			src.health -= 10
		if(2.0)
			src.health -= 5
		if(3.0)
			src.health -= 1
	if(src.health < 1)
		del(src)
	return*/
/*
/obj/alien/resin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red <B>[src] is struck with [src]!</B>"), 1)
	src.health -= 2
	if(src.health <= 0)
		del(src)
*/

/obj/alien/resin/bullet_act(flag)
	if (flag == PROJECTILE_BULLET)
		health -= 35
		if(health <=0)
			src.density = 0
			del(src)
	return

/obj/alien/resin/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			del(src)
			return
		if(3.0)
			if (prob(50))
				del(src)
				return
	return

/obj/alien/resin/blob_act()
	density = 0
	del(src)

/obj/alien/resin/meteorhit()
	//*****RM
	//world << "glass at [x],[y],[z] Mhit"
	src.health = 0
	src.density = 0
	del(src)
	return

/obj/alien/resin/hitby(AM as mob|obj)
	..()
	for(var/mob/O in viewers(src, null))
		O.show_message(text("\red <B>[src] was hit by [AM].</B>"), 1)
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else
		tforce = AM:throwforce
	playsound(src.loc, 'attackblob.ogg', 100, 1)
	src.health = max(0, src.health - tforce)
	if (src.health <= 0)
		src.density = 0
		del(src)
		return
	..()
	return

/obj/alien/resin/attack_hand()
	if ((usr.mutations & 8))
		usr << text("\blue You easily destroy the resin wall.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] destroys the resin wall!", usr)
		src.health = 0
		src.density = 0
		del(src)
	return

/obj/alien/resin/attack_paw()
	if ((usr.mutations & 8))
		usr << text("\blue You easily destroy the resin wall.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] destroys the resin wall!", usr)
		src.health = 0
		src.density = 0
		del(src)
	return

/obj/alien/resin/attack_alien()
	if (istype(usr, /mob/living/carbon/alien/larva))//Safety check for larva. /N
		return
	usr << text("\green You claw at the resin wall.")
	for(var/mob/O in oviewers())
		if ((O.client && !( O.blinded )))
			O << text("\red [] claws at the resin wall!", usr)
	playsound(src.loc, 'attackblob.ogg', 100, 1)
	src.health -= rand(10, 20)
	if(src.health <= 0)
		usr << text("\green You slice the resin wall to pieces.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] slices the resin wall apart!", usr)
		src.health = 0
		src.density = 0
		del(src)
		return
	return

/obj/alien/resin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/aforce = W.force
	src.health = max(0, src.health - aforce)
	playsound(src.loc, 'attackblob.ogg', 100, 1)
	if (src.health <= 0)
		src.density = 0
		del(src)
		return
	..()
	return