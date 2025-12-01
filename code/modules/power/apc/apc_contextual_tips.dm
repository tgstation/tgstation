/obj/machinery/power/apc/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(isAI(user) || iscyborg(user))
		context[SCREENTIP_CONTEXT_LMB] = "Open UI"
		context[SCREENTIP_CONTEXT_RMB] = locked ? "Unlock" : "Lock"
		context[SCREENTIP_CONTEXT_CTRL_LMB] = operating ? "Disable power" : "Enable power"
		context[SCREENTIP_CONTEXT_SHIFT_LMB] = lighting ? "Disable lights" : "Enable lights"
		context[SCREENTIP_CONTEXT_ALT_LMB] = equipment ? "Disable equipment" : "Enable equipment"
		context[SCREENTIP_CONTEXT_CTRL_SHIFT_LMB] = environ ? "Disable environment" : "Enable environment"

	else if (isnull(held_item))
		if (opened == APC_COVER_CLOSED)
			context[SCREENTIP_CONTEXT_RMB] = locked ? "Unlock" : "Lock"
		else if (opened == APC_COVER_OPENED && cell)
			context[SCREENTIP_CONTEXT_LMB] = "Remove cell"

	else if(held_item.tool_behaviour == TOOL_CROWBAR)
		if (opened == APC_COVER_CLOSED)
			context[SCREENTIP_CONTEXT_LMB] = "Open the cover"
		else if ((opened == APC_COVER_OPENED && has_electronics == APC_ELECTRONICS_SECURED) && !(machine_stat & BROKEN))
			context[SCREENTIP_CONTEXT_LMB] = "Close and lock"
		else if (malfhack || (machine_stat & (BROKEN|EMAGGED)))
			context[SCREENTIP_CONTEXT_LMB] = "Remove damaged board"
		else
			context[SCREENTIP_CONTEXT_LMB] = "Remove board"

	else if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		if (opened == APC_COVER_CLOSED)
			context[SCREENTIP_CONTEXT_LMB] = panel_open ? "Unexpose wires" : "Expose wires"
		else if (cell && opened == APC_COVER_OPENED)
			context[SCREENTIP_CONTEXT_LMB] = "Remove cell"
		else if (has_electronics == APC_ELECTRONICS_INSTALLED)
			context[SCREENTIP_CONTEXT_LMB] = "Fasten the board"
		else if (has_electronics == APC_ELECTRONICS_SECURED)
			context[SCREENTIP_CONTEXT_LMB] = "Unfasten the board"

	else if(held_item.tool_behaviour == TOOL_WIRECUTTER)
		if (terminal && opened == APC_COVER_OPENED)
			context[SCREENTIP_CONTEXT_LMB] = "Dismantle wire terminal"

	else if(held_item.tool_behaviour == TOOL_WELDER)
		if (opened == APC_COVER_OPENED && !has_electronics)
			context[SCREENTIP_CONTEXT_LMB] = "Disassemble the APC"

	else if(istype(held_item, /obj/item/stock_parts/power_store/battery) && opened == APC_COVER_OPENED)
		context[SCREENTIP_CONTEXT_LMB] = "Insert Battery"

	else if(istype(held_item, /obj/item/stack/cable_coil) && opened == APC_COVER_OPENED)
		context[SCREENTIP_CONTEXT_LMB] = "Create wire terminal"

	else if(istype(held_item, /obj/item/electronics/apc) && opened == APC_COVER_OPENED)
		context[SCREENTIP_CONTEXT_LMB] = "Insert board"

	else if(istype(held_item, /obj/item/electroadaptive_pseudocircuit) && opened == APC_COVER_OPENED)
		if (!has_electronics)
			context[SCREENTIP_CONTEXT_LMB] = "Insert an APC board"
		else if(!cell)
			context[SCREENTIP_CONTEXT_LMB] = "Insert a battery"

	else if(istype(held_item, /obj/item/wallframe/apc))
		context[SCREENTIP_CONTEXT_LMB] = "Replace damaged frame"

	return CONTEXTUAL_SCREENTIP_SET
