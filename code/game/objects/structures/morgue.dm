<<<<<<< HEAD
/* Morgue stuff
 * Contains:
 *		Morgue
 *		Morgue tray
 *		Crematorium
 *		Crematorium tray
 *		Crematorium button
 */

/*
 * Bodycontainer
 * Parent class for morgue and crematorium
 * For overriding only
 */
/obj/structure/bodycontainer
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue1"
	density = 1
	anchored = 1

	var/obj/structure/tray/connected = null
	var/locked = 0
	var/opendir = SOUTH

/obj/structure/bodycontainer/New()
	..()

/obj/structure/bodycontainer/Destroy()
	open()
	if(connected)
		qdel(connected)
		connected = null
	return ..()

/obj/structure/bodycontainer/on_log()
	update_icon()

/obj/structure/bodycontainer/update_icon()
	return

/obj/structure/bodycontainer/alter_health()
	return src.loc

/obj/structure/bodycontainer/relaymove(mob/user)
	if(user.stat || !isturf(loc))
		return
	open()

/obj/structure/bodycontainer/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/structure/bodycontainer/attack_hand(mob/user)
	if(locked)
		user << "<span class='danger'>It's locked.</span>"
		return
	if(!connected)
		user << "That doesn't appear to have a tray."
		return
	if(connected.loc == src)
		open()
	else
		close()
	add_fingerprint(user)

/obj/structure/bodycontainer/attackby(obj/P, mob/user, params)
	add_fingerprint(user)
	if(istype(P, /obj/item/weapon/pen))
		var/t = stripped_input(user, "What would you like the label to be?", text("[]", name), null)
		if (user.get_active_hand() != P)
			return
		if ((!in_range(src, usr) && src.loc != user))
			return
		if (t)
			name = text("[]- '[]'", initial(name), t)
		else
			name = initial(name)
	else
		return ..()

/obj/structure/bodycontainer/container_resist()
	open()

/obj/structure/bodycontainer/relay_container_resist(mob/living/user, obj/O)
	user << "<span class='notice'>You slam yourself into the side of [O].</span>"
	container_resist()

/obj/structure/bodycontainer/proc/open()
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	var/turf/T = get_step(src, opendir)
	for(var/atom/movable/AM in src)
		AM.forceMove(T)
	update_icon()

/obj/structure/bodycontainer/proc/close()
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	for(var/atom/movable/AM in connected.loc)
		if(!AM.anchored || AM == connected)
			AM.forceMove(src)
	update_icon()

/obj/structure/bodycontainer/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 2)
/*
 * Morgue
 */
/obj/structure/bodycontainer/morgue
	name = "morgue"
	desc = "Used to keep bodies in until someone fetches them."
	icon_state = "morgue1"
	opendir = EAST

/obj/structure/bodycontainer/morgue/New()
	connected = new/obj/structure/tray/m_tray(src)
	connected.connected = src
	..()

/obj/structure/bodycontainer/morgue/update_icon()
	if (!connected || connected.loc != src) // Open or tray is gone.
		icon_state = "morgue0"
	else
		if(contents.len == 1)  // Empty
			icon_state = "morgue1"
		else
			icon_state = "morgue2" // Dead, brainded mob.
			var/list/compiled = recursive_mob_check(src, 0, 0) // Search for mobs in all contents.
			if(!length(compiled)) // No mobs?
				icon_state = "morgue3"
				return
			for(var/mob/living/M in compiled)
				if(M.client && !M.suiciding)
					icon_state = "morgue4" // Cloneable
					break

/*
 * Crematorium
 */
var/global/list/crematoriums = new/list()
/obj/structure/bodycontainer/crematorium
	name = "crematorium"
	desc = "A human incinerator. Works well on barbeque nights."
	icon_state = "crema1"
	opendir = SOUTH
	var/id = 1

/obj/structure/bodycontainer/crematorium/Destroy()
	crematoriums.Remove(src)
	return ..()

/obj/structure/bodycontainer/crematorium/New()
	connected = new/obj/structure/tray/c_tray(src)
	connected.connected = src

	crematoriums.Add(src)
	..()

/obj/structure/bodycontainer/crematorium/update_icon()
	if(!connected || connected.loc != src)
		icon_state = "crema0"
	else

		if(src.contents.len > 1)
			src.icon_state = "crema2"
		else
			src.icon_state = "crema1"

		if(locked)
			src.icon_state = "crema_active"

	return

/obj/structure/bodycontainer/crematorium/proc/cremate(mob/user)
	if(locked)
		return //don't let you cremate something twice or w/e

	if(contents.len <= 1)
		audible_message("<span class='italics'>You hear a hollow crackle.</span>")
		return

	else
		audible_message("<span class='italics'>You hear a roar as the crematorium activates.</span>")

		locked = 1
		update_icon()

		for(var/mob/living/M in contents)
			if (M.stat != DEAD)
				M.emote("scream")
			if(user)
				user.attack_log +="\[[time_stamp()]\] Cremated <b>[M]/[M.ckey]</b>"
				log_attack("\[[time_stamp()]\] <b>[user]/[user.ckey]</b> cremated <b>[M]/[M.ckey]</b>")
			else
				log_attack("\[[time_stamp()]\] <b>UNKNOWN</b> cremated <b>[M]/[M.ckey]</b>")
			M.death(1)
			if(M) //some animals get automatically deleted on death.
				M.ghostize()
				qdel(M)

		for(var/obj/O in contents) //obj instead of obj/item so that bodybags and ashes get destroyed. We dont want tons and tons of ash piling up
			if(O != connected) //Creamtorium does not burn hot enough to destroy the tray
				qdel(O)

		new /obj/effect/decal/cleanable/ash(src)
		sleep(30)
		locked = 0
		update_icon()
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1) //you horrible people


/*
 * Generic Tray
 * Parent class for morguetray and crematoriumtray
 * For overriding only
 */
/obj/structure/tray
	icon = 'icons/obj/stationobjs.dmi'
	density = 1
	layer = BELOW_OBJ_LAYER
	var/obj/structure/bodycontainer/connected = null
	anchored = 1
	pass_flags = LETPASSTHROW

/obj/structure/tray/Destroy()
	if(connected)
		connected.connected = null
		connected.update_icon()
		connected = null
	return ..()

/obj/structure/tray/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/structure/tray/attack_hand(mob/user)
	if (src.connected)
		connected.close()
		add_fingerprint(user)
	else
		user << "<span class='warning'>That's not connected to anything!</span>"

/obj/structure/tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user)
	if(!istype(O, /atom/movable) || O.anchored || !Adjacent(user) || !user.Adjacent(O) || O.loc == user)
		return
	if(!ismob(O))
		if(!istype(O, /obj/structure/closet/body_bag))
			return
	else
		var/mob/M = O
		if(M.buckled)
			return
	if(!ismob(user) || user.lying || user.incapacitated())
		return
	O.loc = src.loc
	if (user != O)
		visible_message("<span class='warning'>[user] stuffs [O] into [src].</span>")
	return

/*
 * Crematorium tray
 */
/obj/structure/tray/c_tray
	name = "crematorium tray"
	desc = "Apply body before burning."
	icon_state = "cremat"

/*
 * Morgue tray
 */
/obj/structure/tray/m_tray
	name = "morgue tray"
	desc = "Apply corpse before closing."
	icon_state = "morguet"

/obj/structure/tray/m_tray/CanPass(atom/movable/mover, turf/target, height=0)
	if(height == 0)
		return 1

	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	if(locate(/obj/structure/table) in get_turf(mover))
		return 1
	else
		return 0

/obj/structure/tray/m_tray/CanAStarPass(ID, dir, caller)
	. = !density
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSTABLE)
=======
/* Morgue stuff
 * Contains:
 *		Morgue
 *		Morgue trays
 *		Creamatorium
 *		Creamatorium trays
 */

/*
 * Morgue
 */

/obj/structure/morgue
	name = "morgue"
	desc = "Used to keep bodies in until someone fetches them."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue1"
	dir = EAST
	density = 1
	var/obj/structure/m_tray/connected = null
	anchored = 1.0

/obj/structure/morgue/proc/update()
	if (connected)
		icon_state = "morgue0"
	else
		if (contents.len > 0)
			var/list/inside = recursive_type_check(src, /mob)
			if (!inside.len)
				icon_state = "morgue3" // no mobs at all, but objects inside
			else
				for (var/mob/body in inside)
					if (body && body.client)
						icon_state = "morgue4" // clone that mofo
						return
				icon_state = "morgue2" // dead no-client mob
		else
			icon_state = "morgue1"

/obj/structure/morgue/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
	return

/obj/structure/morgue/alter_health()
	return src.loc

/obj/structure/morgue/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/morgue/attack_hand(mob/user as mob)
	if (src.connected)
		for(var/atom/movable/A as mob|obj in src.connected.loc)
			if(istype(A, /mob/living/simple_animal/sculpture)) //I have no shame. Until someone rewrites this shitcode extroadinaire, I'll just snowflake over it
				continue
			if (!( A.anchored ))
				A.loc = src
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		//src.connected = null
		qdel(src.connected)
		src.connected = null
	else
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		src.connected = new /obj/structure/m_tray( src.loc )
		step(src.connected, src.dir)
		src.connected.layer = OBJ_LAYER
		var/turf/T = get_step(src, src.dir)
		if (T.contents.Find(src.connected))
			src.connected.connected = src
			src.icon_state = "morgue0"
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.connected.loc
			src.connected.icon_state = "morguet"
			src.connected.dir = src.dir
		else
			qdel(src.connected)
			src.connected = null
	src.add_fingerprint(user)
	update()
	return

/obj/structure/morgue/attackby(P as obj, mob/user as mob)
	if(iscrowbar(P)&&!contents.len)
		if(do_after(user, src,50))
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			new /obj/structure/closet/body_bag(src.loc)
			new /obj/item/stack/sheet/metal(src.loc,5)
			qdel(src)
	if(iswrench(P))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		if(dir==4)
			dir=8
		else
			dir=4
	if (istype(P, /obj/item/weapon/pen))
		var/t = input(user, "What would you like the label to be?", text("[]", src.name), null)  as text
		if (user.get_active_hand() != P)
			return
		if (!Adjacent(user) || user.stat)
			return
		t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
		if (t)
			src.name = text("Morgue- '[]'", t)
		else
			src.name = "Morgue"
	src.add_fingerprint(user)
	return

/obj/structure/morgue/relaymove(mob/user as mob)
	if (user.stat)
		return
	src.connected = new /obj/structure/m_tray( src.loc )
	step(src.connected, EAST)
	src.connected.layer = OBJ_LAYER
	var/turf/T = get_step(src, EAST)
	if (T.contents.Find(src.connected))
		src.connected.connected = src
		src.icon_state = "morgue0"
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.connected.loc
			//Foreach goto(106)
		src.connected.icon_state = "morguet"
	else
		//src.connected = null
		qdel(src.connected)
	return

/obj/structure/morgue/on_log()
	update()

/*
 * Morgue tray
 */
/obj/structure/m_tray
	name = "morgue tray"
	desc = "Apply corpse before closing."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morguet"
	density = 1
	layer = 2.0
	var/obj/structure/morgue/connected = null
	anchored = 1.0

/obj/structure/m_tray/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if (istype(mover, /obj/item/weapon/dummy))
		return 1
	else
		return ..()

/obj/structure/m_tray/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/m_tray/attack_hand(mob/user as mob)
	if (src.connected)
		for(var/atom/movable/A as mob|obj in src.loc)
			if(istype(A, /mob/living/simple_animal/sculpture)) //I have no shame. Until someone rewrites this shitcode extroadinaire, I'll just snowflake over it
				continue
			if (!( A.anchored ))
				A.loc = src.connected
			//Foreach goto(26)
		src.connected.connected = null
		src.connected.update()
		add_fingerprint(user)
		//SN src = null
		qdel(src)
		return
	return

/obj/structure/m_tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if ((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src) || user.contents.Find(O)))
		return
	if (!ismob(O) && !istype(O, /obj/structure/closet/body_bag))
		return
	O.loc = src.loc
	if (user != O)
		for(var/mob/B in viewers(user, 3))
			if ((B.client && !( B.blinded )))
				to_chat(B, text("<span class='warning'>[] stuffs [] into []!</span>", user, O, src))
	return


/*
 * Crematorium
 */

/obj/structure/crematorium
	name = "crematorium"
	desc = "A human incinerator. Works well on barbeque nights."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "crema1"
	density = 1
	var/obj/structure/c_tray/connected = null
	anchored = 1.0
	var/cremating = 0
	var/id = 1
	var/locked = 0

/obj/structure/crematorium/proc/update()
	if (cremating)
		icon_state = "crema_active"
		return

	if (contents.len > 0)
		icon_state = "crema2"
	else
		icon_state = "crema1"

/obj/structure/crematorium/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
	return

/obj/structure/crematorium/alter_health()
	return src.loc

/obj/structure/crematorium/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/crematorium/attack_hand(mob/user as mob)
//	if (cremating) AWW MAN! THIS WOULD BE SO MUCH MORE FUN ... TO WATCH
//		user.show_message("<span class='warning'>Uh-oh, that was a bad idea.</span>", 1)
//		to_chat(usr, "Uh-oh, that was a bad idea.")
//		src:loc:poison += 20000000
//		src:loc:firelevel = src:loc:poison
//		return
	if (cremating)
		to_chat(usr, "<span class='warning'>It's locked.</span>")
		return
	if ((src.connected) && (src.locked == 0))
		for(var/atom/movable/A as mob|obj in src.connected.loc)
			if (!( A.anchored ))
				A.loc = src
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		qdel(src.connected)
		src.connected = null
	else if (src.locked == 0)
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		src.connected = new /obj/structure/c_tray( src.loc )
		step(src.connected, SOUTH)
		src.connected.layer = OBJ_LAYER
		var/turf/T = get_step(src, SOUTH)
		if (T.contents.Find(src.connected))
			src.connected.connected = src
			src.icon_state = "crema0"
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.connected.loc
			src.connected.icon_state = "cremat"
		else
			qdel(src.connected)
			src.connected = null
	src.add_fingerprint(user)
	update()

/obj/structure/crematorium/attackby(P as obj, mob/user as mob)
	if (istype(P, /obj/item/weapon/pen))
		var/t = input(user, "What would you like the label to be?", text("[]", src.name), null)  as text
		if (user.get_active_hand() != P)
			return
		if (!Adjacent(user) || user.stat)
			return
		t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
		if (t)
			src.name = text("Crematorium- '[]'", t)
		else
			src.name = "Crematorium"
	src.add_fingerprint(user)
	return

/obj/structure/crematorium/relaymove(mob/user as mob)
	if (user.stat || locked)
		return
	src.connected = new /obj/structure/c_tray( src.loc )
	step(src.connected, SOUTH)
	src.connected.layer = OBJ_LAYER
	var/turf/T = get_step(src, SOUTH)
	if (T.contents.Find(src.connected))
		src.connected.connected = src
		src.icon_state = "crema0"
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.connected.loc
			//Foreach goto(106)
		src.connected.icon_state = "cremat"
	else
		qdel(src.connected)
		src.connected = null
	return

/obj/structure/crematorium/proc/cremate(mob/user)
//	for(var/obj/machinery/crema_switch/O in src) //trying to figure a way to call the switch, too drunk to sort it out atm
//		if(var/on == 1)
//		return
	if(cremating)
		return //don't let you cremate something twice or w/e

	if(contents.len <= 0)
		for (var/mob/M in viewers(src))
			M.show_message("<span class='warning'>You hear a hollow crackle.</span>", 1)
			return

	else
		var/inside = get_contents_in_object(src)

		if (locate(/obj/item/weapon/disk/nuclear) in inside)
			to_chat(user, "<SPAN CLASS='warning'>You get the feeling that you shouldn't cremate one of the items in the cremator.</SPAN>")
			return
		if(locate(/mob/living/simple_animal/sculpture) in inside)
			to_chat(user, "<span class='warning'>You try to toggle the crematorium on, but all you hear is scrapping stone.</span>")
			return
		for (var/mob/M in viewers(src))
			if(!M.hallucinating())
				M.show_message("<span class='warning'>You hear a roar as the crematorium activates.</span>", 1)
			else
				M.show_message("<span class='notice'>You hear chewing as the crematorium consumes its meal.</span>", 1)
				M << 'sound/items/eatfood.ogg'

		locked = 1
		cremating = 1
		update()

		for (var/mob/living/M in inside)
			if (M.stat!=2)
				M.emote("scream",,, 1)
			//Logging for this causes runtimes resulting in the cremator locking up. Commenting it out until that's figured out.
			//M.attack_log += "\[[time_stamp()]\] Has been cremated by <b>[user]/[user.ckey]</b>" //No point in this when the mob's about to be qdeleted
			//user.attack_log +="\[[time_stamp()]\] Cremated <b>[M]/[M.ckey]</b>"
			//log_attack("\[[time_stamp()]\] <b>[user]/[user.ckey]</b> cremated <b>[M]/[M.ckey]</b>")
			M.death(1)
			M.ghostize()
			qdel(M)
			M = null

		for (var/obj/O in inside) //obj instead of obj/item so that bodybags and ashes get destroyed. We dont want tons and tons of ash piling up
			qdel(O)

		inside = null

		new /obj/effect/decal/cleanable/ash(src)
		sleep(30)
		cremating = 0
		update()
		locked = 0
		playsound(get_turf(src), 'sound/machines/ding.ogg', 50, 1)
	return


/*
 * Crematorium tray
 */
/obj/structure/c_tray
	name = "crematorium tray"
	desc = "Apply body before burning."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "cremat"
	density = 1
	layer = 2.0
	var/obj/structure/crematorium/connected = null
	anchored = 1.0

/obj/structure/c_tray/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if (istype(mover, /obj/item/weapon/dummy))
		return 1
	else
		return ..()

/obj/structure/c_tray/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/c_tray/attack_hand(mob/user as mob)
	if (src.connected)
		for(var/atom/movable/A as mob|obj in src.loc)
			if (!( A.anchored ))
				A.loc = src.connected
			//Foreach goto(26)
		src.connected.connected = null
		src.connected.update()
		add_fingerprint(user)
		//SN src = null
		qdel(src)
		return
	return

/obj/structure/c_tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if ((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src) || user.contents.Find(O)))
		return
	if (!ismob(O) && !istype(O, /obj/structure/closet/body_bag))
		return
	O.loc = src.loc
	if (user != O)
		for(var/mob/B in viewers(user, 3))
			if ((B.client && !( B.blinded )))
				to_chat(B, text("<span class='warning'>[] stuffs [] into []!</span>", user, O, src))
			//Foreach goto(99)
	return

/obj/machinery/crema_switch/attack_hand(mob/user as mob)
	if (allowed(user))
		for (var/obj/structure/crematorium/C in world)
			if (C.id == id)
				C.cremate(user)
	else
		to_chat(user, "<SPAN CLASS='alert'>Access denied.</SPAN>")
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
