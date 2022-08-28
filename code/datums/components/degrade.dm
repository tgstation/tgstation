/**
 * Tracks an item's durability the attached item is used, and decreases effectiveness of the tool when fully degraded.
 * This is done by increasing the tool's tool speed dynamically after each use of the tool, making the do_after take longer.
 */
/datum/component/degrade
	/// What is this tool's maximum durability?
	var/maximum_durability = 20
	///What is this tool's current durability?
	var/current_durability = 20

/datum/component/degrade/Initialize(maximum_durability, current_durability)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/potential_tool = parent
	if(!potential_tool.tool_behaviour)
		return COMPONENT_INCOMPATIBLE
	if(maximum_durability)
		src.maximum_durability = maximum_durability
	if(current_durability)
		src.current_durability = current_durability

	RegisterSignal(parent, list(COMSIG_TOOL_ATOM_ACTED_PRIMARY(initial(potential_tool.tool_behaviour)),
				COMSIG_TOOL_ATOM_ACTED_SECONDARY(initial(potential_tool.tool_behaviour)), COMSIG_MOB_SURGERY_STEP_SUCCESS), .proc/wear_down_tool)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE_MORE, .proc/on_examine_more)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE_MORE, .proc/on_examine_more)


/datum/component/degrade/proc/wear_down_tool(tool_misused = FALSE)
	SIGNAL_HANDLER
	if(current_durability <= 0)
		return
	current_durability--
	current_durability = clamp(current_durability, 0, maximum_durability)
	if(current_durability < (maximum_durability/2)) //todo: make sure this works right
		var/obj/item/current_tool = parent
		var/tools_speed = initial(current_tool.toolspeed)
		var/tools_force = initial(current_tool.force)
		//todo: Make sure these are not only sane, but also good? Like damn homie this shit probably sucks.
		current_tool.toolspeed = (tools_speed) + ((maximum_durability/4)/current_durability) //Here we change the tool's use speed.
		current_tool.force = clamp((tools_force * (current_durability/ maximum_durability)), 0, tools_force) //Here we change the tool's attack force. Clamp prevents div by zero.

/datum/component/degrade/proc/on_examine_more(atom/source, mob/mob, list/examine_list)
	SIGNAL_HANDLER
	var/durability_ratio = (current_durability/maximum_durability)
	if(durability_ratio > 0.5)
		examine_list += span_notice("[source] is in good condition.")
		return
	if(durability_ratio <= 0.5 && durability_ratio > 0.25)
		examine_list += span_notice("[source] is getting rather scratched up and difficult to use.")
		return
	if(durability_ratio <= 0.25 && durability_ratio > 0.1)
		examine_list += span_warning("[source] has been damaged from repeated wear and tear. It might be time to replace it.")
	else
		examine_list += span_boldwarning("[source] is on it's last legs. It can still be used... but it's in need of repair or replacement.")

