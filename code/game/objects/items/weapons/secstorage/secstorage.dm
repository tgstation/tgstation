/obj/item/weapon/secstorage
	name = "secstorage"
	var/obj/screen/storage/boxes = null
	var/obj/screen/close/closer = null
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_opened = "secure0"
	var/locked = 1
	var/code = ""
	var/l_code = null
	var/l_set = 0
	var/l_setshort = 0
	var/l_hacking = 0
	var/emagged = 0
	var/open = 0
	var/internalstorage = 3
	w_class = 3.0

/obj/item/weapon/secstorage/examine()
	set src in oview(1)

	..()
	usr << text("The service panel is [src.open ? "open" : "closed"].")
	return

/obj/item/weapon/secstorage/proc/return_inv()

	var/list/L = list(  )

	L += src.contents

	for(var/obj/item/weapon/secstorage/S in src)
		L += S.return_inv()
	for(var/obj/item/weapon/gift/G in src)
		L += G.gift
		if (istype(G.gift, /obj/item/weapon/secstorage))
			L += G.gift:return_inv()
	return L

/obj/item/weapon/secstorage/proc/show_to(mob/user as mob)

	user.client.screen -= src.boxes
	user.client.screen -= src.closer
	user.client.screen -= src.contents
	user.client.screen += src.boxes
	user.client.screen += src.closer
	user.client.screen += src.contents
	user.s_active = src
	return

/obj/item/weapon/secstorage/proc/hide_from(mob/user as mob)

	if(!user.client)
		return
	user.client.screen -= src.boxes
	user.client.screen -= src.closer
	user.client.screen -= src.contents
	return

/obj/item/weapon/secstorage/proc/close(mob/user as mob)

	src.hide_from(user)
	user.s_active = null
	return

/obj/item/weapon/secstorage/proc/orient_objs(tx, ty, mx, my)

	var/cx = tx
	var/cy = ty
	src.boxes.screen_loc = "[tx],[ty] to [mx],[my]"
	for(var/obj/O in src.contents)
		O.screen_loc = "[cx],[cy]"
		O.layer = 20
		cx++
		if (cx > mx)
			cx = tx
			cy--
		//Foreach goto(56)
	src.closer.screen_loc = "[mx],[my]"
	return

//This proc draws out the inventory and places the items on it. It uses the standard position.
/obj/item/weapon/secstorage/proc/standard_orient_objs()
	var/rows = 0
	var/cols = 6
	var/cx = 4
	var/cy = 2+rows
	src.boxes.screen_loc = "4:16,2:16 to [4+cols]:16,[2+rows]:16"
	for(var/obj/O in src.contents)
		O.screen_loc = "[cx]:16,[cy]:16"
		O.layer = 20
		cx++
		if (cx > (4+cols))
			cx = 4
			cy--
	src.closer.screen_loc = "11:16,2:16"
	return

/obj/item/weapon/secstorage/proc/orient2hud(mob/user as mob)
	standard_orient_objs()
	return

/obj/item/weapon/secstorage/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ( (istype(W, /obj/item/weapon/card/emag)||istype(W, /obj/item/weapon/melee/energy/blade)) && (src.locked == 1) && (!src.emagged))
		emagged = 1
		src.overlays += image('icons/obj/storage.dmi', icon_sparking)
		sleep(6)
		src.overlays = null
		overlays += image('icons/obj/storage.dmi', icon_locking)
		locked = 0
		if(istype(W, /obj/item/weapon/melee/energy/blade))
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, src.loc)
			spark_system.start()
			playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
			playsound(src.loc, "sparks", 50, 1)
			user << "You slice through the lock on [src]."
		else
			user << "You short out the lock on [src]."
		return
	if ((W.w_class > internalstorage || istype(W, /obj/item/weapon/secstorage)))
		return
	if ((istype(W, /obj/item/weapon/screwdriver)) && (src.locked == 1))
		sleep(6)
		src.open =! src.open
		user.show_message(text("\blue You [] the service panel.", (src.open ? "open" : "close")))
		return
	if ((istype(W, /obj/item/device/multitool)) && (src.open == 1) && (src.locked ==1) && (!src.l_hacking))
		user.show_message(text("\red Now attempting to reset internal memory, please hold."), 1)
		src.l_hacking = 1
		if (do_after(usr, 100))
			if (prob(40))
				src.l_setshort = 1
				src.l_set = 0
				user.show_message(text("\red Internal memory reset.  Please give it a few seconds to reinitialize."), 1)
				sleep(80)
				src.l_setshort = 0
				src.l_hacking = 0
			else
				user.show_message(text("\red Unable to reset internal memory."), 1)
				src.l_hacking = 0
		else	src.l_hacking = 0
		return
	if (src.contents.len >= 7)
		return
	if (src.locked == 1)
		return
	user.u_equip(W)
	W.loc = src
	if ((user.client && user.s_active != src))
		user.client.screen -= W
	src.orient2hud(user)
	W.dropped(user)
	add_fingerprint(user)
	//if (istype(W, /obj/item/weapon/gun/energy/crossbow)) return //STEALTHY
	for(var/mob/O in viewers(user, null))
		O.show_message(text("\blue [] has added [] to []!", user, W, src), 1)
		//Foreach goto(139)
	return

/obj/item/weapon/secstorage/dropped(mob/user as mob)

	standard_orient_objs()
	return

/obj/item/weapon/secstorage/MouseDrop(over_object, src_location, over_location)
	..()
	if (src.locked == 1)
		return

	orient2hud(usr)
	if ((over_object == usr && ((get_dist(src, usr) <= 1 ||src.locked == 0) || usr.contents.Find(src))))  //|| usr.telekinesis == 1
		if (usr.s_active)
			usr.s_active.close(usr)
		src.show_to(usr)
	return

/obj/item/weapon/secstorage/attack_paw(mob/user as mob)
	playsound(src.loc, "rustle", 50, 1, -5)
	return src.attack_hand(user)
	return

/obj/item/weapon/secstorage/attack_hand(mob/user as mob)
	if ((src.loc == user) && (src.locked == 1))
		usr << "\red [src] is locked and cannot be opened!"
	else if ((src.loc == user) && (!src.locked))
		playsound(src.loc, "rustle", 50, 1, -5)
		if (user.s_active == src)
			user.s_active.close(user) //Close and re-open
			src.show_to(user)
		else
			user.s_active.close(user) //Just close
	else
		..()
		for(var/mob/M in range(1))
			if (M.s_active == src)
				src.close(M)
		src.orient2hud(user)
	src.add_fingerprint(user)
	return

/obj/item/weapon/secstorage/attack_self(mob/user as mob)
	user.machine = src
	var/dat = text("<TT><B>[]</B><BR>\n\nLock Status: []",src, (src.locked ? "LOCKED" : "UNLOCKED"))
	var/message = "Code"
	if ((src.l_set == 0) && (!src.emagged) && (!src.l_setshort))
		dat += text("<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>")
	if (src.emagged)
		dat += text("<p>\n<font color=red><b>LOCKING SYSTEM ERROR - 1701</b></font>")
	if (src.l_setshort)
		dat += text("<p>\n<font color=red><b>ALERT: MEMORY SYSTEM ERROR - 6040 201</b></font>")
	message = text("[]", src.code)
	if (!src.locked)
		message = "*****"
	dat += text("<HR>\n>[]<BR>\n<A href='?src=\ref[];type=1'>1</A>-<A href='?src=\ref[];type=2'>2</A>-<A href='?src=\ref[];type=3'>3</A><BR>\n<A href='?src=\ref[];type=4'>4</A>-<A href='?src=\ref[];type=5'>5</A>-<A href='?src=\ref[];type=6'>6</A><BR>\n<A href='?src=\ref[];type=7'>7</A>-<A href='?src=\ref[];type=8'>8</A>-<A href='?src=\ref[];type=9'>9</A><BR>\n<A href='?src=\ref[];type=R'>R</A>-<A href='?src=\ref[];type=0'>0</A>-<A href='?src=\ref[];type=E'>E</A><BR>\n</TT>", message, src, src, src, src, src, src, src, src, src, src, src, src)
	user << browse(dat, "window=caselock;size=300x280")

/obj/item/weapon/secstorage/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
		return
	if (href_list["type"])
		if (href_list["type"] == "E")
			if ((src.l_set == 0) && (length(src.code) == 5) && (!src.l_setshort) && (src.code != "ERROR"))
				src.l_code = src.code
				src.l_set = 1
			else if ((src.code == src.l_code) && (src.emagged == 0) && (src.l_set == 1))
				src.locked = 0
				src.overlays = null
				overlays += image('icons/obj/storage.dmi', icon_opened)
				src.code = null
			else
				src.code = "ERROR"
		else
			if ((href_list["type"] == "R") && (src.emagged == 0) && (!src.l_setshort))
				src.locked = 1
				src.overlays = null
				src.code = null
				src.close(usr)
			else
				src.code += text("[]", href_list["type"])
				if (length(src.code) > 5)
					src.code = "ERROR"
		src.add_fingerprint(usr)
		for(var/mob/M in viewers(1, src.loc))
			if ((M.client && M.machine == src))
				src.attack_self(M)
			return
	return

/obj/item/weapon/secstorage/New()

	src.boxes = new /obj/screen/storage(  )
	src.boxes.name = "storage"
	src.boxes.master = src
	src.boxes.icon_state = "block"
	src.boxes.screen_loc = "7,7 to 10,8"
	src.boxes.layer = 19
	src.closer = new /obj/screen/close(  )
	src.closer.master = src
	src.closer.icon_state = "x"
	src.closer.layer = 20
	spawn( 5 )
		standard_orient_objs()
		return
 	return
