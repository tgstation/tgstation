/obj/machinery/airalarm/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(isnull(held_item))
		return 

	if(held_item.tool_behaviour == TOOL_CROWBAR)
		if(buildstage == AIR_ALARM_BUILD_NO_WIRES)
			context[SCREENTIP_CONTEXT_LMB] = "Pry out Electronics"

	else if(held_item.tool_behaviour == TOOL_SCREWDRIVER && buildstage == AIR_ALARM_BUILD_COMPLETE)
		context[SCREENTIP_CONTEXT_LMB] = panel_open ? "Expose wires" : "Unexpose wires"

	else if(held_item.tool_behaviour == TOOL_WIRECUTTER)
		if (panel_open)
			context[SCREENTIP_CONTEXT_LMB] = "Manipulate wires"

	else if(held_item.tool_behaviour == TOOL_WRENCH)
		if(buildstage == AIR_ALARM_BUILD_NO_CIRCUIT)
			context[SCREENTIP_CONTEXT_LMB] = "Detatch Alarm"
	return CONTEXTUAL_SCREENTIP_SET
