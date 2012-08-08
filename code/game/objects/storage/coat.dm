/obj/item/clothing/suit/storage
	var/list/can_hold = new/list() //List of objects which this item can store (if set, it can't store anything else)
	var/list/cant_hold = new/list() //List of objects which this item can't store (in effect only if can_hold isn't set)
	var/max_w_class = 2 //Max size of objects that this object can store (in effect only if can_hold isn't set)
	var/max_combined_w_class = 4 //The sum of the w_classes of all the items in this storage item.
	var/storage_slots = 2 //The number of storage slots in this container.
	var/obj/screen/storage/boxes = null
	var/obj/screen/close/closer = null

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

//This proc draws out the inventory and places the items on it. tx and ty are the upper left tile and mx, my are the bottm right.
//The numbers are calculated from the bottom-left The bottom-left slot being 1,1.
/obj/item/clothing/suit/storage/proc/orient_objs(tx, ty, mx, my)
	var/cx = tx
	var/cy = ty
	src.boxes.screen_loc = text("[tx]:,[ty] to [mx],[my]")
	for(var/obj/O in src.contents)
		O.screen_loc = text("[cx],[cy]")
		O.layer = 20
		cx++
		if (cx > mx)
			cx = tx
			cy--
	src.closer.screen_loc = text("[mx+1],[my]")
	return

//This proc draws out the inventory and places the items on it. It uses the standard position.
/obj/item/clothing/suit/storage/proc/standard_orient_objs(var/rows,var/cols)
	var/cx = 4
	var/cy = 2+rows
	src.boxes.screen_loc = text("4:16,2:16 to [4+cols]:16,[2+rows]:16")
	for(var/obj/O in src.contents)
		O.screen_loc = text("[cx]:16,[cy]:16")
		O.layer = 20
		cx++
		if (cx > (4+cols))
			cx = 4
			cy--
	src.closer.screen_loc = text("[4+cols+1]:16,2:16")
	return

//This proc determins the size of the inventory to be displayed. Please touch it only if you know what you're doing.
/obj/item/clothing/suit/storage/proc/orient2hud(mob/user as mob)
	//var/mob/living/carbon/human/H = user
	var/row_num = 0
	var/col_count = min(7,storage_slots) -1
	if (contents.len > 7)
		row_num = round((contents.len-1) / 7) // 7 is the maximum allowed width.
	src.standard_orient_objs(row_num,col_count)
	return

//This proc is called when you want to place an item into the storage item.
/obj/item/clothing/suit/storage/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/evidencebag) && src.loc != user)
		return

	..()
	if(isrobot(user))
		user << "\blue You're a robot. No."
		return //Robots can't interact with storage items.

	if(src.loc == W)
		return //Means the item is already in the storage item

	if(contents.len >= storage_slots)
		user << "\red \The [src] is full, make some space."
		return //Storage item is full

	if(can_hold.len)
		var/ok = 0
		for(var/A in can_hold)
			if(istype(W, text2path(A) ))
				ok = 1
				break
		if(!ok)
			user << "\red \The [src] cannot hold \the [W]."
			return

	for(var/A in cant_hold) //Check for specific items which this container can't hold.
		if(istype(W, text2path(A) ))
			user << "\red \The [src] cannot hold \the [W]."
			return

	if (W.w_class > max_w_class)
		user << "\red \The [W] is too big for \the [src]"
		return

	var/sum_w_class = W.w_class
	for(var/obj/item/I in contents)
		sum_w_class += I.w_class //Adds up the combined w_classes which will be in the storage item if the item is added to it.

	if(sum_w_class > max_combined_w_class)
		user << "\red \The [src] is full, make some space."
		return

	if(W.w_class >= src.w_class && (istype(W, /obj/item/weapon/storage)))
		if(!istype(src, /obj/item/weapon/storage/backpack/holding))	//bohs should be able to hold backpacks again. The override for putting a boh in a boh is in backpack.dm.
			user << "\red \The [src] cannot hold \the [W] as it's a storage item of the same size."
			return //To prevent the stacking of the same sized items.

	user.u_equip(W)
	W.loc = src
	if ((user.client && user.s_active != src))
		user.client.screen -= W
	src.orient2hud(user)
	W.dropped(user)
	add_fingerprint(user)



/obj/item/weapon/storage/dropped(mob/user as mob)
	return

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
		if( (over_object == usr && in_range(src, usr) || usr.contents.Find(src)) && usr.s_active)
			usr.s_active.close(usr)
		src.show_to(usr)
	return

/obj/item/clothing/suit/storage/attack_paw(mob/user as mob)
	//playsound(src.loc, "rustle", 50, 1, -5) // what
	return src.attack_hand(user)

/obj/item/clothing/suit/storage/attack_hand(mob/user as mob)
	playsound(src.loc, "rustle", 50, 1, -5)
	src.orient2hud(user)
	if (src.loc == user)
		if (user.s_active)
			user.s_active.close(user)
		src.show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if (M.s_active == src)
				src.close(M)
	src.add_fingerprint(user)
	return

/obj/item/clothing/suit/storage/New()

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
	orient2hud()
	return

/obj/item/weapon/storage/emp_act(severity)
	if(!istype(src.loc, /mob/living))
		for(var/obj/O in contents)
			O.emp_act(severity)
	..()