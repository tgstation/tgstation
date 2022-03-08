/**
 * Bump click bespoke element
 *
 * Simulates a click on the attached atom when it's bumped, only if an item in the bumper's hand slots has a specific tool_behaviour, or
 * is a specific item or its subtypes or if the active hand slot is empty and empty-handedness is allowed.
 */
/datum/element/bump_click
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	///Behaviours to look for in bumper's in-hand objects before attacking the attached atom with one.
	var/list/tool_behaviours
	///Tool types to look for in bumper's in-hand objects before attacking the attached atom with one.
	var/list/tool_items
	///Do clicks with an empty active hand go through?
	var/allow_unarmed = FALSE
	///Do clicks on combat mode go through?
	var/allow_combat = FALSE

/datum/element/bump_click/Attach(datum/target, list/tool_behaviours, list/tool_items, allow_unarmed = FALSE, allow_combat = FALSE)
	. = ..()

	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE
	src.tool_behaviours = tool_behaviours
	src.tool_items = typecacheof(tool_items)
	src.allow_unarmed = allow_unarmed
	src.allow_combat = allow_combat

	RegisterSignal(target, COMSIG_ATOM_BUMPED, .proc/use_tool, override = TRUE)

/datum/element/bump_click/Detach(datum/target)
	UnregisterSignal(target, COMSIG_ATOM_BUMPED)
	return ..()

/datum/element/bump_click/proc/get_tool(mob/living/bumper)
	var/obj/item/held_tool

	for(var/tool_behaviour in tool_behaviours)
		held_tool = bumper.is_holding_tool_quality(tool_behaviour)
		if(!held_tool)
			continue
		return held_tool

	for(held_tool in bumper.held_items)
		if(!(held_tool.type in tool_items))
			continue
		return held_tool

/datum/element/bump_click/proc/use_tool(atom/source, mob/living/bumper)
	SIGNAL_HANDLER

	if(!isliving(bumper))
		return
	if(bumper.combat_mode && !allow_combat)
		return
	if(!bumper.get_num_held_items()) //Not holding anything, so no tools to get
		if(allow_unarmed)
			INVOKE_ASYNC(bumper, /mob.proc/ClickOn, source) //Click with empty active hand
		return
	if(!ISADVANCEDTOOLUSER(bumper)) //probably can't perform this interaction anyway
		return

	var/found_tool = get_tool(bumper)
	if(found_tool)
		var/tool_index = bumper.get_held_index_of_item(found_tool)
		if(bumper.swap_hand(tool_index)) //need to switch to the correct hand slot before we can click
			INVOKE_ASYNC(bumper, /mob.proc/ClickOn, source) //Click with found tool
			return

	if(!allow_unarmed)
		return

	if(!bumper.get_active_held_item())
		INVOKE_ASYNC(bumper, /mob.proc/ClickOn, source) //click with empty active hand
		return
