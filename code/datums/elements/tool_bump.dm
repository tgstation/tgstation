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
	///Cooldown to prevent spam
	var/last_act

/datum/element/tool_bump/Attach(datum/target, tool_behaviour = null)
	. = ..()

	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE
	if(tool_behaviour)
		src.tool_behaviour = tool_behaviour

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
	if(TIMER_COOLDOWN_CHECK(bumper, type))
		return
	if(!ISADVANCEDTOOLUSER(bumper)) // Unadvanced tool users can't tool anyway. This just prevents message spam from attackby()
		return
	if(iscyborg(bumper))
		var/mob/living/silicon/robot/robot = bumper
		if(robot.module_active?.tool_behaviour == tool_behaviour)
			INVOKE_ASYNC(source, /atom.proc/attackby, robot.module_active, robot)
			TIMER_COOLDOWN_START(robot, type, CLICK_CD_RAPID)
		return
	var/obj/item/tool_item = bumper.is_holding_tool_quality(tool_behaviour)
	if(tool_item)
		INVOKE_ASYNC(source, /atom.proc/attackby, tool_item, bumper)
		TIMER_COOLDOWN_START(bumper, type, CLICK_CD_RAPID)
