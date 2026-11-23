//These procs handle putting stuff in your hand. It's probably best to use these rather than setting stuff manually
//as they handle all relevant stuff like adding it to the player's screen and such

/**
 * Returns the thing in our active hand (whatever is in our active module-slot, in this case)
 */
/mob/living/silicon/robot/get_active_held_item()
	if(modules_activated)
		return ..()

/mob/living/silicon/robot/put_in_hand_check(obj/item/item_equipping)
	return (item_equipping in model.modules)

/mob/living/silicon/robot/put_in_hand(obj/item/item_module, hand_index, forced = FALSE, ignore_anim = TRUE, visuals_only = FALSE)
	. = ..()
	if(!.)
		return
	item_module.mouse_opacity = initial(item_module.mouse_opacity)
	observer_screen_update(item_module)

/mob/living/silicon/robot/perform_hand_swap(held_index)
	if(is_invalid_module_number(held_index))
		return FALSE

	if(!get_item_for_held_index(held_index))
		return FALSE
	if(held_index == active_hand_index)
		modules_activated = !modules_activated
	else
		active_hand_index = held_index
		modules_activated = TRUE

	update_held_items()
	return TRUE

/mob/living/silicon/robot/can_hold_items(obj/item/I)
	return (I && (I in model.modules)) //Only if it's part of our model.

/mob/living/silicon/robot/is_holding(obj/item/item)
	return ..() || ..(item?.loc)

// Minor variation since we have some items we should never truly drop
/mob/living/silicon/robot/dropItemToGround(obj/item/to_drop, force, silent, invdrop)
	if(to_drop in model.modules)
		deactivate_module(to_drop)
		return null // because we technically didn't drop it
	return ..()

/mob/living/silicon/robot/doUnEquip(obj/item/item_dropping, force, atom/newloc, no_move, invdrop, silent)
	//borgs can drop items that aren't part of the module (used for apparatus modules, the stored item isn't a module).
	if(isnull(model) || !(item_dropping in model.modules))
		return ..()

	if(newloc != model && !force)
		if(!silent)
			to_chat(src, span_notice("You can't drop your [item_dropping.name] module."))
		return FALSE

	. = ..()
	if(!.)
		return
	modules_activated = FALSE
	item_dropping.mouse_opacity = MOUSE_OPACITY_OPAQUE
	//this is the cyborg equivalent of dropped(), though we call that too in doUnEquip.
	item_dropping.cyborg_unequip(src)
	update_held_items()
	playsound_local(src, /datum/sound_effect/rustle, 40, TRUE)

/mob/living/silicon/robot/update_held_items()
	. = ..()
	if(!hud_used)
		return

	// TODO: This is obviously not very good but it's even worse
	// because robots mechanically support an arbitrary amount of module slots.
	// This needs a nice refactoring.

	for(var/i in 1 to get_num_hand_slots())
		var/atom/movable/screen/robot/module_slot/module = hud_used.screen_objects[HUD_KEY_HAND_SLOT(i)]
		if(!module)
			continue

		if(last_working_module < i)
			module.icon_state = "[module.base_icon_state] +b"
		else
			module.icon_state = "[module.base_icon_state][modules_activated && active_hand_index == i ? " +a" : null]"

/mob/living/silicon/robot/change_number_of_hands(amt)
	. = ..()
	last_working_module = get_num_hand_slots()
	update_module_health()

/**
 * parent proc - triggers when an item/module is unequipped from a cyborg.
 */
/obj/item/proc/cyborg_unequip(mob/user)
	return

/**
 * Finds the first available slot and attemps to put item item_module in it.
 *
 * Arguments
 * * item_module - the item being equipped to a slot.
 */
/mob/living/silicon/robot/proc/activate_module(obj/item/item_module)
	if(QDELETED(item_module))
		CRASH("activate_module called with improper item_module")

	if(!(item_module in model.modules))
		CRASH("activate_module called with item_module not in model.modules")

	if(is_holding(item_module))
		to_chat(src, span_warning("That module is already activated."))
		return FALSE

	var/list/empty_held_indexes = get_empty_held_indexes()
	if(!empty_held_indexes.len || is_invalid_module_number(empty_held_indexes[1]))
		to_chat(src, span_warning("Deactivate a module first!"))
		return FALSE

	return put_in_hand(item_module, empty_held_indexes[1])

///Helper for cyborgs unequipping things.
/mob/living/silicon/robot/proc/deactivate_module(obj/item/item_module)
	return transferItemToLoc(item_module, newloc = model)

/mob/living/silicon/robot/proc/update_module_health()
	PROTECTED_PROC(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(!model.breakable_modules)
		last_working_module = get_num_hand_slots()
		return

	if(!get_num_hand_slots())
		return

	var/health_per_module = (maxHealth * 2) / (get_num_hand_slots() + 1)
	var/effective_health = (health + maxHealth) - 1 // so that it breaks at 50 and not 49

	var/old_module_index = last_working_module
	var/new_module_index = floor((effective_health) / health_per_module)

	if(new_module_index == old_module_index)
		return

	var/damaging = new_module_index < old_module_index

	// We add 1 to the indexes just so that they look normal when displayed in chat
	var/starting_module_index = old_module_index + 1
	var/ending_module_index = new_module_index + 1
	if(damaging)
		starting_module_index--
	else
		ending_module_index--

	for(var/module_index in starting_module_index to ending_module_index step (damaging ? -1 : 1))
		if(damaging)
			playsound(src, 'sound/machines/warning-buzzer.ogg', 60, TRUE, TRUE)
			audible_message(span_warning("[src] sounds an alarm! \"SYSTEM ERROR: Module [module_index] OFFLINE.\""))
			if(module_index == 1)
				to_chat(src, span_userdanger("CRITICAL ERROR: ALL modules OFFLINE."))
				if(builtInCamera)
					builtInCamera.camera_enabled = FALSE
					to_chat(src, span_userdanger("CRITICAL ERROR: Built in security camera OFFLINE."))
			else
				to_chat(src, span_userdanger("SYSTEM ERROR: Module [module_index] OFFLINE."))
		else
			to_chat(src, span_notice("ERROR CLEARED: Module [module_index] back online."))
			if(module_index == 1 && builtInCamera)
				builtInCamera.camera_enabled = TRUE
				to_chat(src, span_notice("You hear your built in security camera focus adjust as it comes back online!"))

	last_working_module = new_module_index
	update_held_items()

/**
 * Checks if the provided module number is a valid number.
 *
 * If the number is between 1 and 3 (if check_all_slots is true) or between 1 and the number of disabled
 * modules (if check_all_slots is false), then it returns FALSE. Otherwise, it returns TRUE.
 * Arguments
 * * module_num - the passed module num that is checked for validity.
 * * check_all_slots - TRUE = the proc checks all slots | FALSE = the proc only checks un-disabled slots
 */
/mob/living/silicon/robot/proc/is_invalid_module_number(module_num, check_all_slots = FALSE)
	if(!module_num)
		return TRUE

	return module_num < 1 || module_num > (!check_all_slots ? last_working_module : get_num_hand_slots())

/**
 * ## Please do not use
 * Updates the observers's screens with cyborg items.
 * Currently inventory code handling for observers is tied to carbon (get_held_overlays), meaning this snowflake code for borgs is
 * necessary so observers watching borgs don't bug out. Once that's moved to the living, replace this with it.
 * Removing from the screen is handled by 'doUnEquip'
 * Arg:
 * * item_module - the item being added to the screen.
 */
/mob/living/silicon/robot/proc/observer_screen_update(obj/item/item_module)
	PRIVATE_PROC(TRUE)

	for(var/mob/dead/observe as anything in observers)
		if(!observe.client || observe.client.eye != src)
			LAZYREMOVE(observers, observe)
		observe.client.screen += item_module
