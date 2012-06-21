//added by cael from old bs12
//not sure if there's an immediate place for secure wall lockers, but i'm sure the players will think of something

/obj/structure/closet/walllocker
	desc = "A wall mounted storage locker."
	name = "Wall Locker"
	icon = 'walllocker.dmi'
	icon_state = "wall-locker"
	density = 1
	flags = FPRINT
	var/list/spawnitems = list()
	var/amount = 3 // spawns each items X times.
	anchored = 1
	opened = 0
	var/locked = 1
	var/bang_time = 0
	var/broken = 0
	var/large = 1
	icon_closed = "wall-locker"
	var/icon_locked = "wall-locker1"
	icon_opened = "wall-lockeropen"
	var/icon_broken = "wall-lockerbroken"
	var/icon_off = "wall-lockeroff"

/obj/structure/closet/walllocker/attack_hand(mob/user as mob)
	if (istype(user, /mob/living/silicon/ai))	//Added by Strumpetplaya - AI shouldn't be able to
		return									//activate emergency lockers.  This fixes that.  (Does this make sense, the AI can't call attack_hand, can it? --Mloc)
	if(!amount)
		usr << "It's empty.."
		return
	if(amount)
		for(var/path in spawnitems)
			new path(src.loc)
		amount--
	return

/obj/structure/closet/walllocker/attackby(obj/item/weapon/W as obj, mob/user as mob)
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
	else if(istype(W, /obj/item/weapon/card/emag) && !src.broken)
		var/obj/item/weapon/card/emag/E = W
		if(E.uses)
			E.uses--
		else
			return
		src.broken = 1
		src.locked = 0
		src.icon_state = src.icon_broken
		for(var/mob/O in viewers(user, 3))
			if ((O.client && !( O.blinded )))
				O << text("\blue The locker has been broken by [user] with an electromagnetic card!")
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

/obj/structure/closet/walllocker/security
	name = "wall locker"
	req_access = list(ACCESS_SECURITY)
	icon_state = "wall-locker1"
	density = 1

/obj/structure/closet/walllocker/New()
	spawn(10)
		for(var/obj/item/A in src.loc.contents)
			A.loc = src

/obj/structure/closet/walllocker/alter_health()
	return get_turf(src)

/obj/structure/closet/walllocker/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	return src.opened

	for(var/mob/M in src)
		M.loc = src.loc
		if (M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

	if (!src.can_open())
		return 0

	src.dump_contents()

	src.icon_state = src.icon_opened
	src.opened = 1
	playsound(src.loc, 'click.ogg', 15, 1, -3)
	return 1

	if (!src.can_close())
		return 0

	for (var/obj/item/I in src.loc)
		if (!I.anchored)
			I.loc = src

	/*for (var/obj/overlay/o in src.loc) //REMOVE THIS
		if (!o.anchored)
			o.loc = src*/

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

/obj/structure/closet/walllocker/ex_act(severity)
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

/obj/structure/closet/walllocker/blob_act()
	if (prob(50))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

/obj/structure/closet/walllocker/meteorhit(obj/O as obj)
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

/obj/structure/closet/walllocker/bullet_act(flag)
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

/obj/structure/closet/walllocker/relaymove(mob/user as mob)
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
	else if(src.locked && world.timeofday - bang_time >= 14)
		user << "\blue It's locked!"
		for(var/mob/M in hearers(src, null))
			if(!(M.disabilities & 32) && M.ear_deaf == 0)
				M << text("<FONT size=[]>BANG, bang!</FONT>", max(0, 5 - get_dist(src, M)))
		//user.unlock_medal("It's a trap!", 0, "Get locked or welded into a locker...", "easy")
		bang_time = world.timeofday
		return
	return

/obj/structure/closet/walllocker/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if ((user.restrained() || user.stat))
		return
	if ((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)))
		return
	if(!src.opened)
		return
	if(istype(O, /obj/structure/closet/walllocker) || istype(O, /obj/structure/closet))
		return
	step_towards(O, src.loc)
	if (user != O)
		for(var/mob/B in viewers(user, 3))
			if ((B.client && !( B.blinded )))
				B << text("\red [] stuffs [] into []!", user, O, src)
	src.add_fingerprint(user)
	return
/*
//obj/structure/closet/attack_hand(mob/user as mob)
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

/obj/structure/closet/walllocker/attack_hand(mob/user as mob)
	src.add_fingerprint(user)

	if (!src.toggle())
		return src.attackby(null, user)

/obj/structure/closet/walllocker/attack_paw(mob/user as mob)
	return src.attack_hand(user)

//spawns endless amounts of breathmask, emergency oxy tank and crowbar

/obj/structure/closet/walllocker/emerglocker
	name = "Emergency Locker"
	spawnitems = list(/obj/item/weapon/tank/emergency_oxygen,/obj/item/clothing/mask/breath,/obj/item/weapon/crowbar)
	icon_state = "emerg"

/obj/structure/closet/walllocker/emerglocker/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker/emerglocker/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker/emerglocker/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker/emerglocker/east
	pixel_x = 32
	dir = EAST
