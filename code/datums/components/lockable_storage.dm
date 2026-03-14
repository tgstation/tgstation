/**
 * ##lockable_storage
 * Adds a UI to the object that triggers when you use it in hand (if item) or attack (everything else).
 * The UI is a lock that, when unlocked, allows you to access the contents inside of it.
 * When using this, make sure you have icons for `on_update_icon_state`.
 */
/datum/component/lockable_storage
	///Boolean on whether the panel has been hacked open with a screwdriver.
	var/panel_open = FALSE
	///The number currently sitting in the briefcase's panel.
	var/numeric_input

	///The code that will open this safe, set by usually players.
	///Importantly, can be null if there's no password.
	var/lock_code
	///Boolean on whether the storage can be hacked open with a multitool.
	var/can_hack_open

/datum/component/lockable_storage/Initialize(
	lock_code,
	can_hack_open = TRUE,
)
	. = ..()
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/atom_parent = parent
	atom_parent.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

	if(!atom_parent.atom_storage)
		atom_parent.create_storage(
			max_specific_storage = WEIGHT_CLASS_GIGANTIC,
			max_total_storage = 14,
			canthold = list(/obj/item/storage/briefcase/secure),
		)

	src.can_hack_open = can_hack_open
	set_lock_code(lock_code)

/datum/component/lockable_storage/RegisterWithParent()
	. = ..()
	if(can_hack_open)
		RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), PROC_REF(on_screwdriver_act))
		RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), PROC_REF(on_multitool_act))

	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(on_update_icon_state))
	RegisterSignal(parent, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag))

	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_interact))
	else
		RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_interact))

/datum/component/lockable_storage/UnregisterFromParent()
	if(can_hack_open)
		UnregisterSignal(parent, list(
			COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER),
			COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL),
		))
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM,
		COMSIG_ATOM_UPDATE_ICON_STATE,
		COMSIG_ATOM_EMAG_ACT,
	))

	if(isitem(parent))
		UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)
	else
		UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND)
	return ..()

/**
 * Adds context screentips to the locked item.
 * Arguments:
 * * source - The item that will display its screentip
 * * context - The list of context that will be displayed. We add onto this list for it to show up.
 * * held_item - The item in your hand, which in this case should be a screwdriver or multitool, if necessary.
 * * user - The user who is going to see the screentips.
 */
/datum/component/lockable_storage/proc/on_requesting_context_from_item(datum/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER
	if(isnull(held_item))
		if(source in user.held_items)
			context[SCREENTIP_CONTEXT_LMB] = "Open storage"
			return CONTEXTUAL_SCREENTIP_SET
		context[SCREENTIP_CONTEXT_RMB] = "Open storage"
		return CONTEXTUAL_SCREENTIP_SET

	if(can_hack_open)
		switch(held_item.tool_behaviour)
			if(TOOL_SCREWDRIVER)
				context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] panel"
				return CONTEXTUAL_SCREENTIP_SET
			if(TOOL_MULTITOOL)
				context[SCREENTIP_CONTEXT_LMB] = "Hack panel open"
				return CONTEXTUAL_SCREENTIP_SET

	return NONE

///Called when examining the storage item.
/datum/component/lockable_storage/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(can_hack_open)
		examine_list += "The service panel is currently <b>[panel_open ? "unscrewed" : "screwed shut"]</b>."

/**
 * Called when a screwdriver is used on the parent, if it's hackable.
 */
/datum/component/lockable_storage/proc/on_screwdriver_act(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(!can_hack_open || !source.atom_storage.locked)
		return NONE

	panel_open = !panel_open
	tool.play_tool_sound(source)
	source.balloon_alert(user, "panel [panel_open ? "opened" : "closed"]")
	return ITEM_INTERACT_SUCCESS

/**
 * Called when a multitool is used on the parent, if it's hackable.
 * Checks if we can start hacking and, if so, will begin the hacking process.
 */
/datum/component/lockable_storage/proc/on_multitool_act(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(!can_hack_open || !source.atom_storage.locked)
		return NONE
	if(!panel_open)
		source.balloon_alert(user, "panel closed!")
		return ITEM_INTERACT_BLOCKING
	source.balloon_alert(user, "hacking...")
	INVOKE_ASYNC(src, PROC_REF(hack_open), source, user, tool)
	return ITEM_INTERACT_SUCCESS

///Does a do_after to hack the storage open, takes a long time cause idk.
/datum/component/lockable_storage/proc/hack_open(atom/source, mob/user, obj/item/tool)
	if(!tool.use_tool(parent, user, 40 SECONDS, volume = 50))
		return
	source.balloon_alert(user, "hacked")
	set_lock_code(null)

/datum/component/lockable_storage/proc/break_lock()
	can_hack_open = FALSE // since it's broken for good
	lock_code = null

	var/obj/source = parent
	source.obj_flags |= EMAGGED
	source.atom_storage.locked = STORAGE_NOT_LOCKED
	SEND_SIGNAL(source, COMSIG_LOCKABLE_STORAGE_SET_CODE, lock_code)
	source.update_appearance()

/datum/component/lockable_storage/proc/on_emag(obj/source, mob/user, obj/item/card/emag/emag_card)
	SIGNAL_HANDLER

	if(!source.atom_storage.locked)
		return FALSE

	if(source.obj_flags & EMAGGED)
		return FALSE

	source.visible_message(span_warning("Sparks fly from [source]!"), blind_message = span_hear("You hear a faint electrical spark."))
	source.balloon_alert(user, "lock destroyed")
	playsound(source, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	break_lock()
	return ITEM_INTERACT_SUCCESS

/**
 * Sets the lock code for this storage and updates the locked state accordingly
 * Arguments:
 * * new_code - The new lock code to set, can be null to remove the code
 */
/datum/component/lockable_storage/proc/set_lock_code(new_code, mob/living/user)
	var/obj/source = parent

	// Can't set lock code if the electronics are emagged
	if(source.obj_flags & EMAGGED)
		return FALSE

	lock_code = new_code
	SEND_SIGNAL(source, COMSIG_LOCKABLE_STORAGE_SET_CODE, new_code)
	var/lock_state = lock_code ? STORAGE_FULLY_LOCKED : STORAGE_NOT_LOCKED
	source.atom_storage.set_locked(lock_state)
	source.update_appearance()

	if(istype(user) && new_code)
		to_chat(user, span_notice("You set the [source] pincode to [lock_code]."))

	return TRUE

///Updates the icon state depending on if we're locked or not.
/datum/component/lockable_storage/proc/on_update_icon_state(obj/source)
	SIGNAL_HANDLER

	if(source.obj_flags & EMAGGED)
		source.icon_state = "[source.base_icon_state]_broken"
	else
		source.icon_state = "[source.base_icon_state][source.atom_storage.locked ? "_locked" : null]"

///Called when interacted with in-hand or on attack, opens the UI.
/datum/component/lockable_storage/proc/on_interact(atom/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(ui_interact), user)

/datum/component/lockable_storage/ui_interact(mob/user, datum/tgui/ui)
	var/obj/source = parent
	if(source.obj_flags & EMAGGED)
		ui?.close()
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LockedSafe", parent)
		ui.open()

/datum/component/lockable_storage/ui_data(mob/user)
	var/list/data = list()
	var/atom/source = parent
	data["input_code"] = numeric_input || "*****"
	data["locked"] = source.atom_storage.locked
	data["lock_code"] = !!lock_code //we just need to know if it has one.
	return data

/datum/component/lockable_storage/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(action != "keypad")
		return TRUE
	var/digit = params["digit"]
	switch(digit)
		//locking it back up
		if("C")
			var/atom/source = parent
			numeric_input = ""
			//you can't lock it if it's already locked or lacks a lock code.
			if(source.atom_storage.locked || isnull(lock_code))
				return TRUE
			source.atom_storage.set_locked(STORAGE_FULLY_LOCKED)
			return TRUE
		//setting a password & unlocking
		if("E")
			//inputting a new code if there isn't one set.
			if(!lock_code)
				if(length(numeric_input) != 5)
					return TRUE
				set_lock_code(numeric_input, usr)
				numeric_input = ""
				return TRUE
			//unlocking the current code.
			if(numeric_input != lock_code)
				return TRUE
			var/atom/source = parent
			source.atom_storage.set_locked(STORAGE_NOT_LOCKED)
			numeric_input = ""
			return TRUE
		//putting digits in.
		if("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
			if(length(numeric_input) == 5)
				return
			numeric_input += digit
			return TRUE
