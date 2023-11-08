/datum/component/lockable_storage
	/// The code that will open this safe
	var/lock_code
	/// Does this lock have a code set?
	var/lock_set = FALSE
	/// Is this lock currently being hacked?
	var/lock_hacking = FALSE
	///Boolean on whether the panel has been hacked open with a screwdriver.
	var/panel_open = FALSE
	///Boolean on whether the storage can be hacked open with a multitool.
	var/can_hack_open = TRUE

/datum/component/lockable_storage/Initialize(
	lock_code = "00000",
	lock_set = FALSE,
	can_hack_open = TRUE,
)
	. = ..()
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/atom_parent = parent
	parent.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
	atom_parent.update_appearance()

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

	if(!can_hack_open || !atom_storage.locked)
		return COMPONENT_BLOCK_TOOL_ATTACK
	if(tool.use_tool(src, user, 20))
		panel_open = !panel_open
		balloon_alert(user, "panel [panel_open ? "opened" : "closed"]")
		return COMPONENT_BLOCK_TOOL_ATTACK

/**
 * Called when a multitool is used on the parent, if it's hackable.
 */
/datum/component/lockable_storage/proc/on_multitool_act(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(!can_hack_open || !atom_storage.locked)
		return COMPONENT_BLOCK_TOOL_ATTACK
	if(!panel_open)
		balloon_alert(user, "unscrew closed!")
		return COMPONENT_BLOCK_TOOL_ATTACK
	balloon_alert(user, "hacking...")
	if(tool.use_tool(parent, user, 40 SECONDS))
		balloon_alert(user, "hacked")
		lock_set = FALSE
	return COMPONENT_BLOCK_TOOL_ATTACK

/// Update the icon state depending on if we're locked or not
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
		ui = new(user, src, "LockedStorage", "Safe")
		ui.open()

/datum/component/lockable_storage/ui_data(mob/user)
	var/list/data = list()
	var/atom/source = parent
	data["locked"] = atom_storage.locked
	data["lock_code"] = lock_code
	data["lock_set"] = lock_set
	return data

/datum/component/lockable_storage/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("enter_code")
			var/codes = params["input_code"]
			if(!isnum(codes))
				return TRUE
			if(codes != lock_code)
				return TRUE
			var/atom/source = parent
			source.atom_storage.locked = STORAGE_NOT_LOCKED
			return TRUE
		if("lock_safe")
			var/atom/source = parent
			if(source.atom_storage.locked)
				return TRUE
			source.atom_storage.locked = STORAGE_FULLY_LOCKED
			return TRUE
		if("set_code")
			var/codes = params["input_code"]
			if(!isnum(codes) || length(entered_code) != 5)
				return TRUE
			lock_code = codes
			return TRUE


//DEPRECATED CODE MUST REMOVE!
/obj/item/storage/secure/attack_self(mob/user)
	var/locked = atom_storage.locked
	user.set_machine(src)
	var/dat = "<TT><B>[src]</B><BR>\n\nLock Status: [locked ? "LOCKED" : "UNLOCKED"]"
	var/message = "Code"
	if (!lock_set)
		dat += "<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>"
	message = "[entered_code]"
	if (!locked)
		message = "*****"
	dat += "<HR>\n>[message]<BR>\n<A href='?src=[REF(src)];type=1'>1</A>-<A href='?src=[REF(src)];type=2'>2</A>-<A href='?src=[REF(src)];type=3'>3</A><BR>\n<A href='?src=[REF(src)];type=4'>4</A>-<A href='?src=[REF(src)];type=5'>5</A>-<A href='?src=[REF(src)];type=6'>6</A><BR>\n<A href='?src=[REF(src)];type=7'>7</A>-<A href='?src=[REF(src)];type=8'>8</A>-<A href='?src=[REF(src)];type=9'>9</A><BR>\n<A href='?src=[REF(src)];type=R'>R</A>-<A href='?src=[REF(src)];type=0'>0</A>-<A href='?src=[REF(src)];type=E'>E</A><BR>\n</TT>"
	user << browse(dat, "window=caselock;size=300x280")
