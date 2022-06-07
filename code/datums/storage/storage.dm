/datum/storage
	var/datum/weakref/parent // the actual item we're attached to

	var/list/can_hold //if this is set, only items, and their children, will fit
	var/list/cant_hold //if this is set, items, and their children, won't fit
	var/list/exception_hold //if set, these items will be the exception to the max size of object that can fit.
	/// If set can only contain stuff with this single trait present.
	var/list/can_hold_trait

	var/animated = TRUE // whether or not we should have those cute little animations

	var/max_slots = 7
	var/max_specific_storage = WEIGHT_CLASS_NORMAL // max weight class for a single item being inserted
	var/max_total_storage = 14 // max combined weight classes the storage can hold

	var/list/is_using = list() // list of all the mobs currently viewing the contents

	var/locked = FALSE
	var/attack_hand_interact = TRUE // whether or not we should open when clicked
	var/allow_big_nesting = FALSE // whether or not we allow storage objects of the same size inside

	var/allow_quick_gather = FALSE // should we be allowed to pickup an object by clicking it
	var/allow_quick_empty = FALSE // show we allow emptying all contents by using the storage object in hand
	var/collection_mode = COLLECT_ONE // the mode for collection when allow_quick_gather is enabled

	var/emp_shielded // contents shouldn't be emped

	var/insert_preposition = "in" // you put things *in* a bag, but *on* a plate
	
	var/silent = FALSE // don't show any chat messages regarding inserting items
	var/rustle_sound = TRUE // play a rustling sound when interacting with the bag

	var/quickdraw = FALSE // alt click takes an item out instead of opening up storage

	var/numerical_stacking = FALSE // instead of displaying multiple items of the same type, display them as numbered contents

	var/atom/movable/screen/storage/boxes // storage display object
	var/atom/movable/screen/close/closer // close button object

	var/screen_max_columns = 7 // maximum amount of columns a storage object can have
	var/screen_max_rows = INFINITY
	var/screen_pixel_x = 16 // pixel location of the boxes and close button
	var/screen_pixel_y = 16
	var/screen_start_x = 4 // where storage starts being rendered, screen_loc wise
	var/screen_start_y = 2

	var/datum/action/item_action/storage_collection_mode/toggle_collectmode

/datum/storage/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	boxes = new(null, src)
	closer = new(null, src)

	src.parent = WEAKREF(parent)
	src.max_slots = max_slots || src.max_slots
	src.max_specific_storage = max_specific_storage || src.max_specific_storage
	src.max_total_storage = max_total_storage || src.max_total_storage
	src.numerical_stacking = numerical_stacking || src.numerical_stacking
	src.allow_quick_gather = allow_quick_gather || src.allow_quick_gather
	src.allow_quick_empty = allow_quick_empty || src.allow_quick_empty
	src.collection_mode = collection_mode || src.collection_mode
	src.attack_hand_interact = attack_hand_interact || src.attack_hand_interact

	orient_to_hud()

	var/atom/resolve_parent = src.parent?.resolve()

	if(!resolve_parent)
		stack_trace("storage could not resolve parent weakref")
	
	RegisterSignal(resolve_parent, list(COMSIG_ATOM_ATTACK_PAW, COMSIG_ATOM_ATTACK_HAND), .proc/handle_attack)
	RegisterSignal(resolve_parent, COMSIG_MOUSEDROP_ONTO, .proc/handle_mousedrop)

	RegisterSignal(resolve_parent, COMSIG_ATOM_EMP_ACT, .proc/emp_act)
	RegisterSignal(resolve_parent, COMSIG_PARENT_ATTACKBY, .proc/attackby)
	RegisterSignal(resolve_parent, COMSIG_ITEM_PRE_ATTACK, .proc/intercept_preattack)
	RegisterSignal(resolve_parent, COMSIG_OBJ_DECONSTRUCT, .proc/remove_all)

	RegisterSignal(resolve_parent, COMSIG_ITEM_ATTACK_SELF, .proc/mass_empty)

	RegisterSignal(resolve_parent, list(COMSIG_ATOM_ATTACK_HAND_SECONDARY, COMSIG_CLICK_ALT), .proc/open_storage)

	RegisterSignal(resolve_parent, COMSIG_ATOM_ENTERED, .proc/refresh_views)
	RegisterSignal(resolve_parent, COMSIG_ATOM_EXITED, .proc/remove_and_refresh)
	RegisterSignal(resolve_parent, COMSIG_MOVABLE_MOVED, .proc/close_distance)
	RegisterSignal(resolve_parent, COMSIG_ITEM_EQUIPPED, .proc/update_actions)

/datum/storage/Destroy()
	parent = null
	boxes = null
	closer = null

	for(var/mob/person in is_using)
		if(person.active_storage == src)
			person.active_storage = null

	is_using.Cut()

	return ..()

/// [And now, a message from component storage, brought to you graciously by Lemon]
/// Almost 100% of the time the lists passed into set_holdable are reused for each instance of the component
/// Just fucking cache it 4head
/// Yes I could generalize this, but I don't want anyone else using it. in fact, DO NOT COPY THIS
/// If you find yourself needing this pattern, you're likely better off using static typecaches
/// I'm not because I do not trust implementers of the storage component to use them, BUT
/// IF I FIND YOU USING THIS PATTERN IN YOUR CODE I WILL BREAK YOU ACROSS MY KNEES
/// ~Lemon
GLOBAL_LIST_EMPTY(cached_storage_typecaches)

/datum/storage/proc/set_holdable(list/can_hold_list, list/cant_hold_list)
	if(!islist(can_hold_list))
		can_hold_list = list(can_hold_list)
	if(!islist(cant_hold_list))
		cant_hold_list = list(cant_hold_list)

	// can_hold_description = generate_hold_desc(can_hold_list)
	if (can_hold_list)
		var/unique_key = can_hold_list.Join("-")
		if(!GLOB.cached_storage_typecaches[unique_key])
			GLOB.cached_storage_typecaches[unique_key] = typecacheof(can_hold_list)
		can_hold = GLOB.cached_storage_typecaches[unique_key]

	if (cant_hold_list != null)
		var/unique_key = cant_hold_list.Join("-")
		if(!GLOB.cached_storage_typecaches[unique_key])
			GLOB.cached_storage_typecaches[unique_key] = typecacheof(cant_hold_list)
		cant_hold = GLOB.cached_storage_typecaches[unique_key]

/datum/storage/proc/update_actions()
	SIGNAL_HANDLER

	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	QDEL_NULL(toggle_collectmode)
	
	if(!isitem(resolve_parent) || !allow_quick_gather)
		return
	toggle_collectmode = new(resolve_parent)
	
	if(resolve_parent.item_flags & IN_INVENTORY)
		var/mob/user = resolve_parent.loc
		if(!istype(user))
			return
		toggle_collectmode.Grant(user)

/datum/storage/proc/reset_item(obj/item/thing)
	thing.layer = initial(thing.layer)
	thing.plane = initial(thing.plane)
	thing.mouse_opacity = initial(thing.mouse_opacity)
	thing.screen_loc = null
	if(thing.maptext)
		thing.maptext = ""

/datum/storage/proc/can_insert(obj/item/to_insert, mob/user, messages = TRUE, force = FALSE)
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	if(!isitem(to_insert))
		return FALSE

	if(locked && !force)
		return FALSE

	if(to_insert == resolve_parent)
		return FALSE

	if(to_insert.w_class > max_specific_storage && !is_type_in_typecache(to_insert, exception_hold))
		if(messages)
			to_chat(user, span_warning("\The [to_insert] is too big for \the [resolve_parent]!"))
		return FALSE

	if(resolve_parent.contents.len >= max_slots)
		if(messages)
			to_chat(user, span_warning("\The [to_insert] can't fit into \the [resolve_parent]! Make some space!"))
		return FALSE

	var/total_weight = to_insert.w_class

	for(var/obj/item/thing in resolve_parent)
		total_weight += thing.w_class

	if(total_weight > max_total_storage)
		if(messages)
			to_chat(user, span_warning("\The [to_insert] can't fit into \the [resolve_parent]! Make some space!"))
		return FALSE

	if(length(can_hold))
		if(!is_type_in_typecache(to_insert, can_hold))
			if(messages)
				to_chat(user, span_warning("\The [resolve_parent] cannot hold \the [to_insert]!"))
			return FALSE
	
	if(is_type_in_typecache(to_insert, cant_hold) || HAS_TRAIT(to_insert, TRAIT_NO_STORAGE_INSERT) || (can_hold_trait && !HAS_TRAIT(to_insert, can_hold_trait)))
		if(messages)
			to_chat(user, span_warning("\The [resolve_parent] cannot hold \the [to_insert]!"))
		return FALSE

	var/datum/storage/biggerfish = resolve_parent.loc.atom_storage // this is valid if the container our resolve_parent is being held in is a storage item

	if(biggerfish && biggerfish.max_specific_storage < max_specific_storage)
		if(messages)
			to_chat(user, span_warning("[to_insert] can't fit in [resolve_parent] while [resolve_parent.loc] is in the way!"))
		return FALSE

	if(istype(resolve_parent))
		var/datum/storage/item_storage = to_insert.atom_storage
		if((to_insert.w_class >= resolve_parent.w_class) && item_storage && !allow_big_nesting)
			if(messages)
				to_chat(user, span_warning("[resolve_parent] cannot hold [to_insert] as it's a storage item of the same size!"))
			return FALSE

	return TRUE

/datum/storage/proc/attempt_insert(datum/source, obj/item/to_insert, mob/user, override = FALSE, force = FALSE)
	SIGNAL_HANDLER

	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	if(!can_insert(to_insert, user, force = force))
		return FALSE

	to_insert.item_flags |= IN_STORAGE

	to_insert.forceMove(resolve_parent)
	item_insertion_feedback(user, to_insert, override)

	return TRUE

/datum/storage/proc/handle_mass_pickup(mob/user, list/things, atom/thing_loc, list/rejections, datum/progressbar/progress)
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	for(var/obj/item/thing in things)
		message_admins("[thing]")
		things -= thing
		if(thing.loc != thing_loc)
			continue
		if(thing.type in rejections) // To limit bag spamming: any given type only complains once
			continue
		if(!attempt_insert(resolve_parent, thing, user, TRUE)) // Note can_be_inserted still makes noise when the answer is no
			if(resolve_parent.contents.len >= max_slots)
				break
			rejections += thing.type // therefore full bags are still a little spammy
			continue

		if (TICK_CHECK)
			progress.update(progress.goal - things.len)
			return TRUE

	progress.update(progress.goal - things.len)
	return FALSE

/datum/storage/proc/item_insertion_feedback(mob/user, obj/item/thing, override = FALSE)
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	if(animated)
		animate_parent()

	if(override)
		return

	if(silent)
		return

	if(rustle_sound)
		playsound(resolve_parent, SFX_RUSTLE, 50, TRUE, -5)

	to_chat(user, span_notice("You put [thing] [insert_preposition]to [resolve_parent]."))

	for(var/mob/viewing in oviewers(user, null))
		if(in_range(user, viewing))
			viewing.show_message(span_notice("[user] puts [thing] [insert_preposition]to [resolve_parent]."), MSG_VISUAL)
			return
		if(thing && thing.w_class >= 3)
			viewing.show_message(span_notice("[user] puts [thing] [insert_preposition]to [resolve_parent]."), MSG_VISUAL)
			return

/datum/storage/proc/attempt_remove(obj/item/thing, atom/newLoc)
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	if(istype(thing))
		if(ismob(resolve_parent.loc))
			var/mob/mobparent = resolve_parent.loc
			thing.dropped(mobparent, TRUE)

	if(newLoc)
		reset_item(thing)
		thing.forceMove(newLoc)

		if(rustle_sound)
			playsound(resolve_parent, SFX_RUSTLE, 50, TRUE, -5)
	else
		thing.moveToNullspace()

	thing.item_flags &= ~IN_STORAGE

	if(animated)
		animate_parent()

	refresh_views()

	if(isobj(resolve_parent))
		resolve_parent.update_appearance()

	return TRUE

/datum/storage/proc/remove_all(datum/source, atom/target)
	SIGNAL_HANDLER

	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	if(!target)
		target = get_turf(resolve_parent)

	for(var/obj/item/thing in resolve_parent)
		if(thing.loc != resolve_parent)
			continue
		attempt_remove(thing, target)

/datum/storage/proc/mass_empty(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!allow_quick_empty)
		return

	remove_all(get_turf(user))

/datum/storage/proc/remove_and_refresh(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER

	for(var/mob/user in is_using)
		if(user.client)
			var/client/cuser = user.client
			cuser.screen -= gone

	reset_item(gone)
	refresh_views()

/datum/storage/proc/emp_act(datum/source, severity)
	SIGNAL_HANDLER

	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	if(emp_shielded)
		return
	
	for(var/atom/thing in resolve_parent)
		thing.emp_act(severity)

/datum/storage/proc/intercept_preattack(datum/source, obj/item/thing, mob/user, params)
	SIGNAL_HANDLER

	if(!istype(thing) || !allow_quick_gather || thing.atom_storage)
		return FALSE

	if(collection_mode == COLLECT_ONE)
		attempt_insert(source, thing, user)
		return TRUE

	if(!isturf(thing.loc))
		return TRUE

	INVOKE_ASYNC(src, .proc/collect_on_turf, thing, user)
	return TRUE

/datum/storage/proc/collect_on_turf(obj/item/thing, mob/user)
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return
	
	var/list/turf_things = thing.loc.contents.Copy()

	if(collection_mode == COLLECT_SAME)
		turf_things = typecache_filter_list(turf_things, typecacheof(thing.type))

	var/amount = length(turf_things)
	if(!amount)
		to_chat(user, span_warning("You failed to pick up anything with [resolve_parent]!"))
		return

	var/datum/progressbar/progress = new(user, amount, thing.loc)
	var/list/rejections = list()

	while(do_after(user, 1 SECONDS, resolve_parent, NONE, FALSE, CALLBACK(src, .proc/handle_mass_pickup, user, turf_things, thing.loc, rejections, progress)))
		stoplag(1)

	progress.end_progress()
	to_chat(user, span_notice("You put everything you could [insert_preposition]to [resolve_parent]."))

/datum/storage/proc/handle_mousedrop(datum/source, atom/over_object, mob/user)
	SIGNAL_HANDLER

	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	if(!istype(user))
		return
	if(!over_object)
		return
	if(ismecha(user.loc))
		return
	if(user.incapacitated() || !user.canUseStorage())
		return
	
	resolve_parent.add_fingerprint(user)

	if(over_object == user)
		open_storage(resolve_parent, user)
	if(!istype(over_object, /atom/movable/screen))
		return
	
	if(resolve_parent.loc != user)
		return
	
	if(rustle_sound)
		playsound(resolve_parent, SFX_RUSTLE, 50, TRUE, -5)

	if(istype(over_object, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/hand = over_object
		user.putItemFromInventoryInHandIfPossible(resolve_parent, hand.held_index)
		return

/datum/storage/proc/attackby(datum/source, obj/item/thing, mob/user, params)
	SIGNAL_HANDLER

	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	if(!thing.attackby_storage_insert(src, resolve_parent, user))
		return FALSE

	if(iscyborg(user))
		return TRUE

	attempt_insert(resolve_parent, thing, user)
	return TRUE

/datum/storage/proc/handle_attack(datum/source, mob/user)
	SIGNAL_HANDLER

	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	if(!attack_hand_interact)
		return
	if(user.active_storage == src && resolve_parent.loc == user)
		user.active_storage.hide_contents(user)
		hide_contents(user)
		return
	if(ishuman(user))
		var/mob/living/carbon/human/hum = user
		if(hum.l_store == resolve_parent && !hum.get_active_held_item())
			INVOKE_ASYNC(hum, /mob.proc/put_in_hands, resolve_parent)
			hum.l_store = null
			return
		if(hum.r_store == resolve_parent && !hum.get_active_held_item())
			INVOKE_ASYNC(hum, /mob.proc/put_in_hands, resolve_parent)
			hum.r_store = null
			return

	if(resolve_parent.loc == user)
		open_storage(resolve_parent, user)
		return TRUE

/datum/storage/proc/process_numerical_display()
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	var/list/toreturn = list()

	for(var/obj/item/thing in resolve_parent.contents)
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
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	var/adjusted_contents = resolve_parent.contents.len

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(numerical_stacking)
		numbered_contents = process_numerical_display()
		adjusted_contents = numbered_contents.len

	var/columns = clamp(max_slots, 1, screen_max_columns)
	var/rows = clamp(CEILING(adjusted_contents / columns, 1), 1, screen_max_rows)

	orient_item_boxes(rows, columns, numbered_contents)

/datum/storage/proc/orient_item_boxes(rows, cols, list/obj/item/numerical_display_contents)
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

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
		for(var/obj/item in resolve_parent)
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

	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	if(!toshow.CanReach(resolve_parent))
		resolve_parent.balloon_alert(toshow, "can't reach!")
		return FALSE
	
	if(!isliving(toshow) || toshow.incapacitated())
		return FALSE

	if(locked)
		if(!silent)
			to_chat(toshow, span_warning("[pick("Ka-chunk!", "Ka-chink!", "Plunk!", "Glorf!")] \The [resolve_parent] appears to be locked!"))
		return FALSE
	
	if(!quickdraw)
		show_contents(toshow)

		if(animated)
			animate_parent()
			
		if(rustle_sound)
			playsound(resolve_parent, SFX_RUSTLE, 50, TRUE, -5)

		return TRUE

	var/obj/item/to_remove = locate() in resolve_parent

	if(!to_remove)
		return TRUE

	attempt_remove(to_remove)

	INVOKE_ASYNC(src, .proc/put_in_hands_async, toshow, to_remove)
	
	if(!silent)
		toshow.visible_message(span_warning("[toshow] draws [to_remove] from [resolve_parent]!"), span_notice("You draw [to_remove] from [resolve_parent]."))

	return TRUE

/datum/storage/proc/put_in_hands_async(mob/toshow, obj/item/toremove)
	if(!toshow.put_in_hands(toremove))
		if(!silent)
			to_chat(toshow, span_notice("You fumble for [to_remove] and it falls on the floor."))
		return TRUE

/datum/storage/proc/close_distance(datum/source)
	SIGNAL_HANDLER

	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	for(var/mob/living/user in can_see_contents())
		if (!user.CanReach(resolve_parent))
			hide_contents(user)

/datum/storage/proc/close_all()
	for(var/mob/user in is_using)
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
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	if(!toshow.client)
		return

	if(toshow.active_storage != src && (toshow.stat == CONSCIOUS))
		for(var/obj/item/thing in resolve_parent)
			if(thing.on_found(toshow))
				toshow.active_storage.hide_contents(toshow)
	
	if(toshow.active_storage)
		toshow.active_storage.hide_contents(toshow)

	toshow.active_storage = src

	orient_to_hud()

	is_using |= toshow

	toshow.client.screen |= boxes
	toshow.client.screen |= closer
	toshow.client.screen |= resolve_parent.contents

/datum/storage/proc/hide_contents(mob/toshow)
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	if(!toshow.client)
		return TRUE
	if(toshow.active_storage == src)
		toshow.active_storage = null

	is_using -= toshow
		
	toshow.client.screen -= boxes
	toshow.client.screen -= closer
	toshow.client.screen -= resolve_parent.contents

/datum/storage/proc/toggle_collection_mode(mob/user)
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	collection_mode = (collection_mode+1)%3
	switch(collection_mode)
		if(COLLECT_SAME)
			to_chat(user, span_notice("[resolve_parent] now picks up all items of a single type at once."))
		if(COLLECT_EVERYTHING)
			to_chat(user, span_notice("[resolve_parent] now picks up all items in a tile at once."))
		if(COLLECT_ONE)
			to_chat(user, span_notice("[resolve_parent] now picks up one item at a time."))

/datum/storage/proc/animate_parent()
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	animate(resolve_parent, time = 1.5, loop = 0, transform = matrix().Scale(1.07, 0.9))
	animate(time = 2, transform = null)
