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
	/// Name to display for use-on-item screentips, to avoid overly long screentips.
	var/folder_type_name = "folder"

/obj/item/folder/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins filing an imaginary death warrant! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/folder/Initialize(mapload)
	update_icon()
	. = ..()
	AddElement(/datum/element/burn_on_item_ignition)
	register_item_context()
	register_context()

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

/obj/item/folder/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	if(is_type_in_typecache(target, folder_insertables))
		// As this is shown on the paper, we clarify we are picking it up.
		context[SCREENTIP_CONTEXT_LMB] = "Insert into [folder_type_name]"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/obj/item/folder/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(isnull(held_item))
		return NONE
	if(is_type_in_typecache(held_item, folder_insertables))
		context[SCREENTIP_CONTEXT_LMB] = "Insert"
		return CONTEXTUAL_SCREENTIP_SET
	if(IS_WRITING_UTENSIL(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Rename"
		return CONTEXTUAL_SCREENTIP_SET
	if((held_item.tool_behaviour == TOOL_KNIFE || held_item.tool_behaviour == TOOL_WIRECUTTER) && !contents.len)
		context[SCREENTIP_CONTEXT_LMB] = "Cut apart"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

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

/obj/item/folder/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(is_type_in_typecache(tool, folder_insertables))
		return insertables_act(user, tool)
	if(IS_WRITING_UTENSIL(tool))
		return writing_utensil_act(user, tool)
	if(tool.tool_behaviour == TOOL_KNIFE || tool.tool_behaviour == TOOL_WIRECUTTER)
		return sharp_thing_act(user, tool)
	return NONE

/obj/item/folder/proc/insertables_act(mob/living/user, obj/item/tool)
	if(!user.transferItemToLoc(tool, src, silent = FALSE))
		return ITEM_INTERACT_BLOCKING
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/item/folder/proc/writing_utensil_act(mob/user, obj/item/writing_instrument)
	if(!user.can_write(writing_instrument))
		return ITEM_INTERACT_BLOCKING

	var/inputvalue = tgui_input_text(user, "What would you like to label the folder?", "Folder Labelling", max_length = MAX_NAME_LEN)

	if(!inputvalue)
		return ITEM_INTERACT_BLOCKING
	if(!user.can_perform_action(src))
		return ITEM_INTERACT_BLOCKING

	name = "folder[(inputvalue ? " - '[inputvalue]'" : null)]"
	playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)
	return ITEM_INTERACT_SUCCESS

/obj/item/folder/proc/sharp_thing_act(mob/user, obj/item/sharp_tool)
	if(contents.len)
		balloon_alert(user, "empty [src] first!")
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "cut apart")
	qdel(src)
	user.put_in_hands(new /obj/item/stack/sheet/cardboard)
	return ITEM_INTERACT_SUCCESS

/obj/item/folder/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(is_type_in_typecache(interacting_with, folder_insertables))
		return interact_with_insertables(interacting_with, user)

/obj/item/folder/proc/interact_with_insertables(obj/item/interacting_with, mob/living/user)
	if(interacting_with.loc == user)
		if(!user.transferItemToLoc(interacting_with, src, silent = TRUE))
			return ITEM_INTERACT_BLOCKING
	else
		interacting_with.do_pickup_animation(src)
		interacting_with.forceMove(src)

	playsound(src, interacting_with.pickup_sound, PICKUP_SOUND_VOLUME, interacting_with.sound_vary, ignore_walls = FALSE)
	update_appearance()
	return ITEM_INTERACT_SUCCESS

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
