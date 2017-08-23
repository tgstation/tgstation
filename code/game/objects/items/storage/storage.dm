// External storage-related logic:
// /mob/proc/ClickOn() in /_onclick/click.dm - clicking items in storages
// /mob/living/Move() in /modules/mob/living/living.dm - hiding storage boxes on mob movement
// /item/attackby() in /game/objects/items.dm - use_to_pickup and allow_quick_gather functionality
// -- c0


/obj/item/storage
	name = "storage"
	icon = 'icons/obj/storage.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	var/silent = FALSE // No message on putting items in
	var/list/can_hold = list() //Typecache of objects which this item can store (if set, it can't store anything else)
	var/list/cant_hold = list() //Typecache of objects which this item can't store
	var/list/is_seeing = list() //List of mobs which are currently seeing the contents of this item's storage
	var/max_w_class = WEIGHT_CLASS_SMALL //Max size of objects that this object can store (in effect only if can_hold isn't set)
	var/max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	var/storage_slots = 7 //The number of storage slots in this container.
	var/obj/screen/storage/boxes
	var/obj/screen/close/closer
	var/use_to_pickup = FALSE	//Set this to make it possible to use this item in an inverse way, so you can have the item in your hand and click items on the floor to pick them up.
	var/display_contents_with_number = FALSE	//Set this to make the storage item group contents of the same type and display them as a number.
	var/allow_quick_empty = FALSE	//Set this variable to allow the object to have the 'empty' verb, which dumps all the contents on the floor.
	var/allow_quick_gather = FALSE	//Set this variable to allow the object to have the 'toggle mode' verb, which quickly collects all items from a tile.
	var/collection_mode = COLLECTION_MODE_ALL;  //0 = pick one at a time, 1 = pick all on tile, 2 = pick all of a type
	var/preposition = "in" // You put things 'in' a bag, but trays need 'on'.
	var/rustle_jimmies = TRUE	//Play the rustle sound on insertion

/obj/item/storage/Initialize()
	. = ..()

	can_hold = typecacheof(can_hold)
	cant_hold = typecacheof(cant_hold)

	if(allow_quick_empty)
		verbs += /obj/item/storage/verb/quick_empty
	else
		verbs -= /obj/item/storage/verb/quick_empty

	if(allow_quick_gather)
		verbs += /obj/item/storage/verb/toggle_gathering_mode
	else
		verbs -= /obj/item/storage/verb/toggle_gathering_mode

	boxes = new
	boxes.name = "storage"
	boxes.master = src
	boxes.icon_state = "block"
	boxes.screen_loc = "7,7 to 10,8"
	boxes.layer = HUD_LAYER
	boxes.plane = HUD_PLANE
	closer = new
	closer.master = src
	closer.icon_state = "backpack_close"
	closer.layer = ABOVE_HUD_LAYER
	closer.plane = ABOVE_HUD_PLANE
	orient2hud()

	PopulateContents()

/obj/item/weapon/storage/Destroy()
	for(var/obj/O in src)
		O.mouse_opacity = initial(O.mouse_opacity)

	close_all()
	QDEL_NULL(boxes)
	QDEL_NULL(closer)
	return ..()

/obj/item/storage/MouseDrop(atom/over_object)

	if(!ismob(usr)) //all the check for item manipulation are in other places, you can safely open any storages as anything and its not buggy, i checked
		return
	var/mob/M = usr

	if (istype(M.loc, /obj/mecha)) // stops inventory actions in a mech
		return

	// this must come before the screen objects only block, dunno why it wasn't before
	if(over_object == M && M.CanReach(src, view_only = TRUE))
		orient2hud(M)
		if(M.s_active)
			M.s_active.close(M)
		show_to(M)
		return

	if(M.incapacitated())
		return

	if(!istype(over_object, /obj/screen))
		return dump_content_at(over_object, M)

	var/atom/L = loc
	if(L != usr || (L && L.loc == M))
		return

	if(rustle_jimmies)
		playsound(src, "rustle", 50, 1, -5)

	if(istype(over_object, /obj/screen/inventory/hand))
		var/obj/screen/inventory/hand/H = over_object
		M.putItemFromInventoryInHandIfPossible(src, H.held_index)

	add_fingerprint(M)

/obj/item/storage/MouseDrop_T(atom/movable/O, mob/living/user)
	if(!isitem(O))
		return
	var/obj/item/I = O
	if(!iscarbon(user) && !isdrone(user))
		return
	var/mob/living/L = user
	if(!L.incapacitated() && I == L.get_active_held_item() && can_be_inserted(I, FALSE))
		handle_item_insertion(I, FALSE, L)

/obj/item/storage/get_dumping_location(obj/item/storage/source, mob/living/user)
	return src

//Tries to dump content
/obj/item/storage/proc/dump_content_at(atom/dest_object, mob/living/user)
	var/atom/dump_destination = dest_object.get_dumping_location()
	. = Adjacent(user) && dump_destination && user.Adjacent(dump_destination) && dump_destination.storage_contents_dump_act(src, user))
	if(.)
		playsound(src, "rustle", 50, 1, -5)

//Object behaviour on storage dump
/obj/item/storage/storage_contents_dump_act(obj/item/storage/src_object, mob/living/user)
	var/list/things = src_object.contents.Copy()
	var/datum/progressbar/progress = new(user, things.len, src)
	while (do_after(user, 10, TRUE, src, FALSE, CALLBACK(src, .proc/handle_mass_item_insertion, things, src_object, user, progress)))
		sleep(1)
	qdel(progress)
	orient2hud(user)
	src_object.orient2hud(user)
	if(user.s_active) //refresh the HUD to show the transfered contents
		user.s_active.close(user)
		user.s_active.show_to(user)
	return TRUE

/obj/item/storage/proc/handle_mass_item_insertion(list/things, obj/item/storage/src_object, mob/living/user, datum/progressbar/progress)
	var/number_of_things = things.len
	for(var/obj/item/I in things)
		--number_of_things
		if(I.loc != src_object)
			continue
		if(user.s_active != src_object && I.on_found(user))
			break
		if(can_be_inserted(I, FALSE, user))
			handle_item_insertion(I, TRUE, user)
		if (TICK_CHECK)
			progress.update(progress.goal - number_of_things)
			return TRUE

	progress.update(progress.goal - number_of_things)
	return FALSE

/obj/item/storage/proc/return_inv()
	. = contents.Copy()
	for(var/obj/item/storage/S in src)
		. += S.return_inv()

/obj/item/storage/proc/show_to(mob/user)
	if(!user.client)
		return
	if(user.s_active != src && (user.stat == CONSCIOUS))
		for(var/obj/item/I in src)
			if(I.on_found(user))
				return
	if(user.s_active)
		user.s_active.hide_from(user)
	user.client.screen |= list(boxes, user.client.screen, contents)
	user.s_active = src
	is_seeing |= user

/obj/item/storage/throw_at(atom/target, range, speed, mob/living/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback)
	close_all()
	return ..()

/obj/item/storage/proc/hide_from(mob/user)
	if(!user.client)
		return
	user.client.screen -= boxes
	user.client.screen -= closer
	user.client.screen -= contents
	if(user.s_active == src)
		user.s_active = null
	is_seeing -= user

/obj/item/weapon/proc/can_see_contents()
	. = list()
	for(var/mob/M in is_seeing)
		if(M.s_active == src && M.client)
			. |= M
		else
			is_seeing -= M

/obj/item/storage/proc/close(mob/user)
	hide_from(user)
	user.s_active = null

/obj/item/storage/proc/close_all()
	. = FALSE
	for(var/mob/M in can_see_contents())
		close(M)
		. = TRUE //returns TRUE if any mobs actually got a close(M) call

//This proc draws out the inventory and places the items on it. tx and ty are the upper left tile and mx, my are the bottm right.
//The numbers are calculated from the bottom-left The bottom-left slot being 1,1.
/obj/item/storage/proc/orient_objs(tx, ty, mx, my)
	var/cx = tx
	var/cy = ty
	boxes.screen_loc = "[tx]:,[ty] to [mx],[my]"
	for(var/obj/O in src)
		O.screen_loc = "[cx],[cy]"
		O.layer = ABOVE_HUD_LAYER
		O.plane = ABOVE_HUD_PLANE
		cx++
		if(cx > mx)
			cx = tx
			cy--
	closer.screen_loc = "[mx+1],[my]"

//This proc draws out the inventory and places the items on it. It uses the standard position.
/obj/item/storage/proc/standard_orient_objs(rows, cols, list/obj/item/display_contents)
	var/cx = 4
	var/cy = 2+rows
	boxes.screen_loc = "4:16,2:16 to [4+cols]:16,[2+rows]:16"

	if(display_contents_with_number)
		for(var/datum/numbered_display/ND in display_contents)
			ND.sample_object.mouse_opacity = MOUSE_OPACITY_OPAQUE
			ND.sample_object.screen_loc = "[cx]:16,[cy]:16"
			ND.sample_object.maptext = "<font color='white'>[(ND.number > 1)? "[ND.number]" : ""]</font>"
			ND.sample_object.layer = ABOVE_HUD_LAYER
			ND.sample_object.plane = ABOVE_HUD_PLANE
			cx++
			if(cx > (4+cols))
				cx = 4
				cy--
	else
		for(var/obj/O in src)
			O.mouse_opacity = MOUSE_OPACITY_OPAQUE //This is here so storage items that spawn with contents correctly have the "click around item to equip"
			O.screen_loc = "[cx]:16,[cy]:16"
			O.maptext = ""
			O.layer = ABOVE_HUD_LAYER
			O.plane = ABOVE_HUD_PLANE
			cx++
			if(cx > (4+cols))
				cx = 4
				cy--
	closer.screen_loc = "[4+cols+1]:16,2:16"

/datum/numbered_display
	var/obj/item/sample_object
	var/number = 1

/datum/numbered_display/New(obj/item/sample)
	sample_object = sample

//This proc determines the size of the inventory to be displayed. Please touch it only if you know what you're doing.
/obj/item/storage/proc/orient2hud(mob/user)
	var/adjusted_contents = contents.len

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(display_contents_with_number)
		numbered_contents = list()
		adjusted_contents = 0
		for(var/obj/item/I in src)
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

//This proc return TRUE if the item can be picked up and FALSE if it can't.
//Set the stop_messages to stop it from printing messages
/obj/item/storage/proc/can_be_inserted(obj/item/W, stop_messages = FALSE, mob/user)
	if(!istype(W) || (W.flags_1 & ABSTRACT_1))
		return FALSE //Not an item

	if(loc == W)
		return 0 //Means the item is already in the storage item
	if(contents.len >= storage_slots)
		if(!stop_messages)
			to_chat(user, "<span class='warning'>[src] is full, make some space!</span>")
		return FALSE //Storage item is full

	if(can_hold.len && !is_type_in_typecache(W, can_hold))
		if(!stop_messages)
			to_chat(user, "<span class='warning'>[src] cannot hold [W]!</span>")
		return FALSE

	if(is_type_in_typecache(W, cant_hold)) //Check for specific items which this container can't hold.
		if(!stop_messages)
			to_chat(user, "<span class='warning'>[src] cannot hold [W]!</span>")
		return FALSE

	if(W.w_class > max_w_class)
		if(!stop_messages)
			to_chat(user, "<span class='warning'>[W] is too big for [src]!</span>")
		return FALSE

	var/sum_w_class = W.w_class
	for(var/obj/item/I in src)
		sum_w_class += I.w_class //Adds up the combined w_classes which will be in the storage item if the item is added to it.

	if(sum_w_class > max_combined_w_class)
		if(!stop_messages)
			to_chat(user, "<span class='warning'>[W] won't fit in [src], make some space!</span>")
		return FALSE

	if(W.w_class >= w_class && istype(W, /obj/item/weapon/storage) && !istype(src, /obj/item/weapon/storage/backpack/holding))	//bohs should be able to hold backpacks again. The override for putting a boh in a boh is in backpack.dm.
		if(!stop_messages)
			to_chat(user, "<span class='warning'>[src] cannot hold [W] as it's a storage item of the same size!</span>")
		return FALSE //To prevent the stacking of same sized storage items.

	if(W.flags_1 & NODROP_1) //SHOULD be handled in unEquip, but better safe than sorry.
		to_chat(user, "<span class='warning'>[W] is stuck to your hand, you can't put it in [src]!</span>")
		return FALSE

	return TRUE

//This proc handles items being inserted. It does not perform any checks of whether an item can or can't be inserted. That's done by can_be_inserted()
//The stop_warning parameter will stop the insertion message from being displayed. It is intended for cases where you are inserting multiple items at once,
//such as when picking up all the items on a tile with one click.
/obj/item/storage/proc/handle_item_insertion(obj/item/W, prevent_warning = FALSE, mob/user)
	if(!istype(W))
		return FALSE
	if(user)
		if(!user.transferItemToLoc(W, src))
			return FALSE
	else
		W.forceMove(src)
	if(silent)
		prevent_warning = TRUE
	if(W.pulledby)
		W.pulledby.stop_pulling()
	W.on_enter_storage(src)
	if(user)
		if(user.client && user.s_active != src)
			user.client.screen -= W
		for(var/M in user.observers)
			var/mob/dead/observe = M
			if(observe.client && observe.s_active != src)
				observe.client.screen -= W

		add_fingerprint(user)
		if(rustle_jimmies && !prevent_warning)
			playsound(src, "rustle", 50, 1, -5)

		if(!prevent_warning)
			for(var/mob/M in viewers(usr, null))
				if(M == user)
					to_chat(user, "<span class='notice'>You put [W] [preposition]to [src].</span>")
				else if(in_range(M, usr)) //If someone is standing close enough, they can tell what it is...
					M.show_message("<span class='notice'>[user] puts [W] [preposition]to [src].</span>", 1)
				else if(W && W.w_class >= 3) //Otherwise they can only see large or normal items from a distance...
					M.show_message("<span class='notice'>[user] puts [W] [preposition]to [src].</span>", 1)

		orient2hud(user)
		for(var/mob/M in can_see_contents())
			show_to(M)
	W.mouse_opacity = MOUSE_OPACITY_OPAQUE //So you can click on the area around the item to equip it, instead of having to pixel hunt
	update_icon()
	return TRUE

//Call this proc to handle the removal of an item from the storage item. The item will be moved to the atom sent as new_target
/obj/item/storage/proc/remove_from_storage(obj/item/W, atom/new_location)
	if(!istype(W))
		return FALSE

	if(istype(src, /obj/item/storage/fancy))
		var/obj/item/storage/fancy/F = src
		F.update_icon(TRUE)

	for(var/mob/M in can_see_contents())
		if(M.client)
			M.client.screen -= W

	var/atom/L = loc
	if(ismob(L))
		var/mob/M = L
		W.dropped(M)
	W.layer = initial(W.layer)
	W.plane = initial(W.plane)
	W.forceMove(new_location)

	for(var/mob/M in can_see_contents())
		orient2hud(M)
		show_to(M)

	if(W.maptext)
		W.maptext = ""
	W.on_exit_storage(src)
	update_icon()
	W.mouse_opacity = initial(W.mouse_opacity)
	return TRUE

/obj/item/storage/deconstruct(disassembled = TRUE)
	var/drop_loc = loc
	if(ismob(drop_loc))
		drop_loc = get_turf(src)
	for(var/obj/item/I in src)
		remove_from_storage(I, drop_loc)
	qdel(src)

//This proc is called when you want to place an item into the storage item.
/obj/item/storage/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/hand_labeler))
		var/obj/item/hand_labeler/labeler = W
		if(labeler.mode)
			return FALSE
	. = TRUE //no afterattack
	if(iscyborg(user))
		return	//Robots can't interact with storage items.

	if(!can_be_inserted(W, FALSE, user))
		if(contents.len >= storage_slots) //don't use items on the backpack if they don't fit
			return
		return FALSE

	handle_item_insertion(W, FALSE, user)

/obj/item/storage/AllowDrop()
	return TRUE

/obj/item/storage/attack_hand(mob/living/user)
	var/atom/L = loc
	if(user.s_active == src && L == user) //if you're already looking inside the storage item
		user.s_active.close(user)
		close(user)
		return

	if(rustle_jimmies)
		playsound(src, "rustle", 50, 1, -5)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.l_store == src && !H.get_active_held_item())	//Prevents opening if it's in a pocket.
			H.put_in_hands(src)
			H.l_store = null
			return
		if(H.r_store == src && !H.get_active_held_item())
			H.put_in_hands(src)
			H.r_store = null
			return

	orient2hud(user)
	if(L == user)
		if(user.s_active)
			user.s_active.close(user)
		show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if(M.s_active == src)
				close(M)
	add_fingerprint(user)

/obj/item/storage/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/storage/verb/toggle_gathering_mode()
	set name = "Switch Gathering Method"
	set category = "Object"

	if(usr.incapacitated())
		return

	switch (collection_mode)
		if(COLLECTION_MODE_ALL)
			collection_mode = COLLECTION_MODE_TYPE
			to_chat(usr, "[src] now picks up all items of a single type at once.")
		if(COLLECTION_MODE_ONE)
			collection_mode = COLLECTION_MODE_ALL
			to_chat(usr, "[src] now picks up all items in a tile at once.")
		if(COLLECTION_MODE_TYPE)
			collection_mode = COLLECTION_MODE_ONE
			to_chat(usr, "[src] now picks up one item at a time.")

// Empty all the contents onto the current turf
/obj/item/storage/verb/quick_empty()
	set name = "Empty Contents"
	set category = "Object"

	if((!ishuman(usr) && (loc != usr)) || usr.incapacitated())
		return
	var/turf/T = get_turf(src)
	var/list/things = contents.Copy()
	var/datum/progressbar/progress = new(usr, things.len, T)
	while (do_after(usr, 10, TRUE, T, FALSE, CALLBACK(src, .proc/mass_remove_from_storage, T, things, progress)))
		sleep(1)
	qdel(progress)

/obj/item/storage/proc/mass_remove_from_storage(atom/target, list/things, datum/progressbar/progress)
	var/number_of_things = things.len
	for(var/obj/item/I in things)
		--number_of_things
		if (I.loc != src)
			continue
		remove_from_storage(I, target)
		if (TICK_CHECK)
			progress.update(progress.goal - number_of_things)
			return TRUE

	progress.update(progress.goal - number_of_things)
	return FALSE

// Empty all the contents onto the current turf, without checking the user's status.
/obj/item/storage/proc/do_quick_empty()
	var/turf/T = get_turf(src)
	if(usr)
		hide_from(usr)
	for(var/obj/item/I in src)
		remove_from_storage(I, T)

/obj/item/storage/emp_act(severity)
	if(!isliving(loc))
		for(var/obj/O in src)
			O.emp_act(severity)
	..()

/obj/item/storage/attack_self(mob/user)
	//Clicking on itself will empty it, if it has the verb to do that.
	if(user.get_active_held_item() == src && allow_quick_empty)
		quick_empty()

/obj/item/storage/handle_atom_del(atom/A)
	remove_from_storage(A, null)

/obj/item/storage/contents_explosion(severity, target)
	for(var/I in src)
		var/atom/movable/AM = I
		AM.ex_act(severity, target)

//Cyberboss says: "USE THIS TO FILL IT, NOT INITIALIZE OR NEW"

/obj/item/storage/proc/PopulateContents()
