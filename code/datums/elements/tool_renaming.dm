/**
 * Renaming tool element
 *
 * When using this tool on an object with UNIQUE_RENAME,
 * lets the user rename/redesc it.
 */
/datum/element/tool_renaming

/datum/element/tool_renaming/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(attempt_rename))

/datum/element/tool_renaming/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ITEM_INTERACTING_WITH_ATOM)

/datum/element/tool_renaming/proc/attempt_rename(datum/source, mob/living/user, atom/interacting_with, list/modifiers)
	SIGNAL_HANDLER

	if(!isobj(interacting_with))
		return NONE
	
	var/obj/renamed_obj = interacting_with

	if(!(renamed_obj.obj_flags & UNIQUE_RENAME))
		return NONE

	var/pen_choice = tgui_input_list(user, "What would you like to edit?", "Pen Setting", list("Rename", "Description", "Reset"))
	if(QDELETED(renamed_obj) || !user.can_perform_action(renamed_obj) || isnull(pen_choice))
		return ITEM_INTERACT_BLOCKING

	switch(pen_choice)
		if("Rename")
			var/input = tgui_input_text(user, "What do you want to name [renamed_obj]?", "Object Name", "[renamed_obj.name]", MAX_NAME_LEN)
			var/old_name = renamed_obj.name
			if(QDELETED(renamed_obj) || !user.can_perform_action(renamed_obj))
				return ITEM_INTERACT_BLOCKING
			if(input == old_name || !input)
				to_chat(user, span_notice("You changed [renamed_obj] to... well... [renamed_obj]."))
				return ITEM_INTERACT_BLOCKING
			renamed_obj.AddComponent(/datum/component/rename, input, renamed_obj.desc)
			to_chat(user, span_notice("You have successfully renamed \the [old_name] to [renamed_obj]."))
			ADD_TRAIT(renamed_obj, TRAIT_WAS_RENAMED, PEN_LABEL_TRAIT)
			renamed_obj.update_appearance(UPDATE_ICON)

		if("Description")
			var/input = tgui_input_text(user, "Describe [renamed_obj]", "Description", "[renamed_obj.desc]", 280)
			var/old_desc = renamed_obj.desc
			if(QDELETED(renamed_obj) || !user.can_perform_action(renamed_obj))
				return ITEM_INTERACT_BLOCKING
			if(input == old_desc || !input)
				to_chat(user, span_notice("You decide against changing [renamed_obj]'s description."))
				return ITEM_INTERACT_BLOCKING
			renamed_obj.AddComponent(/datum/component/rename, renamed_obj.name, input)
			to_chat(user, span_notice("You have successfully changed [renamed_obj]'s description."))
			ADD_TRAIT(renamed_obj, TRAIT_WAS_RENAMED, PEN_LABEL_TRAIT)
			renamed_obj.update_appearance(UPDATE_ICON)

		if("Reset")
			qdel(renamed_obj.GetComponent(/datum/component/rename))
			to_chat(user, span_notice("You have successfully reset [renamed_obj]'s name and description."))
			REMOVE_TRAIT(renamed_obj, TRAIT_WAS_RENAMED, PEN_LABEL_TRAIT)
			renamed_obj.update_appearance(UPDATE_ICON)
	return ITEM_INTERACT_SUCCESS
