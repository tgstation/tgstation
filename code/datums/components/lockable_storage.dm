/datum/component/lockable_storage
	///Boolean on whether the panel has been hacked open with a screwdriver.
	var/panel_open = FALSE
	///The number currently sitting in the briefcase's panel.
	var/numeric_input

	///The code that will open this safe, set by usually players.
	///Importantly, can be null if there's no password.
	var/lock_code
	///Does this lock have a code set?
	var/lock_set
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
	atom_parent.update_appearance()

	src.lock_code = lock_code
	if(lock_code)
		lock_set = TRUE
	src.can_hack_open = can_hack_open

/datum/component/lockable_storage/RegisterWithParent()
	. = ..()
	if(can_hack_open)
		RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), PROC_REF(on_screwdriver_act))
		RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), PROC_REF(on_multitool_act))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(on_update_icon_state))

	RegisterSignals(parent, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_ITEM_ATTACK_SELF), PROC_REF(on_interact))

/datum/component/lockable_storage/UnregisterFromParent()
	. = ..()
	if(can_hack_open)
		UnregisterSignal(parent, list(
			COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER),
			COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL),
		))
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM,
		COMSIG_ATOM_UPDATE_ICON_STATE,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ITEM_ATTACK_SELF,
	))

/**
 * Adds context screentips to the locked item.
 * Arguments:
 * * source - refers to item that will display its screentip
 * * context - refers to, in this case, an item that can be used to hack the storage item open.
 * * held_item - refers to the item in your hand, which is hopefully an ingredient
 * * user - refers to user who will see the screentip when the proper context and tool are there
 */
/datum/component/lockable_storage/proc/on_requesting_context_from_item(datum/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER
	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Open storage"
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
		return COMPONENT_BLOCK_TOOL_ATTACK

	panel_open = !panel_open
	source.balloon_alert(user, "panel [panel_open ? "opened" : "closed"]")
	return COMPONENT_BLOCK_TOOL_ATTACK

/**
 * Called when a multitool is used on the parent, if it's hackable.
 * Checks if we can start hacking and, if so, will begin the hacking process.
 */
/datum/component/lockable_storage/proc/on_multitool_act(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(!can_hack_open || !source.atom_storage.locked)
		return COMPONENT_BLOCK_TOOL_ATTACK
	if(!panel_open)
		source.balloon_alert(user, "panel closed!")
		return COMPONENT_BLOCK_TOOL_ATTACK
	source.balloon_alert(user, "hacking...")
	INVOKE_ASYNC(src, PROC_REF(hack_open), source, user, tool)
	return COMPONENT_BLOCK_TOOL_ATTACK

///Does a do_after to hack the storage open, takes a long time cause idk.
/datum/component/lockable_storage/proc/hack_open(atom/source, mob/user, obj/item/tool)
	if(!tool.use_tool(parent, user, 40 SECONDS))
		return
	source.balloon_alert(user, "hacked")
	lock_set = FALSE

///Updates the icon state depending on if we're locked or not.
/datum/component/lockable_storage/proc/on_update_icon_state(obj/source)
	SIGNAL_HANDLER
	source.icon_state = "[source.base_icon_state][source.atom_storage.locked ? "_locked" : null]"

///Called when interacted with in-hand or on attack, opens the UI.
/datum/component/lockable_storage/proc/on_interact(atom/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(ui_interact), user)

/datum/component/lockable_storage/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LockedSafe", "Safe")
		ui.open()

/datum/component/lockable_storage/ui_data(mob/user)
	var/list/data = list()
	var/atom/source = parent
	data["input_code"] = numeric_input || "*****"
	data["locked"] = source.atom_storage.locked
	data["lock_code"] = lock_code
	data["lock_set"] = lock_set
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
			source.atom_storage.locked = STORAGE_FULLY_LOCKED
			source.atom_storage.hide_contents(usr)
			source.update_appearance(UPDATE_ICON)
			return TRUE
		//setting a password & unlocking
		if("E")
			//inputting a new code if there isn't one set.
			if(!lock_code)
				if(length(numeric_input) != 5)
					return TRUE
				lock_code = numeric_input
				lock_set = TRUE
				numeric_input = ""
				return TRUE
			//unlocking the current code.
			if(numeric_input != lock_code)
				return TRUE
			var/atom/source = parent
			source.atom_storage.locked = STORAGE_NOT_LOCKED
			numeric_input = ""
			source.update_appearance(UPDATE_ICON)
			return TRUE
		//putting digits in.
		if("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
			if(length(numeric_input) == 5)
				return
			numeric_input += digit
			return TRUE
