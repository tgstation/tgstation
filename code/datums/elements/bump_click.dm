/**
 * Bump click bespoke element
 *
 * Simulates a click on the attached atom when it's bumped, only if an item in the bumper's hand slots has a specific tool_behaviour, or
 * is a specific item or its subtypes or if the active hand slot is empty and empty-handedness is allowed.
 */
/datum/element/bump_click
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2
	///Behaviours to look for in bumper's in-hand objects before attacking the attached atom with one.
	var/list/tool_behaviours
	///Tool types to look for in bumper's in-hand objects before attacking the attached atom with one.
	var/list/tool_types
	///Do clicks with an empty active hand go through?
	var/allow_unarmed = FALSE
	///Do clicks on combat mode go through?
	var/allow_combat = FALSE
	///We no longer give a shit about tool_types or tool_behaviours and will click with any held item.
	var/allow_any = TRUE

/datum/element/bump_click/Attach(datum/target, list/tool_behaviours, list/tool_items, allow_unarmed = FALSE, allow_combat = FALSE, allow_any = FALSE)
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

	RegisterSignal(target, COMSIG_ATOM_BUMPED, .proc/use_tool, override = TRUE)

/datum/element/bump_click/Detach(datum/target)
	UnregisterSignal(target, COMSIG_ATOM_BUMPED)
	return ..()

/datum/element/bump_click/proc/check_tool(obj/item/held_item)
	if(held_item.tool_behaviour in tool_behaviours)
		return TRUE

	if(held_item.type in tool_types)
		return TRUE

	return FALSE

/datum/element/bump_click/proc/use_tool(atom/source, mob/bumper)
	SIGNAL_HANDLER

	if(isliving(bumper))
		var/mob/living/bumping = bumper
		if(bumping.combat_mode && !allow_combat)
			return
	var/obj/item/held_item = bumper.get_active_held_item()
	if(!held_item) //Not holding anything in active hand, so no tool to check
		if(allow_unarmed)
			INVOKE_ASYNC(bumper, /mob.proc/ClickOn, source) //Click with empty active hand
		return
	if(allow_any)
		INVOKE_ASYNC(bumper, /mob.proc/ClickOn, source) //Click with whatever we're holding
		return
	if(check_tool(held_item))
		INVOKE_ASYNC(bumper, /mob.proc/ClickOn, source) //Click with approved item
