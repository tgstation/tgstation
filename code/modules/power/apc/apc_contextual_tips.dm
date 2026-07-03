/obj/machinery/power/apc/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(isAI(user) || iscyborg(user))
		context[SCREENTIP_CONTEXT_LMB] = "Открыть UI"
		context[SCREENTIP_CONTEXT_RMB] = locked ? "Разблокировать" : "Заблокировать"
		context[SCREENTIP_CONTEXT_CTRL_LMB] = operating ? "Отключить питание" : "Включить питание"
		context[SCREENTIP_CONTEXT_SHIFT_LMB] = lighting ? "Выключить свет" : "Включить свет"
		context[SCREENTIP_CONTEXT_ALT_LMB] = equipment ? "Выключить оборудование" : "Включить оборудование"
		context[SCREENTIP_CONTEXT_CTRL_SHIFT_LMB] = environ ? "Выключить окружение" : "Включить окружение"

	else if (isnull(held_item))
		if (opened == APC_COVER_CLOSED)
			context[SCREENTIP_CONTEXT_RMB] = locked ? "Разблокировать" : "Заблокировать"
		else if (opened == APC_COVER_OPENED && cell)
			context[SCREENTIP_CONTEXT_LMB] = "Извлечь батарею"

	else if(held_item.tool_behaviour == TOOL_CROWBAR)
		if (opened == APC_COVER_CLOSED)
			context[SCREENTIP_CONTEXT_LMB] = "Открыть панель"
		else if ((opened == APC_COVER_OPENED && has_electronics == APC_ELECTRONICS_SECURED) && !(machine_stat & BROKEN))
			context[SCREENTIP_CONTEXT_LMB] = "Закрыть и заблокировать"
		else if (malfhack || (machine_stat & (BROKEN|EMAGGED)))
			context[SCREENTIP_CONTEXT_LMB] = "Извлечь повреждённую плату"
		else
			context[SCREENTIP_CONTEXT_LMB] = "Извлечь плату"

	else if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		if (opened == APC_COVER_CLOSED)
			context[SCREENTIP_CONTEXT_LMB] = panel_open ? "Закрыть провода" : "Оголить провода"
		else if (cell && opened == APC_COVER_OPENED)
			context[SCREENTIP_CONTEXT_LMB] = "Извлечь батарею"
		else if (has_electronics == APC_ELECTRONICS_INSTALLED)
			context[SCREENTIP_CONTEXT_LMB] = "Закрепить панель"
		else if (has_electronics == APC_ELECTRONICS_SECURED)
			context[SCREENTIP_CONTEXT_LMB] = "Открепить панель"

	else if(held_item.tool_behaviour == TOOL_WIRECUTTER)
		if (terminal && opened == APC_COVER_OPENED)
			context[SCREENTIP_CONTEXT_LMB] = "Демонтировать проводную клемму"

	else if(held_item.tool_behaviour == TOOL_WELDER)
		if (opened == APC_COVER_OPENED && !has_electronics)
			context[SCREENTIP_CONTEXT_LMB] = "Разобрать ЛКП"

	else if(istype(held_item, /obj/item/stock_parts/power_store/battery) && opened == APC_COVER_OPENED)
		context[SCREENTIP_CONTEXT_LMB] = "Вставить батарею"

	else if(istype(held_item, /obj/item/stack/cable_coil) && opened == APC_COVER_OPENED)
		context[SCREENTIP_CONTEXT_LMB] = "Создать проводную клемму"

	else if(istype(held_item, /obj/item/electronics/apc) && opened == APC_COVER_OPENED)
		context[SCREENTIP_CONTEXT_LMB] = "Вставить плату"

	else if(istype(held_item, /obj/item/electroadaptive_pseudocircuit) && opened == APC_COVER_OPENED)
		if (!has_electronics)
			context[SCREENTIP_CONTEXT_LMB] = "Вставить плату ЛКП"
		else if(!cell)
			context[SCREENTIP_CONTEXT_LMB] = "Вставить батарею"

	else if(istype(held_item, /obj/item/wallframe/apc))
		context[SCREENTIP_CONTEXT_LMB] = "Заменить повреждённую панель"

	return CONTEXTUAL_SCREENTIP_SET
