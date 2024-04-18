//These procs handle putting stuff in your hand. It's probably best to use these rather than setting stuff manually
//as they handle all relevant stuff like adding it to the player's screen and such

/**
 * Returns the thing in our active hand (whatever is in our active module-slot, in this case)
 */
/mob/living/silicon/robot/get_active_held_item()
	return module_active

/**
 * Parent proc - triggers when an item/module is unequipped from a cyborg.
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

	if(activated(item_module))
		to_chat(src, span_warning("That module is already activated."))
		return FALSE

	if(disabled_modules & BORG_MODULE_ALL_DISABLED)
		to_chat(src, span_warning("All modules are disabled!"))
		return FALSE

	/// What's the first free slot for the borg?
	var/first_free_slot = !held_items[1] ? 1 : (!held_items[2] ? 2 : (!held_items[3] ? 3 : null))

	if(!first_free_slot || is_invalid_module_number(first_free_slot))
		to_chat(src, span_warning("Deactivate a module first!"))
		return FALSE

	return equip_module_to_slot(item_module, first_free_slot)

/**
 * Is passed an item and a module slot. Equips the item to that borg slot.
 *
 * Arguments
 * * item_module - the item being equipped to a slot
 * * module_num - the slot number being equipped to.
 */
/mob/living/silicon/robot/proc/equip_module_to_slot(obj/item/item_module, module_num)
	var/storage_was_closed = FALSE //Just to be consistant and all
	if(!shown_robot_modules) //Tools may be invisible if the collection is hidden
		hud_used.toggle_show_robot_modules()
		storage_was_closed = TRUE
	switch(module_num)
		if(BORG_CHOOSE_MODULE_ONE)
			item_module.screen_loc = inv1.screen_loc
		if(BORG_CHOOSE_MODULE_TWO)
			item_module.screen_loc = inv2.screen_loc
		if(BORG_CHOOSE_MODULE_THREE)
			item_module.screen_loc = inv3.screen_loc

	held_items[module_num] = item_module
	item_module.mouse_opacity = initial(item_module.mouse_opacity)
	SET_PLANE_EXPLICIT(item_module, ABOVE_HUD_PLANE, src)
	item_module.forceMove(src)

	if(istype(item_module, /obj/item/borg/sight))
		var/obj/item/borg/sight/borg_sight = item_module
		sight_mode |= borg_sight.sight_mode
		update_sight()

	observer_screen_update(item_module, TRUE)

	if(storage_was_closed)
		hud_used.toggle_show_robot_modules()
	item_module.on_equipped(src, ITEM_SLOT_HANDS)
	return TRUE

/**
 * Unequips item item_module from slot module_num. Deletes it if delete_after = TRUE.
 *
 * Arguments
 * * item_module - the item being unequipped
 * * module_num - the slot number being unequipped.
 */
/mob/living/silicon/robot/proc/unequip_module_from_slot(obj/item/item_module, module_num)
	if(QDELETED(item_module))
		CRASH("unequip_module_from_slot called with improper item_module")

	if(!(item_module in model.modules))
		CRASH("unequip_module_from_slot called with item_module not in model.modules")

	item_module.mouse_opacity = MOUSE_OPACITY_OPAQUE

	if(istype(item_module, /obj/item/storage/bag/tray/))
		item_module.atom_storage.remove_all(loc)
	if(istype(item_module, /obj/item/borg/sight))
		var/obj/item/borg/sight/borg_sight = item_module
		sight_mode &= ~borg_sight.sight_mode
		update_sight()

	if(client)
		client.screen -= item_module

	if(module_active == item_module)
		module_active = null

	switch(module_num)
		if(BORG_CHOOSE_MODULE_ONE)
			if(!(disabled_modules & BORG_MODULE_ALL_DISABLED))
				inv1.icon_state = initial(inv1.icon_state)
		if(BORG_CHOOSE_MODULE_TWO)
			if(!(disabled_modules & BORG_MODULE_TWO_DISABLED))
				inv2.icon_state = initial(inv2.icon_state)
		if(BORG_CHOOSE_MODULE_THREE)
			if(!(disabled_modules & BORG_MODULE_THREE_DISABLED))
				inv3.icon_state = initial(inv3.icon_state)

	if(item_module.item_flags & DROPDEL)
		item_module.item_flags &= ~DROPDEL //we shouldn't HAVE things with DROPDEL_1 in our modules, but better safe than runtiming horribly

	held_items[module_num] = null
	item_module.cyborg_unequip(src)
	item_module.forceMove(model) //Return item to configuration so it appears in its contents, so it can be taken out again.

	observer_screen_update(item_module, FALSE)
	hud_used.update_robot_modules_display()
	return TRUE

/**
 * Breaks the slot number, changing the icon.
 *
 * Arguments
 * * module_num - the slot number being repaired.
 */
/mob/living/silicon/robot/proc/break_cyborg_slot(module_num)
	if(is_invalid_module_number(module_num, TRUE))
		return FALSE

	if(held_items[module_num]) //If there's a held item, unequip it first.
		if(!unequip_module_from_slot(held_items[module_num], module_num)) //If we fail to unequip it, then don't continue
			return FALSE

	switch(module_num)
		if(BORG_CHOOSE_MODULE_ONE)
			if(disabled_modules & BORG_MODULE_ALL_DISABLED)
				return FALSE

			inv1.icon_state = "[initial(inv1.icon_state)] +b"
			disabled_modules |= BORG_MODULE_ALL_DISABLED

			playsound(src, 'sound/machines/warning-buzzer.ogg', 75, TRUE, TRUE)
			audible_message(span_warning("[src] sounds an alarm! \"CRITICAL ERROR: ALL modules OFFLINE.\""))

			if(builtInCamera)
				builtInCamera.camera_enabled = FALSE
				to_chat(src, span_userdanger("CRITICAL ERROR: Built in security camera OFFLINE."))

			to_chat(src, span_userdanger("CRITICAL ERROR: ALL modules OFFLINE."))

		if(BORG_CHOOSE_MODULE_TWO)
			if(disabled_modules & BORG_MODULE_TWO_DISABLED)
				return FALSE

			inv2.icon_state = "[initial(inv2.icon_state)] +b"
			disabled_modules |= BORG_MODULE_TWO_DISABLED

			playsound(src, 'sound/machines/warning-buzzer.ogg', 60, TRUE, TRUE)
			audible_message(span_warning("[src] sounds an alarm! \"SYSTEM ERROR: Module [module_num] OFFLINE.\""))
			to_chat(src, span_userdanger("SYSTEM ERROR: Module [module_num] OFFLINE."))

		if(BORG_CHOOSE_MODULE_THREE)
			if(disabled_modules & BORG_MODULE_THREE_DISABLED)
				return FALSE

			inv3.icon_state = "[initial(inv3.icon_state)] +b"
			disabled_modules |= BORG_MODULE_THREE_DISABLED

			playsound(src, 'sound/machines/warning-buzzer.ogg', 50, TRUE, TRUE)
			audible_message(span_warning("[src] sounds an alarm! \"SYSTEM ERROR: Module [module_num] OFFLINE.\""))
			to_chat(src, span_userdanger("SYSTEM ERROR: Module [module_num] OFFLINE."))

	return TRUE

/**
 * Breaks all of a cyborg's slots.
 */
/mob/living/silicon/robot/proc/break_all_cyborg_slots()
	for(var/cyborg_slot in 1 to 3)
		break_cyborg_slot(cyborg_slot)

/**
 * Repairs the slot number, updating the icon.
 *
 * Arguments
 * * module_num - the module number being repaired.
 */
/mob/living/silicon/robot/proc/repair_cyborg_slot(module_num)
	if(is_invalid_module_number(module_num, TRUE))
		return FALSE

	switch(module_num)
		if(BORG_CHOOSE_MODULE_ONE)
			if(!(disabled_modules & BORG_MODULE_ALL_DISABLED))
				return FALSE

			inv1.icon_state = initial(inv1.icon_state)
			disabled_modules &= ~BORG_MODULE_ALL_DISABLED
			if(builtInCamera)
				builtInCamera.camera_enabled = TRUE
				to_chat(src, span_notice("You hear your built in security camera focus adjust as it comes back online!"))
		if(BORG_CHOOSE_MODULE_TWO)
			if(!(disabled_modules & BORG_MODULE_TWO_DISABLED))
				return FALSE

			inv2.icon_state = initial(inv2.icon_state)
			disabled_modules &= ~BORG_MODULE_TWO_DISABLED
		if(BORG_CHOOSE_MODULE_THREE)
			if(!(disabled_modules & BORG_MODULE_THREE_DISABLED))
				return FALSE

			inv3.icon_state = initial(inv3.icon_state)
			disabled_modules &= ~BORG_MODULE_THREE_DISABLED

	to_chat(src, span_notice("ERROR CLEARED: Module [module_num] back online."))

	return TRUE

/**
 * Repairs all slots. Unbroken slots are unaffected.
 */
/mob/living/silicon/robot/proc/repair_all_cyborg_slots()
	for(var/cyborg_slot in 1 to 3)
		repair_cyborg_slot(cyborg_slot)

/**
 * Updates the observers's screens with cyborg itemss.
 * Arguments
 * * item_module - the item being added or removed from the screen
 * * add - whether or not the item is being added, or removed.
 */
/mob/living/silicon/robot/proc/observer_screen_update(obj/item/item_module, add = TRUE)
	if(observers?.len)
		for(var/M in observers)
			var/mob/dead/observe = M
			if(observe.client && observe.client.eye == src)
				if(add)
					observe.client.screen += item_module
				else
					observe.client.screen -= item_module
			else
				observers -= observe
				if(!observers.len)
					observers = null
					break

/**
 * Unequips the active held item, if there is one.
 */
/mob/living/silicon/robot/proc/uneq_active()
	if(module_active)
		unequip_module_from_slot(module_active, get_selected_module())

// Technically none of the items are dropped, only unequipped
/mob/living/silicon/robot/drop_all_held_items()
	for(var/cyborg_slot in 1 to length(held_items))
		if(!held_items[cyborg_slot])
			continue
		unequip_module_from_slot(held_items[cyborg_slot], cyborg_slot)

/**
 * Checks if the item is currently in a slot.
 *
 * If the item is found in a slot, this returns TRUE. Otherwise, it returns FALSE
 * Arguments
 * * item_module - the item being checked
 */
/mob/living/silicon/robot/proc/activated(obj/item/item_module)
	if(item_module in held_items)
		return TRUE
	if(item_module.loc in held_items) //Apparatus check
		return TRUE
	return FALSE

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

	/// The number of module slots we're checking
	var/max_number = 3
	if(!check_all_slots)
		if(disabled_modules & BORG_MODULE_ALL_DISABLED)
			max_number = 0
		else if(disabled_modules & BORG_MODULE_TWO_DISABLED)
			max_number = 1
		else if(disabled_modules & BORG_MODULE_THREE_DISABLED)
			max_number = 2

	return module_num < 1 || module_num > max_number

/**
 * Returns the slot number of the selected module, or zero if no modules are selected.
 */
/mob/living/silicon/robot/proc/get_selected_module()
	if(module_active)
		return held_items.Find(module_active)

	return 0

/**
 * Selects the module in the slot module_num.
 * Arguments
 * * module_num - the slot number being selected
 */
/mob/living/silicon/robot/proc/select_module(module_num)
	if(is_invalid_module_number(module_num) || !held_items[module_num]) //If the slot number is invalid, or there's nothing there, we have nothing to equip
		return FALSE

	switch(module_num)
		if(BORG_CHOOSE_MODULE_ONE)
			if(module_active != held_items[module_num])
				inv1.icon_state = "[initial(inv1.icon_state)] +a"
		if(BORG_CHOOSE_MODULE_TWO)
			if(module_active != held_items[module_num])
				inv2.icon_state = "[initial(inv2.icon_state)] +a"
		if(BORG_CHOOSE_MODULE_THREE)
			if(module_active != held_items[module_num])
				inv3.icon_state = "[initial(inv3.icon_state)] +a"
	module_active = held_items[module_num]
	return TRUE

/**
 * Deselects the module in the slot module_num.
 * Arguments
 * * module_num - the slot number being de-selected
 */
/mob/living/silicon/robot/proc/deselect_module(module_num)
	switch(module_num)
		if(BORG_CHOOSE_MODULE_ONE)
			if(module_active == held_items[module_num])
				inv1.icon_state = initial(inv1.icon_state)
		if(BORG_CHOOSE_MODULE_TWO)
			if(module_active == held_items[module_num])
				inv2.icon_state = initial(inv2.icon_state)
		if(BORG_CHOOSE_MODULE_THREE)
			if(module_active == held_items[module_num])
				inv3.icon_state = initial(inv3.icon_state)
	module_active = null
	return TRUE

/**
 * Toggles selection of the module in the slot module_num.
 * Arguments
 * * module_num - the slot number being toggled
 */
/mob/living/silicon/robot/proc/toggle_module(module_num)
	if(is_invalid_module_number(module_num))
		return FALSE

	if(module_num == get_selected_module())
		deselect_module(module_num)
		return TRUE

	if(module_active != held_items[module_num])
		deselect_module(get_selected_module())

	return select_module(module_num)

/**
 * Cycles through the list of enabled modules, deselecting the current one and selecting the next one.
 */
/mob/living/silicon/robot/proc/cycle_modules()
	var/slot_start = get_selected_module()
	var/slot_num
	if(slot_start)
		deselect_module(slot_start) //Only deselect if we have a selected slot.
		slot_num = slot_start + 1
	else
		slot_num = 1
		slot_start = 4

	while(slot_num != slot_start) //If we wrap around without finding any free slots, just give up.
		if(select_module(slot_num))
			return
		slot_num++
		if(slot_num > 4) // not >3 otherwise cycling with just one item on module 3 wouldn't work
			slot_num = 1 //Wrap around.

/mob/living/silicon/robot/perform_hand_swap()
	cycle_modules()
	return TRUE

/mob/living/silicon/robot/can_hold_items(obj/item/I)
	return (I && (I in model.modules)) //Only if it's part of our model.
