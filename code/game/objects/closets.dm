/obj/structure/closet/alter_health()
	return get_turf(src)

/obj/structure/closet/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0 || wall_mounted)) return 1
	return (!density)

/obj/structure/closet/proc/can_open()
	if(src.welded || istype(src.loc,/obj/structure/bigDelivery))
		return 0
	return 1

/obj/structure/closet/proc/can_close()
	for(var/obj/structure/closet/closet in get_turf(src))
		if(closet != src)
			return 0
	return 1

/obj/structure/closet/proc/dump_contents()
	for(var/obj/item/I in src)
		I.loc = src.loc

	for(var/obj/mecha/working/ripley/deathripley/I in src)
		I.loc = src.loc

	for(var/mob/M in src)
		M.loc = src.loc
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

/obj/structure/closet/proc/open()
	if(src.opened)
		return 0

	if(!src.can_open())
		return 0

	src.dump_contents()

	src.icon_state = src.icon_opened
	src.opened = 1
	if(istype(src, /obj/structure/closet/body_bag))
		playsound(src.loc, 'zip.ogg', 15, 1, -3)
	else
		playsound(src.loc, 'click.ogg', 15, 1, -3)
	density = 0
	return 1

/obj/structure/closet/proc/close()
	if(!src.opened)
		return 0
	if(!src.can_close())
		return 0

	for(var/obj/item/I in src.loc)
		if(!I.anchored)
			I.loc = src

	for(var/obj/mecha/working/ripley/deathripley/I in src.loc)
		I.loc = src

	for(var/mob/M in src.loc)
		if(istype (M, /mob/dead/observer))
			continue
		if(M.buckled)
			continue

		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src

		M.loc = src
	src.icon_state = src.icon_closed
	src.opened = 0
	if(istype(src, /obj/structure/closet/body_bag))
		playsound(src.loc, 'zip.ogg', 15, 1, -3)
	else
		playsound(src.loc, 'click.ogg', 15, 1, -3)
	density = 1
	return 1

/obj/structure/closet/proc/toggle()
	if(src.opened)
		return src.close()
	return src.open()

// this should probably use dump_contents()
/obj/structure/closet/ex_act(severity)
	switch(severity)
		if(1)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			del(src)
		if(2)
			if(prob(50))
				for (var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
		if(3)
			if(prob(5))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)

/obj/structure/closet/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	if(health <= 0)
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

	return

// this should probably use dump_contents()
/obj/structure/closet/blob_act()
	if(prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

/obj/structure/closet/meteorhit(obj/O as obj)
	if(O.icon_state == "flaming")
		src.dump_contents()
		del(src)

/obj/structure/closet/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(src.opened)
		if(istype(W, /obj/item/weapon/grab))
			src.MouseDrop_T(W:affecting, user)      //act like they were dragged onto the closet

		if(istype(W, /obj/item/weapon/weldingtool) && W:welding )
			if(!W:remove_fuel(0,user))
				user << "\blue You need more welding fuel to complete this task."
				return
			new /obj/item/stack/sheet/metal(src.loc)
			for(var/mob/M in viewers(src))
				M.show_message("\red [src] has been cut apart by [user.name] with the weldingtool.", 3, "\red You hear welding.", 2)
			del(src)
			return

		if(isrobot(user))
			return

		if(istype(W, /obj/item/weapon/packageWrap))
			return

		usr.drop_item()

		if(W)
			W.loc = src.loc

	else if(istype(W, /obj/item/weapon/packageWrap))
		return
	else if(istype(W, /obj/item/weapon/weldingtool) && W:welding )
		if(!W:remove_fuel(0,user))
			user << "\blue You need more welding fuel to complete this task."
			return
		src.welded =! src.welded
		for(var/mob/M in viewers(src))
			M.show_message("\red [src] has been [welded?"welded shut":"unwelded"] by [user.name].", 3, "\red You hear welding.", 2)
	else
		src.attack_hand(user)
	return

/obj/structure/closet/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis)
		return
	if((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)))
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(!src.opened)
		return
	if(istype(O, /obj/structure/closet))
		return
	step_towards(O, src.loc)
	if(user != O)
		user.show_viewers(text("\red [] stuffs [] into []!", user, O, src))
	src.add_fingerprint(user)
	return

/obj/structure/closet/relaymove(mob/user as mob)
	if(user.stat)
		return

	if(!src.open())
		if(istype(src.loc,/obj/structure/bigDelivery) && lasttry == 0)
			var/obj/structure/bigDelivery/Pack = src.loc
			if(istype(Pack.loc,/turf) && Pack.waswelded == 0)
				for (var/mob/M in hearers(src.loc, null))
					M << text("<FONT size=[] color=red>BANG, bang, rrrrrip!</FONT>", max(0, 5 - get_dist(src, M)))
				lasttry = 1
				sleep(10)
				src.welded = 0
				Pack.unwrap()
				src.open()
				spawn(30)
					lasttry = 0
		else if(!istype(src.loc,/obj/structure/bigDelivery))
			user << "\blue It won't budge!"
			if(!lastbang)
				lastbang = 1
				for (var/mob/M in hearers(src, null))
					M << text("<FONT size=[]>BANG, bang!</FONT>", max(0, 5 - get_dist(src, M)))
				spawn(30)
					lastbang = 0

/obj/structure/closet/Move()
	..()
	for(var/mob/M in contents)
		for(var/obj/effect/speech_bubble/B in range(1, src))
			if(B.parent == M)
				B.loc = loc


/obj/structure/closet/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/closet/attack_hand(mob/user as mob)
	src.add_fingerprint(user)

	if(!src.toggle())
		usr << "\blue It won't budge!"
