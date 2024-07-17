/obj/vehicle/sealed/space_pod/screwdriver_act(mob/living/user, obj/item/tool)
	. = NONE
	if(return_drivers())
		balloon_alert(user, "mustnt have drivers!")
		return ITEM_INTERACT_BLOCKING
	panel_open = !panel_open
	tool.play_tool_sound(src)
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/vehicle/sealed/space_pod/item_interaction(mob/living/user, obj/item/pod_equipment/equipment, list/modifiers)
	. = NONE
	if(!istype(equipment))
		return

	if(!panel_open)
		balloon_alert(user, "panel not open!")
		return ITEM_INTERACT_BLOCKING

	if(equipment_count_in_slot(equipment.slot) > slot_max(equipment.slot))
		balloon_alert(user, "not enough space!")
		return ITEM_INTERACT_BLOCKING

	if(!do_after(user, 3 SECONDS, src))
		return ITEM_INTERACT_FAILURE

	if(equip_item(equipment, user))
		balloon_alert(user, "attached!")
		return ITEM_INTERACT_SUCCESS

/obj/vehicle/sealed/space_pod/crowbar_act(mob/living/user, obj/item/tool)
	. = NONE
	if(!panel_open)
		balloon_alert(user, "panel not open!")
		return ITEM_INTERACT_BLOCKING

	var/picked = tgui_input_list(user, "Remove what?", "Remove what?", get_all_parts())
	if(!picked)
		return ITEM_INTERACT_BLOCKING

	tool.play_tool_sound(src)

	if(!do_after(user, 3 SECONDS, src))
		return ITEM_INTERACT_FAILURE

	if(unequip_item(picked, user))
		return ITEM_INTERACT_SUCCESS

/obj/vehicle/sealed/space_pod/proc/equip_item(obj/item/pod_equipment/equipment, mob/living/user)
	. = TRUE
	if(!isnull(user) && !user.transferItemToLoc(equipment, src))
		return FALSE
	else
		equipment.forceMove(src)

	if(slot_max(equipment.slot) > 1)
		equipped[equipment.slot] += list(equipment) // makes the list if it doesnt exist fun fun
	else
		equipped[equipment.slot] = equipment

	equipment.pod = src
	equipment.on_attach(user)

/obj/vehicle/sealed/space_pod/proc/unequip_item(obj/item/pod_equipment/equipment, mob/living/user)
	. = TRUE
	if(!user?.put_in_hands(equipment))
		equipment.forceMove(drop_location())

	if(slot_max(equipment.slot) > 1)
		equipped[equipment.slot] -= list(equipment)
	else
		equipped[equipment.slot] = null

	equipment.on_detach(user)
	equipment.pod = null

