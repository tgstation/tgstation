/datum/storage
	var/atom/parent

	var/max_slots
	var/max_specific_storage // max weight class for a single item being inserted
	var/max_total_storage // max combined weight classes the storage can hold

	var/list/is_using = list() // list of all the mobs currently viewing the contents

	var/locked = FALSE
	var/attack_hand_interact = TRUE // whether or not we should open when clicked
	var/allow_big_nesting = FALSE // whether or not we allow storage objects of the same size inside

	var/pickup_on_click = FALSE // should we be allowed to pickup an object by clicking it
	var/collection_mode = COLLECT_ONE

	var/insert_preposition = "in" // you put things *in* a bag, but *on* a plate
	
	var/silent = FALSE // don't show any chat messages regarding inserting items
	var/rustle_sound = TRUE // play a rustling sound when interacting with the bag

	var/numerical_stacking = FALSE // instead of displaying multiple items of the same type, display them as numbered contents

	var/atom/movable/screen/storage/boxes // storage display object
	var/atom/movable/screen/close/closer // close button object

	var/screen_max_columns = 7 // maximum amount of columns a storage object can have
	var/screen_max_rows = INFINITY
	var/screen_pixel_x = 16 // pixel location of the boxes and close button
	var/screen_pixel_y = 16
	var/screen_start_x = 4 // where storage starts being rendered, screen_loc wise
	var/screen_start_y = 2



/datum/storage/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	boxes = new(null, src)
	closer = new(null, src)

	src.parent = parent
	src.max_slots = max_slots
	src.max_specific_storage = max_specific_storage
	src.max_total_storage = max_total_storage

	orient_to_hud()
	
	RegisterSignal(parent, list(COMSIG_ATOM_ATTACK_PAW, COMSIG_ATOM_ATTACK_HAND), .proc/handle_attack)
	RegisterSignal(parent, COMSIG_MOUSEDROP_ONTO, .proc/handle_mousedrop)

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/attackby)
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, .proc/intercept_preattack)
	RegisterSignal(parent, COMSIG_OBJ_DECONSTRUCT, .proc/remove_all)

	RegisterSignal(parent, list(COMSIG_ATOM_ATTACK_HAND_SECONDARY, COMSIG_CLICK_ALT), .proc/open_storage)

	RegisterSignal(parent, COMSIG_ATOM_ENTERED, .proc/refresh_views)
	RegisterSignal(parent, COMSIG_ATOM_EXITED, .proc/remove_and_refresh)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/close_distance)

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
	thing.screen_loc = null
	if(thing.maptext)
		thing.maptext = ""

/datum/storage/proc/attempt_insert(datum/source, obj/item/to_insert, mob/user, override = FALSE)
	SIGNAL_HANDLER

	. = TRUE

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

	to_insert.item_flags |= IN_STORAGE

	to_insert.forceMove(parent)
	item_insertion_feedback(user, to_insert, override)

/datum/storage/proc/handle_mass_pickup(mob/user, list/things, atom/thing_loc, list/rejections, datum/progressbar/progress)
	for(var/obj/item/thing in things)
		message_admins("[thing]")
		things -= thing
		if(thing.loc != thing_loc)
			continue
		if(thing.type in rejections) // To limit bag spamming: any given type only complains once
			continue
		if(!attempt_insert(parent, thing, user, TRUE)) // Note can_be_inserted still makes noise when the answer is no
			if(parent.contents.len >= max_slots)
				break
			rejections += thing.type // therefore full bags are still a little spammy
			continue

		if (TICK_CHECK)
			progress.update(progress.goal - things.len)
			return TRUE

	progress.update(progress.goal - things.len)
	return FALSE

/datum/storage/proc/item_insertion_feedback(mob/user, obj/item/thing, override = FALSE)
	if(silent && !override)
		return

	if(rustle_sound)
		playsound(parent, SFX_RUSTLE, 50, TRUE, -5)

	to_chat(user, span_notice("You put [thing] [insert_preposition]to [parent]."))

	for(var/mob/viewing in oviewers(user, null))
		if(in_range(user, viewing))
			viewing.show_message(span_notice("[user] puts [thing] [insert_preposition]to [parent]."), MSG_VISUAL)
			return
		if(thing && thing.w_class >= 3)
			viewing.show_message(span_notice("[user] puts [thing] [insert_preposition]to [parent]."), MSG_VISUAL)
			return

/datum/storage/proc/attempt_remove(obj/item/thing, atom/newLoc)
	if(istype(thing))
		if(ismob(parent.loc))
			var/mob/mobparent = parent.loc
			thing.dropped(mobparent, TRUE)

	if(newLoc)
		reset_item(thing)
		thing.forceMove(newLoc)

		if(rustle_sound)
			playsound(parent, SFX_RUSTLE, 50, TRUE, -5)
	else
		thing.moveToNullspace()

	thing.item_flags &= ~IN_STORAGE

	refresh_views()

	if(isobj(parent))
		parent.update_appearance()

	return TRUE

/datum/storage/proc/remove_all(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!target)
		target = get_turf(parent)

	for(var/obj/item/thing in parent)
		if(thing.loc != parent)
			continue
		attempt_remove(thing, target)

/datum/storage/proc/remove_and_refresh(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER

	message_admins("ran remove and refresh")

	for(var/mob/user in is_using)
		if(user.client)
			message_admins("removed from [user]")
			var/client/cuser = user.client
			cuser.screen -= gone

	reset_item(gone)
	refresh_views()

/datum/storage/proc/intercept_preattack(datum/source, obj/item/thing, mob/user, params)
	SIGNAL_HANDLER

	if(!istype(thing) || !pickup_on_click || thing.atom_storage)
		return FALSE

	. = TRUE // cancel the attack chain now

	if(collection_mode == COLLECT_ONE)
		attempt_insert(source, thing, user)
		return

	if(!isturf(thing.loc))
		return

	INVOKE_ASYNC(src, .proc/collect_on_turf, thing, user)

/datum/storage/proc/collect_on_turf(obj/item/thing, mob/user)
	var/list/turf_things = thing.loc.contents.Copy()

	if(collection_mode == COLLECT_SAME)
		turf_things = typecache_filter_list(turf_things, typecacheof(thing.type))

	var/amount = length(turf_things)
	if(!amount)
		to_chat(user, span_warning("You failed to pick up anything with [parent]!"))
		return

	var/datum/progressbar/progress = new(user, amount, thing.loc)
	var/list/rejections = list()

	while(do_after(user, 1 SECONDS, parent, NONE, FALSE, CALLBACK(src, .proc/handle_mass_pickup, user, turf_things, thing.loc, rejections, progress)))
		stoplag(1)

	progress.end_progress()
	to_chat(user, span_notice("You put everything you could [insert_preposition]to [parent]."))

/datum/storage/proc/handle_mousedrop(datum/source, atom/over_object, mob/user)
	SIGNAL_HANDLER

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
		open_storage(parent, user)
	if(!istype(over_object, /atom/movable/screen))
		return
	
	if(parent.loc != user)
		return
	
	if(rustle_sound)
		playsound(parent, SFX_RUSTLE, 50, TRUE, -5)

	if(istype(over_object, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/hand = over_object
		user.putItemFromInventoryInHandIfPossible(parent, hand.held_index)
		return

/datum/storage/proc/attackby(datum/source, obj/item/thing, mob/user, params)
	SIGNAL_HANDLER

	if(!thing.attackby_storage_insert(src, parent, user))
		return FALSE

	. = TRUE // prevent after attack

	if(iscyborg(user))
		return

	attempt_insert(parent, thing, user)

/datum/storage/proc/handle_attack(datum/source, mob/user)
	SIGNAL_HANDLER

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
		open_storage(parent, user)
		return TRUE

/datum/storage/proc/process_numerical_display()
	var/list/toreturn = list()

	for(var/obj/item/thing in parent.contents)
		var/total_amnt = 1

		if(istype(thing, /obj/item/stack))
			var/obj/item/stack/things = thing
			total_amnt = things.amount

		if(!toreturn["[thing.type]-[thing.name]"])
			toreturn["[thing.type]-[thing.name]"] = new /datum/numbered_display(thing, total_amnt)
		else
			var/datum/numbered_display/numberdisplay = toreturn["[thing.type]-[thing.name]"]
			numberdisplay.number += total_amnt

	return toreturn

/datum/storage/proc/orient_to_hud()
	var/adjusted_contents = parent.contents.len

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(numerical_stacking)
		numbered_contents = process_numerical_display()
		adjusted_contents = numbered_contents.len

	var/columns = clamp(max_slots, 1, screen_max_columns)
	var/rows = clamp(CEILING(adjusted_contents / columns, 1), 1, screen_max_rows)

	orient_item_boxes(rows, columns, numbered_contents)

/datum/storage/proc/orient_item_boxes(rows, cols, list/obj/item/numerical_display_contents)
	boxes.screen_loc = "[screen_start_x]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y] to [screen_start_x+cols-1]:[screen_pixel_x],[screen_start_y+rows-1]:[screen_pixel_y]"
	var/current_x = screen_start_x
	var/current_y = screen_start_y

	if(islist(numerical_display_contents))
		for(var/type in numerical_display_contents)
			var/datum/numbered_display/numberdisplay = numerical_display_contents[type]

			numberdisplay.sample_object.mouse_opacity = MOUSE_OPACITY_OPAQUE
			numberdisplay.sample_object.screen_loc = "[current_x]:[screen_pixel_x],[current_y]:[screen_pixel_y]"
			numberdisplay.sample_object.maptext = MAPTEXT("<font color='white'>[(numberdisplay.number > 1)? "[numberdisplay.number]" : ""]</font>")
			numberdisplay.sample_object.plane = ABOVE_HUD_PLANE

			current_x++

			if(current_x - screen_start_x >= cols)
				current_x = screen_start_x
				current_y++

				if(current_y - screen_start_y >= rows)
					break

	else
		for(var/obj/item in parent)
			item.mouse_opacity = MOUSE_OPACITY_OPAQUE 
			item.screen_loc = "[current_x]:[screen_pixel_x],[current_y]:[screen_pixel_y]"
			item.maptext = ""
			item.plane = ABOVE_HUD_PLANE

			current_x++

			if(current_x - screen_start_x >= cols)
				current_x = screen_start_x
				current_y++

				if(current_y - screen_start_y >= rows)
					break

	closer.screen_loc = "[screen_start_x + cols]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y]"

/datum/storage/proc/open_storage(datum/source, mob/toshow)
	SIGNAL_HANDLER

	if(!toshow.CanReach(parent))
		parent.balloon_alert(toshow, "can't reach!")
		return FALSE
	
	if(!isliving(toshow) || toshow.incapacitated())
		return FALSE

	if(locked)
		to_chat(toshow, span_warning("[pick("Ka-chunk!", "Ka-chink!", "Plunk!", "Glorf!")] \The [parent] appears to be locked!"))
		return FALSE
	
	show_contents(toshow)

	if(rustle_sound)
		playsound(parent, SFX_RUSTLE, 50, TRUE, -5)

/datum/storage/proc/close_distance(datum/source)
	SIGNAL_HANDLER

	for(var/mob/living/user in can_see_contents())
		if (!user.CanReach(parent))
			hide_contents(user)

/datum/storage/proc/refresh_views(datum/source)
	SIGNAL_HANDLER

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
