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
	anchored = 1.0

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
	..()

/obj/structure/bodycontainer/on_log()
	update_icon()

/obj/structure/bodycontainer/update_icon()
	return

/obj/structure/bodycontainer/alter_health()
	return src.loc

/obj/structure/bodycontainer/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/bodycontainer/attack_hand(mob/user as mob)
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

/obj/structure/bodycontainer/attackby(P as obj, mob/user as mob, params)
	if (istype(P, /obj/item/weapon/pen))
		var/t = stripped_input(user, "What would you like the label to be?", text("[]", name), null)
		if (user.get_active_hand() != P)
			return
		if ((!in_range(src, usr) && src.loc != user))
			return
		if (t)
			name = text("[]- '[]'", initial(name), t)
		else
			name = initial(name)
	add_fingerprint(user)

/obj/structure/bodycontainer/container_resist()
	open()

/obj/structure/bodycontainer/proc/open()
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	var/turf/T = get_step(src, opendir)
	for(var/atom/movable/A in src)
		A.loc = T
	update_icon()

/obj/structure/bodycontainer/proc/close()
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	for(var/atom/movable/A in connected.loc)
		if(!A.anchored || A == connected)
			A.loc = src
	update_icon()

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
	..()

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

/obj/structure/bodycontainer/crematorium/proc/cremate(mob/user as mob)
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
		locked = 0
		update_icon()
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1) //you horrible people

/*
Crematorium Switch
*/
/obj/machinery/crema_switch/attack_hand(mob/user as mob)
	if(src.allowed(usr))
		for (var/obj/structure/bodycontainer/crematorium/C in crematoriums)
			if (C.id != id)
				continue

			C.cremate(user)
	else
		usr << "<span class='danger'>Access denied.</span>"
	return

/obj/machinery/crema_switch/attackby(obj/item/W as obj, mob/user as mob, params)
	if(W.GetID())
		attack_hand(user)
	else
		return ..()


/*
 * Generic Tray
 * Parent class for morguetray and crematoriumtray
 * For overriding only
 */
/obj/structure/tray
	icon = 'icons/obj/stationobjs.dmi'
	density = 1
	layer = 2.9
	var/obj/structure/bodycontainer/connected = null
	anchored = 1.0
	throwpass = 1

/obj/structure/tray/Destroy()
	if(connected)
		connected.connected = null
		connected.update_icon()
		connected = null
	..()

/obj/structure/tray/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/tray/attack_hand(mob/user as mob)
	if (src.connected)
		connected.close()
		add_fingerprint(user)
	else
		user << "<span class='warning'>That's not connected to anything!</span>"

/obj/structure/tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
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

