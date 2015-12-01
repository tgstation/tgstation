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
	var/pick_up_stuff = 1 // Pick up things that spawn at this location.
	var/wall_mounted = 0 //never solid (You can always pass over it)
	var/health = 100
	var/lastbang
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate
							  //then open it in a populated area to crash clients.
	var/breakout_time = 2 //2 minutes by default

	starting_materials = list(MAT_IRON = 2*CC_PER_SHEET_METAL)
	w_type = RECYK_METAL
	ignoreinvert = 1


/obj/structure/closet/initialize()
	..()
	if(!opened)		// if closed, any item at the crate's loc is put in the contents
		take_contents()
	else
		density = 0

// Fix for #383 - C4 deleting fridges with corpses
/obj/structure/closet/Destroy()
	dump_contents()
	..()

/obj/structure/closet/alter_health()
	return get_turf(src)

/obj/structure/closet/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
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
	if(usr)
		var/mob/living/L = usr
		var/obj/machinery/power/supermatter/SM = locate() in contents
		if(istype(SM))
			message_admins("[L.name] ([L.ckey]) opened \the [src] that contained supermatter (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[L.x];Y=[L.y];Z=[L.z]'>JMP</a>)")
			log_game("[L.name] ([L.ckey]) opened \the [src] that contained supermatter (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[L.x];Y=[L.y];Z=[L.z]'>JMP</a>)")


	//Cham Projector Exception
	for(var/obj/effect/dummy/chameleon/AD in src)
		AD.loc = src.loc

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
		INVOKE_EVENT(AM.on_moved,list("loc"=src))

/obj/structure/closet/proc/open()
	if(src.opened)
		return 0

	if(!src.can_open())
		return 0


	src.icon_state = src.icon_opened
	src.opened = 1
	src.density = 0
	src.dump_contents()
	INVOKE_EVENT(on_destroyed, list())
	if(istype(src, /obj/structure/closet/body_bag))
		playsound(get_turf(src), 'sound/items/zip.ogg', 15, 1, -3)
	else
		playsound(get_turf(src), 'sound/machines/click.ogg', 15, 1, -3)
	return 1

/obj/structure/closet/proc/insert(var/atom/movable/AM)


	if(contents.len >= storage_capacity)
		return -1

	// Prevent AIs from being crammed into lockers. /vg/ Redmine #153 - N3X
	if(istype(AM, /mob/living/silicon/ai) || istype(AM, /mob/living/simple_animal/sculpture))
		return 0

	if(istype(AM, /mob/living))
		var/mob/living/L = AM
		if(L.locked_to)
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
	/* /vg/: Delete if there's no code in here we need.
	var/itemcount = 0

	//Cham Projector Exception
	for(var/obj/effect/dummy/chameleon/AD in src.loc)
		if(itemcount >= storage_capacity)
			break
		AD.loc = src
		itemcount++

	for(var/obj/item/I in src.loc)
		if(itemcount >= storage_capacity)
			break
		if(!I.anchored)
			I.loc = src
			itemcount++

	for(var/mob/M in src.loc)
		if(itemcount >= storage_capacity)
			break
		if(istype (M, /mob/dead/observer))
			continue
		if(M.locked_to)
			continue

		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src

		M.loc = src
		itemcount++
	*/
	src.icon_state = src.icon_closed
	src.opened = 0
	if(istype(src, /obj/structure/closet/body_bag))
		playsound(get_turf(src), 'sound/items/zip.ogg', 15, 1, -3)
	else
		playsound(get_turf(src), 'sound/machines/click.ogg', 15, 1, -3)
	density = 1
	for(var/obj/effect/beam/B in loc)
		B.Crossed(src)
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
			qdel(src)
		if(2)
			if(prob(50))
				for (var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					A.ex_act(severity++)
				qdel(src)
		if(3)
			if(prob(5))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					A.ex_act(severity++)
				qdel(src)

/obj/structure/closet/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	if(health <= 0)
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

	return

/obj/structure/closet/beam_connect(var/obj/effect/beam/B)
	if(!processing_objects.Find(src))
		processing_objects.Add(src)
		testing("Connected [src] with [B]!")
	return ..()

/obj/structure/closet/beam_disconnect(var/obj/effect/beam/B)
	..()
	if(beams.len==0)
		// I hope to christ this doesn't break shit.
		processing_objects.Remove(src)

/obj/structure/closet/process()
	//..()
	for(var/obj/effect/beam/B in beams)
		health -= B.get_damage()

	if(health <= 0)
		dump_contents()
		qdel(src)

// This is broken, see attack_ai.
/obj/structure/closet/attack_robot(mob/living/silicon/robot/user as mob)
	if(isMoMMI(user))
		src.add_hiddenprint(user)
		add_fingerprint(user)
		return src.attack_hand(user)
	..(user)

/obj/machinery/closet/attack_ai(mob/user as mob)
	if(isMoMMI(user))
		src.add_hiddenprint(user)
		add_fingerprint(user)
		return src.attack_hand(user)
	..(user)

/obj/structure/closet/attack_animal(mob/living/simple_animal/user as mob)
	if(user.environment_smash)
		visible_message("<span class='warning'>[user] destroys the [src]. </span>")
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

// this should probably use dump_contents()
/obj/structure/closet/blob_act()
	if(prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

/obj/structure/closet/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(src.opened)
		if(istype(W, /obj/item/weapon/grab))
			if(src.large)
				var/obj/item/weapon/grab/G = W
				src.MouseDrop_T(G.affecting, user)	//act like they were dragged onto the closet
			else
				to_chat(user, "<span class='notice'>The locker is too small to stuff [W] into!</span>")
		if(istype(W,/obj/item/tk_grab))
			return 0

		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(!WT.remove_fuel(0,user))
				to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
				return
			var/obj/item/stack/sheet/metal/Met = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
			Met.amount = 2
			for(var/mob/M in viewers(src))
				M.show_message("<span class='notice'>\The [src] has been cut apart by [user] with \the [WT].</span>", 3, "You hear welding.", 2)
			del(src)
			return

		user.drop_item(W, src.loc)

	else if(istype(W, /obj/item/stack/package_wrap))
		return
	else if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.remove_fuel(0,user))
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
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
		to_chat(user, "<span class='notice'>It won't budge!</span>")
		if(!lastbang)
			lastbang = 1
			for (var/mob/M in hearers(src, null))
				to_chat(M, text("<FONT size=[]>BANG, bang!</FONT>", max(0, 5 - get_dist(src, M))))
			spawn(30)
				lastbang = 0


/obj/structure/closet/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/closet/attack_hand(mob/user as mob)
	if(!Adjacent(user))
		return
	src.add_fingerprint(user)

	var/mob/living/L = user
	if(src.opened==0 && L && L.client && L.hallucinating()) //If the closet is CLOSED and user is hallucinating
		if(prob(10))
			var/client/C = L.client
			var/image/temp_overlay = image(src.icon, icon_state=src.icon_opened) //Get the closet's OPEN icon
			temp_overlay.override = 1
			temp_overlay.loc = src

			var/image/spooky_overlay
			switch(rand(0,5))
				if(0) spooky_overlay = image('icons/mob/animal.dmi',icon_state="hunter",dir=turn(L.dir,180))
				if(1) spooky_overlay = image('icons/mob/animal.dmi',icon_state="zombie",dir=turn(L.dir,180))
				if(2) spooky_overlay = image('icons/mob/horror.dmi',icon_state="horror_[pick("male","female")]",dir=turn(L.dir,180))
				if(3) spooky_overlay = image('icons/mob/animal.dmi',icon_state="faithless",dir=turn(L.dir,180))
				if(4) spooky_overlay = image('icons/mob/animal.dmi',icon_state="carp",dir=turn(L.dir,180))
				if(5) spooky_overlay = image('icons/mob/animal.dmi',icon_state="skelly",dir=turn(L.dir,180))

			if(!spooky_overlay) return

			temp_overlay.overlays += spooky_overlay

			C.images += temp_overlay
			to_chat(L, sound('sound/machines/click.ogg'))
			to_chat(L, sound('sound/hallucinations/scary.ogg'))
			L.Weaken(5)

			sleep(50)

			if(C)
				C.images -= temp_overlay
			return

	if(!src.toggle())
		to_chat(usr, "<span class='notice'>It won't budge!</span>")

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user as mob)
	src.add_fingerprint(user)

	if(!src.toggle())
		to_chat(usr, "<span class='notice'>It won't budge!</span>")

/obj/structure/closet/verb/verb_toggleopen()
	set src in oview(1)
	set category = "Object"
	set name = "Toggle Open"

	if(!usr.canmove || usr.stat || usr.restrained() || (usr.status_flags & FAKEDEATH))
		return

	if(ishuman(usr) || isMoMMI(usr))
		if(isMoMMI(usr))
			src.add_hiddenprint(usr)
			add_fingerprint(usr)
		src.attack_hand(usr)
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

/obj/structure/closet/update_icon()//Putting the welded stuff in updateicon() so it's easy to overwrite for special cases (Fridges, cabinets, and whatnot)
	overlays.len = 0
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
	var/mob/user = usr
	var/breakout_time = 2 //2 minutes by default

	if(opened || (!welded && !locked))
		return  //Door's open, not locked or welded, no point in resisting.

	//okay, so the closet is either welded or locked... resist!!!
	user.delayNext(DELAY_ALL,100)

	to_chat(user, "<span class='notice'>You lean on the back of [src] and start pushing the door open. (this will take about [breakout_time] minutes.)</span>")
	for(var/mob/O in viewers(src))
		to_chat(O, "<span class='warning'>[src] begins to shake violently!</span>")
	var/turf/T = get_turf(src)	//Check for moved locker
	if(do_after(user, src, (breakout_time*60*10))) //minutes * 60seconds * 10deciseconds
		if(!user || user.stat != CONSCIOUS || user.loc != src || opened || (!locked && !welded) || T != get_turf(src))
			return
		//we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting

		welded = 0 //applies to all lockers lockers
		locked = 0 //applies to critter crates and secure lockers only
		broken = 1 //applies to secure lockers only
		visible_message("<span class='danger'>[user] successfully broke out of [src]!</span>")
		to_chat(user, "<span class='notice'>You successfully break out of [src]!</span>")
		open()
