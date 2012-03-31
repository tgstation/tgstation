/*
CONTAINS:
GLASS SHEET
REINFORCED GLASS SHEET
SHARDS

*/

/proc/construct_window(mob/usr as mob, obj/item/stack/sheet/src as obj)
	if (!( istype(usr.loc, /turf/simulated) ))
		return
	if ( ! (istype(usr, /mob/living/carbon/human) || \
			istype(usr, /mob/living/silicon) || \
			istype(usr, /mob/living/carbon/monkey) && ticker && ticker.mode.name == "monkey") )
		usr << "\red You don't have the dexterity to do this!"
		return 1
	var/reinf = istype(src, /obj/item/stack/sheet/rglass)
	var/title = reinf?"Sheet Reinf. Glass":"Sheet-Glass"
	title += " ([src.amount] sheet\s left)"
	switch(alert(title, "Would you like full tile glass or one direction?", "one direct", "full (2 sheets)", "cancel", null))
		if("one direct")
			if (src.loc != usr)
				return 1
			if (src.amount < 1)
				return 1
			var/list/directions = new/list(cardinal)
			for (var/obj/structure/window/win in usr.loc)
				directions-=win.dir
				if(!(win.ini_dir in cardinal))
					usr << "\red Can't let you do that."
					return 1
			var/dir_to_set = 2
			//yes, this could probably be done better but hey... it works...
			for(var/obj/structure/window/WT in usr.loc)
				if (WT.dir == dir_to_set)
					dir_to_set = 4
			for(var/obj/structure/window/WT in usr.loc)
				if (WT.dir == dir_to_set)
					dir_to_set = 1
			for(var/obj/structure/window/WT in usr.loc)
				if (WT.dir == dir_to_set)
					dir_to_set = 8
			for(var/obj/structure/window/WT in usr.loc)
				if (WT.dir == dir_to_set)
					dir_to_set = 2
			var/obj/structure/window/W
			if(reinf)
				W = new /obj/structure/window/reinforced( usr.loc, reinf )
				W.state = 0
			else
				W = new /obj/structure/window/basic( usr.loc, reinf )
			W.dir = dir_to_set
			W.ini_dir = W.dir
			W.anchored = 0
			src.use(1)
		if("full (2 sheets)")
			if (src.loc != usr)
				return 1
			if (src.amount < 2)
				return 1
			if (locate(/obj/structure/window) in usr.loc)
				usr << "\red Can't let you do that."
				return 1
			var/obj/structure/window/W
			if(reinf)
				W = new /obj/structure/window/reinforced( usr.loc, reinf )
				W.state = 0
			else
				W = new /obj/structure/window/basic( usr.loc, reinf )
			W.dir = SOUTHWEST
			W.ini_dir = SOUTHWEST
			W.anchored = 0
			src.use(2)
		else
			//do nothing
	return

// GLASS

/obj/item/stack/sheet/glass/attack_self(mob/user as mob)
	construct_window(usr, src)

/obj/item/stack/sheet/glass/attackby(obj/item/W, mob/user)
	..()
	if(istype(W,/obj/item/weapon/cable_coil))
		var/obj/item/weapon/cable_coil/CC = W
		if(CC.amount < 5)
			user << "\b There is not enough wire in this coil. You need 5 lengths."
		CC.amount -= 5
		amount -= 1
		user << "\blue You attach wire to the [name]."
		new/obj/item/stack/light_w(user.loc)
		if(CC.amount <= 0)
			user.u_equip(CC)
			del(CC)
		if(src.amount <= 0)
			user.u_equip(src)
			del(src)
	else if( istype(W, /obj/item/stack/rods) )
		var/obj/item/stack/rods/V  = W
		var/obj/item/stack/sheet/rglass/RG = new (user.loc)
		RG.add_fingerprint(user)
		RG.add_to_stacks(user)
		V.use(1)
		var/obj/item/stack/sheet/glass/G = src
		src = null
		var/replace = (user.get_inactive_hand()==G)
		G.use(1)
		if (!G && !RG && replace)
			user.put_in_hand(RG)
	else
		return ..()


// REINFORCED GLASS

/obj/item/stack/sheet/rglass/attack_self(mob/user as mob)
	construct_window(usr, src)






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
			src.pixel_x = rand(-12, 12)
			src.pixel_y = rand(-12, 12)
		if("medium")
			src.pixel_x = rand(-8, 8)
			src.pixel_y = rand(-8, 8)
		if("large")
			src.pixel_x = rand(-5, 5)
			src.pixel_y = rand(-5, 5)
		else
	return

/obj/item/weapon/shard/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ( istype(W, /obj/item/weapon/weldingtool) && W:welding )
		W:eyecheck(user)
		new /obj/item/stack/sheet/glass( user.loc )
		//SN src = null
		del(src)
		return
	return ..()

/obj/item/weapon/shard/HasEntered(AM as mob|obj)
	if(ismob(AM))
		var/mob/M = AM
		if (istype(M, /mob/living/carbon/metroid)) //I mean they float, seriously. - Erthilo
			return
		M << "\red <B>You step in the broken glass!</B>"
		playsound(src.loc, 'glass_step.ogg', 50, 1)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!((H.shoes) || (H.wear_suit && H.wear_suit.body_parts_covered & FEET)))
				var/datum/organ/external/affecting = H.get_organ(pick("l_foot", "r_foot"))
				H.Weaken(3)
				affecting.take_damage(5, 0)
				H.UpdateDamageIcon()
				H.updatehealth()
	..()

	//&& H.wear_suit.body_parts_covered&FEET)))