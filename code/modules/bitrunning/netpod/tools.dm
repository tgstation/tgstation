/obj/machinery/netpod/crowbar_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		attack_hand(user)
		return ITEM_INTERACT_SUCCESS

	if(default_pry_open(tool, user) || default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/machinery/netpod/screwdriver_act(mob/living/user, obj/item/tool)
	if(occupant)
		balloon_alert(user, "in use!")
		return ITEM_INTERACT_SUCCESS

	if(state_open)
		balloon_alert(user, "close it first!")
		return ITEM_INTERACT_SUCCESS

	return default_deconstruction_screwdriver(user, tool)
