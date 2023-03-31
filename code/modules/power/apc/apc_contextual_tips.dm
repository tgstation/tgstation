/obj/machinery/power/apc/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if (isnull(held_item))
		if (opened == APC_COVER_CLOSED)
			context[SCREENTIP_CONTEXT_RMB] = locked ? "Unlock" : "Lock"
		else if (opened == APC_COVER_OPENED && cell)
			context[SCREENTIP_CONTEXT_LMB] = "Remove cell"

	else if(held_item.tool_behaviour == TOOL_CROWBAR)
		if (opened == APC_COVER_CLOSED)
			context[SCREENTIP_CONTEXT_LMB] = "Open the cover"
		else if ((opened == APC_COVER_OPENED && has_electronics == APC_ELECTRONICS_SECURED) && !(machine_stat & BROKEN))
			context[SCREENTIP_CONTEXT_LMB] = "Close and lock"
		else if (machine_stat & BROKEN|(machine_stat & EMAGGED| malfhack))
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

	else if(istype(held_item, /obj/item/stock_parts/cell) && opened == APC_COVER_OPENED)
		context[SCREENTIP_CONTEXT_LMB] = "Insert Cell"

	else if(istype(held_item, /obj/item/stack/cable_coil) && opened == APC_COVER_OPENED)
		context[SCREENTIP_CONTEXT_LMB] = "Create wire terminal"

	else if(istype(held_item, /obj/item/electronics/apc) && opened == APC_COVER_OPENED)
		context[SCREENTIP_CONTEXT_LMB] = "Insert board"

	else if(istype(held_item, /obj/item/electroadaptive_pseudocircuit) && opened == APC_COVER_OPENED)
		if (!has_electronics)
			context[SCREENTIP_CONTEXT_LMB] = "Insert an APC board"
		else if(!cell)
			context[SCREENTIP_CONTEXT_LMB] = "Insert a cell"

	else if(istype(held_item, /obj/item/wallframe/apc))
		context[SCREENTIP_CONTEXT_LMB] = "Replace damaged frame"

	return CONTEXTUAL_SCREENTIP_SET
