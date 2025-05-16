/obj/machinery/big_manipulator/ui_interact(mob/user, datum/tgui/ui)
	if(id_locked)
		to_chat(user, span_warning("[src] is locked behind id authentication!"))
		ui?.close()
		return
	if(!anchored)
		to_chat(user, span_warning("[src] isn't attached to the ground!"))
		ui?.close()
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BigManipulator")
		ui.open()


/obj/machinery/big_manipulator/ui_data(mob/user)
	var/list/data = list()
	data["active"] = on
	data["item_as_filter"] = filter_obj?.resolve()
	data["selected_type"] = selected_type.name
	data["interaction_mode"] = interaction_mode
	data["has_worker"] = !isnull(monkey_worker)
	data["worker_interaction"] = worker_interaction
	data["worker_combat_mode"] = worker_combat_mode
	data["worker_alt_mode"] = worker_alt_mode
	data["highest_priority"] = override_priority
	data["throw_range"] = manipulator_throw_range
	var/list/priority_list = list()
	data["settings_list"] = list()
	for(var/datum/manipulator_priority/allowed_setting as anything in allowed_priority_settings)
		var/list/priority_data = list()
		priority_data["name"] = allowed_setting.name
		priority_data["priority_width"] = allowed_setting.number
		priority_list += list(priority_data)
	data["settings_list"] = priority_list
	data["min_delay"] = minimal_delay
	data["interaction_delay"] = interaction_delay
	return data


/obj/machinery/big_manipulator/ui_static_data(mob/user)
	var/list/data = list()
	data["delay_step"] = DELAY_STEP
	data["max_delay"] = MAX_DELAY
	return data


/obj/machinery/big_manipulator/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("on")
			try_press_on(ui.user)
			return TRUE
		if("eject_worker")
			eject_worker(ui.user)
			return TRUE
		if("drop")
			drop_held_object()
			return TRUE
		if("change_take_item_type")
			cycle_pickup_type()
			return TRUE
		if("change_mode")
			change_mode()
			return TRUE
		if("add_filter")
			add_filter(usr)
			return TRUE
		if("highest_priority_change")
			override_priority = !override_priority
			return TRUE
		if("worker_interaction_change")
			cycle_worker_interaction()
			return TRUE
		if("worker_combat_mode_change")
			worker_combat_mode = !worker_combat_mode
			var/mob/living/carbon/human/species/monkey/monkey_resolve = monkey_worker?.resolve()
			monkey_resolve?.set_combat_mode(worker_combat_mode)
			return TRUE
		if("worker_alt_mode_change")
			worker_alt_mode = !worker_alt_mode
			resolved_modifiers["button"] = (worker_alt_mode ? "right" : "left")
			if(resolved_modifiers["button"] == "right")
				resolved_modifiers["right"] = TRUE
			else
				resolved_modifiers.Remove("right")
			return TRUE
		if("change_priority")
			var/new_priority_number = params["priority"]
			for(var/datum/manipulator_priority/new_order as anything in allowed_priority_settings)
				if(new_order.number != new_priority_number)
					continue
				new_order.number--
				check_similarities(new_order.number)
				break
			update_priority_list()
			return TRUE
		if("cycle_throw_range")
			cycle_throw_range()
			return TRUE
		if("changeDelay")
			change_delay(text2num(params["new_delay"]))
			return TRUE

