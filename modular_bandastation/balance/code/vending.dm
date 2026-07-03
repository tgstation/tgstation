/obj/machinery/vending/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(src.ai_controller)
		src.balloon_alert(user, "не поддаётся!")
		return ITEM_INTERACT_BLOCKING
	. = ..()
