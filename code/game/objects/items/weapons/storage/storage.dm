/obj/item/weapon/storage
	icon = 'icons/obj/storage.dmi'
	name = "storage"
	var/list/can_hold = new/list() //List of objects which this item can store (if set, it can't store anything else)
	var/list/cant_hold = new/list() //List of objects which this item can't store (in effect only if can_hold isn't set)
	var/max_w_class = 2 //Max size of objects that this object can store (in effect only if can_hold isn't set)
	var/max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	var/storage_slots = 7 //The number of storage slots in this container.
	var/obj/screen/storage/boxes = null
	var/obj/screen/close/closer = null
	var/use_to_pickup	//Set this to make it possible to use this item in an inverse way, so you can have the item in your hand and click items on the floor to pick them up.
	var/display_contents_with_number	//Set this to make the storage item group contents of the same type and display them as a number.
	var/allow_quick_empty	//Set this variable to allow the object to have the 'empty' verb, which dumps all the contents on the floor.
	var/allow_quick_gather	//Set this variable to allow the object to have the 'toggle mode' verb, which quickly collects all items from a tile.
	var/collection_mode = 1;  //0 = pick one at a time, 1 = pick all on tile
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
	if(user.s_active != src)
		for(var/obj/item/I in src)
			if(I.on_found(user))
				return
	if(user.s_active)
		user.s_active.hide_from(user)
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
	if(user.s_active == src)
		user.s_active = null
	return

/obj/item/weapon/storage/proc/close(mob/user as mob)

	src.hide_from(user)
	user.s_active = null
	return

//This proc draws out the inventory and places the items on it. tx and ty are the upper left tile and mx, my are the bottm right.
//The numbers are calculated from the bottom-left The bottom-left slot being 1,1.
/obj/item/weapon/storage/proc/orient_objs(tx, ty, mx, my)
	var/cx = tx
	var/cy = ty
	src.boxes.screen_loc = "[tx]:,[ty] to [mx],[my]"
	for(var/obj/O in src.contents)
		O.screen_loc = "[cx],[cy]"
		O.layer = 20
		cx++
		if (cx > mx)
			cx = tx
			cy--
	src.closer.screen_loc = "[mx+1],[my]"
	return

//This proc draws out the inventory and places the items on it. It uses the standard position.
/obj/item/weapon/storage/proc/standard_orient_objs(var/rows, var/cols, var/list/obj/item/display_contents)
	var/cx = 4
	var/cy = 2+rows
	src.boxes.screen_loc = "4:16,2:16 to [4+cols]:16,[2+rows]:16"

	if(display_contents_with_number)
		for(var/datum/numbered_display/ND in display_contents)
			ND.sample_object.screen_loc = "[cx]:16,[cy]:16"
			ND.sample_object.maptext = "<font color='white'>[(ND.number > 1)? "[ND.number]" : ""]</font>"
			ND.sample_object.layer = 20
			cx++
			if (cx > (4+cols))
				cx = 4
				cy--
	else
		for(var/obj/O in contents)
			O.screen_loc = "[cx]:16,[cy]:16"
			O.maptext = ""
			O.layer = 20
			cx++
			if (cx > (4+cols))
				cx = 4
				cy--
	src.closer.screen_loc = "[4+cols+1]:16,2:16"
	return

/datum/numbered_display
	var/obj/item/sample_object
	var/number

	New(obj/item/sample as obj)
		if(!istype(sample))
			del(src)
		sample_object = sample
		number = 1

//This proc determins the size of the inventory to be displayed. Please touch it only if you know what you're doing.
/obj/item/weapon/storage/proc/orient2hud(mob/user as mob)

	var/adjusted_contents = contents.len

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(display_contents_with_number)
		numbered_contents = list()
		adjusted_contents = 0
		for(var/obj/item/I in contents)
			var/found = 0
			for(var/datum/numbered_display/ND in numbered_contents)
				if(ND.sample_object.type == I.type)
					ND.number++
					found = 1
					break
			if(!found)
				adjusted_contents++
				numbered_contents.Add( new/datum/numbered_display(I) )

	//var/mob/living/carbon/human/H = user
	var/row_num = 0
	var/col_count = min(7,storage_slots) -1
	if (adjusted_contents > 7)
		row_num = round((adjusted_contents-1) / 7) // 7 is the maximum allowed width.
	src.standard_orient_objs(row_num, col_count, numbered_contents)
	return

//This proc return 1 if the item can be picked up and 0 if it can't.
//Set the stop_messages to stop it from printing emssages
/obj/item/weapon/storage/proc/can_be_inserted(obj/item/W as obj, stop_messages = 0)
	if(!istype(W)) return //Not an item

	if(src.loc == W)
		return 0 //Means the item is already in the storage item
	if(contents.len >= storage_slots)
		if(!stop_messages)
			usr << "\red The [src] is full, make some space."
		return 0 //Storage item is full

	if(can_hold.len)
		var/ok = 0
		for(var/A in can_hold)
			if(istype(W, text2path(A) ))
				ok = 1
				break
		if(!ok)
			if(!stop_messages)
				usr << "\red This [src] cannot hold [W]."
			return 0

	for(var/A in cant_hold) //Check for specific items which this container can't hold.
		if(istype(W, text2path(A) ))
			if(!stop_messages)
				usr << "\red This [src] cannot hold [W]."
			return 0

	if (W.w_class > max_w_class)
		if(!stop_messages)
			usr << "\red This [W] is too big for this [src]"
		return 0

	var/sum_w_class = W.w_class
	for(var/obj/item/I in contents)
		sum_w_class += I.w_class //Adds up the combined w_classes which will be in the storage item if the item is added to it.

	if(sum_w_class > max_combined_w_class)
		if(!stop_messages)
			usr << "\red The [src] is full, make some space."
		return 0

	if(W.w_class >= src.w_class && (istype(W, /obj/item/weapon/storage)))
		if(!istype(src, /obj/item/weapon/storage/backpack/holding))	//bohs should be able to hold backpacks again. The override for putting a boh in a boh is in backpack.dm.
			if(!stop_messages)
				usr << "\red The [src] cannot hold [W] as it's a storage item of the same size."
			return 0 //To prevent the stacking of same sized storage items.

	return 1

//This proc handles items being inserted. It does not perform any checks of whether an item can or can't be inserted. That's done by can_be_inserted()
//The stop_warning parameter will stop the insertion message from being displayed. It is intended for cases where you are inserting multiple items at once,
//such as when picking up all the items on a tile with one click.
/obj/item/weapon/storage/proc/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	if(!istype(W)) return
	if(usr)
		usr.u_equip(W)
		usr.update_icons()	//update our overlays
	W.loc = src
	W.on_enter_storage(src)
	if(usr)
		if (usr.client && usr.s_active != src)
			usr.client.screen -= W
		W.dropped(usr)
		add_fingerprint(usr)

		if(!prevent_warning && !istype(W, /obj/item/weapon/gun/energy/crossbow))
			for(var/mob/M in viewers(usr, null))
				if (M == usr)
					usr << "\blue You put the [W] into [src]."
				else if (M in range(1)) //If someone is standing close enough, they can tell what it is...
					M.show_message("\blue [usr] puts [W] into [src].")
				else if (W && W.w_class >= 3.0) //Otherwise they can only see large or normal items from a distance...
					M.show_message("\blue [usr] puts [W] into [src].")

		src.orient2hud(usr)
		if(usr.s_active)
			usr.s_active.show_to(usr)
	update_icon()

//Call this proc to handle the removal of an item from the storage item. The item will be moved to the atom sent as new_target
/obj/item/weapon/storage/proc/remove_from_storage(obj/item/W as obj, atom/new_location)
	if(!istype(W)) return

	if(istype(src, /obj/item/weapon/storage/fancy))
		var/obj/item/weapon/storage/fancy/F = src
		F.update_icon(1)

	for(var/mob/M in range(1, src.loc))
		if (M.s_active == src.loc)
			if (M.client)
				M.client.screen -= src

	if(new_location)
		if(ismob(loc))
			W.dropped(usr)
		if(ismob(new_location))
			W.layer = 20
		else
			W.layer = initial(W.layer)
		W.loc = new_location
	else
		W.loc = get_turf(src)

	if(usr)
		src.orient2hud(usr)
		if(usr.s_active)
			usr.s_active.show_to(usr)
	if(W.maptext)
		W.maptext = ""
	W.on_exit_storage(src)
	update_icon()

//This proc is called when you want to place an item into the storage item.
/obj/item/weapon/storage/attackby(obj/item/W as obj, mob/user as mob)
	..()

	if(isrobot(user))
		user << "\blue You're a robot. No."
		return //Robots can't interact with storage items.

	if(!can_be_inserted(W))
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

	handle_item_insertion(W)
	return

/obj/item/weapon/storage/dropped(mob/user as mob)
	return

/obj/item/weapon/storage/MouseDrop(over_object, src_location, over_location)
	..()
	orient2hud(usr)
	if ((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		if (usr.s_active)
			usr.s_active.close(usr)
		src.show_to(usr)
	return

/obj/item/weapon/storage/attack_hand(mob/user as mob)
	playsound(src.loc, "rustle", 50, 1, -5)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.l_store == src && !H.get_active_hand())	//Prevents opening if it's in a pocket.
			H.put_in_hands(src)
			H.l_store = null
			return
		if(H.r_store == src && !H.get_active_hand())
			H.put_in_hands(src)
			H.r_store = null
			return

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

/obj/item/weapon/storage/verb/toggle_gathering_mode()
	set name = "Switch Gathering Method"
	set category = "Object"

	collection_mode = !collection_mode
	switch (collection_mode)
		if(1)
			usr << "The [src] now picks up all ore in a tile at once."
		if(0)
			usr << "The [src] now picks up one ore at a time."


/obj/item/weapon/storage/verb/quick_empty()
	set name = "Empty Contents"
	set category = "Object"

	if(!ishuman(usr) || usr.stat || usr.restrained())
		return

	var/turf/T = get_turf(src)
	for(var/obj/item/I in contents)
		remove_from_storage(I, T)

/obj/item/weapon/storage/New()

	if(allow_quick_empty)
		verbs += /obj/item/weapon/storage/verb/quick_empty
	else
		verbs -= /obj/item/weapon/storage/verb/quick_empty

	if(allow_quick_gather)
		verbs += /obj/item/weapon/storage/verb/toggle_gathering_mode
	else
		verbs -= /obj/item/weapon/storage/verb/toggle_gathering_mode

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

// BubbleWrap - A box can be folded up to make card
/obj/item/weapon/storage/attack_self(mob/user as mob)

	//Clicking on itself will empty it, if it has the verb to do that.
	if(user.get_active_hand() == src)
		if(src.verbs.Find(/obj/item/weapon/storage/verb/quick_empty))
			src.quick_empty()
			return

	//Otherwise we'll try to fold it.
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

/obj/item/weapon/storage/box/syndicate/New()
	..()
	switch (pickweight(list("bloodyspai" = 1, "stealth" = 1, "screwed" = 1, "guns" = 1, "murder" = 1, "freedom" = 1, "hacker" = 1, "lordsingulo" = 1)))
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

		if ("murder")
			new /obj/item/weapon/melee/energy/sword(src)
			new /obj/item/clothing/glasses/thermal/syndi(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/clothing/shoes/syndigaloshes(src)
			return

		if("freedom")
			var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
			O.imp = new /obj/item/weapon/implant/freedom(O)
			var/obj/item/weapon/implanter/U = new /obj/item/weapon/implanter(src)
			U.imp = new /obj/item/weapon/implant/uplink(U)
			return

		if ("hacker")
			new /obj/item/weapon/aiModule/syndicate(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/device/encryptionkey/binary(src)
			return

		if ("lordsingulo")
			new /obj/item/device/radio/beacon/syndicate(src)
			new /obj/item/clothing/suit/space/syndicate(src)
			new /obj/item/clothing/head/helmet/space/syndicate(src)
			new /obj/item/weapon/card/emag(src)
			return

/obj/item/weapon/storage/dice/New()
	new /obj/item/weapon/dice( src )
	new /obj/item/weapon/dice/d20( src )
	..()
	return

/obj/item/weapon/storage/mousetraps/New()
	new /obj/item/device/assembly/mousetrap( src )
	new /obj/item/device/assembly/mousetrap( src )
	new /obj/item/device/assembly/mousetrap( src )
	new /obj/item/device/assembly/mousetrap( src )
	new /obj/item/device/assembly/mousetrap( src )
	new /obj/item/device/assembly/mousetrap( src )
	..()
	return

/obj/item/weapon/storage/pill_bottle/MouseDrop(obj/over_object as obj) //Quick pillbottle fix. -Agouri

	if (ishuman(usr) || ismonkey(usr)) //Can monkeys even place items in the pocket slots? Leaving this in just in case~
		var/mob/M = usr
		if (!( istype(over_object, /obj/screen) ))
			return ..()
		if ((!( M.restrained() ) && !( M.stat ) /*&& M.pocket == src*/))
			switch(over_object.name)
				if("r_hand")
					M.u_equip(src)
					M.put_in_r_hand(src)
				if("l_hand")
					M.u_equip(src)
					M.put_in_l_hand(src)
			src.add_fingerprint(usr)
			return
		if(over_object == usr && in_range(src, usr) || usr.contents.Find(src))
			if (usr.s_active)
				usr.s_active.close(usr)
			src.show_to(usr)
			return
	return   ///////////////////////////////////////////////////////Alright, that should do it. *MARKER* for any possible runtimes


/obj/item/weapon/storage/pill_bottle/verb/toggle_mode()
	set name = "Switch Pill Bottle Method"
	set category = "Object"

	mode = !mode
	switch (mode)
		if(1)
			usr << "The pill bottle now picks up all pills in a tile at once."
		if(0)
			usr << "The pill bottle now picks up one pill at a time."

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