/obj/machinery/netpod/crowbar_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		attack_hand(user)
		return ITEM_INTERACT_SUCCESS

	if(default_pry_open(tool, user) || default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS


/obj/machinery/netpod/screwdriver_act(mob/living/user, obj/item/tool)
	if(occupant)
		balloon_alert(user, "in use!")
		return ITEM_INTERACT_SUCCESS

	if(state_open)
		balloon_alert(user, "close first.")
		return ITEM_INTERACT_SUCCESS

	if(default_deconstruction_screwdriver(user, "[base_icon_state]_panel", "[base_icon_state]_closed", tool))
		update_appearance() // sometimes icon doesnt properly update during flick()
		ui_close(user)
		return ITEM_INTERACT_SUCCESS
