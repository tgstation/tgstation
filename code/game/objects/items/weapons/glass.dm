/*
CONTAINS:
GLASS SHEET
REINFORCED GLASS SHEET
SHARDS

*/

/obj/item/weapon/sheet/glass/attack_hand(mob/user as mob)
	if ((user.r_hand == src || user.l_hand == src))
		src.add_fingerprint(user)
		var/obj/item/weapon/sheet/glass/F = new /obj/item/weapon/sheet/glass( user )
		F.amount = 1
		src.amount--
		if (user.hand)
			user.l_hand = F
		else
			user.r_hand = F
		F.layer = 20
		F.add_fingerprint(user)
		if (src.amount < 1)
			//SN src = null
			del(src)
			return
	else
		..()
	src.force = 5
	return

/obj/item/weapon/sheet/glass/attackby(obj/item/weapon/W, mob/user)
	if ( istype(W, /obj/item/weapon/sheet/glass) )
		var/obj/item/weapon/sheet/glass/G = W
		if (G.amount >= 50)
			return
		if (G.amount + src.amount > 50)
			src.amount = G.amount + src.amount - 50
			G.amount = 50
		else
			G.amount += src.amount
			//SN src = null
			del(src)
			return
		return
	else if( istype(W, /obj/item/weapon/rods) )

		var/obj/item/weapon/rods/V  = W
		var/obj/item/weapon/sheet/rglass/R = new /obj/item/weapon/sheet/rglass(user.loc)
		R.loc = user.loc
		R.add_fingerprint(user)


		if(V.amount == 1)

			if(user.client)
				user.client.screen -= V

			user.u_equip(W)
			del(W)
		else
			V.amount--


		if(src.amount == 1)

			if(user.client)
				user.client.screen -= src

			user.u_equip(src)
			del(src)
		else
			src.amount--
			return



/obj/item/weapon/sheet/glass/examine()
	set src in view(1)

	..()
	usr << text("There are [] glass sheet\s on the stack.", src.amount)
	return

/obj/item/weapon/sheet/glass/attack_self(mob/user as mob)

	if (!( istype(usr.loc, /turf/simulated) ))
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	switch(alert("Sheet-Glass", "Would you like full tile glass or one direction?", "one direct", "full (2 sheets)", "cancel", null))
		if("one direct")
			var/go = 1
			for (var/obj/window/win in usr.loc)
				if(win.ini_dir == NORTHWEST || win.ini_dir == NORTHEAST || win.ini_dir == SOUTHWEST || win.ini_dir == SOUTHEAST)
					go = 0
			if(go)
				var/obj/window/W = new /obj/window( usr.loc )
				W.anchored = 0
				if (src.amount < 1)
					return
				src.amount--
			else usr << "Can't let you do that."
		if("full (2 sheets)")
			var/go = 1
			for (var/obj/window/win in usr.loc)
				if(win)
					go = 0
			if (go)
				if (src.amount < 2)
					return
				src.amount -= 2
				var/obj/window/W = new /obj/window( usr.loc )
				W.dir = SOUTHWEST
				W.ini_dir = SOUTHWEST
				W.anchored = 0
			else usr << "Can't let you do that."
		else
	if (src.amount <= 0)
		user.u_equip(src)
		del(src)
		return
	return






// REINFORCED GLASS

/obj/item/weapon/sheet/rglass/attack_hand(mob/user as mob)
	if ((user.r_hand == src || user.l_hand == src))
		src.add_fingerprint(user)
		var/obj/item/weapon/sheet/rglass/F = new /obj/item/weapon/sheet/rglass( user )
		F.amount = 1
		src.amount--
		if (user.hand)
			user.l_hand = F
		else
			user.r_hand = F
		F.layer = 20
		F.add_fingerprint(user)
		if (src.amount < 1)
			//SN src = null
			del(src)
			return
	else
		..()
	src.force = 5
	return

/obj/item/weapon/sheet/rglass/attackby(obj/item/weapon/sheet/rglass/W as obj, mob/user as mob)
	if (!( istype(W, /obj/item/weapon/sheet/rglass) ))
		return
	if (W.amount >= 50)
		return
	if (W.amount + src.amount > 50)
		src.amount = W.amount + src.amount - 50
		W.amount = 50
	else
		W.amount += src.amount
		del(src)
		return
	return

/obj/item/weapon/sheet/rglass/examine()
	set src in view(1)

	..()
	usr << text("There are [] reinforced glass sheet\s on the stack.", src.amount)
	return

/obj/item/weapon/sheet/rglass/attack_self(mob/user as mob)
	if (!istype(usr.loc, /turf/simulated))
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	switch(alert("Sheet Reinf. Glass", "Would you like full tile glass or one direction?", "one direct", "full (2 sheets)", "cancel", null))
		if("one direct")
			var/go = 1
			for (var/obj/window/win in usr.loc)
				if(win.ini_dir == NORTHWEST || win.ini_dir == NORTHEAST || win.ini_dir == SOUTHWEST || win.ini_dir == SOUTHEAST)
					go = 0
			if(go)
				var/obj/window/W = new /obj/window( usr.loc, 1 )
				W.anchored = 0
				W.state = 0
				if (src.amount < 1)
					return
				src.amount--
			else usr << "Can't let you do that."
		if("full (2 sheets)")
			var/go = 1
			for (var/obj/window/win in usr.loc)
				if(win)
					go = 0
			if(go)
				if (src.amount < 2)
					return
				src.amount -= 2
				var/obj/window/W = new /obj/window( usr.loc, 1 )
				W.dir = SOUTHWEST
				W.ini_dir = SOUTHWEST
				W.anchored = 0
				W.state = 0
			else usr << "Can't let you do that."
		else
	if (src.amount <= 0)
		user.u_equip(src)
		//SN src = null
		del(src)
		return
	return








// SHARDS

/obj/item/weapon/shard/Bump()

	spawn( 0 )
		if (prob(20))
			src.force = 15
		else
			src.force = 4
		..()
		return
	return

/obj/item/weapon/shard/New()

	//****RM
	//world<<"New shard at [x],[y],[z]"

	src.icon_state = pick("large", "medium", "small")
	switch(src.icon_state)
		if("small")
			src.pixel_x = rand(1, 18)
			src.pixel_y = rand(1, 18)
		if("medium")
			src.pixel_x = rand(1, 16)
			src.pixel_y = rand(1, 16)
		if("large")
			src.pixel_x = rand(1, 10)
			src.pixel_y = rand(1, 5)
		else
	return

/obj/item/weapon/shard/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (!( istype(W, /obj/item/weapon/weldingtool) && W:welding ))
		return
	W:eyecheck(user)
	new /obj/item/weapon/sheet/glass( user.loc )
	//SN src = null
	del(src)
	return

/obj/item/weapon/shard/HasEntered(AM as mob|obj)
	if(ismob(AM))
		var/mob/M = AM
		M << "\red <B>You step in the broken glass!</B>"
		playsound(src.loc, 'glass_step.ogg', 50, 1)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.shoes)
				var/datum/organ/external/affecting = H.organs[pick("l_foot", "r_foot")]
				H.weakened = max(3, H.weakened)
				affecting.take_damage(5, 0)
				H.UpdateDamageIcon()
				H.updatehealth()
	..()