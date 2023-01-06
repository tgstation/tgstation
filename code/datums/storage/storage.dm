/**
 * Datumized Storage
 * Eliminates the need for custom signals specifically for the storage component, and attaches a storage variable (atom_storage) to every atom.
 * The parent and real_location variables are both weakrefs, so they must be resolved before they can be used.
 * If you're looking to create custom storage type behaviors, check ../subtypes
 */
/datum/storage
	/// the actual item we're attached to
	var/datum/weakref/parent
	/// the actual item we're storing in
	var/datum/weakref/real_location

	/// if this is set, only items, and their children, will fit
	var/list/can_hold
	/// if this is set, items, and their children, won't fit
	var/list/cant_hold
	/// if set, these items will be the exception to the max size of object that can fit.
	var/list/exception_hold
	/// if set can only contain stuff with this single trait present.
	var/list/can_hold_trait

	/// whether or not we should have those cute little animations
	var/animated = TRUE

	var/max_slots = 7
	/// max weight class for a single item being inserted
	var/max_specific_storage = WEIGHT_CLASS_NORMAL
	/// max combined weight classes the storage can hold
	var/max_total_storage = 14

	/// list of all the mobs currently viewing the contents
	var/list/is_using = list()

	var/locked = FALSE
	/// whether or not we should open when clicked
	var/attack_hand_interact = TRUE
	/// whether or not we allow storage objects of the same size inside
	var/allow_big_nesting = FALSE

	/// should we be allowed to pickup an object by clicking it
	var/allow_quick_gather = FALSE
	/// show we allow emptying all contents by using the storage object in hand
	var/allow_quick_empty = FALSE
	/// the mode for collection when allow_quick_gather is enabled
	var/collection_mode = COLLECT_ONE

	/// shows what we can hold in examine text
	var/can_hold_description

	/// contents shouldn't be emped
	var/emp_shielded

	/// you put things *in* a bag, but *on* a plate
	var/insert_preposition = "in"

	/// don't show any chat messages regarding inserting items
	var/silent = FALSE
	/// same as above but only for the user, useful to cut on chat spam without removing feedback for other players
	var/silent_for_user = FALSE
	/// play a rustling sound when interacting with the bag
	var/rustle_sound = TRUE

	/// alt click takes an item out instead of opening up storage
	var/quickdraw = FALSE

	/// instead of displaying multiple items of the same type, display them as numbered contents
	var/numerical_stacking = FALSE

	/// storage display object
	var/atom/movable/screen/storage/boxes
	/// close button object
	var/atom/movable/screen/close/closer

	/// maximum amount of columns a storage object can have
	var/screen_max_columns = 7
	var/screen_max_rows = INFINITY
	/// pixel location of the boxes and close button
	var/screen_pixel_x = 16
	var/screen_pixel_y = 16
	/// where storage starts being rendered, screen_loc wise
	var/screen_start_x = 4
	var/screen_start_y = 2

	var/datum/weakref/modeswitch_action_ref

	/// If true shows the contents of the storage in open_storage
	var/display_contents = TRUE

/datum/storage/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	boxes = new(null, src)
	closer = new(null, src)

	src.parent = WEAKREF(parent)
	src.real_location = src.parent
	src.max_slots = max_slots || src.max_slots
	src.max_specific_storage = max_specific_storage || src.max_specific_storage
	src.max_total_storage = max_total_storage || src.max_total_storage
	src.numerical_stacking = numerical_stacking || src.numerical_stacking
	src.allow_quick_gather = allow_quick_gather || src.allow_quick_gather
	src.allow_quick_empty = allow_quick_empty || src.allow_quick_empty
	src.collection_mode = collection_mode || src.collection_mode
	src.attack_hand_interact = attack_hand_interact || src.attack_hand_interact

	var/atom/resolve_parent = src.parent?.resolve()
	var/atom/resolve_location = src.real_location?.resolve()

	if(!resolve_parent)
		stack_trace("storage could not resolve parent weakref")
		qdel(src)
		return

	if(!resolve_location)
		stack_trace("storage could not resolve location weakref")
		qdel(src)
		return

	RegisterSignals(resolve_parent, list(COMSIG_ATOM_ATTACK_PAW, COMSIG_ATOM_ATTACK_HAND), PROC_REF(on_attack))
	RegisterSignal(resolve_parent, COMSIG_MOUSEDROP_ONTO, PROC_REF(on_mousedrop_onto))
	RegisterSignal(resolve_parent, COMSIG_MOUSEDROPPED_ONTO, PROC_REF(on_mousedropped_onto))

	RegisterSignal(resolve_parent, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))
	RegisterSignal(resolve_parent, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(resolve_parent, COMSIG_ITEM_PRE_ATTACK, PROC_REF(on_preattack))
	RegisterSignal(resolve_parent, COMSIG_OBJ_DECONSTRUCT, PROC_REF(on_deconstruct))

	RegisterSignal(resolve_parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(mass_empty))

	RegisterSignals(resolve_parent, list(COMSIG_CLICK_ALT, COMSIG_ATOM_ATTACK_GHOST, COMSIG_ATOM_ATTACK_HAND_SECONDARY), PROC_REF(open_storage_on_signal))
	RegisterSignal(resolve_parent, COMSIG_PARENT_ATTACKBY_SECONDARY, PROC_REF(open_storage_attackby_secondary))

	RegisterSignal(resolve_location, COMSIG_ATOM_ENTERED, PROC_REF(handle_enter))
	RegisterSignal(resolve_location, COMSIG_ATOM_EXITED, PROC_REF(handle_exit))
	RegisterSignal(resolve_parent, COMSIG_MOVABLE_MOVED, PROC_REF(close_distance))
	RegisterSignal(resolve_parent, COMSIG_ITEM_EQUIPPED, PROC_REF(update_actions))

	RegisterSignal(resolve_parent, COMSIG_TOPIC, PROC_REF(topic_handle))

	orient_to_hud()

/datum/storage/Destroy()
	parent = null
	real_location = null

	for(var/mob/person in is_using)
		if(person.active_storage == src)
			person.active_storage = null
			person.client?.screen -= boxes
			person.client?.screen -= closer

	QDEL_NULL(boxes)
	QDEL_NULL(closer)

	is_using.Cut()

	return ..()

/datum/storage/proc/on_deconstruct()
	SIGNAL_HANDLER

	remove_all()

/// Automatically ran on all object insertions: flag marking and view refreshing.
/datum/storage/proc/handle_enter(datum/source, obj/item/arrived)
	SIGNAL_HANDLER

	if(!istype(arrived))
		return

	var/atom/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	resolve_parent.update_appearance(UPDATE_ICON_STATE)

	arrived.item_flags |= IN_STORAGE
	refresh_views()
	arrived.on_enter_storage(src)

/// Automatically ran on all object removals: flag marking and view refreshing.
/datum/storage/proc/handle_exit(datum/source, obj/item/gone)
	SIGNAL_HANDLER

	if(!istype(gone))
		return

	var/atom/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	resolve_parent.update_appearance(UPDATE_ICON_STATE)

	gone.item_flags &= ~IN_STORAGE
	remove_and_refresh(gone)
	gone.on_exit_storage(src)

/**
 * Sets where items are physically being stored in the case it shouldn't be on the parent.
 *
 * @param atom/real the new real location of the datum
 * @param should_drop if TRUE, all the items in the old real location will be dropped
 */
/datum/storage/proc/set_real_location(atom/real, should_drop = FALSE)
	if(!real)
		return

	var/atom/resolve_location = src.real_location?.resolve()
	if(!resolve_location)
		return

	var/atom/resolve_parent = src.parent?.resolve()
	if(!resolve_parent)
		return

	if(should_drop)
		remove_all(get_turf(resolve_parent))

	resolve_location.flags_1 &= ~HAS_DISASSOCIATED_STORAGE_1
	real.flags_1 |= HAS_DISASSOCIATED_STORAGE_1

	UnregisterSignal(resolve_location, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))

	RegisterSignal(real, COMSIG_ATOM_ENTERED, PROC_REF(handle_enter))
	RegisterSignal(real, COMSIG_ATOM_EXITED, PROC_REF(handle_exit))

	real_location = WEAKREF(real)

/datum/storage/proc/topic_handle(datum/source, user, href_list)
	SIGNAL_HANDLER

	if(href_list["show_valid_pocket_items"])
		handle_show_valid_items(source, user)

/datum/storage/proc/handle_show_valid_items(datum/source, user)
	to_chat(user, span_notice("[source] can hold: [can_hold_description]"))

/// Almost 100% of the time the lists passed into set_holdable are reused for each instance
/// Just fucking cache it 4head
/// Yes I could generalize this, but I don't want anyone else using it. in fact, DO NOT COPY THIS
/// If you find yourself needing this pattern, you're likely better off using static typecaches
/// I'm not because I do not trust implementers of the storage component to use them, BUT
/// IF I FIND YOU USING THIS PATTERN IN YOUR CODE I WILL BREAK YOU ACROSS MY KNEES
/// ~Lemon
GLOBAL_LIST_EMPTY(cached_storage_typecaches)

/datum/storage/proc/set_holdable(list/can_hold_list = null, list/cant_hold_list = null)
	if(!islist(can_hold_list))
		can_hold_list = list(can_hold_list)
	if(!islist(cant_hold_list))
		cant_hold_list = list(cant_hold_list)

	can_hold_description = generate_hold_desc(can_hold_list)

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

/// Generates a description, primarily for clothing storage.
/datum/storage/proc/generate_hold_desc(can_hold_list)
	var/list/desc = list()

	for(var/valid_type in can_hold_list)
		var/obj/item/valid_item = valid_type
		desc += "\a [initial(valid_item.name)]"

	return "\n\t[span_notice("[desc.Join("\n\t")]")]"

/// Updates the action button for toggling collectmode.
/datum/storage/proc/update_actions(atom/source, mob/equipper, slot)
	SIGNAL_HANDLER

	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	if(!istype(resolve_parent) || !allow_quick_gather)
		QDEL_NULL(modeswitch_action_ref)
		return

	var/datum/action/existing = modeswitch_action_ref?.resolve()
	if(!QDELETED(existing))
		return

	var/datum/action/modeswitch_action = resolve_parent.add_item_action(/datum/action/item_action/storage_gather_mode)
	RegisterSignal(modeswitch_action, COMSIG_ACTION_TRIGGER, PROC_REF(action_trigger))
	modeswitch_action_ref = WEAKREF(modeswitch_action)

/// Refreshes and item to be put back into the real world, out of storage.
/datum/storage/proc/reset_item(obj/item/thing)
	thing.layer = initial(thing.layer)
	SET_PLANE_IMPLICIT(thing, initial(thing.plane))
	thing.mouse_opacity = initial(thing.mouse_opacity)
	thing.screen_loc = null
	if(thing.maptext)
		thing.maptext = ""

/**
 * Checks if an item is capable of being inserted into the storage
 *
 * @param obj/item/to_insert the item we're checking
 * @param messages if TRUE, will print out a message if the item is not valid
 * @param force bypass locked storage
 */
/datum/storage/proc/can_insert(obj/item/to_insert, mob/user, messages = TRUE, force = FALSE)
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	var/obj/item/resolve_location = real_location?.resolve()
	if(!resolve_location)
		return

	if(QDELETED(to_insert))
		return FALSE

	if(!isitem(to_insert))
		return FALSE

	if(locked && !force)
		return FALSE

	if((to_insert == resolve_parent) || (to_insert == real_location))
		return FALSE

	if(to_insert.w_class > max_specific_storage && !is_type_in_typecache(to_insert, exception_hold))
		if(messages && user)
			to_chat(user, span_warning("\The [to_insert] is too big for \the [resolve_parent]!"))
		return FALSE

	if(resolve_location.contents.len >= max_slots)
		if(messages && user && !silent_for_user)
			to_chat(user, span_warning("\The [to_insert] can't fit into \the [resolve_parent]! Make some space!"))
		return FALSE

	var/total_weight = to_insert.w_class

	for(var/obj/item/thing in resolve_location)
		total_weight += thing.w_class

	if(total_weight > max_total_storage)
		if(messages && user && !silent_for_user)
			to_chat(user, span_warning("\The [to_insert] can't fit into \the [resolve_parent]! Make some space!"))
		return FALSE

	if(length(can_hold))
		if(!is_type_in_typecache(to_insert, can_hold))
			if(messages && user)
				to_chat(user, span_warning("\The [resolve_parent] cannot hold \the [to_insert]!"))
			return FALSE

	if(is_type_in_typecache(to_insert, cant_hold) || HAS_TRAIT(to_insert, TRAIT_NO_STORAGE_INSERT) || (can_hold_trait && !HAS_TRAIT(to_insert, can_hold_trait)))
		if(messages && user)
			to_chat(user, span_warning("\The [resolve_parent] cannot hold \the [to_insert]!"))
		return FALSE

	if(HAS_TRAIT(to_insert, TRAIT_NODROP))
		if(messages)
			to_chat(user, span_warning("\The [to_insert] is stuck on your hand!"))
		return FALSE

	var/datum/storage/biggerfish = resolve_parent.loc.atom_storage // this is valid if the container our resolve_parent is being held in is a storage item

	if(biggerfish && biggerfish.max_specific_storage < max_specific_storage)
		if(messages && user)
			to_chat(user, span_warning("[to_insert] can't fit in [resolve_parent] while [resolve_parent.loc] is in the way!"))
		return FALSE

	if(istype(resolve_parent))
		var/datum/storage/item_storage = to_insert.atom_storage
		if((to_insert.w_class >= resolve_parent.w_class) && item_storage && !allow_big_nesting)
			if(messages && user)
				to_chat(user, span_warning("[resolve_parent] cannot hold [to_insert] as it's a storage item of the same size!"))
			return FALSE

	return TRUE

/**
 * Attempts to insert an item into the storage
 *
 * @param datum/source used by the signal handler
 * @param obj/item/to_insert the item we're inserting
 * @param mob/user the user who is inserting the item
 * @param override see item_insertion_feedback()
 * @param force bypass locked storage
 */
/datum/storage/proc/attempt_insert(obj/item/to_insert, mob/user, override = FALSE, force = FALSE)
	var/obj/item/resolve_location = real_location?.resolve()
	if(!resolve_location)
		return FALSE

	if(!can_insert(to_insert, user, force = force))
		return FALSE

	to_insert.item_flags |= IN_STORAGE
	to_insert.forceMove(resolve_location)
	item_insertion_feedback(user, to_insert, override)
	resolve_location.update_appearance()
	return TRUE

/**
 * Inserts every item in a given list, with a progress bar
 *
 * @param mob/user the user who is inserting the items
 * @param list/things the list of items to insert
 * @param atom/thing_loc the location of the items (used to make sure an item hasn't moved during pickup)
 * @param list/rejections a list used to make sure we only complain once about an invalid insertion
 * @param datum/progressbar/progress the progressbar used to show the progress of the insertion
 */
/datum/storage/proc/handle_mass_pickup(mob/user, list/things, atom/thing_loc, list/rejections, datum/progressbar/progress)
	var/obj/item/resolve_parent = parent?.resolve()
	var/obj/item/resolve_location = real_location?.resolve()
	if(!resolve_parent || !resolve_location)
		return

	for(var/obj/item/thing in things)
		things -= thing
		if(thing.loc != thing_loc)
			continue
		if(thing.type in rejections) // To limit bag spamming: any given type only complains once
			continue
		if(!attempt_insert(thing, user, TRUE)) // Note can_be_inserted still makes noise when the answer is no
			if(resolve_location.contents.len >= max_slots)
				break
			rejections += thing.type // therefore full bags are still a little spammy
			continue

		if (TICK_CHECK)
			progress.update(progress.goal - things.len)
			return TRUE

	progress.update(progress.goal - things.len)
	return FALSE

/**
 * Provides visual feedback in chat for an item insertion
 *
 * @param mob/user the user who is inserting the item
 * @param obj/item/thing the item we're inserting
 * @param override skip feedback, only do animation check
 */
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

	if(!silent_for_user)
		to_chat(user, span_notice("You put [thing] [insert_preposition]to [resolve_parent]."))

	for(var/mob/viewing in oviewers(user, null))
		if(in_range(user, viewing))
			viewing.show_message(span_notice("[user] puts [thing] [insert_preposition]to [resolve_parent]."), MSG_VISUAL)
			return
		if(thing && thing.w_class >= 3)
			viewing.show_message(span_notice("[user] puts [thing] [insert_preposition]to [resolve_parent]."), MSG_VISUAL)
			return

/**
 * Attempts to remove an item from the storage
 *
 * @param obj/item/thing the object we're removing
 * @param atom/newLoc where we're placing the item
 * @param silent if TRUE, we won't play any exit sounds
 */
/datum/storage/proc/attempt_remove(obj/item/thing, atom/newLoc, silent = FALSE)
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

		if(rustle_sound && !silent)
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

/**
 * Removes everything inside of our storage
 *
 * @param atom/target where we're placing the item
 */
/datum/storage/proc/remove_all(atom/target)
	var/obj/item/resolve_parent = parent?.resolve()
	var/obj/item/resolve_location = real_location?.resolve()
	if(!resolve_parent || !resolve_location)
		return

	if(!target)
		target = get_turf(resolve_parent)

	for(var/obj/item/thing in resolve_location)
		if(thing.loc != resolve_location)
			continue
		if(!attempt_remove(thing, target, silent = TRUE))
			continue
		thing.pixel_x = thing.base_pixel_x + rand(-8, 8)
		thing.pixel_y = thing.base_pixel_y + rand(-8, 8)


/**
 * Removes only a specific type of item from our storage
 *
 * @param type the type of item to remove
 * @param amount how many we should attempt to pick up at one time
 * @param check_adjacent if TRUE, we'll check adjacent locations for the item type
 * @param force if TRUE, we'll bypass the check_adjacent check all together
 * @param mob/user the user who is removing the items
 * @param list/inserted a list passed to attempt_remove for ultimate removal
 */
/datum/storage/proc/remove_type(type, atom/destination, amount = INFINITY, check_adjacent = FALSE, force = FALSE, mob/user, list/inserted)
	var/obj/item/resolve_location = real_location?.resolve()
	if(!resolve_location)
		return

	if(!force)
		if(check_adjacent)
			if(!user || !user.CanReach(destination) || !user.CanReach(resolve_location))
				return FALSE
	var/list/taking = typecache_filter_list(resolve_location.contents, typecacheof(type))
	if(taking.len > amount)
		taking.len = amount
	if(inserted) //duplicated code for performance, don't bother checking retval/checking for list every item.
		for(var/i in taking)
			if(attempt_remove(i, destination))
				inserted |= i
	else
		for(var/i in taking)
			attempt_remove(i, destination)
	return TRUE

/// Signal handler for remove_all()
/datum/storage/proc/mass_empty(datum/source, atom/location, force)
	SIGNAL_HANDLER

	if(!allow_quick_empty && !force)
		return

	remove_all(get_turf(location))

/**
 * Recursive proc to get absolutely EVERYTHING inside a storage item, including the contents of inner items.
 *
 * @param list/interface the list we're adding objects to
 * @param recursive whether or not we're checking inside of inner items
 */
/datum/storage/proc/return_inv(list/interface, recursive = TRUE)
	if(!islist(interface))
		return FALSE

	var/obj/item/resolve_location = real_location?.resolve()
	if(!resolve_location)
		return

	var/list/ret = list()
	ret |= resolve_location.contents
	if(recursive)
		for(var/i in ret.Copy())
			var/atom/atom = i
			atom.atom_storage?.return_inv(ret, TRUE)

	interface |= ret

	return TRUE

/**
 * Resets an object, removes it from our screen, and refreshes the view.
 *
 * @param atom/movable/gone the object leaving our storage
 */
/datum/storage/proc/remove_and_refresh(atom/movable/gone)
	SIGNAL_HANDLER

	for(var/mob/user in is_using)
		if(user.client)
			var/client/cuser = user.client
			cuser.screen -= gone

	reset_item(gone)
	refresh_views()

/// Signal handler for the emp_act() of all contents
/datum/storage/proc/on_emp_act(datum/source, severity)
	SIGNAL_HANDLER

	var/obj/item/resolve_location = real_location?.resolve()
	if(!resolve_location)
		return

	if(emp_shielded)
		return

	for(var/atom/thing in resolve_location)
		thing.emp_act(severity)

/// Signal handler for preattack from an object.
/datum/storage/proc/on_preattack(datum/source, obj/item/thing, mob/user, params)
	SIGNAL_HANDLER

	if(!istype(thing) || !allow_quick_gather || thing.atom_storage)
		return

	if(collection_mode == COLLECT_ONE)
		attempt_insert(thing, user)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(!isturf(thing.loc))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	INVOKE_ASYNC(src, PROC_REF(collect_on_turf), thing, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/**
 * Collects every item of a type on a turf.
 *
 * @param obj/item/thing the initial object to pick up
 * @param mob/user the user who is picking up the items
 */
/datum/storage/proc/collect_on_turf(obj/item/thing, mob/user)
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	var/list/turf_things = thing.loc.contents.Copy()

	if(collection_mode == COLLECT_SAME)
		turf_things = typecache_filter_list(turf_things, typecacheof(thing.type))

	var/amount = length(turf_things)
	if(!amount)
		resolve_parent.balloon_alert(user, "nothing to pick up!")
		return

	var/datum/progressbar/progress = new(user, amount, thing.loc)
	var/list/rejections = list()

	while(do_after(user, 1 SECONDS, resolve_parent, NONE, FALSE, CALLBACK(src, PROC_REF(handle_mass_pickup), user, turf_things, thing.loc, rejections, progress)))
		stoplag(1)

	progress.end_progress()
	resolve_parent.balloon_alert(user, "picked up")

/// Signal handler for whenever we drag the storage somewhere.
/datum/storage/proc/on_mousedrop_onto(datum/source, atom/over_object, mob/user)
	SIGNAL_HANDLER

	var/obj/item/resolve_parent = parent?.resolve()
	var/obj/item/resolve_location = real_location?.resolve()
	if(!resolve_parent || !resolve_location)
		return

	if(ismecha(user.loc) || user.incapacitated() || !user.canUseStorage())
		return

	resolve_parent.add_fingerprint(user)

	if(istype(over_object, /atom/movable/screen/inventory/hand))

		if(resolve_parent.loc != user)
			return

		var/atom/movable/screen/inventory/hand/hand = over_object
		user.putItemFromInventoryInHandIfPossible(resolve_parent, hand.held_index)

	else if(ismob(over_object))
		if(over_object != user)
			return

		INVOKE_ASYNC(src, PROC_REF(open_storage), user)

	else if(!istype(over_object, /atom/movable/screen))
		INVOKE_ASYNC(src, PROC_REF(dump_content_at), over_object, user)

/**
 * Dumps all of our contents at a specific location.
 *
 * @param atom/dest_object where to dump to
 * @param mob/user the user who is dumping the contents
 */
/datum/storage/proc/dump_content_at(atom/dest_object, mob/user)
	var/obj/item/resolve_parent = parent.resolve()
	var/obj/item/resolve_location = real_location.resolve()

	if(locked)
		return
	if(!user.CanReach(resolve_parent) || !user.CanReach(dest_object))
		return

	if(SEND_SIGNAL(dest_object, COMSIG_STORAGE_DUMP_CONTENT, resolve_location, user) & STORAGE_DUMP_HANDLED)
		return

	// Storage to storage transfer is instant
	if(dest_object.atom_storage)
		to_chat(user, span_notice("You dump the contents of [resolve_parent] into [dest_object]."))

		if(rustle_sound)
			playsound(resolve_parent, SFX_RUSTLE, 50, TRUE, -5)

		for(var/obj/item/to_dump in resolve_location)
			if(to_dump.loc != resolve_location)
				continue
			dest_object.atom_storage.attempt_insert(to_dump, user)

		return

	var/atom/dump_loc = dest_object.get_dumping_location()
	if(isnull(dump_loc))
		return

	// Storage to loc transfer requires a do_after
	to_chat(user, span_notice("You start dumping out the contents of [resolve_parent] onto [dest_object]..."))
	if(!do_after(user, 2 SECONDS, target = dest_object))
		return

	remove_all(dump_loc)

/// Signal handler for whenever something gets mouse-dropped onto us.
/datum/storage/proc/on_mousedropped_onto(datum/source, obj/item/dropping, mob/user)
	SIGNAL_HANDLER

	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	if(!istype(dropping))
		return
	if(dropping != user.get_active_held_item())
		return
	if(dropping.atom_storage) // If it has storage it should be trying to dump, not insert.
		return

	if(!iscarbon(user) && !isdrone(user))
		return
	var/mob/living/user_living = user
	if(user_living.incapacitated())
		return

	attempt_insert(dropping, user)

/// Signal handler for whenever we're attacked by an object.
/datum/storage/proc/on_attackby(datum/source, obj/item/thing, mob/user, params)
	SIGNAL_HANDLER

	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	if(!thing.attackby_storage_insert(src, resolve_parent, user))
		return FALSE

	if(iscyborg(user))
		return TRUE

	attempt_insert(thing, user)
	return TRUE

/// Signal handler for whenever we're attacked by a mob.
/datum/storage/proc/on_attack(datum/source, mob/user)
	SIGNAL_HANDLER

	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return
	if(!attack_hand_interact)
		return
	if(user.active_storage == src && resolve_parent.loc == user)
		user.active_storage.hide_contents(user)
		hide_contents(user)
		return TRUE
	if(ishuman(user))
		var/mob/living/carbon/human/hum = user
		if(hum.l_store == resolve_parent && !hum.get_active_held_item())
			INVOKE_ASYNC(hum, TYPE_PROC_REF(/mob, put_in_hands), resolve_parent)
			hum.l_store = null
			return
		if(hum.r_store == resolve_parent && !hum.get_active_held_item())
			INVOKE_ASYNC(hum, TYPE_PROC_REF(/mob, put_in_hands), resolve_parent)
			hum.r_store = null
			return

	if(resolve_parent.loc == user)
		INVOKE_ASYNC(src, PROC_REF(open_storage), user)
		return TRUE

/// Generates the numbers on an item in storage to show stacking.
/datum/storage/proc/process_numerical_display()
	var/obj/item/resolve_location = real_location?.resolve()
	if(!resolve_location)
		return

	var/list/toreturn = list()

	for(var/obj/item/thing in resolve_location.contents)
		var/total_amnt = 1

		if(isstack(thing))
			var/obj/item/stack/things = thing
			total_amnt = things.amount

		if(!toreturn["[thing.type]-[thing.name]"])
			toreturn["[thing.type]-[thing.name]"] = new /datum/numbered_display(thing, total_amnt)
		else
			var/datum/numbered_display/numberdisplay = toreturn["[thing.type]-[thing.name]"]
			numberdisplay.number += total_amnt

	return toreturn

/// Updates the storage UI to fit all objects inside storage.
/datum/storage/proc/orient_to_hud()
	var/obj/item/resolve_location = real_location?.resolve()
	if(!resolve_location)
		return

	var/adjusted_contents = resolve_location.contents.len

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(numerical_stacking)
		numbered_contents = process_numerical_display()
		adjusted_contents = numbered_contents.len
	//if the ammount of contents reaches some multiplier of the final column (and its not the last slot), let the player view an additional row
	var/additional_row = (!(adjusted_contents % screen_max_columns) && adjusted_contents < max_slots)

	var/columns = clamp(max_slots, 1, screen_max_columns)
	var/rows = clamp(CEILING(adjusted_contents / columns, 1) + additional_row, 1, screen_max_rows)

	orient_item_boxes(rows, columns, numbered_contents)

/// Generates the actual UI objects, their location, and alignments whenever we open storage up.
/datum/storage/proc/orient_item_boxes(rows, cols, list/obj/item/numerical_display_contents)
	var/obj/item/resolve_location = real_location?.resolve()
	if(!resolve_location)
		return

	boxes.screen_loc = "[screen_start_x]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y] to [screen_start_x+cols-1]:[screen_pixel_x],[screen_start_y+rows-1]:[screen_pixel_y]"
	var/current_x = screen_start_x
	var/current_y = screen_start_y
	var/turf/our_turf = get_turf(resolve_location)

	if(islist(numerical_display_contents))
		for(var/type in numerical_display_contents)
			var/datum/numbered_display/numberdisplay = numerical_display_contents[type]

			var/obj/item/display_sample = numberdisplay.sample_object
			display_sample.mouse_opacity = MOUSE_OPACITY_OPAQUE
			display_sample.screen_loc = "[current_x]:[screen_pixel_x],[current_y]:[screen_pixel_y]"
			display_sample.maptext = MAPTEXT("<font color='white'>[(numberdisplay.number > 1)? "[numberdisplay.number]" : ""]</font>")
			SET_PLANE(display_sample, ABOVE_HUD_PLANE, our_turf)

			current_x++

			if(current_x - screen_start_x >= cols)
				current_x = screen_start_x
				current_y++

				if(current_y - screen_start_y >= rows)
					break

	else
		for(var/obj/item in resolve_location)
			item.mouse_opacity = MOUSE_OPACITY_OPAQUE
			item.screen_loc = "[current_x]:[screen_pixel_x],[current_y]:[screen_pixel_y]"
			item.maptext = ""
			item.plane = ABOVE_HUD_PLANE
			SET_PLANE(item, ABOVE_HUD_PLANE, our_turf)

			current_x++

			if(current_x - screen_start_x >= cols)
				current_x = screen_start_x
				current_y++

				if(current_y - screen_start_y >= rows)
					break

	closer.screen_loc = "[screen_start_x + cols]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y]"


/// Signal handler for when we get attacked with secondary click by an item.
/datum/storage/proc/open_storage_attackby_secondary(datum/source, atom/weapon, mob/user)
	SIGNAL_HANDLER

	return open_storage_on_signal(source, user)

/// Signal handler to open up the storage when we recieve a signal.
/datum/storage/proc/open_storage_on_signal(datum/source, mob/to_show)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(open_storage), to_show)
	return COMPONENT_NO_AFTERATTACK

/// Opens the storage to the mob, showing them the contents to their UI.
/datum/storage/proc/open_storage(mob/to_show)
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return FALSE

	var/obj/item/resolve_location = real_location?.resolve()
	if(!resolve_location)
		return FALSE

	if(isobserver(to_show))
		show_contents(to_show)
		return FALSE

	if(!to_show.CanReach(resolve_parent))
		resolve_parent.balloon_alert(to_show, "can't reach!")
		return FALSE

	if(!isliving(to_show) || to_show.incapacitated())
		return FALSE

	if(locked)
		if(!silent)
			resolve_parent.balloon_alert(to_show, "locked!")
		return FALSE

	if(!quickdraw || to_show.get_active_held_item())
		if(display_contents)
			show_contents(to_show)

		if(animated)
			animate_parent()

		if(rustle_sound)
			playsound(resolve_parent, SFX_RUSTLE, 50, TRUE, -5)

		return TRUE

	var/obj/item/to_remove = locate() in resolve_location

	if(!to_remove)
		return TRUE

	attempt_remove(to_remove)

	INVOKE_ASYNC(src, PROC_REF(put_in_hands_async), to_show, to_remove)

	if(!silent)
		to_show.visible_message(span_warning("[to_show] draws [to_remove] from [resolve_parent]!"), span_notice("You draw [to_remove] from [resolve_parent]."))

	return TRUE

/// Async version of putting something into a mobs hand.
/datum/storage/proc/put_in_hands_async(mob/toshow, obj/item/toremove)
	if(!toshow.put_in_hands(toremove))
		if(!silent)
			toremove.balloon_alert(toshow, "fumbled!")
		return TRUE

/// Signal handler for whenever a mob walks away with us, close if they can't reach us.
/datum/storage/proc/close_distance(datum/source)
	SIGNAL_HANDLER

	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	for(var/mob/user in can_see_contents())
		if (!user.CanReach(resolve_parent))
			hide_contents(user)

/// Close the storage UI for everyone viewing us.
/datum/storage/proc/close_all()
	for(var/mob/user in is_using)
		hide_contents(user)

/// Refresh the views of everyone currently viewing the storage.
/datum/storage/proc/refresh_views()
	for (var/mob/user in can_see_contents())
		show_contents(user)

/// Checks who is currently capable of viewing our storage (and is.)
/datum/storage/proc/can_see_contents()
	var/list/seeing = list()
	for (var/mob/user in is_using)
		if(user.active_storage == src && user.client)
			seeing += user
		else
			is_using -= user
	return seeing

/**
 * Show our storage to a mob.
 *
 * @param mob/toshow the mob to show the storage to
 */
/datum/storage/proc/show_contents(mob/toshow)
	var/obj/item/resolve_location = real_location?.resolve()
	if(!resolve_location)
		return

	if(!toshow.client)
		return

	if(toshow.active_storage != src && (toshow.stat == CONSCIOUS))
		for(var/obj/item/thing in resolve_location)
			if(thing.on_found(toshow))
				toshow.active_storage.hide_contents(toshow)

	if(toshow.active_storage)
		toshow.active_storage.hide_contents(toshow)

	toshow.active_storage = src

	if(ismovable(resolve_location))
		var/atom/movable/movable_loc = resolve_location
		movable_loc.become_active_storage(src)

	orient_to_hud()

	is_using |= toshow

	toshow.client.screen |= boxes
	toshow.client.screen |= closer
	toshow.client.screen |= resolve_location.contents

/**
 * Hide our storage from a mob.
 *
 * @param mob/toshow the mob to hide the storage from
 */
/datum/storage/proc/hide_contents(mob/toshow)
	var/obj/item/resolve_location = real_location?.resolve()
	if(!resolve_location)
		return

	if(!toshow.client)
		return TRUE
	if(toshow.active_storage == src)
		toshow.active_storage = null

	if(!length(is_using) && ismovable(resolve_location))
		var/atom/movable/movable_loc = resolve_location
		movable_loc.lose_active_storage(src)

	is_using -= toshow

	toshow.client.screen -= boxes
	toshow.client.screen -= closer
	toshow.client.screen -= resolve_location.contents

/datum/storage/proc/action_trigger(datum/signal_source, datum/action/source)
	SIGNAL_HANDLER

	toggle_collection_mode(source.owner)
	return TRUE

/**
 * Toggles the collectmode of our storage.
 *
 * @param mob/toshow the mob toggling us
 */
/datum/storage/proc/toggle_collection_mode(mob/user)
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	collection_mode = (collection_mode+1)%3
	switch(collection_mode)
		if(COLLECT_SAME)
			resolve_parent.balloon_alert(user, "will now only pick up a single type")
		if(COLLECT_EVERYTHING)
			resolve_parent.balloon_alert(user, "will now pick up everything")
		if(COLLECT_ONE)
			resolve_parent.balloon_alert(user, "will now pick up one at a time")

/// Gives a spiffy animation to our parent to represent opening and closing.
/datum/storage/proc/animate_parent()
	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	var/matrix/old_matrix = resolve_parent.transform
	animate(resolve_parent, time = 1.5, loop = 0, transform = resolve_parent.transform.Scale(1.07, 0.9))
	animate(time = 2, transform = old_matrix)
