/obj/item/weapon/storage
	icon = 'storage.dmi'
	name = "storage"
	var/list/can_hold = new/list() //List of objects which this item can store (if set, it can't store anything else)
	var/list/cant_hold = new/list() //List of objects which this item can't store (in effect only if can_hold isn't set)
	var/max_w_class = 2 //Max size of objects that this object can store (in effect only if can_hold isn't set)
	var/max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	var/storage_slots = 7 //The number of storage slots in this container.
	var/obj/screen/storage/boxes = null
	var/obj/screen/close/closer = null
	w_class = 3.0
	var/foldable = null	// BubbleWrap - if set, can be folded (when empty) into a sheet of cardboard

/obj/item/weapon/storage/proc/return_inv()

	var/list/L = list(  )

	L += src.contents

	for(var/obj/item/weapon/storage/S in src)
		L += S.return_inv()
	for(var/obj/item/weapon/gift/G in src)
		L += G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L += G.gift:return_inv()
	return L

/obj/item/weapon/storage/proc/show_to(mob/user as mob)
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

/obj/item/weapon/storage/proc/hide_from(mob/user as mob)

	if(!user.client)
		return
	user.client.screen -= src.boxes
	user.client.screen -= src.closer
	user.client.screen -= src.contents
	return

/obj/item/weapon/storage/proc/close(mob/user as mob)

	src.hide_from(user)
	user.s_active = null
	return

//This proc draws out the inventory and places the items on it. tx and ty are the upper left tile and mx, my are the bottm right.
//The numbers are calculated from the bottom-left (Right hand slot on the map) being 1,1.
/obj/item/weapon/storage/proc/orient_objs(tx, ty, mx, my)
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

//This proc determins the size of the inventory to be displayed. Please touch it only if you know what you're doing.
/obj/item/weapon/storage/proc/orient2hud(mob/user as mob)
	var/mob/living/carbon/human/H = user
	var/col_num = 0
	var/row_count = min(7,storage_slots) -1 //For belts, the meanings of the two variables are inverted, so we don't have to declare new ones
	if (contents.len > 7)
		col_num = round((contents.len-1) / 7) // 7 is the maximum allowed column height for r_hand, l_hand and back storage items.
	if (src == user.l_hand)
		src.orient_objs(3-col_num, 3+row_count, 3, 3)
	else if(src == user.r_hand)
		src.orient_objs(1, 3+row_count, 1+col_num, 3)
	else if(src == user.back)
		src.orient_objs(4-col_num, 3+row_count, 4, 3)
	else if(istype(user, /mob/living/carbon/human) && src == H.belt)//only humans have belts
		src.orient_objs(1, 3+col_num, 1+row_count, 3)
	else
		src.orient_objs(5, 10+col_num, 5 + row_count, 10)
	return

//This proc is called when you want to place an item into the storage item.
/obj/item/weapon/storage/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(isrobot(user))
		user << "\blue You're a robot. No."
		return //Robots can't interact with storage items.

	if(istype(W,/obj/item/weapon/evidencebag) && src.loc != user)
		return

	if(src.loc == W)
		return //Means the item is already in the storage item

	if(contents.len >= storage_slots)
		user << "\red The [src] is full, make some space."
		return //Storage item is full

	if(can_hold.len)
		var/ok = 0
		for(var/A in can_hold)
			if(istype(W, text2path(A) ))
				ok = 1
				break
		if(!ok)
			user << "\red This [src] cannot hold [W]."
			return

	for(var/A in cant_hold) //Check for specific items which this container can't hold.
		if(istype(W, text2path(A) ))
			user << "\red This [src] cannot hold [W]."
			return

	if (W.w_class > max_w_class)
		user << "\red This [W] is too big for this [src]"
		return

	if(istype(W, /obj/item/weapon/tray))
		var/obj/item/weapon/tray/T = W
		if(T.calc_carry() > 0)
			if(prob(85))
				user << "\red The tray won't fit in [src]."
				return
			else

				W.loc = user.loc
				if ((user.client && user.s_active != src))
					user.client.screen -= W
				W.dropped(user)
				user << "\red God damnit!"

	var/sum_w_class = W.w_class
	for(var/obj/item/I in contents)
		sum_w_class += I.w_class //Adds up the combined w_classes which will be in the storage item if the item is added to it.

	if(sum_w_class > max_combined_w_class)
		user << "\red The [src] is full, make some space."
		return

	if(W.w_class >= src.w_class && (istype(W, /obj/item/weapon/storage)))
		if(!istype(src, /obj/item/weapon/storage/backpack/holding))	//bohs should be able to hold backpacks again. The override for putting a boh in a boh is in backpack.dm.
			user << "\red The [src] cannot hold [W] as it's a storage item of the same size."
			return //To prevent the stacking of the same sized items.

	user.u_equip(W)
	W.loc = src
	if ((user.client && user.s_active != src))
		user.client.screen -= W
	src.orient2hud(user)
	W.dropped(user)
	add_fingerprint(user)

	if(istype(src, /obj/item/weapon/storage/backpack/santabag)) // update the santa bag icon
		if(contents.len < 5)
			src.icon_state = "giftbag0"
		else if(contents.len >= 5 && contents.len < 15)
			src.icon_state = "giftbag1"
		else if(contents.len >= 15)
			src.icon_state = "giftbag2"

	if (istype(W, /obj/item/weapon/gun/energy/crossbow)) return //STEALTHY
	for(var/mob/O in viewers(user, null))
		O.show_message(text("\blue [user] has added [W] to [src]!"))
		//Foreach goto(139)
	return

/obj/item/weapon/storage/dropped(mob/user as mob)
	var/col_num = 0
	var/row_count = min(7,storage_slots) -1
	if (contents.len > 7)
		col_num = round((contents.len-1) / 7) // 7 is the maximum allowed column height for r_hand, l_hand and back storage items.
	src.orient_objs(5, 10+col_num, 5 + row_count, 10)
	return

/obj/item/weapon/storage/MouseDrop(over_object, src_location, over_location)
	..()
	if ((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		if (usr.s_active)
			usr.s_active.close(usr)
		src.show_to(usr)
	return

/obj/item/weapon/storage/attack_paw(mob/user as mob)
	//playsound(src.loc, "rustle", 50, 1, -5) // what
	return src.attack_hand(user)

/obj/item/weapon/storage/attack_hand(mob/user as mob)
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

/obj/item/weapon/storage/New()

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
		var/col_num = 0
		var/row_count = min(7,storage_slots) -1
		if (contents.len > 7)
			if(contents.len % 7)
				col_num = round(contents.len / 7) // 7 is the maximum allowed column height for r_hand, l_hand and back storage items.
		src.orient_objs(5, 10+col_num, 5 + row_count, 10)
		return
	return

/obj/item/weapon/storage/emp_act(severity)
	if(!istype(src.loc, /mob/living))
		for(var/obj/O in contents)
			O.emp_act(severity)
	..()

/obj/screen/storage/attackby(W, mob/user as mob)
	src.master.attackby(W, user)
	return
// BubbleWrap - A box can be folded up to make card
/obj/item/weapon/storage/attack_self(mob/user as mob)
	if ( contents.len )
		return
	if ( !ispath(src.foldable) )
		return
	var/found = 0
	// Close any open UI windows first
	for(var/mob/M in range(1))
		if (M.s_active == src)
			src.close(M)
		if ( M == user )
			found = 1
	if ( !found )	// User is too far away
		return
	// Now make the cardboard
	user << "\blue You fold [src] flat."
	new src.foldable(get_turf(src))
	del(src)
//BubbleWrap END

/obj/item/weapon/storage/box/
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/box/survival/New()
	..()
	contents = list()
	sleep(1)
	new /obj/item/clothing/mask/breath( src )
	new /obj/item/weapon/tank/emergency_oxygen( src )
	return

/obj/item/weapon/storage/box/engineer/New()
	..()
	contents = list()
	sleep(1)
	new /obj/item/clothing/mask/breath( src )
	new /obj/item/weapon/tank/emergency_oxygen/engi( src )
	return

/obj/item/weapon/storage/box/medic/New()
	..()
	contents = list()
	sleep(1)
	new /obj/item/clothing/mask/medical( src )
	new /obj/item/weapon/tank/emergency_oxygen/anesthetic( src )
	new /obj/item/weapon/tank/emergency_oxygen/anesthetic( src )
	new /obj/item/weapon/tank/emergency_oxygen/anesthetic( src )
	new /obj/item/weapon/tank/emergency_oxygen/anesthetic( src )
	new /obj/item/weapon/tank/emergency_oxygen/anesthetic( src )
	new /obj/item/weapon/tank/emergency_oxygen/anesthetic( src )
	return

/obj/item/weapon/storage/box/ert/New()
	..()
	contents = list()
	sleep(1)
	new /obj/item/weapon/reagent_containers/glass/bottle/ert/cryo( src )
	new /obj/item/weapon/reagent_containers/glass/bottle/ert/cryo( src )
	new /obj/item/weapon/reagent_containers/glass/bottle/ert/cryo( src )
	new /obj/item/weapon/reagent_containers/glass/bottle/ert/quikheal( src )
	new /obj/item/weapon/reagent_containers/glass/bottle/ert/quikheal( src )
	new /obj/item/weapon/reagent_containers/glass/bottle/ert/boost( src )
	new /obj/item/weapon/reagent_containers/glass/bottle/ert/boost( src )
	return

/obj/item/weapon/storage/box/syndicate/New()
	..()
	switch (pickweight(list("bloodyspai" = 1, "stealth" = 1, "screwed" = 1, "guns" = 1, "freedom" = 1)))
		if ("bloodyspai")
			new /obj/item/clothing/under/chameleon(src)
			new /obj/item/clothing/mask/gas/voice(src)
			new /obj/item/weapon/card/id/syndicate(src)
			new /obj/item/clothing/shoes/syndigaloshes(src)
			return

		if ("stealth")
			new /obj/item/weapon/gun/energy/crossbow(src)
			new /obj/item/weapon/pen/paralysis(src)
			new /obj/item/device/chameleon(src)
			return

		if ("screwed")
			new /obj/effect/spawner/newbomb/timer/syndicate(src)
			new /obj/effect/spawner/newbomb/timer/syndicate(src)
			new /obj/item/device/powersink(src)
			new /obj/item/clothing/suit/space/syndicate(src)
			new /obj/item/clothing/head/helmet/space/syndicate(src)
			return

		if ("guns")
			new /obj/item/weapon/gun/projectile(src)
			new /obj/item/ammo_magazine/a357(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/weapon/plastique(src)
			return

		if("freedom")
			var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
			O.imp = new /obj/item/weapon/implant/freedom(O)
			var/obj/item/weapon/implanter/U = new /obj/item/weapon/implanter(src)
			U.imp = new /obj/item/weapon/implant/uplink(U)
			return

/obj/item/weapon/storage/dice/New()
	new /obj/item/weapon/dice( src )
	new /obj/item/weapon/dice/d20( src )
	..()
	return

/obj/item/weapon/storage/mousetraps/New()
	new /obj/item/weapon/mousetrap( src )
	new /obj/item/weapon/mousetrap( src )
	new /obj/item/weapon/mousetrap( src )
	new /obj/item/weapon/mousetrap( src )
	new /obj/item/weapon/mousetrap( src )
	new /obj/item/weapon/mousetrap( src )
	..()
	return

/obj/item/weapon/storage/pill_bottle/MouseDrop(obj/over_object as obj) //Quick pillbottle fix. -Agouri

	if (ishuman(usr) || ismonkey(usr)) //Can monkeys even place items in the pocket slots? Leaving this in just in case~
		var/mob/M = usr
		if (!( istype(over_object, /obj/screen) ))
			return ..()
		if ((!( M.restrained() ) && !( M.stat ) /*&& M.pocket == src*/))
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
			if (usr.s_active)
				usr.s_active.close(usr)
			src.show_to(usr)
			return
	return   ///////////////////////////////////////////////////////Alright, that should do it. *MARKER* for any possible runtimes

/obj/item/weapon/storage/pillbottlebox/New()
	new /obj/item/weapon/storage/pill_bottle( src )
	new /obj/item/weapon/storage/pill_bottle( src )
	new /obj/item/weapon/storage/pill_bottle( src )
	new /obj/item/weapon/storage/pill_bottle( src )
	new /obj/item/weapon/storage/pill_bottle( src )
	new /obj/item/weapon/storage/pill_bottle( src )
	new /obj/item/weapon/storage/pill_bottle( src )
	..()
	return

////////////////////////////////////////////////////////////////////////////////
