#define PERSONAL 1
#define DEPARTMENTAL 2
#define FREE_ACCESS 3

///Secure closets that can be hand crafted and have their access requirments modified
/obj/structure/closet/secure_closet/custom
	desc = "Secured closet with modifiable access"
	req_access = null
	material_drop = /obj/item/stack/sheet/iron
	material_drop_amount = 2

	/// access type selected
	var/access_type = FREE_ACCESS

	///physical reference of the players id card to check for PERSONAL access level
	var/obj/item/card/id/id_card = null

	/// should we prevent furthur access change
	var/access_locked = FALSE

	/// is the card reader installed in this machine
	var/card_reader_installed = FALSE

/obj/structure/closet/secure_closet/custom/Destroy()
	. = ..()
	id_card = null

/obj/structure/closet/secure_closet/custom/examine(mob/user)
	. = ..()
	. += "You can change its name & description with a pen"
	if(card_reader_installed)
		. += span_notice("Swipe your PDA with an ID card/Just ID to change access levels.")
	else
		. += span_notice("A card reader can be installed for further access control.")

/obj/structure/closet/secure_closet/custom/CheckParts(list/parts_list)
	for(var/obj/item/electronics/airlock/access_control in parts_list)
		electronics = access_control
		set_access()
		electronics.moveToNullspace()
		break

/obj/structure/closet/secure_closet/custom/multitool_act(mob/living/user, obj/item/tool)
	if(locked)
		balloon_alert(user, "unlock it first")
		return TRUE

	if(!card_reader_installed)
		balloon_alert(user, "needs card reader!")
		return

	access_locked = !access_locked
	balloon_alert(user, "access panel [access_locked ? "locked" : "unlocked"]")
	return TRUE

/// copy over access of electronics
/obj/structure/closet/secure_closet/custom/proc/set_access()
	if (electronics.one_access)
		req_one_access = electronics.accesses
	else
		req_access = electronics.accesses

/obj/structure/closet/secure_closet/custom/attackby(obj/item/attacking_item, mob/living/user)
	if(istype(attacking_item, /obj/item/airlock_painter))
		var/obj/item/airlock_painter/painter = attacking_item

		var/static/choices = list(
			"Bar" = "cabinet",
			"Cargo" = "qm",
			"Engineering" = "ce",
			"Hydroponics" = "hydro",
			"Medical" = "med",
			"Personal" = "personal closet",
			"Science" = "rd",
			"Security" = "cap",
			"Mining" = "mining",
			"Virology" = "bio_viro",
		)
		var/choice = tgui_input_list(user, "Set Closet Texture", "Texture", choices)
		if(isnull(choice))
			return TRUE

		if(!painter.use_paint(user))
			return TRUE
		icon_state = choices[choice]
		update_appearance()

	if(!broken && welded && istype(attacking_item, /obj/item/stock_parts/card_reader))
		if(card_reader_installed)
			balloon_alert(user, "already installed!")
			return TRUE

		if(do_after(user, 4 SECONDS))
			card_reader_installed = TRUE
			attacking_item.moveToNullspace()
			qdel(attacking_item)
			balloon_alert(user, "card reader installed")

		return TRUE
	else if(istype(attacking_item, /obj/item/pen))
		//you need to unlock to perform the operation else anyone can change name & description on a locked closet
		if(locked)
			balloon_alert(user, "unlock first!")
			return TRUE

		//you cant rename departmental lockers cause thats vandalism
		if(access_type != PERSONAL)
			balloon_alert(user, "not yours to rename!")
			return TRUE

		var/name_set = FALSE
		var/desc_set = FALSE

		var/str = tgui_input_text(user, "Personal Locker Name", "Locker Name")
		if(!isnull(str))
			name = str
			name_set = TRUE

		str = tgui_input_text(user, "Personal Locker Description", "Locker Description")
		if(!isnull(str))
			desc = str
			desc_set = TRUE

		var/bit_flag = NONE
		if(name_set)
			bit_flag |= UPDATE_NAME
		if(desc_set)
			bit_flag |= UPDATE_DESC
		if(bit_flag != NONE)
			update_appearance(bit_flag)

		return TRUE
	else if(card_reader_installed)
		if(attacking_item.tool_behaviour == TOOL_CROWBAR)
			if(!attacking_item.use_tool(src, user, 4 SECONDS))
				return TRUE

			new /obj/item/stock_parts/card_reader(drop_location())
			card_reader_installed = FALSE
			return TRUE

		if(broken)
			balloon_alert(user, "its broken!")
			return TRUE
		var/obj/item/card/id/id = null
		if(istype(attacking_item, /obj/item/card/id))
			id = attacking_item
		else if(istype(attacking_item, /obj/item/modular_computer/pda))
			var/obj/item/modular_computer/pda/pda = attacking_item
			id = pda.computer_id_slot
		if(isnull(id))
			return ..()
		else if(isnull(electronics))
			balloon_alert(user, "missing electronics!")
			return TRUE

		//you need to unlock to perform the operation else anyone can change access on a locked closet
		if(locked)
			balloon_alert(user, "unlock first!")
			return TRUE

		if(access_locked)
			balloon_alert(user, "access panel locked!")
			return TRUE

		//change the access type
		var/static/list/choices = list(
			"Personal" = PERSONAL,
			"Departmental" = DEPARTMENTAL,
			"None" = FREE_ACCESS
		)
		var/choice = tgui_input_list(user, "Set Access Type", "Access Type", choices)
		if(isnull(choice))
			return
		access_type = choices[choice]

		id_card = null
		switch(access_type)
			if(PERSONAL) //only the player who swiped their pda has access.
				id_card = id
			if(DEPARTMENTAL) //anyone who has the same access permissions as this id has access
				electronics.accesses = id.GetAccess()
				set_access()
			if(FREE_ACCESS) //free for all
				electronics.accesses = list()
				set_access()
		balloon_alert(user, "access is now [choice]")

		return TRUE

	return ..()

/obj/structure/closet/secure_closet/custom/togglelock(mob/living/user, silent)
	if(broken)
		balloon_alert(user, "its broken!")
		return

	if(access_type == PERSONAL)
		//physical id references don't match up
		if(user.get_idcard() != id_card)
			balloon_alert(user, "not your locker!")
			return

		//code copied from parent method
		if(iscarbon(user))
			add_fingerprint(user)
		locked = !locked
		user.visible_message(span_notice("[user] [locked ? null : "un"]locks [src]."),
						span_notice("You [locked ? null : "un"]lock [src]."))
		update_appearance()
	else
		return ..()

/obj/structure/closet/secure_closet/custom/atom_destruction(damage_flag)
	new /obj/item/stack/sheet/iron(drop_location(), 1)
	if(card_reader_installed)
		new /obj/item/stock_parts/card_reader(drop_location())
	. = ..()

/obj/structure/closet/secure_closet/custom/deconstruct(disassembled)
	if (!(flags_1 & NODECONSTRUCT_1) && card_reader_installed)
		new /obj/item/stock_parts/card_reader(drop_location())
	. = ..()

#undef PERSONAL
#undef DEPARTMENTAL
#undef FREE_ACCESS
