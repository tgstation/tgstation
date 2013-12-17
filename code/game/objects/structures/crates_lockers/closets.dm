/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "closed"
	density = 1
	flags = FPRINT
	var/icon_closed = "closed"
	var/icon_opened = "open"
	var/opened = 0
	var/welded = 0
	var/locked = 0
	var/broken = 0
	var/large = 1
	var/wall_mounted = 0 //never solid (You can always pass over it)
	var/health = 100
	var/lastbang
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate
							  //then open it in a populated area to crash clients.

/obj/structure/closet/initialize()
	..()
	if(!opened)		// if closed, any item at the crate's loc is put in the contents
		take_contents()

/obj/structure/closet/alter_health()
	return get_turf(src)

/obj/structure/closet/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0 || wall_mounted)) return 1
	return (!density)

/obj/structure/closet/proc/can_open()
	if(src.welded)
		return 0
	return 1

/obj/structure/closet/proc/can_close()
	for(var/obj/structure/closet/closet in get_turf(src))
		if(closet != src)
			return 0
	return 1

/obj/structure/closet/proc/dump_contents()

	for(var/obj/O in src)
		O.loc = src.loc

	for(var/mob/M in src)
		M.loc = src.loc
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

/obj/structure/closet/proc/take_contents()

	for(var/atom/movable/AM in src.loc)
		if(insert(AM) == -1) // limit reached
			break

/obj/structure/closet/proc/open()
	if(src.opened)
		return 0

	if(!src.can_open())
		return 0

	src.dump_contents()

	src.icon_state = src.icon_opened
	src.opened = 1
	if(istype(src, /obj/structure/closet/body_bag))
		playsound(src.loc, 'sound/items/zip.ogg', 15, 1, -3)
	else
		playsound(src.loc, 'sound/machines/click.ogg', 15, 1, -3)
	density = 0
	return 1

/obj/structure/closet/proc/insert(var/atom/movable/AM)

	if(contents.len >= storage_capacity)
		return -1

	if(istype(AM, /mob/living))
		var/mob/living/L = AM
		if(L.buckled)
			return 0
		if(L.client)
			L.client.perspective = EYE_PERSPECTIVE
			L.client.eye = src
	else if(!istype(AM, /obj/item) && !istype(AM, /obj/effect/dummy/chameleon))
		return 0
	else if(AM.density || AM.anchored)
		return 0
	AM.loc = src
	return 1

/obj/structure/closet/proc/close()
	if(!src.opened)
		return 0
	if(!src.can_close())
		return 0

	take_contents()

	src.icon_state = src.icon_closed
	src.opened = 0
	if(istype(src, /obj/structure/closet/body_bag))
		playsound(src.loc, 'sound/items/zip.ogg', 15, 1, -3)
	else
		playsound(src.loc, 'sound/machines/click.ogg', 15, 1, -3)
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
			for(var/atom/movable/A as mob|obj in src)//pulls everything out of the locker and hits it with an explosion
				A.loc = src.loc
				A.ex_act(severity++)
			del(src)
		if(2)
			if(prob(50))
				for (var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					A.ex_act(severity++)
				del(src)
		if(3)
			if(prob(5))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					A.ex_act(severity++)
				del(src)

/obj/structure/closet/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	if(health <= 0)
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

	return

/obj/structure/closet/attack_animal(mob/living/simple_animal/user as mob)
	if(user.wall_smash)
		visible_message("\red [user] destroys the [src]. ")
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

// this should probably use dump_contents()
/obj/structure/closet/blob_act()
	if(prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

/obj/structure/closet/meteorhit(obj/O as obj)
	if(O.icon_state == "flaming")
		for(var/mob/M in src)
			M.meteorhit(O)
		src.dump_contents()
		del(src)

/obj/structure/closet/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(src.opened)
		if(istype(W, /obj/item/weapon/grab))
			if(src.large)
				var/obj/item/weapon/grab/G = W
				src.MouseDrop_T(G.affecting, user)	//act like they were dragged onto the closet
			else
				user << "<span class='notice'>The locker is too small to stuff [W] into!</span>"
		if(istype(W,/obj/item/tk_grab))
			return 0

		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(!WT.remove_fuel(0,user))
				user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
				return
			new /obj/item/stack/sheet/metal(src.loc)
			for(var/mob/M in viewers(src))
				M.show_message("<span class='notice'>\The [src] has been cut apart by [user] with \the [WT].</span>", 3, "You hear welding.", 2)
			del(src)
			return

		if(isrobot(user))
			return

		user.drop_item(src)

	else if(istype(W, /obj/item/weapon/packageWrap))
		return
	else if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.remove_fuel(0,user))
			user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
			return
		src.welded =! src.welded
		src.update_icon()
		for(var/mob/M in viewers(src))
			M.show_message("<span class='warning'>[src] has been [welded?"welded shut":"unwelded"] by [user.name].</span>", 3, "You hear welding.", 2)
	else if(!place(user, W))
		src.attack_hand(user)
	return

/obj/structure/closet/proc/place(var/mob/user, var/obj/item/I)
	return 0

/obj/structure/closet/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob, var/needs_opened = 1, var/show_message = 1, var/move_them = 1)
	if(istype(O, /obj/screen))	//fix for HUD elements making their way into the world	-Pete
		return 0
	if(!isturf(O.loc))
		return 0
	if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis || user.lying)
		return 0
	if((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1))
		return 0
	if(!istype(user.loc, /turf)) // are you in a container/closet/pod/etc? Will also check for null loc
		return 0
	if(needs_opened && !src.opened)
		return 0
	if(istype(O, /obj/structure/closet))
		return 0
	if(move_them)
		step_towards(O, src.loc)
	if(show_message && user != O)
		user.show_viewers("<span class='danger'>[user] stuffs [O] into [src]!</span>")
	src.add_fingerprint(user)
	return 1

/obj/structure/closet/relaymove(mob/user as mob)
	if(user.stat || !isturf(src.loc))
		return

	if(!src.open())
		user << "<span class='notice'>It won't budge!</span>"
		if(!lastbang)
			lastbang = 1
			for (var/mob/M in hearers(src, null))
				M << text("<FONT size=[]>BANG, bang!</FONT>", max(0, 5 - get_dist(src, M)))
			spawn(30)
				lastbang = 0


/obj/structure/closet/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/closet/attack_hand(mob/user as mob)
	src.add_fingerprint(user)

	if(!src.toggle())
		usr << "<span class='notice'>It won't budge!</span>"

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user as mob)
	src.add_fingerprint(user)

	if(!src.toggle())
		usr << "<span class='notice'>It won't budge!</span>"

/obj/structure/closet/verb/verb_toggleopen()
	set src in oview(1)
	set category = "Object"
	set name = "Toggle Open"

	if(!usr.canmove || usr.stat || usr.restrained())
		return

	if(ishuman(usr))
		src.attack_hand(usr)
	else
		usr << "<span class='warning'>This mob type can't use this verb.</span>"

/obj/structure/closet/update_icon()//Putting the welded stuff in updateicon() so it's easy to overwrite for special cases (Fridges, cabinets, and whatnot)
	overlays.Cut()
	if(!opened)
		icon_state = icon_closed
		if(welded)
			overlays += "welded"
	else
		icon_state = icon_opened

// Objects that try to exit a locker by stepping were doing so successfully,
// and due to an oversight in turf/Enter() were going through walls.  That
// should be independently resolved, but this is also an interesting twist.
/obj/structure/closet/Exit(atom/movable/AM)
	open()
	if(AM.loc == src) return 0
	return 1

/obj/structure/closet/container_resist()
	var/mob/living/user = usr
	var/breakout_time = 2 //2 minutes by default
	if(istype(user.loc, /obj/structure/closet/critter) && !welded)
		breakout_time = 0.75 //45 seconds if it's an unwelded critter crate

	if(opened || (!welded && !locked))
		return  //Door's open, not locked or welded, no point in resisting.

	//okay, so the closet is either welded or locked... resist!!!
	user.next_move = world.time + 100
	user.last_special = world.time + 100
	user << "<span class='notice'>You lean on the back of [src] and start pushing the door open. (this will take about [breakout_time] minutes.)</span>"
	for(var/mob/O in viewers(src))
		O << "<span class='warning'>[src] begins to shake violently!</span>"
	var/turf/T = get_turf(src)	//Check for moved locker
	if(do_after(user,(breakout_time*60*10))) //minutes * 60seconds * 10deciseconds
		if(!user || user.stat != CONSCIOUS || user.loc != src || opened || (!locked && !welded) || T != get_turf(src))
			return
		//we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting

		welded = 0 //applies to all lockers lockers
		locked = 0 //applies to critter crates and secure lockers only
		broken = 1 //applies to secure lockers only
		visible_message("<span class='danger'>[user] successfully broke out of [src]!</span>")
		user << "<span class='notice'>You successfully break out of [src]!</span>"
		open()
