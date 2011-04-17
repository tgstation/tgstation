/obj/secure_closet/alter_health()
	return get_turf(src)

/obj/secure_closet/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	return src.opened

/obj/secure_closet/proc/can_close()
	for(var/obj/closet/closet in get_turf(src))
		return 0
	for(var/obj/secure_closet/closet in get_turf(src))
		if(closet != src)
			return 0
	return 1

/obj/secure_closet/proc/can_open()
	if (src.locked)
		return 0
	return 1

/obj/secure_closet/proc/dump_contents()
	for (var/obj/item/I in src)
		I.loc = src.loc

	for (var/obj/overlay/o in src) //REMOVE THIS
		o.loc = src.loc

	for(var/mob/M in src)
		M.loc = src.loc
		if (M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE
/obj/secure_closet/proc/open()
	if (src.opened)
		return 0

	if (!src.can_open())
		return 0

	src.dump_contents()

	src.icon_state = src.icon_opened
	src.opened = 1
	playsound(src.loc, 'click.ogg', 15, 1, -3)
	return 1

/obj/secure_closet/proc/close()
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

/obj/secure_closet/proc/toggle()
	if (src.opened)
		return src.close()
	return src.open()

/obj/secure_closet/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken)
		if(prob(50/severity))
			src.locked = !src.locked
		if(prob(20/severity) && !opened)
			if(!locked)
				open()
			else
				src.req_access = list()
				src.req_access += pick(get_all_accesses())
	..()

/obj/secure_closet/ex_act(severity)
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

/obj/secure_closet/blob_act()
	if (prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

/obj/secure_closet/meteorhit(obj/O as obj)
	if (O.icon_state == "flaming")
		for(var/obj/item/I in src)
			I.loc = src.loc
		for(var/mob/M in src)
			M.loc = src.loc
			if (M.client)
				M.client.eye = M.client.mob
				M.client.perspective = MOB_PERSPECTIVE
		src.icon_state = src.icon_broken
		del(src)
		return
	return

/obj/secure_closet/bullet_act(flag)
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
	if(prob(1.5))
		for (var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)
	return

/obj/secure_closet/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (src.opened)
		if (istype(W, /obj/item/weapon/grab))
			if (src.large)
				src.MouseDrop_T(W:affecting, user)	//act like they were dragged onto the closet
			else
				user << "The locker is too small to stuff [W] into!"
		user.drop_item()
		if (W)
			W.loc = src.loc
	else if(src.broken)
		user << "\red It appears to be broken."
		return
	else if( (istype(W, /obj/item/weapon/card/emag)||istype(W, /obj/item/weapon/blade)) && !src.broken)
		broken = 1
		locked = 0
		desc = "It appears to be broken."
		icon_state = src.icon_broken
		if(istype(W, /obj/item/weapon/blade))
			var/datum/effects/system/spark_spread/spark_system = new /datum/effects/system/spark_spread()
			spark_system.set_up(5, 0, src.loc)
			spark_system.start()
			playsound(src.loc, 'blade1.ogg', 50, 1)
			playsound(src.loc, "sparks", 50, 1)
			for(var/mob/O in viewers(user, 3))
				O.show_message(text("\blue The locker has been sliced open by [] with an energy blade!", user), 1, text("\red You hear metal being sliced and sparks flying."), 2)
		else
			for(var/mob/O in viewers(user, 3))
				O.show_message(text("\blue The locker has been broken by [] with an electromagnetic card!", user), 1, text("You hear a faint electrical spark."), 2)
	else if(src.allowed(user))
		src.locked = !src.locked
		for(var/mob/O in viewers(user, 3))
			if ((O.client && !( O.blinded )))
				O << text("\blue The locker has been []locked by [].", (src.locked ? null : "un"), user)
		if(src.locked)
			src.icon_state = src.icon_locked
		else
			src.icon_state = src.icon_closed

	else
		user << "\red Access Denied"
	return

/obj/secure_closet
	var/lastbang
/obj/secure_closet/relaymove(mob/user as mob)
	if (user.stat)
		return
	if (!( src.locked ))
		for(var/obj/item/I in src)
			I.loc = src.loc
		for(var/mob/M in src)
			M.loc = src.loc
			if (M.client)
				M.client.eye = M.client.mob
				M.client.perspective = MOB_PERSPECTIVE
		src.icon_state = src.icon_opened
		src.opened = 1
	else
		user << "\blue It's welded shut!"
		if (world.time > lastbang+5)
			lastbang = world.time
			for(var/mob/M in hearers(src, null))
				M << text("<FONT size=[]>BANG, bang!</FONT>", max(0, 5 - get_dist(src, M)))
	return

/obj/secure_closet/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if ((user.restrained() || user.stat))
		return
	if ((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)))
		return
	if(!src.opened)
		return
	if(istype(O, /obj/secure_closet) || istype(O, /obj/closet))
		return
	step_towards(O, src.loc)
	if (user != O)
		for(var/mob/B in viewers(user, 3))
			if ((B.client && !( B.blinded )))
				B << text("\red [] stuffs [] into []!", user, O, src)
	src.add_fingerprint(user)
	return
/*
/obj/secure_closet/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	if (!src.opened && !src.locked)
		if(!src.can_open())
			return
		//open it
		for(var/obj/item/I in src)
			I.loc = src.loc
		for(var/mob/M in src)
			M.loc = src.loc
			if (M.client)
				M.client.eye = M.client.mob
				M.client.perspective = MOB_PERSPECTIVE
		src.icon_state = src.icon_opened
		playsound(src.loc, 'click.ogg', 15, 1, -3)
		src.opened = 1
	else if(src.opened)
		if(!src.can_close())
			return
		//close it
		for(var/obj/item/I in src.loc)
			if (!( I.anchored ))
				I.loc = src
		for(var/mob/M in src.loc)
			if (M.buckled)
				continue
			if (M.client)
				M.client.perspective = EYE_PERSPECTIVE
				M.client.eye = src
			M.loc = src
		src.icon_state = src.icon_closed
		playsound(src.loc, 'click.ogg', 15, 1, -3)
		src.opened = 0
	else
		return src.attackby(null, user)
	return*/

/obj/secure_closet/attack_hand(mob/user as mob)
	src.add_fingerprint(user)

	if (!src.toggle())
		return src.attackby(null, user)

/obj/secure_closet/attack_paw(mob/user as mob)
	return src.attack_hand(user)
