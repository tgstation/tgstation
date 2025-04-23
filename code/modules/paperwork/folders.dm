/obj/item/folder
	name = "folder"
	desc = "A folder."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "folder"
	w_class = WEIGHT_CLASS_SMALL
	pressure_resistance = 2
	resistance_flags = FLAMMABLE
	/// The background color for tgui in hex (with a `#`)
	var/bg_color = "#7f7f7f"
	/// A typecache of the objects that can be inserted into a folder
	var/static/list/folder_insertables = typecacheof(list(
		/obj/item/paper,
		/obj/item/photo,
		/obj/item/documents,
		/obj/item/paperwork,
	))
	/// Do we hide the contents on examine?
	var/contents_hidden = FALSE
	/// icon_state of overlay for papers inside of this folder
	var/paper_overlay_state = "folder_paper"

/obj/item/folder/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins filing an imaginary death warrant! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/folder/Initialize(mapload)
	update_icon()
	. = ..()
	AddElement(/datum/element/burn_on_item_ignition)

/obj/item/folder/Destroy()
	for(var/obj/important_thing in contents)
		if(!(important_thing.resistance_flags & INDESTRUCTIBLE))
			continue
		important_thing.forceMove(drop_location()) //don't destroy round critical content such as objective documents.
	return ..()

/obj/item/folder/examine()
	. = ..()
	if(length(contents) && !contents_hidden)
		. += span_notice("<b>Right-click</b> to remove [contents[1]].")

/obj/item/folder/proc/rename(mob/user, obj/item/writing_instrument)
	if(!user.can_write(writing_instrument))
		return

	var/inputvalue = tgui_input_text(user, "What would you like to label the folder?", "Folder Labelling", max_length = MAX_NAME_LEN)

	if(!inputvalue)
		return

	if(user.can_perform_action(src))
		name = "folder[(inputvalue ? " - '[inputvalue]'" : null)]"
		playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)

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
		var/to_add = get_paper_overlay()
		if (to_add)
			. += to_add

/obj/item/folder/proc/get_paper_overlay()
	var/mutable_appearance/paper_overlay = mutable_appearance(icon, paper_overlay_state, offset_spokesman = src, appearance_flags = KEEP_APART)
	paper_overlay = contents[1].color_atom_overlay(paper_overlay)
	return paper_overlay

/obj/item/folder/attackby(obj/item/weapon, mob/user, list/modifiers)
	if(is_type_in_typecache(weapon, folder_insertables))
		//Add paper, photo or documents into the folder
		if(!user.transferItemToLoc(weapon, src))
			return
		to_chat(user, span_notice("You put [weapon] into [src]."))
		update_appearance()
	else if(IS_WRITING_UTENSIL(weapon))
		rename(user, weapon)

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

/obj/item/folder/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
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
