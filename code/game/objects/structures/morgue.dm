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
	name = "Morgue"
	desc = "Used to keep bodies in until someone fetches them."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue1"
	density = 1
	var/obj/structure/m_tray/connected = null
	anchored = 1.0

/obj/structure/morgue/New()
	connected = new(src)
	connected.connected = src
	..()

/obj/structure/morgue/Destroy()
	open()
	if(connected)
		qdel(connected)
		connected = null
	..()

/obj/structure/morgue/on_log()
	update_icon()

/obj/structure/morgue/update_icon()
	if (!connected || connected.loc != src) //open or the tray broke off somehow
		src.icon_state = "morgue0"
	else
		if(src.contents.len == 1) //empty except for the tray
			src.icon_state = "morgue1"
		else

			src.icon_state = "morgue2"//default dead no-client mob

			var/list/compiled = recursive_mob_check(src,0,0)//run through contents

			if(!length(compiled))//no mobs at all, but objects inside
				src.icon_state = "morgue3"
				return

			for(var/mob/living/M in compiled)
				if(M.client)
					src.icon_state = "morgue4"//clone that mofo
					break

/obj/structure/morgue/alter_health()
	return src.loc

/obj/structure/morgue/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/morgue/attack_hand(mob/user as mob)
	if(!connected)
		user << "That doesn't appear to have a tray."
		return
	if(connected.loc == src)
		open()
	else
		close()
	add_fingerprint(user)

/obj/structure/morgue/attackby(P as obj, mob/user as mob)
	if (istype(P, /obj/item/weapon/pen))
		var/t = input(user, "What would you like the label to be?", text("[]", src.name), null)  as text
		if (user.get_active_hand() != P)
			return
		if ((!in_range(src, usr) && src.loc != user))
			return
		t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
		if (t)
			src.name = text("Morgue- '[]'", t)
		else
			src.name = "Morgue"
	add_fingerprint(user)

/obj/structure/morgue/container_resist()
	open()

/obj/structure/morgue/proc/open()
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	var/turf/T = get_step(src, EAST)
	for(var/atom/movable/A in src)
		A.loc = T
	update_icon()

/obj/structure/morgue/proc/close()
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	for(var/atom/movable/A in connected.loc)
		if(!A.anchored || A == connected)
			A.loc = src
	update_icon()


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
	throwpass = 1

/obj/structure/m_tray/Destroy()
	if(connected)
		connected.connected = null
		connected.update_icon()
		connected = null
	..()

/obj/structure/m_tray/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/m_tray/attack_hand(mob/user as mob)
	if (src.connected)
		connected.close()
		add_fingerprint(user)
	else
		user << "That's not connected to anything."

/obj/structure/m_tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if ((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src) || user.contents.Find(O)))
		return
	if (!ismob(O) && !istype(O, /obj/structure/closet/body_bag))
		return
	if (!ismob(user) || user.stat || user.lying || user.stunned)
		return
	O.loc = src.loc
	if (user != O)
		for(var/mob/B in viewers(user, 3))
			B.show_message("<span class='danger'>[user] stuffs [O] into [src]!</span>", 1)
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

/obj/structure/crematorium/New()
	connected = new(src)
	connected.connected = src
	..()

/obj/structure/crematorium/Destroy()
	open()
	if(connected)
		qdel(connected)
		connected = null
	..()

/obj/structure/crematorium/update_icon()
	if(!connected || connected.loc != src)
		icon_state = "crema0"
	else

		if(src.contents.len > 1)
			src.icon_state = "crema2"
		else
			src.icon_state = "crema1"

		if(cremating)
			src.icon_state = "crema_active"

	return


/obj/structure/crematorium/alter_health()
	return src.loc

/obj/structure/crematorium/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/crematorium/attack_hand(mob/user as mob)
	if (cremating || locked)
		user << "<span class='danger'>It's locked.</span>"
		return
	if (!connected)
		user << "That doesn't appear to have a tray."
		return
	if(connected.loc == src)
		open()
	else
		close()
	add_fingerprint(user)

/obj/structure/crematorium/attackby(P as obj, mob/user as mob)
	if (istype(P, /obj/item/weapon/pen))
		var/t = input(user, "What would you like the label to be?", text("[]", src.name), null)  as text
		if (user.get_active_hand() != P)
			return
		if ((!in_range(src, usr) > 1 && src.loc != user))
			return
		t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
		if (t)
			src.name = text("Crematorium- '[]'", t)
		else
			src.name = "Crematorium"
	src.add_fingerprint(user)
	return

/obj/structure/crematorium/container_resist()
	open()

/obj/structure/crematorium/proc/cremate(mob/user as mob)
	if(cremating)
		return //don't let you cremate something twice or w/e

	if(contents.len <= 1)
		audible_message("<span class='danger'>You hear a hollow crackle.</span>")
		return

	else
		audible_message("<span class='danger'>You hear a roar as the crematorium activates.</span>")

		cremating = 1
		locked = 1
		update_icon()

		for(var/mob/living/M in contents)
			if (M.stat!=2)
				M.emote("scream")
			//Logging for this causes runtimes resulting in the cremator locking up. Commenting it out until that's figured out.
			//M.attack_log += "\[[time_stamp()]\] Has been cremated by <b>[user]/[user.ckey]</b>" //No point in this when the mob's about to be deleted
			user.attack_log +="\[[time_stamp()]\] Cremated <b>[M]/[M.ckey]</b>"
			log_attack("\[[time_stamp()]\] <b>[user]/[user.ckey]</b> cremated <b>[M]/[M.ckey]</b>")
			M.death(1)
			M.ghostize()
			qdel(M)

		for(var/obj/O in contents) //obj instead of obj/item so that bodybags and ashes get destroyed. We dont want tons and tons of ash piling up
			if(O != connected) //Creamtorium does not burn hot enough to destroy the tray
				qdel(O)

		new /obj/effect/decal/cleanable/ash(src)
		sleep(30)
		cremating = 0
		locked = 0
		update_icon()
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)

/obj/structure/crematorium/proc/open()
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	var/turf/T = get_step(src, SOUTH)
	for(var/atom/movable/A in src)
		A.loc = T
	update_icon()

/obj/structure/crematorium/proc/close()
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	for(var/atom/movable/A in connected.loc)
		if(!A.anchored || A == connected)
			A.loc = src
	update_icon()

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
	throwpass = 1

/obj/structure/c_tray/Destroy()
	if(connected)
		connected.connected = null
		connected.update_icon()
		connected = null
	..()

/obj/structure/c_tray/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/c_tray/attack_hand(mob/user as mob)
	if (src.connected)
		connected.close()
		add_fingerprint(user)
	else
		user << "That's not connected to anything."

/obj/structure/c_tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if ((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src) || user.contents.Find(O)))
		return
	if (!ismob(O) && !istype(O, /obj/structure/closet/body_bag))
		return
	if (!ismob(user) || user.stat || user.lying || user.stunned)
		return
	O.loc = src.loc
	if (user != O)
		for(var/mob/B in viewers(user, 3))
			B.show_message("<span class='danger'>[user] stuffs [O] into [src]!</span>", 1)
			//Foreach goto(99)
	return

/obj/machinery/crema_switch/attack_hand(mob/user as mob)
	if(src.allowed(usr))
		for (var/obj/structure/crematorium/C in world)
			if (C.id == id)
				if (!C.cremating)
					C.cremate(user)
	else
		usr << "<span class='danger'>Access denied.</span>"
	return

