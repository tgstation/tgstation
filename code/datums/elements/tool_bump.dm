/**
 * Tool bump bespoke element
 *
 * Attacks attached atom with the bumper's held object only if it has a specific tool_behaviour or is a specific type of item (e.g. fireaxe).
 */
/datum/element/tool_bump
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	///Behaviours to look for in bumper's held objects before attacking the attached atom with one.
	var/list/tool_behaviours
	///Can we use this tool to perform this behaviour with our off-hand (e.g. mining)?
	var/require_active_hand = TRUE
	///Tool types to look for in bumper's held objects before attacking the attached atom with one.
	var/list/tool_items

/datum/element/tool_bump/Attach(datum/target, tool_behaviours = null, require_active_hand = TRUE, tool_items = null)
	. = ..()

	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE
	LAZYADD(src.tool_behaviours, tool_behaviours)
	src.require_active_hand = require_active_hand
	LAZYADD(src.tool_items, tool_items)

	RegisterSignal(target, COMSIG_ATOM_BUMPED, .proc/check_tool, override = TRUE)

/datum/element/tool_bump/Detach(datum/target)
	UnregisterSignal(target, COMSIG_ATOM_BUMPED)
	return ..()

///Attacks target with held item if it fits the tool_behaviour of the element
/datum/element/tool_bump/proc/check_tool(atom/source, mob/bumpee)
	SIGNAL_HANDLER

	if(!ISADVANCEDTOOLUSER(bumpee))
		return
	if(!isliving(bumpee))
		return
	if(bumpee.next_move > world.time)
		return
	if(!bumpee.get_num_held_items())
		return

	var/mob/living/bumper = bumpee

	if(bumper.combat_mode) //Not meant to let you bump attack
		return

	var/obj/item/held_tool
	if(iscyborg(bumper))
		var/mob/living/silicon/robot/cyborg = bumper

		held_tool = cyborg.module_active
		if(!held_tool)
			return

		if(LAZYFIND(tool_behaviours, held_tool.tool_behaviour))
			INVOKE_ASYNC(held_tool, /obj/item.proc/melee_attack_chain, bumper, source)
			return
		for(var/tool_path in tool_items)
			if(istype(held_tool, tool_path))
				INVOKE_ASYNC(held_tool, /obj/item.proc/melee_attack_chain, bumper, source)
		return

	if(require_active_hand)
		held_tool = bumper.get_active_held_item()
		if(!held_tool)
			return
		if(LAZYFIND(tool_behaviours, held_tool.tool_behaviour))
			INVOKE_ASYNC(held_tool, /obj/item.proc/melee_attack_chain, bumper, source)
			return
		for(var/tool_path in tool_items)
			if(istype(held_tool, tool_path))
				INVOKE_ASYNC(held_tool, /obj/item.proc/melee_attack_chain, bumper, source)
				return
	else
		for(var/tool_behaviour in tool_behaviours)
			held_tool = bumper.is_holding_tool_quality(tool_behaviour)
			if(!held_tool)
				continue
			INVOKE_ASYNC(held_tool, /obj/item.proc/melee_attack_chain, bumper, source)
			return
		for(var/tool_path in tool_items)
			for(held_tool in bumper.held_items)
				if(istype(held_tool, tool_path))
					INVOKE_ASYNC(held_tool, /obj/item.proc/melee_attack_chain, bumper, source)
					return
