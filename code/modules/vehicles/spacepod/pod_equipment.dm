/obj/vehicle/sealed/space_pod/screwdriver_act(mob/living/user, obj/item/tool)
	. = NONE
	if(length(occupants))
		balloon_alert(user, "must not be occupied!")
		return ITEM_INTERACT_BLOCKING
	if(!panel_open && !does_lock_permit_it(user))
		balloon_alert(user, "locked!")
		return ITEM_INTERACT_BLOCKING
	panel_open = !panel_open
	tool.play_tool_sound(src)
	update_appearance()
	balloon_alert(user, "panel [panel_open ? "open" : "closed"]")
	return ITEM_INTERACT_SUCCESS

/obj/vehicle/sealed/space_pod/item_interaction(mob/living/user, obj/item/pod_equipment/equipment, list/modifiers)
	. = NONE

	if(istype(equipment, /obj/item/tank/internals) && isnull(cabin_air_tank) && panel_open) //these two could be done better
		if(!user.transferItemToLoc(equipment, src))
			return ITEM_INTERACT_FAILURE
		cabin_air_tank = equipment
		to_chat(user, span_notice("You slot [equipment] into [src]."))
		playsound(src, 'sound/effects/tank_insert_clunky.ogg', 50)
		update_appearance(UPDATE_OVERLAYS)
		return ITEM_INTERACT_SUCCESS

	if(istype(equipment, /obj/item/stock_parts/power_store/battery) && isnull(cell) && panel_open)
		if(!user.transferItemToLoc(equipment, src))
			return ITEM_INTERACT_FAILURE
		cell = equipment
		to_chat(user, span_notice("You slot [equipment] into [src]."))
		return ITEM_INTERACT_SUCCESS

	if(!istype(equipment))
		return

	if(!panel_open)
		balloon_alert(user, "panel not open!")
		return ITEM_INTERACT_BLOCKING

	if(length(equipped[equipment.slot]) > slot_max(equipment.slot))
		balloon_alert(user, "not enough space!")
		return ITEM_INTERACT_BLOCKING

	var/exclusive_part = is_part_exclusive(equipment)
	if(!isnull(exclusive_part))
		balloon_alert(user, "incompatible with [exclusive_part]!")
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "attaching...")

	if(!do_after(user, 2 SECONDS, src))
		return ITEM_INTERACT_FAILURE

	if(equip_item(equipment, user))
		balloon_alert(user, "attached!")
		return ITEM_INTERACT_SUCCESS

/obj/vehicle/sealed/space_pod/crowbar_act(mob/living/user, obj/item/tool)
	. = NONE
	if(!panel_open)
		balloon_alert(user, "panel not open!")
		return ITEM_INTERACT_BLOCKING

	var/obj/picked = tgui_input_list(user, "Remove what?", "Remove what?", get_all_parts() + cabin_air_tank + cell)
	if(!picked || !user.can_perform_action(src, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH))
		return ITEM_INTERACT_BLOCKING

	tool.play_tool_sound(src)

	balloon_alert(user, "removing...")

	if(!do_after(user, 2 SECONDS, src))
		return ITEM_INTERACT_FAILURE

	if(istype(picked, /obj/item/tank/internals))
		if(!user?.put_in_hands(picked))
			picked.forceMove(drop_location())
		cabin_air_tank = null
		playsound(src, 'sound/effects/tank_remove_thunk.ogg', 50)
		return ITEM_INTERACT_SUCCESS
	else if (istype(picked, /obj/item/stock_parts/power_store))
		if(!user?.put_in_hands(picked))
			picked.forceMove(drop_location())
		cell = null
		return ITEM_INTERACT_SUCCESS


	if(unequip_item(picked, user))
		return ITEM_INTERACT_SUCCESS

/obj/vehicle/sealed/space_pod/proc/equip_item(obj/item/pod_equipment/equipment, mob/living/user)
	. = TRUE
	if(!isnull(user) && !user.transferItemToLoc(equipment, src))
		return FALSE
	else
		equipment.forceMove(src)

	equipped[equipment.slot] += list(equipment) // makes the list if it doesnt exist fun fun

	equipment.pod = src
	equipment.on_attach(user)

	update_static_data_for_all_viewers()

	update_appearance()


/obj/vehicle/sealed/space_pod/proc/unequip_item(obj/item/pod_equipment/equipment, mob/living/user)
	. = TRUE
	if(!user?.put_in_hands(equipment))
		equipment.forceMove(drop_location())

	equipped[equipment.slot] -= list(equipment)

	equipment.on_detach(user)
	equipment.pod = null

	update_static_data_for_all_viewers()

	update_appearance()

/obj/vehicle/sealed/space_pod/get_cell()
	return cell
