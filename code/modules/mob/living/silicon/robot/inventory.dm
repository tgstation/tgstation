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

	return put_in_hand(item_module, first_free_slot)

/mob/living/silicon/robot/put_in_hand(obj/item/item_module, hand_index, forced = FALSE, ignore_anim = TRUE, visuals_only = FALSE)
	. = ..()
	if(!.)
		return
	item_module.mouse_opacity = initial(item_module.mouse_opacity)
	observer_screen_update(item_module)

///Helper for cyborgs unequipping things.
/mob/living/silicon/robot/proc/deactivate_module(obj/item/item_module)
	transferItemToLoc(item_module, newloc = model)

/mob/living/silicon/robot/doUnEquip(obj/item/item_dropping, force, atom/newloc, no_move, invdrop, silent)
	//borgs can drop items that aren't part of the module (used for apparatus modules, the stored item isn't a module).
	if(isnull(model) || !(item_dropping in model.modules))
		return ..()

	if(newloc != model)
		to_chat(src, span_notice("You can't drop your [item_dropping.name] module."))
		return FALSE

	var/module_num = get_selected_module()
	. = ..()
	if(!.)
		return
	item_dropping.mouse_opacity = MOUSE_OPACITY_OPAQUE
	//this is the cyborg equivalent of dropped(), though we call that too in doUnEquip.
	item_dropping.cyborg_unequip(src)
	deselect_module(module_num)


/mob/living/silicon/robot/update_held_items()
	. = ..()
	if(isnull(client) || isnull(hud_used) || hud_used.hud_version == HUD_STYLE_NOHUD)
		return
	var/turf/our_turf = get_turf(src)

	for(var/obj/item/held in held_items)
		SET_PLANE(held, ABOVE_HUD_PLANE, our_turf)
		if(held_items[BORG_CHOOSE_MODULE_ONE] == held)
			held.screen_loc = inv1.screen_loc
		else if(held_items[BORG_CHOOSE_MODULE_TWO] == held)
			held.screen_loc = inv2.screen_loc
		else if(held_items[BORG_CHOOSE_MODULE_THREE] == held)
			held.screen_loc = inv3.screen_loc
		client.screen |= held

/mob/living/silicon/robot/put_in_hand_check(obj/item/item_equipping)
	return (item_equipping in model.modules)

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
		if(!deactivate_module(held_items[module_num])) //If we fail to unequip it, then don't continue
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
 * Unequips the active held item, if there is one.
 */
/mob/living/silicon/robot/proc/uneq_active()
	if(module_active)
		deactivate_module(module_active)

// Technically none of the items are dropped, only unequipped
/mob/living/silicon/robot/drop_all_held_items()
	for(var/cyborg_slot in 1 to length(held_items))
		if(!held_items[cyborg_slot])
			continue
		deactivate_module(held_items[cyborg_slot])

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
	return FALSE

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
			inv1.icon_state = initial(inv1.icon_state)
		if(BORG_CHOOSE_MODULE_TWO)
			inv2.icon_state = initial(inv2.icon_state)
		if(BORG_CHOOSE_MODULE_THREE)
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
	if(!observers?.len)
		return
	for(var/mob/dead/observe as anything in observers)
		if(!observe.client || observe.client.eye != src)
			observers -= observe
			if(!observers.len)
				observers = null
				return
		observe.client.screen += item_module
