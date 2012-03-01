/obj/structure/stool/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				del(src)
				return
		if(3.0)
			if (prob(5))
				//SN src = null
				del(src)
				return
		else
	return

/obj/structure/stool/blob_act()
	if(prob(75))
		new /obj/item/stack/sheet/metal( src.loc )
		del(src)

/obj/structure/stool/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		playsound(src.loc, 'Ratchet.ogg', 50, 1)
		new /obj/item/stack/sheet/metal( src.loc )
		//SN src = null
		del(src)
	return


/obj/structure/stool/bed/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		playsound(src.loc, 'Ratchet.ogg', 50, 1)
		new /obj/item/stack/sheet/metal( src.loc )
		del(src)
	return

/obj/structure/stool/chair/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/assembly/shock_kit))
		var/obj/structure/stool/chair/e_chair/E = new /obj/structure/stool/chair/e_chair( src.loc )
		playsound(src.loc, 'Deconstruct.ogg', 50, 1)
		E.dir = src.dir
		E.part1 = W
		W.loc = E
		W.master = E
		user.u_equip(W)
		W.layer = initial(W.layer)
		//SN src = null
		del(src)
		return
	return

/obj/structure/stool/bed/Del()
	for(var/mob/M in src.buckled_mobs)
		if (M.buckled == src)
			M.lying = 0
	unbuckle_all()
	..()
	return

/obj/structure/stool/proc/unbuckle_all()
	for(var/mob/M in src:buckled_mobs)
		if (M.buckled == src)
			M.buckled = null
			M.anchored = 0
			M.update_clothing()

/obj/structure/stool/proc/manual_unbuckle_all(mob/user as mob)
	var/N = 0;
	for(var/mob/M in src:buckled_mobs)
		if (M.buckled == src)
			if (M != user)
				M.visible_message(\
					"\blue [M.name] was unbuckled by [user.name]!",\
					"You unbuckled from [src] by [user.name].",\
					"You hear metal clanking")
			else
				M.visible_message(\
					"\blue [M.name] unbuckled \himself!",\
					"You unbuckle yourself from [src].",\
					"You hear metal clanking")
//			world << "[M] is no longer buckled to [src]"
			M.anchored = 0
			M.buckled = null
			M.update_clothing()
			N++
	return N

/obj/structure/stool/proc/buckle_mob(mob/M as mob, mob/user as mob)
	if (!ticker)
		user << "You can't buckle anyone in before the game starts."
	if ((!( istype(M, /mob) ) || get_dist(src, user) > 1 || M.loc != src.loc || user.restrained() || usr.stat || M.buckled))
		return
	if (M == usr)
		M.visible_message(\
			"\blue [M.name] buckles in!",\
			"You buckle yourself to [src].",\
			"You hear metal clanking")
	else
		M.visible_message(\
			"\blue [M.name] is buckled into [src] by [user.name]!",\
			"You buckled in to [src] by [user.name].",\
			"You hear metal clanking")
	M.anchored = 1
	M.buckled = src
	M.loc = src.loc
	M.dir = src.dir
	M.update_clothing()
	src:buckled_mobs += M
	src.add_fingerprint(user)
	return

/obj/structure/stool/bed/MouseDrop_T(mob/M as mob, mob/user as mob)
	if (!istype(M)) return
	buckle_mob(M, user)
	M.lying = 1
	return

/obj/structure/stool/bed/attack_hand(mob/user as mob)
	for(var/mob/M in src.buckled_mobs)
		if (M.buckled == src)
			M.lying = 0
	if (manual_unbuckle_all(user))
		src.add_fingerprint(user)
	return

/obj/structure/stool/chair/e_chair/New()

	src.overl = new /atom/movable/overlay( src.loc )
	src.overl.icon = 'objects.dmi'
	src.overl.icon_state = "e_chairo0"
	src.overl.layer = 5
	src.overl.name = "electrified chair"
	src.overl.master = src
	spark.set_up(12, 1, src)
	return

/obj/structure/stool/chair/e_chair/Del()

	//src.overl = null
	del(src.overl)
	..()
	return

/obj/structure/stool/chair/e_chair/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/wrench))
		var/obj/structure/stool/chair/C = new /obj/structure/stool/chair( src.loc )
		playsound(src.loc, 'Ratchet.ogg', 50, 1)
		C.dir = src.dir
		src.part1.loc = src.loc
		src.part1.master = null
		src.part1 = null
		//SN src = null
		del(src)
		return
	if(istype(W, /obj/item/device/assembly/signaler))
		var/obj/item/assembly/shock_kit/kit = src.part1
		var/obj/item/device/radio/electropack/target = kit.part2
		var/obj/item/device/assembly/signaler/S = W
		target.set_frequency(S.frequency)
		target.code = S.code
		for(var/mob/M in viewers(src, null))
			M.show_message("\red [user] has set the electric chair using the [W].")
	return

/obj/structure/stool/chair/e_chair/verb/toggle_power()
	set name = "Toggle Electric Chair"
	set category = "Object"
	set src in oview(1)

	if ((usr.stat || usr.restrained() || !( usr.canmove ) || usr.lying))
		return
	if(isshocking && on)
		shock()
	src.on = !( src.on )
	src.icon_state = text("e_chair[]", src.on)
	src.overl.icon_state = text("e_chairo[]", src.on)
	return

/obj/structure/stool/chair/e_chair/proc/shock()
	if (!( src.on ))
		return
	if(isshocking)
		processing_objects.Remove(src)
		src.icon_state = text("e_chair[]", src.on)
		src.overl.icon_state = text("e_chairo[]", src.on)
		for(var/mob/living/M in affected)
			M.jitteriness = 0
			M.is_jittery = 0
			M.anchored = 0
			affected.Remove(M)
		isshocking = 0
		return
	else
		src.icon_state = "e_chairs"
		src.overl.icon_state = "e_chairos"
		spark.start()
		for(var/mob/M in hearers(src, null))
			M.show_message("\red The electric chair went off!.", 3, "\red You hear a deep sharp shock.", 2)
		processing_objects.Add(src)
		isshocking = 1
		return

/obj/structure/stool/chair/e_chair/process()
	// special power handling
	var/area/A = get_area(src)
	if(isarea(A) && A.powered(EQUIP))
		A.use_power(EQUIP, 5000)
	for(var/mob/living/M in src.loc)
		affected.Add(M)
		M.make_jittery(1000)
		M.anchored = 1
		M.Stun(600)
		M.burn_skin(10)
		spark.start()

/obj/structure/stool/chair/ex_act(severity)
	unbuckle_all()
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if (prob(5))
				del(src)
				return
	return

/obj/structure/stool/chair/blob_act()
	if(prob(75))
		unbuckle_all()
		del(src)

/obj/structure/stool/chair/New()
	src.verbs -= /atom/movable/verb/pull
	if (src.dir == NORTH)
		src.layer = FLY_LAYER
	..()
	return

/obj/structure/stool/chair/Del()
	unbuckle_all()
	..()
	return

/obj/structure/stool/chair/verb/rotate()
	set name = "Rotate Chair"
	set category = "Object"
	set src in oview(1)

	src.dir = turn(src.dir, 90)
	if (src.dir == NORTH)
		src.layer = FLY_LAYER
	else
		src.layer = OBJ_LAYER
	return

/obj/structure/stool/chair/MouseDrop_T(mob/M as mob, mob/user as mob)
	buckle_mob(M, user)
	return

/obj/structure/stool/chair/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/stool/chair/attack_hand(mob/user as mob)
	if (manual_unbuckle_all(user))
		src.add_fingerprint(user)
	return

//roller bed

/obj/structure/stool/bed/roller
	name = "roller bed"
	icon = 'rollerbed.dmi'
	icon_state = "down"
	anchored = 0

	Move()
		..()
		for(var/mob/M in src:buckled_mobs)
			if (M.buckled == src)
				M.loc = src.loc

	buckle_mob(mob/M as mob, mob/user as mob)
		if (!ticker)
			user << "You can't buckle anyone in before the game starts."
			return 0
		if ((!( istype(M, /mob) ) || get_dist(src, user) >= 1 || M.loc != src.loc || user.restrained() || usr.stat || M.buckled))
			return 0
		if (M == usr)
			M.visible_message(\
				"\blue [M.name] buckles in!",\
				"You buckle yourself to [src].",\
				"You hear metal clanking")
		else
			M.visible_message(\
				"\blue [M.name] is buckled in to [src] by [user.name]!",\
				"You buckled into [src] by [user.name].",\
				"You hear metal clanking")
		M.anchored = 1
		M.buckled = src
		M.loc = src.loc
		M.pixel_y = 6
		M.update_clothing()
		src:buckled_mobs += M
		src.add_fingerprint(user)
		density = 1
		icon_state = "up"
		return 1

	manual_unbuckle_all(mob/user as mob)
		var/N = 0;
		for(var/mob/M in src:buckled_mobs)
			if (M.buckled == src)
				if (M != user)
					M.visible_message(\
						"\blue [M.name] was unbuckled by [user.name]!",\
						"You unbuckled from [src] by [user.name].",\
						"You hear metal clanking")
				else
					var/t_himself = "itself"
					if (M.gender == MALE)
						t_himself = "himself"
					else if (M.gender == FEMALE)
						t_himself = "herself"

					M.visible_message(\
						"\blue [M.name] unbuckled [t_himself]!",\
						"You unbuckle yourself from [src].",\
						"You hear metal clanking")
				M.pixel_y = 0
				M.anchored = 0
				M.buckled = null
				M.update_clothing()
				N++
		if(N)
			density = 0
			icon_state = "down"
		return N
