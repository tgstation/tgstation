/obj/closet/alter_health()
	return get_turf(src)

/obj/closet/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	return opened

/obj/closet/proc/can_open()
	if (src.welded)
		return 0
	return 1

/obj/closet/proc/can_close()
	for(var/obj/closet/closet in get_turf(src))
		if(closet != src)
			return 0
	for(var/obj/secure_closet/closet in get_turf(src))
		return 0
	return 1

/obj/closet/proc/dump_contents()
	for (var/obj/item/I in src)
		I.loc = src.loc

	for (var/obj/overlay/o in src) //REMOVE THIS
		o.loc = src.loc

	for(var/mob/M in src)
		M.loc = src.loc
		if (M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

/obj/closet/proc/open()
	if (src.opened)
		return 0

	if (!src.can_open())
		return 0

	src.dump_contents()

	src.icon_state = src.icon_opened
	src.opened = 1
	playsound(src.loc, 'click.ogg', 15, 1, -3)
	return 1

/obj/closet/proc/close()
	if (!src.opened)
		return 0
	if (!src.can_close())
		return 0

	for (var/obj/item/I in src.loc)
		if (!I.anchored)
			I.loc = src

	for (var/obj/overlay/o in src.loc) //REMOVE THIS
		if (!o.anchored)
			o.loc = src

	for (var/mob/M in src.loc)
		if (M.buckled)
			continue

		if (M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src

		M.loc = src
	src.icon_state = src.icon_closed
	src.opened = 0
	playsound(src.loc, 'click.ogg', 15, 1, -3)
	return 1

/obj/closet/proc/toggle()
	if (src.opened)
		return src.close()
	return src.open()

// this should probably use dump_contents()
/obj/closet/ex_act(severity)
	switch(severity)
		if (1)
			for (var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			del(src)
		if (2)
			if (prob(50))
				for (var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
		if (3)
			if (prob(5))
				for (var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)

/obj/closet/bullet_act(flag)

/* Just in case someone gives closets health
	if (flag == PROJECTILE_BULLET)
		src.health -= 1
		src.healthcheck()
		return
	if (flag != PROJECTILE_LASER)
		src.health -= 3
		src.healthcheck()
		return
	else
		src.health -= 5
		src.healthcheck()
		return
*/
	if(prob(4))
		for (var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)
	return

// this should probably use dump_contents()
/obj/closet/blob_act()
	if (prob(50))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

/obj/closet/meteorhit(obj/O as obj)
	if (O.icon_state == "flaming")
		src.dump_contents()
		del(src)

/obj/closet/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (src.opened)
		if (istype(W, /obj/item/weapon/grab))
			src.MouseDrop_T(W:affecting, user)      //act like they were dragged onto the closet

		if (istype(W, /obj/item/weapon/weldingtool) && W:welding)
			if (W:get_fuel() < 2)
				user << "\blue You need more welding fuel to complete this task."
				return
			W:use_fuel(1)
			new /obj/item/weapon/sheet/metal(src.loc)
			for (var/mob/M in viewers(src))
				M.show_message("\red [src] has been cut apart by [user.name] with the weldingtool.", 3, "\red You hear welding.", 2)
			del(src)
			return

		usr.drop_item()

		if (W)
			W.loc = src.loc

	else if(istype(W, /obj/item/weapon/weldingtool) && W:welding)
		if (W:get_fuel() < 2)
			user << "\blue You need more welding fuel to complete this task."
			return
		W:eyecheck(user)
		W:use_fuel(1)
		src.welded =! src.welded
		for(var/mob/M in viewers(src))
			M.show_message("\red [src] has been [welded?"welded shut":"unwelded"] by [user.name].", 3, "\red You hear welding.", 2)
	else
		src.attack_hand(user)
	return

/obj/closet/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if (!user.can_use_hands())
		return
	if ((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)))
		return
	if (user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if (!istype(user.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(!src.opened)
		return
	if(istype(O, /obj/secure_closet) || istype(O, /obj/closet))
		return
	step_towards(O, src.loc)
	user.show_viewers(text("\red [] stuffs [] into []!", user, O, src))
	src.add_fingerprint(user)
	return

/obj/closet/relaymove(mob/user as mob)
	if (user.stat)
		return

	if (!src.open())
		user << "\blue It won't budge!"
		for (var/mob/M in hearers(src, null))
			M << text("<FONT size=[]>BANG, bang!</FONT>", max(0, 5 - get_dist(src, M)))

/obj/closet/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/closet/attack_hand(mob/user as mob)
	src.add_fingerprint(user)

	if (!src.toggle())
		usr << "\blue It won't budge!"
