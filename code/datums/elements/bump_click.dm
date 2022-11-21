/**
 * Bump click bespoke element
 *
 * Simulates a click on the attached atom when it's bumped, if the bumper and their active object meet certain criteria.
 */
/datum/element/bump_click
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY // Detach for turfs
	argument_hash_start_idx = 2
	///Tool behaviours to check for on the bumper's active held item before clicking the attached atom with it.
	var/list/tool_behaviours
	///Types (and their subtypes) of item to look for in the bumper's active hand before clicking the attached atom.
	var/list/tool_types
	///Click with an empty active hand?
	var/allow_unarmed = FALSE
	///Click with combat mode on?
	var/allow_combat = FALSE
	///Click with any item?
	var/allow_any = TRUE

/datum/element/bump_click/Attach(datum/target, list/tool_behaviours, list/tool_types, allow_unarmed = FALSE, allow_combat = FALSE, allow_any = FALSE)
	. = ..()

	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE
	if(!allow_any)
		src.tool_behaviours = tool_behaviours
		if(length(tool_types) && !length(src.tool_types)) //only want to generate typecache once and only if necessary
			src.tool_types = typecacheof(tool_types)
	src.allow_any = allow_any
	src.allow_unarmed = allow_unarmed
	src.allow_combat = allow_combat

	RegisterSignal(target, COMSIG_ATOM_BUMPED, PROC_REF(use_tool), override = TRUE)

/datum/element/bump_click/Detach(datum/target)
	UnregisterSignal(target, COMSIG_ATOM_BUMPED)
	return ..()

/datum/element/bump_click/proc/check_tool(obj/item/held_item)
	if(held_item.tool_behaviour in tool_behaviours)
		return TRUE

	if(held_item.type in tool_types)
		return TRUE

	return FALSE

/datum/element/bump_click/proc/use_tool(atom/source, mob/living/bumper)
	SIGNAL_HANDLER

	if(!isliving(bumper))
		return
	var/mob/living/bumping = bumper
	if(bumping.combat_mode && !allow_combat)
		return
	var/obj/item/held_item = bumping.get_active_held_item()
	if(!held_item) //Not holding anything in active hand, so no tool to check
		if(allow_unarmed)
			INVOKE_ASYNC(bumping, TYPE_PROC_REF(/mob, ClickOn), source) //Click with empty active hand
		return
	if(allow_any)
		INVOKE_ASYNC(bumping, TYPE_PROC_REF(/mob, ClickOn), source) //Click with whatever we're holding
		return
	if(check_tool(held_item))
		INVOKE_ASYNC(bumping, TYPE_PROC_REF(/mob, ClickOn), source) //Click with approved item
