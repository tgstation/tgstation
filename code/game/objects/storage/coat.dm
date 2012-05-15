
/obj/item/clothing/suit/storage
	var/obj/screen/storage/boxes
	var/obj/screen/close/closer
	var/obj/slot1
	var/obj/slot2

/obj/item/clothing/suit/storage/New()
	src.boxes = new /obj/screen/storage(  )
	src.boxes.name = "storage"
	src.boxes.master = src
	src.boxes.icon_state = "block"
	src.boxes.screen_loc = "7,7 to 9,7"
	src.boxes.layer = 19
	src.closer = new /obj/screen/close(  )
	src.closer.master = src
	src.closer.icon_state = "x"
	src.closer.layer = 20
	src.closer.screen_loc = "9,7"

/obj/item/clothing/suit/storage/proc/view_inv(mob/user as mob)
	if(!user.client)
		return
	user.client.screen += src.boxes
	user.client.screen += src.closer
	user.client.screen += src.contents

/obj/item/clothing/suit/storage/proc/close(mob/user as mob)
	if(!user.client)
		return
	user.client.screen -= src.boxes
	user.client.screen -= src.closer
	user.client.screen -= src.contents

/obj/item/clothing/suit/storage/MouseDrop(atom/over_object)
	if(ishuman(usr))
		var/mob/living/carbon/human/M = usr
		if (!( istype(over_object, /obj/screen) ))
			return ..()
		playsound(src.loc, "rustle", 50, 1, -5)
		if ((!( M.restrained() ) && !( M.stat ) && M.wear_suit == src))
			if (over_object.name == "r_hand")
				if (!( M.r_hand ))
					M.u_equip(src)
					M.r_hand = src
			else
				if (over_object.name == "l_hand")
					if (!( M.l_hand ))
						M.u_equip(src)
						M.l_hand = src
			M.update_clothing()
			src.add_fingerprint(usr)
			return
		if(over_object == usr && in_range(src, usr) || usr.contents.Find(src))
			src.view_inv(M)
			src.orient_objs(7,7,9,7)
			return
	return

/obj/item/clothing/suit/storage/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W.w_class > 2 || src.loc == W )
		return
	if(istype(W,/obj/item/weapon/evidencebag) && src.loc != user)
		return
	if(src.contents.len >= 2)
		user << "\red There's nowhere to place that!"
		return
	user.u_equip(W)
	W.loc = src
	if ((user.client && user.s_active != src))
		user.client.screen -= W
	else if(user.s_active == src)
		close(user)
		view_inv(user)
		orient2hud(user)
	W.dropped(user)

/obj/item/clothing/suit/storage/attack_paw(mob/user as mob)
	playsound(src.loc, "rustle", 50, 1, -5)
	return attack_hand(user)

/obj/item/clothing/suit/storage/attack_hand(mob/user as mob)
	playsound(src.loc, "rustle", 50, 1, -5)
	if (src.loc == user)
		if (user.s_active)
			user.s_active.close(user)
		src.show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if (M.s_active == src)
				src.close(M)
	src.orient2hud(user)
	src.add_fingerprint(user)
	return

/obj/item/clothing/suit/storage/proc/orient2hud(mob/user as mob)
	if (src == user.l_hand)
		src.orient_objs(3, 4, 3, 3)
	else if (src == user.r_hand)
		src.orient_objs(1, 4, 1, 3)
	else if (istype(user,/mob/living/carbon/human) && src == user:wear_suit)
		src.orient_objs(1, 3, 2, 3)
	else
		src.orient_objs(4, 3, 4, 2)
	return

/obj/item/clothing/suit/storage/proc/orient_objs(tx, ty, mx, my)
	var/cx = tx
	var/cy = ty
	src.boxes.screen_loc = text("[tx],[ty] to [mx],[my]")
	for(var/obj/O in src.contents)
		O.screen_loc = text("[cx],[cy]")
		O.layer = 20
		cx++
		if (cx > mx)
			cx = tx
			cy--
	src.closer.screen_loc = text("[mx+1],[my]")
	return

/obj/item/clothing/suit/storage/proc/show_to(mob/user as mob)
	for(var/obj/item/weapon/mousetrap/MT in src)
		if(MT.armed)
			for(var/mob/O in viewers(user, null))
				if(O == user)
					user.show_message(text("\red <B>You reach into the [src.name], but there was a live mousetrap in there!</B>"), 1)
				else
					user.show_message(text("\red <B>[user] reaches into the [src.name] and sets off a hidden mousetrap!</B>"), 1)
			MT.loc = user.loc
			MT.triggered(user, user.hand ? "l_hand" : "r_hand")
			MT.layer = OBJ_LAYER
			return
	user.client.screen -= src.boxes
	user.client.screen -= src.closer
	user.client.screen -= src.contents
	user.client.screen += src.boxes
	user.client.screen += src.closer
	user.client.screen += src.contents
	user.s_active = src
	return

/*/obj/item/clothing/suit/storage/New()

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
		src.orient_objs(7, 8, 10, 7)
		return
	return

/obj/item/clothing/suit/storage/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(can_hold.len)
		var/ok = 0
		for(var/A in can_hold)
			if(istype(W, text2path(A) )) ok = 1
		if(!ok)
			user << "\red This container cannot hold [W]."
			return

	if (src.contents.len >= 7)
		return
	if ((W.w_class >= 3 || istype(W, /obj/item/weapon/storage) || src.loc == W))
		return
	user.u_equip(W)
	W.loc = src
	if ((user.client && user.s_active != src))
		user.client.screen -= W
	src.orient2hud(user)
	W.dropped(user)
	add_fingerprint(user)
	if (istype(W, /obj/item/weapon/gun/energy/crossbow)) return //STEALTHY
	for(var/mob/O in viewers(user, null))
		O.show_message(text("\blue [] has added [] to []!", user, W, src), 1)
		//Foreach goto(139)
	return

/obj/item/clothing/suit/storage/dropped(mob/user as mob)
	src.orient_objs(7, 8, 10, 7)
	return

/obj/item/clothing/suit/storage/MouseDrop(over_object, src_location, over_location)
	..()
	if ((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		if (usr.s_active)
			usr.s_active.close(usr)
		src.show_to(usr)
	return

/obj/item/clothing/suit/storage/attack_paw(mob/user as mob)
	playsound(src.loc, "rustle", 50, 1, -5)
	return src.attack_hand(user)
	return

/obj/item/clothing/suit/storage/attack_hand(mob/user as mob)
	playsound(src.loc, "rustle", 50, 1, -5)
	if (src.loc == user)
		if (user.s_active)
			user.s_active.close(user)
		src.show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if (M.s_active == src)
				src.close(M)
			//Foreach goto(76)
		src.orient2hud(user)
	src.add_fingerprint(user)
	return

/obj/item/clothing/suit/storage/proc/return_inv()

	var/list/L = list(  )

	L += src.contents

	for(var/obj/item/weapon/storage/S in src)
		L += S.return_inv()
	for(var/obj/item/weapon/gift/G in src)
		L += G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L += G.gift:return_inv()
	return L

/obj/item/clothing/suit/storage/proc/show_to(mob/user as mob)
	for(var/obj/item/weapon/mousetrap/MT in src)
		if(MT.armed)
			for(var/mob/O in viewers(user, null))
				if(O == user)
					user.show_message(text("\red <B>You reach into the [src.name], but there was a live mousetrap in there!</B>"), 1)
				else
					user.show_message(text("\red <B>[user] reaches into the [src.name] and sets off a hidden mousetrap!</B>"), 1)
			MT.loc = user.loc
			MT.triggered(user, user.hand ? "l_hand" : "r_hand")
			MT.layer = OBJ_LAYER
			return
	user.client.screen -= src.boxes
	user.client.screen -= src.closer
	user.client.screen -= src.contents
	user.client.screen += src.boxes
	user.client.screen += src.closer
	user.client.screen += src.contents
	user.s_active = src
	return

/obj/item/clothing/suit/storage/proc/hide_from(mob/user as mob)

	if(!user.client)
		return
	user.client.screen -= src.boxes
	user.client.screen -= src.closer
	user.client.screen -= src.contents
	return

/obj/item/clothing/suit/storage/proc/close(mob/user as mob)

	src.hide_from(user)
	user.s_active = null
	return

/obj/item/weapon/storage/proc/orient_objs(tx, ty, mx, my)

	var/cx = tx
	var/cy = ty
	src.boxes.screen_loc = text("[],[] to [],[]", tx, ty, mx, my)
	for(var/obj/O in src.contents)
		O.screen_loc = text("[],[]", cx, cy)
		O.layer = 20
		cx++
		if (cx > mx)
			cx = tx
			cy--
		//Foreach goto(56)
	src.closer.screen_loc = text("[],[]", mx, my)
	return
*/