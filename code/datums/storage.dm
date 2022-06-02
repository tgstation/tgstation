/datum/storage
	var/atom/parent

	var/max_slots
	var/max_specific_storage
	var/max_total_storage

	var/list/is_using = list()

	var/locked = FALSE
	var/attack_hand_interact = TRUE
	var/allow_big_nesting = FALSE

	var/atom/movable/screen/storage/boxes //storage display object
	var/atom/movable/screen/close/closer //close button object

	//Screen variables: Do not mess with these vars unless you know what you're doing. They're not defines so storage that isn't in the same location can be supported in the future.
	var/screen_max_columns = 7 //These two determine maximum screen sizes.
	var/screen_max_rows = INFINITY
	var/screen_pixel_x = 16 //These two are pixel values for screen loc of boxes and closer
	var/screen_pixel_y = 16
	var/screen_start_x = 4 //These two are where the storage starts being rendered, screen_loc wise.
	var/screen_start_y = 2



/datum/storage/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	boxes = new(null, src)
	closer = new(null, src)

	src.parent = parent
	src.max_slots = max_slots
	src.max_specific_storage = max_specific_storage
	src.max_total_storage = max_total_storage

	orient_to_hud()

/datum/storage/Destroy()
	parent = null
	boxes = null
	closer = null
	is_using.Cut()

	return ..()


/datum/storage/proc/reset_item(obj/item/thing)
	thing.layer = initial(thing.layer)
	thing.plane = initial(thing.plane)
	thing.mouse_opacity = initial(thing.mouse_opacity)
	if(thing.maptext)
		thing.maptext = ""



/datum/storage/proc/attempt_insert(obj/item/to_insert, mob/user)
	message_admins("ran")
	if(!isitem(to_insert))
		return FALSE

	if(to_insert == parent)
		return FALSE

	if(to_insert.loc == parent)
		return FALSE

	if(to_insert.w_class > max_specific_storage)
		to_chat(user, span_warning("\The [to_insert] is too big for \the [parent]!"))
		return FALSE

	if(parent.contents.len >= max_slots)
		to_chat(user, span_warning("\The [to_insert] can't fit into \the [parent]! Make some space!"))
		return FALSE

	var/total_weight = to_insert.w_class

	for(var/obj/item/thing in parent)
		total_weight += thing.w_class

	if(total_weight > max_total_storage)
		to_chat(user, span_warning("\The [to_insert] can't fit into \the [parent]! Make some space!"))
		return FALSE

	var/datum/storage/biggerfish = parent.loc.atom_storage

	if(biggerfish && biggerfish.max_specific_storage < max_specific_storage)
		to_chat(user, span_warning("[to_insert] can't fit in [parent] while [parent.loc] is in the way!"))
		return FALSE

	if(isitem(parent))
		var/obj/item/iparent = parent
		var/datum/storage/item_storage = to_insert.atom_storage
		if((to_insert.w_class >= iparent.w_class) && item_storage && !allow_big_nesting)
			to_chat(user, span_warning("[iparent] cannot hold [to_insert] as it's a storage item of the same size!"))
			return FALSE

	to_insert.forceMove(parent)
	playsound(parent, SFX_RUSTLE, 50, TRUE, -5)

/datum/storage/proc/attempt_remove(obj/item/thing, atom/newLoc)
	if(istype(thing))
		if(ismob(parent.loc))
			var/mob/mobparent = parent.loc
			thing.dropped(mobparent, silent = TRUE)

	if(newLoc)
		reset_item(thing)
		thing.forceMove(newLoc)
		playsound(parent, SFX_RUSTLE, 50, TRUE, -5)
	else
		thing.moveToNullspace()

	refresh_views()

	if(isobj(parent))
		parent.update_appearance()

	return TRUE

/datum/storage/proc/remove_all(atom/target)
	if(!target)
		target = get_turf(parent)

	for(var/obj/item/thing in parent)
		if(thing.loc != parent)
			continue
		attempt_remove(thing, target)



/datum/storage/proc/handle_mousedrop(atom/over_object, mob/user)
	if(!istype(user))
		return
	if(!over_object)
		return
	if(ismecha(user.loc))
		return
	if(user.incapacitated() || !user.canUseStorage())
		return
	
	parent.add_fingerprint(user)

	if(over_object == user)
		open_storage(user)
	if(!istype(over_object, /atom/movable/screen))
		return
	
	if(parent.loc != user)
		return
	
	playsound(parent, SFX_RUSTLE, 50, TRUE, -5)

	if(istype(over_object, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/hand = over_object
		user.putItemFromInventoryInHandIfPossible(parent, hand.held_index)
		return

/datum/storage/proc/attackby(datum/source, obj/item/thing, mob/user, params)
	if(!thing.attackby_storage_insert(src, parent, user))
		return FALSE

	. = TRUE

	if(iscyborg(user))
		return

	attempt_insert(thing, user)

/datum/storage/proc/handle_attack(mob/user)
	if(!attack_hand_interact)
		return
	if(user.active_storage == src && parent.loc == user)
		user.active_storage.hide_contents(user)
		hide_contents(user)
		return
	if(ishuman(user))
		var/mob/living/carbon/human/hum = user
		if(hum.l_store == parent && !hum.get_active_held_item())
			INVOKE_ASYNC(hum, /mob.proc/put_in_hands, parent)
			hum.l_store = null
			return
		if(hum.r_store == parent && !hum.get_active_held_item())
			INVOKE_ASYNC(hum, /mob.proc/put_in_hands, parent)
			hum.r_store = null
			return

	if(parent.loc == user)
		open_storage(user)
		return TRUE



/datum/storage/proc/orient_to_hud()
	var/adjusted_contents = parent.contents.len

	var/columns = clamp(max_slots, 1, screen_max_columns)
	var/rows = clamp(CEILING(adjusted_contents / columns, 1), 1, screen_max_rows)
	orient_item_boxes(rows, columns)

/datum/storage/proc/orient_item_boxes(rows, cols)
	boxes.screen_loc = "[screen_start_x]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y] to [screen_start_x+cols-1]:[screen_pixel_x],[screen_start_y+rows-1]:[screen_pixel_y]"
	var/cx = screen_start_x
	var/cy = screen_start_y

	for(var/obj/item in parent)
		if(QDELETED(item))
			continue
		item.mouse_opacity = MOUSE_OPACITY_OPAQUE //This is here so storage items that spawn with contents correctly have the "click around item to equip"
		item.screen_loc = "[cx]:[screen_pixel_x],[cy]:[screen_pixel_y]"
		item.maptext = ""
		item.plane = ABOVE_HUD_PLANE
		cx++
		if(cx - screen_start_x >= cols)
			cx = screen_start_x
			cy++
			if(cy - screen_start_y >= rows)
				break

	closer.screen_loc = "[screen_start_x + cols]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y]"

/datum/storage/proc/open_storage(mob/toshow)
	if(!toshow.CanReach(parent))
		parent.balloon_alert(toshow, "can't reach!")
		return FALSE
	
	if(!isliving(toshow) || toshow.incapacitated())
		return FALSE

	if(locked)
		to_chat(toshow, span_warning("[pick("Ka-chunk!", "Ka-chink!", "Plunk!", "Glorf!")] \The [parent] appears to be locked!"))
		return FALSE

	. = TRUE
	
	show_contents(toshow)
	playsound(parent, SFX_RUSTLE, 50, TRUE, -5)

/datum/storage/proc/close_distance()
	for(var/mob/living/user in can_see_contents())
		if (!user.CanReach(parent))
			hide_contents(user)

/datum/storage/proc/refresh_views()
	for (var/user in can_see_contents())
		show_contents(user)

/datum/storage/proc/can_see_contents()
	var/list/seeing = list()
	for (var/mob/user in is_using)
		if(user.active_storage == src && user.client)
			seeing += user
		else
			is_using -= user
	return seeing

/datum/storage/proc/show_contents(mob/toshow)
	if(!toshow.client)
		return

	if(toshow.active_storage != src && (toshow.stat == CONSCIOUS))
		for(var/obj/item/thing in parent)
			if(thing.on_found(toshow))
				toshow.active_storage.hide_contents(toshow)
	
	if(toshow.active_storage)
		toshow.active_storage.hide_contents(toshow)

	toshow.active_storage = src

	orient_to_hud()

	is_using |= toshow

	toshow.client.screen |= boxes
	toshow.client.screen |= closer
	toshow.client.screen |= parent.contents

/datum/storage/proc/hide_contents(mob/toshow)
	if(!toshow.client)
		return TRUE
	if(toshow.active_storage == src)
		toshow.active_storage = null

	is_using -= toshow
		
	toshow.client.screen -= boxes
	toshow.client.screen -= closer
	toshow.client.screen -= parent.contents
