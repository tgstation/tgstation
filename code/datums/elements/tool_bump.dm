/**
 * Tool bump bespoke element
 *
 * Calls proc on the attached atom with a held object of the bumper's only if it has a specific tool_behaviour or is a specific type of item (e.g. fireaxe)
 */
/datum/element/tool_bump
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	///Behaviours to look for in bumper's held objects before procing the attached atom with it
	var/list/tool_behaviours
	///Can we use this tool to perform this behaviour with our off-hand (e.g. mining)
	var/require_active_hand = TRUE
	///Proc to call on bumped atom if carrying correct tool
	var/proc_to_call
	///Tool types to look for in bumper's held objects before procing the attached atom with it
	var/list/tool_items

/datum/element/tool_bump/Attach(datum/target, tool_behaviours = null, require_active_hand = TRUE, proc_to_call = null, tool_items = null)
	. = ..()

	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE
	LAZYADD(src.tool_behaviours, tool_behaviours)
	src.require_active_hand = require_active_hand
	src.proc_to_call = proc_to_call
	LAZYADD(src.tool_items, tool_items)

	RegisterSignal(target, COMSIG_ATOM_BUMPED, .proc/check_tool, override = TRUE)

/datum/element/tool_bump/Detach(datum/target)
	UnregisterSignal(target, COMSIG_ATOM_BUMPED)
	return ..()

///Attacks target with held item if it fits the tool_behaviour of the element
/datum/element/tool_bump/proc/check_tool(atom/source, mob/bumpee)
	SIGNAL_HANDLER

	if(!isliving(bumpee))
		return

	var/mob/living/bumper = bumpee

	if(bumper.next_move > world.time)
		return
	if(!ISADVANCEDTOOLUSER(bumper))
		return
	if(bumper.combat_mode) //Not meant to let you bump attack
		return
	if(!bumper.get_num_held_items())
		return

	if(iscyborg(bumper))
		var/mob/living/silicon/robot/robot = bumper
		if(LAZYFIND(tool_behaviours, robot.module_active?.tool_behaviour))
			INVOKE_ASYNC(robot.module_active, /obj/item.proc/melee_attack_chain, bumper, source)
		return

	var/obj/item/held_tool
	if(require_active_hand)
		held_tool = bumper.get_active_held_item()
		if(!held_tool)
			return
		if(LAZYFIND(tool_behaviours, held_tool.tool_behaviour))
			call_proc(source, held_tool, bumper)
			return
		for(var/tool_path in tool_items)
			message_admins("tool_path is [tool_path]!")
			if(istype(held_tool, tool_path))
				call_proc(source, held_tool, bumper)
				return
			message_admins("held_tool [held_tool] was not type of tool_path [tool_path]!")
	else
		for(var/tool_behaviour in tool_behaviours)
			held_tool = bumper.is_holding_tool_quality(tool_behaviour)
			if(held_tool)
				call_proc(source, held_tool, bumper)
				return
		for(var/tool_path in tool_items)
			message_admins("tool_path is [tool_path]!")
			for(var/obj/item/held_item in bumper.held_items)
				message_admins("held_item is [held_item]!")
				if(istype(held_item, tool_path))
					call_proc(source, held_item, bumper)
					return
				message_admins("held_item [held_item] was not type of tool_path [tool_path]!")

/datum/element/tool_bump/proc/call_proc(atom/source, obj/item/tool, mob/living/bumper)
	INVOKE_ASYNC(tool, /obj/item.proc/melee_attack_chain, bumper, source)
