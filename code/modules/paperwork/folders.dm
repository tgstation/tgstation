/obj/item/folder
	name = "folder"
	desc = "A folder."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "folder"
	w_class = WEIGHT_CLASS_SMALL
	pressure_resistance = 2
	resistance_flags = FLAMMABLE
	/// The background color for tgui in hex (with a `#`)
	var/bg_color = "#7f7f7f"

/obj/item/folder/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins filing an imaginary death warrant! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/folder/Initialize(mapload)
	update_icon()
	. = ..()

/obj/item/folder/Destroy()
	for(var/obj/important_thing in contents)
		if(!(important_thing.resistance_flags & INDESTRUCTIBLE))
			continue
		important_thing.forceMove(drop_location()) //don't destroy round critical content such as objective documents.
	return ..()

/obj/item/folder/examine()
	. = ..()
	if(length(contents))
		. += span_notice("Right-click to remove [contents[1]].")

/obj/item/folder/proc/rename(mob/user)
	if(!user.is_literate())
		to_chat(user, span_notice("You scribble illegibly on the cover of [src]!"))
		return

	var/inputvalue = tgui_input_text(user, "What would you like to label the folder?", "Folder Labelling", max_length = MAX_NAME_LEN)

	if(!inputvalue)
		return

	if(user.canUseTopic(src, BE_CLOSE))
		name = "folder[(inputvalue ? " - '[inputvalue]'" : null)]"

/obj/item/folder/proc/remove_item(obj/item/Item, mob/user)
	if(istype(Item))
		Item.forceMove(user.loc)
		user.put_in_hands(Item)
		to_chat(user, span_notice("You remove [Item] from [src]."))
		update_icon()

/obj/item/folder/attack_hand(mob/user, list/modifiers)
	if(length(contents) && LAZYACCESS(modifiers, RIGHT_CLICK))
		remove_item(contents[1], user)
		return TRUE
	. = ..()

/obj/item/folder/update_overlays()
	. = ..()
	if(contents.len)
		. += "folder_paper"

/obj/item/folder/attackby(obj/item/weapon, mob/user, params)
	if(burn_paper_product_attackby_check(weapon, user))
		return
	if(istype(weapon, /obj/item/paper) || istype(weapon, /obj/item/photo) || istype(weapon, /obj/item/documents))
		//Add paper, photo or documents into the folder
		if(!user.transferItemToLoc(weapon, src))
			return
		to_chat(user, span_notice("You put [weapon] into [src]."))
		update_appearance()
	else if(istype(weapon, /obj/item/pen))
		rename(user)

/obj/item/folder/attack_self(mob/user)
	add_fingerprint(usr)
	ui_interact(user)
	return

/obj/item/folder/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Folder")
		ui.open()

/obj/item/folder/ui_data(mob/user)
	var/list/data = list()
	if(istype(src, /obj/item/folder/syndicate))
		data["theme"] = "syndicate"
	data["bg_color"] = "[bg_color]"
	data["folder_name"] = "[name]"

	data["contents"] = list()
	data["contents_ref"] = list()
	for(var/Content in src)
		data["contents"] += "[Content]"
		data["contents_ref"] += "[REF(Content)]"

	return data

/obj/item/folder/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(usr.stat != CONSCIOUS || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	switch(action)
		// Take item out
		if("remove")
			var/obj/item/Item = locate(params["ref"]) in src
			remove_item(Item, usr)
			. = TRUE
		// Inspect the item
		if("examine")
			var/obj/item/Item = locate(params["ref"]) in src
			if(istype(Item))
				usr.examinate(Item)
				. = TRUE
