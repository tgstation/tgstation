/**
 * Tool bump bespoke element
 *
 * Calls attackby on the source with the bumper's held object only if it has a specific tool_behaviour
 */
/datum/element/tool_bump
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	///Behaviour to look for in bumper's held object before attacking the attached atom with it
	var/tool_behaviour
	///Can we use this tool to perform this behaviour with our off-hand (e.g. mining)
	var/require_active_hand = TRUE

/datum/element/tool_bump/Attach(datum/target, tool_behaviour = null, require_active_hand = TRUE)
	. = ..()

	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE
	src.tool_behaviour = tool_behaviour
	src.require_active_hand = require_active_hand

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

	if(TIMER_COOLDOWN_CHECK(source, bumper))
		return
	if(!ISADVANCEDTOOLUSER(bumper)) // Unadvanced tool users can't tool anyway. This just prevents message spam from attackby()
		return
	if(bumper.combat_mode) //Not meant to let you bump attack certain atoms with certain tools
		return

	if(iscyborg(bumper))
		var/mob/living/silicon/robot/robot = bumper
		if(robot.module_active?.tool_behaviour == tool_behaviour)
			INVOKE_ASYNC(source, /atom.proc/attackby, robot.module_active, robot)
			TIMER_COOLDOWN_START(source, robot, CLICK_CD_MELEE) //this user can't tool bump this atom more often than this cooldown
		return

	var/obj/item/tool_item
	if(require_active_hand)
		tool_item =	bumper.get_active_held_item()
		if(tool_item?.tool_behaviour != tool_behaviour)
			return
	else
		tool_item = bumper.is_holding_tool_quality(tool_behaviour)

	if(tool_item)
		INVOKE_ASYNC(source, /atom.proc/attackby, tool_item, bumper)
		TIMER_COOLDOWN_START(source, bumper, CLICK_CD_MELEE)
