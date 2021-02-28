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
	/**
	 * The topmost piece of paper
	 *
	 * Additionaly, all are in contents. This is used for the paper
	 * displayed on the clipboard's icon and it is the one attacked,
	 * when attacking the clipboard.
	 * (As you can't organise contents directly in BYOND)
	 */
	var/obj/item/paper/toppaper

/obj/item/clipboard/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins putting [user.p_their()] head into the clip of \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS //The clipboard's clip is very strong. Industrial duty. Can kill a man easily.

/obj/item/clipboard/Initialize()
	update_appearance()
	. = ..()

/obj/item/clipboard/Destroy()
	QDEL_NULL(pen)
	QDEL_NULL(toppaper) //let movable/Destroy handle the rest
	return ..()

/obj/item/clipboard/examine()
	. = ..()
	if(pen)
		. += "<span class='notice'>Ctrl-click to remove [pen].</span>"
	if(toppaper)
		. += "<span class='notice'>Ctrl-click to remove the topmost paper, [toppaper].</span>"

/obj/item/clipboard/proc/remove_paper(obj/item/paper/Paper, mob/user)
	if(istype(Paper))
		Paper.forceMove(user.loc)
		user.put_in_hands(Paper)
		to_chat(user, "<span class='notice'>You remove [Paper] from [src].</span>")
		if(Paper == toppaper)
			toppaper = null
			var/obj/item/paper/newtop = locate(/obj/item/paper) in src
			if(newtop && (newtop != Paper))
				toppaper = newtop
			else
				toppaper = null
		update_icon()

/obj/item/clipboard/proc/remove_pen(mob/user)
	pen.forceMove(user.loc)
	user.put_in_hands(pen)
	to_chat(user, "<span class='notice'>You remove [pen] from [src].</span>")
	pen = null
	update_icon()

/obj/item/clipboard/AltClick(mob/user)
	..()
	if(toppaper)
		remove_paper(toppaper, user)
	else
		remove_pen(user)

/obj/item/clipboard/CtrlClick(mob/user)
	..()
	remove_pen(user)

/obj/item/clipboard/update_overlays()
	. = ..()
	if(toppaper)
		. += toppaper.icon_state
		. += toppaper.overlays
	if(pen)
		. += "clipboard_pen"
	. += "clipboard_over"

/obj/item/clipboard/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/paper))
		//Add paper into the clipboard
		if(!user.transferItemToLoc(W, src))
			return
		toppaper = W
		to_chat(user, "<span class='notice'>You clip [W] onto [src].</span>")
	else if(istype(W, /obj/item/pen) && !pen)
		//Add a pen into the clipboard, attack (write) if there is already one
		if(!usr.transferItemToLoc(W, src))
			return
		pen = W
		to_chat(usr, "<span class='notice'>You slot [W] into [src].</span>")
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

	var/obj/item/paper/P = toppaper
	data["top_paper"] = "[P]"
	data["top_paper_ref"] = "[REF(P)]"

	data["paper"] = list()
	data["paper_ref"] = list()
	for(P in src)
		if(P == toppaper)
			continue
		data["paper"] += "[P]"
		data["paper_ref"] += "[REF(P)]"

	return data

/obj/item/clipboard/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(usr.stat != CONSCIOUS || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	to_chat(usr, "Executing action [action]")
	switch(action)
		// Take the pen out
		if("remove_pen")
			if(pen)
				remove_pen(usr)
				. = TRUE
		// Take paper out
		if("remove_paper")
			var/obj/item/paper/P = locate(params["ref"]) in src
			if(istype(P))
				remove_paper(P, usr)
				. = TRUE
		// Look at (or edit) the paper
		if("edit_paper")
			var/obj/item/paper/P = locate(params["ref"]) in src
			if(istype(P))
				P.ui_interact(usr)
				update_icon()
				. = TRUE
		// Move paper to the top
		if("move_top_paper")
			var/obj/item/paper/P = locate(params["ref"]) in src
			if(istype(P))
				toppaper = P
				to_chat(usr, "<span class='notice'>You move [P] to the top.</span>")
				update_icon()
				. = TRUE
		// Rename the paper (it's a verb)
		if("rename_paper")
			var/obj/item/paper/P = locate(params["ref"]) in src
			if(istype(P))
				P.rename()
				update_icon()
				. = TRUE
