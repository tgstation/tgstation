/obj/structure/closet/secure_closet/can_open()
	..()
	if(src.locked)
		return 0
	return 1

/obj/structure/closet/secure_closet/close()
	..()
	if(broken)
		icon_state = src.icon_off
	return 1

/obj/structure/closet/secure_closet/emp_act(severity)
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

/obj/structure/closet/secure_closet/proc/togglelock(mob/user as mob)
	if(src.allowed(user))
		src.locked = !src.locked
		for(var/mob/O in viewers(user, 3))
			if((O.client && !( O.blinded )))
				O << "<span class='notice'>The locker has been [locked ? null : "un"]locked by [user].</span>"
		if(src.locked)
			src.icon_state = src.icon_locked
		else
			src.icon_state = src.icon_closed
	else
		user << "<span class='notice'>Access Denied</span>"

/obj/structure/closet/secure_closet/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(src.opened)
		if(istype(W, /obj/item/weapon/grab))
			if(src.large)
				src.MouseDrop_T(W:affecting, user)	//act like they were dragged onto the closet
			else
				user << "<span class='notice'>The locker is too small to stuff [W] into!</span>"
		user.drop_item()
		if(W)
			W.loc = src.loc
	else if(src.broken)
		user << "<span class='notice'>The locker appears to be broken.</span>"
		return
	else if((istype(W, /obj/item/weapon/card/emag)||istype(W, /obj/item/weapon/melee/energy/blade)) && !src.broken)
		broken = 1
		locked = 0
		desc = "It appears to be broken."
		icon_state = icon_off
		flick(icon_broken, src)
		if(istype(W, /obj/item/weapon/melee/energy/blade))
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, src.loc)
			spark_system.start()
			playsound(src.loc, 'blade1.ogg', 50, 1)
			playsound(src.loc, "sparks", 50, 1)
			for(var/mob/O in viewers(user, 3))
				O.show_message("<span class='warning'>The locker has been sliced open by [user] with an energy blade!</span>", 1, "You hear metal being sliced and sparks flying.", 2)
		else
			for(var/mob/O in viewers(user, 3))
				O.show_message("<span class='warning'>The locker has been broken by [user] with an electromagnetic card!</span>", 1, "You hear a faint electrical spark.", 2)
	else
		togglelock(user)

/obj/structure/closet/secure_closet/relaymove(mob/user as mob)
	if(user.stat)
		return

	if(user.stat)
		return
	if(!(src.locked))
		for(var/obj/item/I in src)
			I.loc = src.loc
		for(var/mob/M in src)
			M.loc = src.loc
			if(M.client)
				M.client.eye = M.client.mob
				M.client.perspective = MOB_PERSPECTIVE
		src.icon_state = src.icon_opened
		src.opened = 1
	else
		user << "<span class='notice'>The locker is welded shut!</span>"
		if(world.time > lastbang+5)
			lastbang = world.time
			for(var/mob/M in hearers(src, null))
				M << text("<FONT size=[]>BANG, bang!</FONT>", max(0, 5 - get_dist(src, M)))
	return

/obj/structure/closet/secure_closet/attack_hand(mob/user as mob)
	src.add_fingerprint(user)

	if(!src.toggle())
		return src.attackby(null, user)

/obj/structure/closet/secure_closet/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/closet/secure_closet/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Toggle Lock"

	if(!usr.canmove || usr.stat || usr.restrained()) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return

	if(get_dist(usr, src) != 1)
		return

	if(src.broken)
		return

	if (ishuman(usr))
		if (!opened)
			togglelock(usr)
	else
		usr << "<span class='warning'>This mob type can't use this verb.</span>"