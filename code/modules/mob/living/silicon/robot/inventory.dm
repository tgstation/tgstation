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

	var/atom/movable/screen/robot/module_slot/module1 = hud_used.screen_objects[HUD_KEY_HAND_SLOT(BORG_CHOOSE_MODULE_ONE)]
	var/atom/movable/screen/robot/module_slot/module2 = hud_used.screen_objects[HUD_KEY_HAND_SLOT(BORG_CHOOSE_MODULE_TWO)]
	var/atom/movable/screen/robot/module_slot/module3 = hud_used.screen_objects[HUD_KEY_HAND_SLOT(BORG_CHOOSE_MODULE_THREE)]

	if(last_broken_module <= BORG_CHOOSE_MODULE_ONE)
		module1.icon_state = "[module1.base_icon_state] +b"
	else
		module1.icon_state = "[module1.base_icon_state][modules_activated && active_hand_index == 1 ? " +a" : null]"

	if(last_broken_module <= BORG_CHOOSE_MODULE_TWO)
		module2.icon_state = "[module2.base_icon_state] +b"
	else
		module2.icon_state = "[module2.base_icon_state][modules_activated && active_hand_index == 2 ? " +a" : null]"

	if(last_broken_module <= BORG_CHOOSE_MODULE_THREE)
		module3.icon_state = "[module3.base_icon_state] +b"
	else
		module3.icon_state = "[module3.base_icon_state][modules_activated && active_hand_index == 3 ? " +a" : null]"

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

/mob/living/silicon/robot/proc/update_module_health(old_health)
	PROTECTED_PROC(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(!model.breakable_modules)
		last_broken_module = get_num_hand_slots()
		return
	if(!get_num_hand_slots())
		return

	var/effective_max_health = maxHealth * 2
	var/effective_health = health + maxHealth
	var/effective_old_health = old_health + maxHealth
	var/health_per_module = effective_max_health / (get_num_hand_slots() + 1)

	var/old_module_index = floor((effective_old_health - 1) / health_per_module) + 1
	var/new_module_index = floor((effective_health - 1) / health_per_module) + 1

	var/damaging = effective_health < effective_old_health
	if(damaging)
		old_module_index--
	else
		new_module_index--

	for(var/module_index in old_module_index to new_module_index step (damaging ? -1 : 1))
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

	last_broken_module = damaging ? new_module_index : old_module_index
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

	return module_num < 1 || module_num > last_broken_module

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
