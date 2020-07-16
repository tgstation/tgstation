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
  * Finds the first available slot and attemps to put item I in it.
  *
  * Arguments
  * * I - the item being equipped to a slot.
  */
/mob/living/silicon/robot/proc/activate_module(obj/item/I)
	if(!I)
		return FALSE

	if(!(I in module.modules))
		return FALSE

	if(activated(I))
		to_chat(src, "<span class='warning'>That module is already activated.</span>")
		return FALSE
	
	if(disabled_modules & BORG_MODULE_ALL_DISABLED)
		to_chat(src, "<span class='warning'>All modules are disabled!</span>")
		return FALSE

	/// What's the first free slot for the borg?
	var/first_free_slot = 0
	if(!held_items[1])
		first_free_slot = 1
	else if(!held_items[2])
		first_free_slot = 2
	else if(!held_items[3])
		first_free_slot = 3

	if(is_invalid_module_number(first_free_slot))
		to_chat(src, "<span class='warning'>Deactivate a module first!</span>")
		return FALSE

	return equip_module_to_slot(I, first_free_slot)

/**
  * Is passed an item and a module slot. Equips the item to that borg slot.
  *
  * Arguments
  * * I - the item being equipped to a slot
  * * module_num - the slot number being equipped to.
  */
/mob/living/silicon/robot/proc/equip_module_to_slot(obj/item/I, module_num)
	switch(module_num)
		if(1)
			I.screen_loc = inv1.screen_loc
		if(2)
			I.screen_loc = inv2.screen_loc
		if(3)
			I.screen_loc = inv3.screen_loc

	held_items[module_num] = I		
	I.equipped(src, ITEM_SLOT_HANDS)
	I.mouse_opacity = initial(I.mouse_opacity)
	I.layer = ABOVE_HUD_LAYER
	I.plane = ABOVE_HUD_PLANE
	I.forceMove(src)

	if(istype(I, /obj/item/borg/sight))
		var/obj/item/borg/sight/S = I
		sight_mode |= S.sight_mode
		update_sight()

	observer_screen_update(I,TRUE)
	return TRUE

/**
  * Unequips item I from slot module_num. Deletes it if delete_after = TRUE.
  *
  * Arguments
  * * I - the item being unequipped
  * * module_num - the slot number being unequipped.
  */
/mob/living/silicon/robot/proc/unequip_module_from_slot(obj/item/I, module_num)
	if(!I)
		return FALSE

	if(!(I in module.modules)) 
		return FALSE

	I.mouse_opacity = MOUSE_OPACITY_OPAQUE

	if(istype(I, /obj/item/storage/bag/tray/))
		SEND_SIGNAL(I, COMSIG_TRY_STORAGE_QUICK_EMPTY)
	if(istype(I, /obj/item/borg/sight))
		var/obj/item/borg/sight/S = I
		sight_mode &= ~S.sight_mode
		update_sight()

	if(client)
		client.screen -= I

	if(module_active == I)
		module_active = null

	switch(module_num)
		if(1)
			if(!(disabled_modules & BORG_MODULE_ALL_DISABLED))
				inv1.icon_state = "inv1"
		if(2)
			if(!(disabled_modules & BORG_MODULE_TWO_DISABLED))
				inv2.icon_state = "inv2"
		if(3)
			if(!(disabled_modules & BORG_MODULE_THREE_DISABLED))
				inv3.icon_state = "inv3"

	if(I.item_flags & DROPDEL)
		I.item_flags &= ~DROPDEL //we shouldn't HAVE things with DROPDEL_1 in our modules, but better safe than runtiming horribly
		
	held_items[module_num] = null
	I.cyborg_unequip(src)
	I.forceMove(module) //Return item to module so it appears in its contents, so it can be taken out again.

	observer_screen_update(I, FALSE)
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
		if(1)
			if(disabled_modules & BORG_MODULE_ALL_DISABLED)
				return FALSE
		
			inv1.icon_state = "inv1 +b"
			disabled_modules |= BORG_MODULE_ALL_DISABLED

		if(2)
			if(disabled_modules & BORG_MODULE_TWO_DISABLED)
				return FALSE
		
			inv2.icon_state = "inv2 +b"
			disabled_modules |= BORG_MODULE_TWO_DISABLED

		if(3)
			if(disabled_modules & BORG_MODULE_THREE_DISABLED)
				return FALSE
		
			inv3.icon_state = "inv3 +b"
			disabled_modules |= BORG_MODULE_THREE_DISABLED

	playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, TRUE, TRUE)
	audible_message("<span class='warning'>[src] sounds an alarm! \"SYSTEM ERROR: Module [module_num] OFFLINE.\"</span>", self_message = null)
	to_chat(src, "<span class='userdanger'>SYSTEM ERROR: Module [module_num] OFFLINE.</span>")

	return TRUE
	

/**
  * Breaks all of a cyborg's slots. 
  */
/mob/living/silicon/robot/proc/break_all_cyborg_slots()
	for(var/S in 1 to 3)
		break_cyborg_slot(S)

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
		if(1)
			if(!(disabled_modules & BORG_MODULE_ALL_DISABLED))
				return FALSE
		
			inv1.icon_state = "inv1"
			disabled_modules &= ~BORG_MODULE_ALL_DISABLED
		if(2)
			if(!(disabled_modules & BORG_MODULE_TWO_DISABLED))
				return FALSE
		
			inv2.icon_state = "inv2"
			disabled_modules &= ~BORG_MODULE_TWO_DISABLED
		if(3)
			if(!(disabled_modules & BORG_MODULE_THREE_DISABLED))
				return FALSE
		
			inv3.icon_state = "inv3"
			disabled_modules &= ~BORG_MODULE_THREE_DISABLED

	to_chat(src, "<span class='notice'>ERROR CLEARED: Module [module_num] back online.</span>")

	return TRUE

/**
  * Repairs all slots. Unbroken slots are unaffected.
  */
/mob/living/silicon/robot/proc/repair_all_cyborg_slots()
	for(var/S in 1 to 3)
		repair_cyborg_slot(S)

/**
  * Updates the observers's screens with cyborg itemss.
  * Arguments
  * * I - the item being added or removed from the screen
  * * add - whether or not the item is being added, or removed.
  */
/mob/living/silicon/robot/proc/observer_screen_update(obj/item/I,add = TRUE)
	if(observers && observers.len)
		for(var/M in observers)
			var/mob/dead/observe = M
			if(observe.client && observe.client.eye == src)
				if(add)
					observe.client.screen += I
				else
					observe.client.screen -= I
			else
				observers -= observe
				if(!observers.len)
					observers = null
					break

/**
  * Unequips the active held item.
  */
/mob/living/silicon/robot/proc/uneq_active()
	unequip_module_from_slot(module_active, get_selected_module())

/**
  * Unequips all held items.
  */
/mob/living/silicon/robot/proc/uneq_all()
	for(var/I in 1 to 3)
		if(held_items[I])
			unequip_module_from_slot(held_items[I], I)

/**
  * Checks if the item is currently in a slot.
  * 
  * If the item is found in a slot, this returns TRUE. Otherwise, it returns FALSE
  * Arguments
  * * I - the item being checked
  */
/mob/living/silicon/robot/proc/activated(obj/item/I)
	if(I in held_items)
		return TRUE
	return FALSE

/**
  * Checks if the provided module number is a valid number.
  * 
  * If the number is between 1 and 3, or between 1 and the number of disabled
  * modules (if check_all_slots is true), then it returns FALSE. Otherwise, it returns TRUE.
  * Arguments
  * * module_num - the passed module num that is checked for validity.
  * * check_all_slots - TRUE = the proc checks all slots | FALSE = the proc only checks un-disabled slots
  */
/mob/living/silicon/robot/proc/is_invalid_module_number(module_num, check_all_slots = FALSE)
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
	if(!held_items[module_num])
		return FALSE

	switch(module_num)
		if(1)
			if(module_active != held_items[module_num])
				inv1.icon_state = "inv1 +a"
		if(2)
			if(module_active != held_items[module_num])
				inv2.icon_state = "inv2 +a"
		if(3)
			if(module_active != held_items[module_num])
				inv3.icon_state = "inv3 +a"
	module_active = held_items[module_num]

/**
  * Deselects the module in the slot module_num.
  * Arguments
  * * module_num - the slot number being de-selected
  */
/mob/living/silicon/robot/proc/deselect_module(module_num)
	switch(module_num)
		if(1)
			if(module_active == held_items[module_num])
				inv1.icon_state = "inv1"
		if(2)
			if(module_active == held_items[module_num])
				inv2.icon_state = "inv2"
		if(3)
			if(module_active == held_items[module_num])
				inv3.icon_state = "inv3"
	module_active = null

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

/mob/living/silicon/robot/swap_hand()
	cycle_modules()
