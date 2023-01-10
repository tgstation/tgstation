/**
 * Clipboard
 */
/obj/item/clipboard
	name = "clipboard"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "clipboard"
	inhand_icon_state = "clipboard"
	worn_icon_state = "clipboard"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FLAMMABLE
	/// The stored pen
	var/obj/item/pen/pen
	/// Is the pen integrated?
	var/integrated_pen = FALSE
	/**
	 * Weakref of the topmost piece of paper
	 *
	 * This is used for the paper displayed on the clipboard's icon
	 * and it is the one attacked, when attacking the clipboard.
	 * (As you can't organise contents directly in BYOND)
	 */
	var/datum/weakref/toppaper_ref

/obj/item/clipboard/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins putting [user.p_their()] head into the clip of \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS //The clipboard's clip is very strong. Industrial duty. Can kill a man easily.

/obj/item/clipboard/Initialize(mapload)
	update_appearance()
	. = ..()

/obj/item/clipboard/Destroy()
	QDEL_NULL(pen)
	return ..()

/obj/item/clipboard/examine()
	. = ..()
	if(!integrated_pen && pen)
		. += span_notice("Alt-click to remove [pen].")
	var/obj/item/paper/toppaper = toppaper_ref?.resolve()
	if(toppaper)
		. += span_notice("Right-click to remove [toppaper].")

/// Take out the topmost paper
/obj/item/clipboard/proc/remove_paper(obj/item/paper/paper, mob/user)
	if(!istype(paper))
		return
	paper.forceMove(user.loc)
	user.put_in_hands(paper)
	to_chat(user, span_notice("You remove [paper] from [src]."))
	var/obj/item/paper/toppaper = toppaper_ref?.resolve()
	if(paper == toppaper)
		UnregisterSignal(toppaper, COMSIG_ATOM_UPDATED_ICON)
		toppaper_ref = null
		var/obj/item/paper/newtop = locate(/obj/item/paper) in src
		if(newtop && (newtop != paper))
			toppaper_ref = WEAKREF(newtop)
		else
			toppaper_ref = null
	update_icon()

/obj/item/clipboard/proc/remove_pen(mob/user)
	pen.forceMove(user.loc)
	user.put_in_hands(pen)
	to_chat(user, span_notice("You remove [pen] from [src]."))
	pen = null
	update_icon()

/obj/item/clipboard/AltClick(mob/user)
	..()
	if(pen)
		if(integrated_pen)
			to_chat(user, span_warning("You can't seem to find a way to remove [src]'s [pen]."))
		else
			remove_pen(user)

/obj/item/clipboard/update_overlays()
	. = ..()
	var/obj/item/paper/toppaper = toppaper_ref?.resolve()
	if(toppaper)
		. += toppaper.icon_state
		. += toppaper.overlays
	if(pen)
		. += "clipboard_pen"
	. += "clipboard_over"

/obj/item/clipboard/attack_hand(mob/user, list/modifiers)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		var/obj/item/paper/toppaper = toppaper_ref?.resolve()
		remove_paper(toppaper, user)
		return TRUE
	. = ..()

/obj/item/clipboard/attackby(obj/item/weapon, mob/user, params)
	var/obj/item/paper/toppaper = toppaper_ref?.resolve()
	if(istype(weapon, /obj/item/paper))
		//Add paper into the clipboard
		if(!user.transferItemToLoc(weapon, src))
			return
		if(toppaper)
			UnregisterSignal(toppaper, COMSIG_ATOM_UPDATED_ICON)
		RegisterSignal(weapon, COMSIG_ATOM_UPDATED_ICON, PROC_REF(on_top_paper_change))
		toppaper_ref = WEAKREF(weapon)
		to_chat(user, span_notice("You clip [weapon] onto [src]."))
	else if(istype(weapon, /obj/item/pen) && !pen)
		//Add a pen into the clipboard, attack (write) if there is already one
		if(!usr.transferItemToLoc(weapon, src))
			return
		pen = weapon
		to_chat(usr, span_notice("You slot [weapon] into [src]."))
	else if(toppaper)
		toppaper.attackby(user.get_active_held_item(), user)
	update_appearance()

/obj/item/clipboard/attack_self(mob/user)
	add_fingerprint(usr)
	ui_interact(user)
	return

/obj/item/clipboard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Clipboard")
		ui.open()

/obj/item/clipboard/ui_data(mob/user)
	// prepare data for TGUI
	var/list/data = list()
	data["pen"] = "[pen]"
	data["integrated_pen"] = integrated_pen

	var/obj/item/paper/toppaper = toppaper_ref?.resolve()
	data["top_paper"] = "[toppaper]"
	data["top_paper_ref"] = "[REF(toppaper)]"

	data["paper"] = list()
	data["paper_ref"] = list()
	for(var/obj/item/paper/paper in src)
		if(paper == toppaper)
			continue
		data["paper"] += "[paper]"
		data["paper_ref"] += "[REF(paper)]"

	return data

/obj/item/clipboard/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(usr.stat != CONSCIOUS || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	switch(action)
		// Take the pen out
		if("remove_pen")
			if(pen)
				if(!integrated_pen)
					remove_pen(usr)
				else
					to_chat(usr, span_warning("You can't seem to find a way to remove [src]'s [pen]."))
				. = TRUE
		// Take paper out
		if("remove_paper")
			var/obj/item/paper/paper = locate(params["ref"]) in src
			if(istype(paper))
				remove_paper(paper, usr)
				. = TRUE
		// Look at (or edit) the paper
		if("edit_paper")
			var/obj/item/paper/paper = locate(params["ref"]) in src
			if(istype(paper))
				paper.ui_interact(usr)
				update_icon()
				. = TRUE
		// Move paper to the top
		if("move_top_paper")
			var/obj/item/paper/paper = locate(params["ref"]) in src
			if(istype(paper))
				toppaper_ref = WEAKREF(paper)
				to_chat(usr, span_notice("You move [paper] to the top."))
				update_icon()
				. = TRUE
		// Rename the paper (it's a verb)
		if("rename_paper")
			var/obj/item/paper/paper = locate(params["ref"]) in src
			if(istype(paper))
				paper.rename()
				update_icon()
				. = TRUE

/**
 * This is a simple proc to handle calling update_icon() upon receiving the top paper's `COMSIG_ATOM_UPDATE_APPEARANCE`.
 */
/obj/item/clipboard/proc/on_top_paper_change()
	SIGNAL_HANDLER
	update_appearance()
