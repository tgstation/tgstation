/*
CONTAINS:
GLASS SHEET
REINFORCED GLASS SHEET
SHARDS

*/

// GLASS

/obj/item/stack/sheet/glass/attack_self(mob/user as mob)
	construct_window(user)

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

/obj/item/stack/sheet/glass/proc/construct_window(mob/user as mob)
	if(!user || !src)	return 0
	if(!istype(user.loc,/turf)) return 0
	if(!user.IsAdvancedToolUser())
		user << "\red You don't have the dexterity to do this!"
		return 0
	var/title = "Sheet-Glass"
	title += " ([src.amount] sheet\s left)"
	switch(alert(title, "Would you like full tile glass or one direction?", "one direct", "full (2 sheets)", "cancel", null))
		if("one direct")
			if(!src)	return 1
			if(src.loc != user)	return 1
			var/list/directions = new/list(cardinal)
			for (var/obj/structure/window/win in user.loc)
				directions-=win.dir
				if(!(win.ini_dir in cardinal))
					user << "\red Can't let you do that."
					return 1
			var/dir_to_set = 2
			//yes, this could probably be done better but hey... it works...
			for(var/obj/structure/window/WT in user.loc)
				if (WT.dir == dir_to_set)
					dir_to_set = 4
			for(var/obj/structure/window/WT in user.loc)
				if (WT.dir == dir_to_set)
					dir_to_set = 1
			for(var/obj/structure/window/WT in user.loc)
				if (WT.dir == dir_to_set)
					dir_to_set = 8
			for(var/obj/structure/window/WT in user.loc)
				if (WT.dir == dir_to_set)
					dir_to_set = 2
			var/obj/structure/window/W
			W = new /obj/structure/window/basic( user.loc, 0 )
			W.dir = dir_to_set
			W.ini_dir = W.dir
			W.anchored = 0
			src.use(1)
		if("full (2 sheets)")
			if(!src)	return 1
			if(src.loc != user)	return 1
			if(locate(/obj/structure/window) in user.loc)
				user << "\red There is a window in the way."
				return 1
			var/obj/structure/window/W
			W = new /obj/structure/window/basic( user.loc, 0 )
			W.dir = SOUTHWEST
			W.ini_dir = SOUTHWEST
			W.anchored = 0
			src.use(2)
	return 0


// REINFORCED GLASS

/obj/item/stack/sheet/rglass/attack_self(mob/user as mob)
	construct_window(user)

/obj/item/stack/sheet/rglass/proc/construct_window(mob/user as mob)
	if(!user || !src)	return 0
	if(!istype(user.loc,/turf)) return 0
	if(!user.IsAdvancedToolUser())
		user << "\red You don't have the dexterity to do this!"
		return 0
	var/title = "Sheet Reinf. Glass"
	title += " ([src.amount] sheet\s left)"
	switch(alert(title, "Would you like full tile glass or one direction?", "one direct", "full (2 sheets)", "cancel", null))
		if("one direct")
			if(!src)	return 1
			if(src.loc != user)	return 1
			var/list/directions = new/list(cardinal)
			for (var/obj/structure/window/win in user.loc)
				directions-=win.dir
				if(!(win.ini_dir in cardinal))
					user << "\red Can't let you do that."
					return 1
			var/dir_to_set = 2
			//yes, this could probably be done better but hey... it works...
			for(var/obj/structure/window/WT in user.loc)
				if (WT.dir == dir_to_set)
					dir_to_set = 4
			for(var/obj/structure/window/WT in user.loc)
				if (WT.dir == dir_to_set)
					dir_to_set = 1
			for(var/obj/structure/window/WT in user.loc)
				if (WT.dir == dir_to_set)
					dir_to_set = 8
			for(var/obj/structure/window/WT in user.loc)
				if (WT.dir == dir_to_set)
					dir_to_set = 2
			var/obj/structure/window/W
			W = new /obj/structure/window/reinforced( user.loc, 1 )
			W.state = 0
			W.dir = dir_to_set
			W.ini_dir = W.dir
			W.anchored = 0
			src.use(1)
		if("full (2 sheets)")
			if(!src)	return 1
			if(src.loc != user)	return 1
			if(locate(/obj/structure/window) in user.loc)
				user << "\red There is a window in the way."
				return 1
			var/obj/structure/window/W
			W = new /obj/structure/window/reinforced( user.loc, 1 )
			W.state = 0
			W.dir = SOUTHWEST
			W.ini_dir = SOUTHWEST
			W.anchored = 0
			src.use(2)
	return 0

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
		var/obj/item/stack/sheet/glass/NG = new (user.loc)
		for (var/obj/item/stack/sheet/glass/G in user.loc)
			if(G==NG)
				continue
			if(G.amount>=G.max_amount)
				continue
			G.attackby(NG, user)
			usr << "You add the newly-formed glass to the stack. It now contains [NG.amount] sheets."
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