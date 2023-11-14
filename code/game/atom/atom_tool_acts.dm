/**
 *Tool behavior procedure. Redirects to tool-specific procs by default.
 *
 * You can override it to catch all tool interactions, for use in complex deconstruction procs.
 *
 * Must return  parent proc ..() in the end if overridden
 */
/atom/proc/tool_act(mob/living/user, obj/item/tool, tool_type, is_right_clicking)
	var/act_result
	var/signal_result

	var/is_left_clicking = !is_right_clicking

	if(is_left_clicking) // Left click first for sensibility
		var/list/processing_recipes = list() //List of recipes that can be mutated by sending the signal
		signal_result = SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT(tool_type), user, tool, processing_recipes)
		if(signal_result & COMPONENT_BLOCK_TOOL_ATTACK) // The COMSIG_ATOM_TOOL_ACT signal is blocking the act
			return TOOL_ACT_SIGNAL_BLOCKING
		if(processing_recipes.len)
			process_recipes(user, tool, processing_recipes)
		if(QDELETED(tool))
			return TRUE
	else
		signal_result = SEND_SIGNAL(src, COMSIG_ATOM_SECONDARY_TOOL_ACT(tool_type), user, tool)
		if(signal_result & COMPONENT_BLOCK_TOOL_ATTACK) // The COMSIG_ATOM_TOOL_ACT signal is blocking the act
			return TOOL_ACT_SIGNAL_BLOCKING

	switch(tool_type)
		if(TOOL_CROWBAR)
			act_result = is_left_clicking ? crowbar_act(user, tool) : crowbar_act_secondary(user, tool)
		if(TOOL_MULTITOOL)
			act_result = is_left_clicking ? multitool_act(user, tool) : multitool_act_secondary(user, tool)
		if(TOOL_SCREWDRIVER)
			act_result = is_left_clicking ? screwdriver_act(user, tool) : screwdriver_act_secondary(user, tool)
		if(TOOL_WRENCH)
			act_result = is_left_clicking ? wrench_act(user, tool) : wrench_act_secondary(user, tool)
		if(TOOL_WIRECUTTER)
			act_result = is_left_clicking ? wirecutter_act(user, tool) : wirecutter_act_secondary(user, tool)
		if(TOOL_WELDER)
			act_result = is_left_clicking ? welder_act(user, tool) : welder_act_secondary(user, tool)
		if(TOOL_ANALYZER)
			act_result = is_left_clicking ? analyzer_act(user, tool) : analyzer_act_secondary(user, tool)
	if(!act_result)
		return

	// A tooltype_act has completed successfully
	if(is_left_clicking)
		log_tool("[key_name(user)] used [tool] on [src] at [AREACOORD(src)]")
		SEND_SIGNAL(tool,  COMSIG_TOOL_ATOM_ACTED_PRIMARY(tool_type), src)
	else
		log_tool("[key_name(user)] used [tool] on [src] (right click) at [AREACOORD(src)]")
		SEND_SIGNAL(tool,  COMSIG_TOOL_ATOM_ACTED_SECONDARY(tool_type), src)
	return TOOL_ACT_TOOLTYPE_SUCCESS

//! Tool-specific behavior procs.
///

/// Called on an object when a tool with crowbar capabilities is used to left click an object
/atom/proc/crowbar_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with crowbar capabilities is used to right click an object
/atom/proc/crowbar_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with multitool capabilities is used to left click an object
/atom/proc/multitool_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with multitool capabilities is used to right click an object
/atom/proc/multitool_act_secondary(mob/living/user, obj/item/tool)
	return

///Check if an item supports a data buffer (is a multitool)
/atom/proc/multitool_check_buffer(user, obj/item/multitool, silent = FALSE)
	if(!istype(multitool, /obj/item/multitool))
		if(user && !silent)
			to_chat(user, span_warning("[multitool] has no data buffer!"))
		return FALSE
	return TRUE

/// Called on an object when a tool with screwdriver capabilities is used to left click an object
/atom/proc/screwdriver_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with screwdriver capabilities is used to right click an object
/atom/proc/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wrench capabilities is used to left click an object
/atom/proc/wrench_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wrench capabilities is used to right click an object
/atom/proc/wrench_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wirecutter capabilities is used to left click an object
/atom/proc/wirecutter_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wirecutter capabilities is used to right click an object
/atom/proc/wirecutter_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with welder capabilities is used to left click an object
/atom/proc/welder_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with welder capabilities is used to right click an object
/atom/proc/welder_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with analyzer capabilities is used to left click an object
/atom/proc/analyzer_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with analyzer capabilities is used to right click an object
/atom/proc/analyzer_act_secondary(mob/living/user, obj/item/tool)
	return
