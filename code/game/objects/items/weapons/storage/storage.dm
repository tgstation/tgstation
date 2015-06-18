// To clarify:
// For use_to_pickup and allow_quick_gather functionality,
// see item/attackby() (/game/objects/items.dm)
// Do not remove this functionality without good reason, cough reagent_containers cough.
// -Sayu


/obj/item/weapon/storage
	name = "storage"
	icon = 'icons/obj/storage.dmi'
	w_class = 3.0
	var/list/can_hold = new/list() //List of objects which this item can store (if set, it can't store anything else)
	var/list/cant_hold = new/list() //List of objects which this item can't store (in effect only if can_hold isn't set)
	var/list/is_seeing = new/list() //List of mobs which are currently seeing the contents of this item's storage
	var/max_w_class = 2 //Max size of objects that this object can store (in effect only if can_hold isn't set)
	var/max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	var/storage_slots = 7 //The number of storage slots in this container.
	var/obj/screen/storage/boxes = null
	var/obj/screen/close/closer = null
	var/use_to_pickup	//Set this to make it possible to use this item in an inverse way, so you can have the item in your hand and click items on the floor to pick them up.
	var/display_contents_with_number	//Set this to make the storage item group contents of the same type and display them as a number.
	var/allow_quick_empty	//Set this variable to allow the object to have the 'empty' verb, which dumps all the contents on the floor.
	var/allow_quick_gather	//Set this variable to allow the object to have the 'toggle mode' verb, which quickly collects all items from a tile.
	var/collection_mode = 1;  //0 = pick one at a time, 1 = pick all on tile, 2 = pick all of a type
	var/preposition = "in" // You put things 'in' a bag, but trays need 'on'.


/obj/item/weapon/storage/MouseDrop(atom/over_object)
	if(iscarbon(usr) || isdrone(usr)) //all the check for item manipulation are in other places, you can safely open any storages as anything and its not buggy, i checked
		var/mob/M = usr

		if(!over_object)
			return

		if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
			return

		if(over_object == M && Adjacent(M)) // this must come before the screen objects only block
			orient2hud(M)					// dunno why it wasn't before
			if(M.s_active)
				M.s_active.close(M)
			show_to(M)
			return

		if(!( M.restrained() ) && !( M.stat ))
			if(!( istype(over_object, /obj/screen) ))
				return content_can_dump(over_object, M)

			if(!(loc == usr) || (loc && loc.loc == usr))
				return

			playsound(loc, "rustle", 50, 1, -5)
			switch(over_object.name)
				if("r_hand")
					if(!M.unEquip(src))
						return
					M.put_in_r_hand(src)
				if("l_hand")
					if(!M.unEquip(src))
						return
					M.put_in_l_hand(src)
			add_fingerprint(usr)

//Check if this storage can dump the items
/obj/item/weapon/storage/proc/content_can_dump(atom/dest_object, mob/user)
	if(Adjacent(user) && dest_object.Adjacent(user))
		if(dest_object.storage_contents_dump_act(src, user))
			playsound(loc, "rustle", 50, 1, -5)
			return 1
	return 0

//Object behaviour on storage dump
/obj/item/weapon/storage/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	dump_act(src_object, user)
	orient2hud(user)
	src_object.orient2hud(user)
	if(user.s_active) //refresh the HUD to show the transfered contents
		user.s_active.close(user)
		user.s_active.show_to(user)
	return 1

//Specific storage transfer behaviour for Storage
/obj/item/weapon/storage/dump_act(obj/item/weapon/storage/src_object, mob/user)
	for(var/obj/item/I in src_object)
		if(can_be_inserted(I,0,user))
			src_object.dump_from_storage(I, src)

//dump Single item from storage, + dump item reaction
/obj/item/weapon/storage/proc/dump_from_storage(obj/item/I, atom/dest_object)
	remove_from_storage(I, dest_object)
	//For item behaviour on dump : I.dump()

/obj/item/weapon/storage/proc/return_inv()
	var/list/L = list()
	L += contents

	for(var/obj/item/weapon/storage/S in src)
		L += S.return_inv()
	return L


/obj/item/weapon/storage/proc/show_to(mob/user)
	if(user.s_active != src && (user.stat == CONSCIOUS))
		for(var/obj/item/I in src)
			if(I.on_found(user))
				return
	if(user.s_active)
		user.s_active.hide_from(user)
	user.client.screen -= boxes
	user.client.screen -= closer
	user.client.screen -= contents
	user.client.screen += boxes
	user.client.screen += closer
	user.client.screen += contents
	user.s_active = src
	is_seeing |= user


/obj/item/weapon/storage/throw_at(atom/target, range, speed)
	close_all()
	return ..()


/obj/item/weapon/storage/proc/hide_from(mob/user)
	if(!user.client)
		return
	user.client.screen -= boxes
	user.client.screen -= closer
	user.client.screen -= contents
	if(user.s_active == src)
		user.s_active = null
	is_seeing -= user


/obj/item/weapon/storage/proc/can_see_contents()
	var/list/cansee = list()
	for(var/mob/M in is_seeing)
		if(M.s_active == src && M.client)
			cansee |= M
		else
			is_seeing -= M
	return cansee


/obj/item/weapon/storage/proc/close(mob/user)
	hide_from(user)
	user.s_active = null


/obj/item/weapon/storage/proc/close_all()
	for(var/mob/M in can_see_contents())
		close(M)
		. = 1 //returns 1 if any mobs actually got a close(M) call


//This proc draws out the inventory and places the items on it. tx and ty are the upper left tile and mx, my are the bottm right.
//The numbers are calculated from the bottom-left The bottom-left slot being 1,1.
/obj/item/weapon/storage/proc/orient_objs(tx, ty, mx, my)
	var/cx = tx
	var/cy = ty
	boxes.screen_loc = "[tx]:,[ty] to [mx],[my]"
	for(var/obj/O in contents)
		O.screen_loc = "[cx],[cy]"
		O.layer = 20
		cx++
		if(cx > mx)
			cx = tx
			cy--
	closer.screen_loc = "[mx+1],[my]"


//This proc draws out the inventory and places the items on it. It uses the standard position.
/obj/item/weapon/storage/proc/standard_orient_objs(rows, cols, list/obj/item/display_contents)
	var/cx = 4
	var/cy = 2+rows
	boxes.screen_loc = "4:16,2:16 to [4+cols]:16,[2+rows]:16"

	if(display_contents_with_number)
		for(var/datum/numbered_display/ND in display_contents)
			ND.sample_object.screen_loc = "[cx]:16,[cy]:16"
			ND.sample_object.maptext = "<font color='white'>[(ND.number > 1)? "[ND.number]" : ""]</font>"
			ND.sample_object.layer = 20
			cx++
			if(cx > (4+cols))
				cx = 4
				cy--
	else
		for(var/obj/O in contents)
			O.screen_loc = "[cx]:16,[cy]:16"
			O.maptext = ""
			O.layer = 20
			cx++
			if(cx > (4+cols))
				cx = 4
				cy--
	closer.screen_loc = "[4+cols+1]:16,2:16"


/datum/numbered_display
	var/obj/item/sample_object
	var/number

	New(obj/item/sample)
		if(!istype(sample))
			del(src)
		sample_object = sample
		number = 1


//This proc determins the size of the inventory to be displayed. Please touch it only if you know what you're doing.
/obj/item/weapon/storage/proc/orient2hud(mob/user)
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
	if(adjusted_contents > 7)
		row_num = round((adjusted_contents-1) / 7) // 7 is the maximum allowed width.
	standard_orient_objs(row_num, col_count, numbered_contents)


//This proc return 1 if the item can be picked up and 0 if it can't.
//Set the stop_messages to stop it from printing messages
/obj/item/weapon/storage/proc/can_be_inserted(obj/item/W, stop_messages = 0, mob/user)
	if(!istype(W) || (W.flags & ABSTRACT)) return //Not an item

	if(loc == W)
		return 0 //Means the item is already in the storage item
	if(contents.len >= storage_slots)
		if(!stop_messages)
			usr << "<span class='warning'>[src] is full, make some space!</span>"
		return 0 //Storage item is full

	if(can_hold.len)
		var/ok = 0
		for(var/A in can_hold)
			if(istype(W, A))
				ok = 1
				break
		if(!ok)
			if(!stop_messages)
				usr << "<span class='warning'>[src] cannot hold [W]!</span>"
			return 0

	for(var/A in cant_hold) //Check for specific items which this container can't hold.
		if(istype(W, A))
			if(!stop_messages)
				usr << "<span class='warning'>[src] cannot hold [W]!</span>"
			return 0

	if(W.w_class > max_w_class)
		if(!stop_messages)
			usr << "<span class='warning'>[W] is too big for [src]!</span>"
		return 0

	var/sum_w_class = W.w_class
	for(var/obj/item/I in contents)
		sum_w_class += I.w_class //Adds up the combined w_classes which will be in the storage item if the item is added to it.

	if(sum_w_class > max_combined_w_class)
		if(!stop_messages)
			usr << "<span class='warning'>[src] is full, make some space!</span>"
		return 0

	if(W.w_class >= w_class && (istype(W, /obj/item/weapon/storage)))
		if(!istype(src, /obj/item/weapon/storage/backpack/holding))	//bohs should be able to hold backpacks again. The override for putting a boh in a boh is in backpack.dm.
			if(!stop_messages)
				usr << "<span class='warning'>[src] cannot hold [W] as it's a storage item of the same size!</span>"
			return 0 //To prevent the stacking of same sized storage items.

	if(W.flags & NODROP) //SHOULD be handled in unEquip, but better safe than sorry.
		usr << "<span class='warning'>\the [W] is stuck to your hand, you can't put it in \the [src]!</span>"
		return 0

	return 1


//This proc handles items being inserted. It does not perform any checks of whether an item can or can't be inserted. That's done by can_be_inserted()
//The stop_warning parameter will stop the insertion message from being displayed. It is intended for cases where you are inserting multiple items at once,
//such as when picking up all the items on a tile with one click.
/obj/item/weapon/storage/proc/handle_item_insertion(obj/item/W, prevent_warning = 0, mob/user)
	if(!istype(W)) return 0
	if(usr)
		if(!usr.unEquip(W))
			return 0
	W.loc = src
	W.on_enter_storage(src)
	if(usr)
		if(usr.client && usr.s_active != src)
			usr.client.screen -= W

		add_fingerprint(usr)

		if(!prevent_warning && !istype(W, /obj/item/weapon/gun/energy/kinetic_accelerator/crossbow))
			for(var/mob/M in viewers(usr, null))
				if(M == usr)
					usr << "<span class='notice'>You put [W] [preposition]to [src].</span>"
				else if(in_range(M, usr)) //If someone is standing close enough, they can tell what it is...
					M.show_message("<span class='notice'>[usr] puts [W] [preposition]to [src].</span>", 1)
				else if(W && W.w_class >= 3.0) //Otherwise they can only see large or normal items from a distance...
					M.show_message("<span class='notice'>[usr] puts [W] [preposition]to [src].</span>", 1)

		orient2hud(usr)
		for(var/mob/M in can_see_contents())
			show_to(M)
	update_icon()
	return 1


//Call this proc to handle the removal of an item from the storage item. The item will be moved to the atom sent as new_target
/obj/item/weapon/storage/proc/remove_from_storage(obj/item/W, atom/new_location)
	if(!istype(W)) return 0

	if(istype(src, /obj/item/weapon/storage/fancy))
		var/obj/item/weapon/storage/fancy/F = src
		F.update_icon(1)

	for(var/mob/M in can_see_contents())
		if(M.client)
			M.client.screen -= W

	if(ismob(loc))
		W.dropped(usr)
	W.layer = initial(W.layer)
	W.loc = new_location

	if(usr)
		orient2hud(usr)
		if(usr.s_active)
			usr.s_active.show_to(usr)
	if(W.maptext)
		W.maptext = ""
	W.on_exit_storage(src)
	update_icon()
	return 1


//This proc is called when you want to place an item into the storage item.
/obj/item/weapon/storage/attackby(obj/item/W, mob/user, params)
	..()

	if(isrobot(user))
		user << "<span class='warning'>You're a robot. No.</span>"
		return 0	//Robots can't interact with storage items.

	if(!can_be_inserted(W, 0 , user))
		return 0

	handle_item_insertion(W, 0 , user)
	return 1


/obj/item/weapon/storage/dropped(mob/user)
	return

/obj/item/weapon/storage/attack_hand(mob/user)
	playsound(loc, "rustle", 50, 1, -5)

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

	orient2hud(user)
	if(loc == user)
		if(user.s_active)
			user.s_active.close(user)
		show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if(M.s_active == src)
				close(M)
	add_fingerprint(user)

/obj/item/weapon/storage/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/weapon/storage/verb/toggle_gathering_mode()
	set name = "Switch Gathering Method"
	set category = "Object"

	if(usr.stat || !usr.canmove || usr.restrained())
		return

	collection_mode = (collection_mode+1)%3
	switch (collection_mode)
		if(2)
			usr << "[src] now picks up all items of a single type at once."
		if(1)
			usr << "[src] now picks up all items in a tile at once."
		if(0)
			usr << "[src] now picks up one item at a time."

// Empty all the contents onto the current turf
/obj/item/weapon/storage/verb/quick_empty()
	set name = "Empty Contents"
	set category = "Object"

	if((!ishuman(usr) && (loc != usr)) || usr.stat || usr.restrained() ||!usr.canmove)
		return

	do_quick_empty()

// Empty all the contents onto the current turf, without checking the user's status.
/obj/item/weapon/storage/proc/do_quick_empty()
	var/turf/T = get_turf(src)
	if(usr)
		hide_from(usr)
	for(var/obj/item/I in contents)
		remove_from_storage(I, T)


/obj/item/weapon/storage/New()
	..()
	if(allow_quick_empty)
		verbs += /obj/item/weapon/storage/verb/quick_empty
	else
		verbs -= /obj/item/weapon/storage/verb/quick_empty

	if(allow_quick_gather)
		verbs += /obj/item/weapon/storage/verb/toggle_gathering_mode
	else
		verbs -= /obj/item/weapon/storage/verb/toggle_gathering_mode

	boxes = new /obj/screen/storage()
	boxes.name = "storage"
	boxes.master = src
	boxes.icon_state = "block"
	boxes.screen_loc = "7,7 to 10,8"
	boxes.layer = 19
	closer = new /obj/screen/close()
	closer.master = src
	closer.icon_state = "x"
	closer.layer = 20
	orient2hud()


/obj/item/weapon/storage/Destroy()
	close_all()
	qdel(boxes)
	qdel(closer)
	..()


/obj/item/weapon/storage/emp_act(severity)
	if(!istype(loc, /mob/living))
		for(var/obj/O in contents)
			O.emp_act(severity)
	..()


/obj/item/weapon/storage/attack_self(mob/user)
	//Clicking on itself will empty it, if it has the verb to do that.
	if(user.get_active_hand() == src)
		if(verbs.Find(/obj/item/weapon/storage/verb/quick_empty))
			quick_empty()

