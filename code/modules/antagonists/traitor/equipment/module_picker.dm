/// The datum and interface for the malf unlock menu, which lets them choose actions to unlock.
/datum/module_picker
	var/name = "Malfunction Modules Menu"
	var/ui_x = 620
	var/ui_y = 525
	var/selected_cat
	var/compact_mode = FALSE
	var/processing_time = 50
	var/list/possible_modules

/datum/module_picker/New()
	possible_modules = get_malf_modules()

/// Removes all malfunction-related abilities from the target AI.
/datum/module_picker/proc/remove_malf_verbs(mob/living/silicon/ai/AI)
	for(var/datum/AI_Module/AM in possible_modules)
		for(var/datum/action/A in AI.actions)
			if(istype(A, initial(AM.power_type)))
				qdel(A)

/proc/cmp_malfmodules_priority(datum/AI_Module/A, datum/AI_Module/B)
	return B.cost - A.cost

/proc/get_malf_modules()
	var/list/filtered_modules = list()

	for(var/path in GLOB.malf_modules)
		var/datum/AI_Module/AM = new path
		if((AM.power_type == /datum/action/innate/ai) && !AM.upgrade)
			continue
		if(!filtered_modules[AM.category])
			filtered_modules[AM.category] = list()
		filtered_modules[AM.category][AM] = AM

	for(var/category in filtered_modules)
		filtered_modules[category] = sortTim(filtered_modules[category], /proc/cmp_malfmodules_priority)

	return filtered_modules

/datum/module_picker/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "malfunction_module_picker", name, ui_x, ui_y, master_ui, state)
		ui.open()

/datum/module_picker/ui_data(mob/user)
	var/list/data = list()
	data["processing_time"] = processing_time
	data["compact_mode"] = compact_mode
	return data

/datum/module_picker/ui_static_data(mob/user)
	var/list/data = list()

	data["categories"] = list()
	for(var/category in possible_modules)
		var/list/cat = list(
			"name" = category,
			"items" = (category == selected_cat ? list() : null))
		for(var/module in possible_modules[category])
			var/datum/AI_Module/AM = possible_modules[category][module]
			cat["items"] += list(list(
				"name" = AM.name,
				"cost" = AM.cost,
				"desc" = AM.description,
				"ref" = REF(AM),
			))
		data["categories"] += list(cat)

	return data

/datum/module_picker/ui_act(action, list/params)
	if(..())
		return
	if(!isAI(usr))
		return

	switch(action)
		if("buy")
			var/list/buyable_modules = list()
			for(var/category in possible_modules)
				buyable_modules += possible_modules[category]
			var/module = locate(params["ref"]) in buyable_modules
			if(!module || !(module in buyable_modules))
				return
			var/datum/AI_Module/AM = module
			purchase_module(usr, AM)
			. = TRUE
		if("select")
			selected_cat = params["category"]
			. = TRUE
		if("compact_toggle")
			compact_mode = !compact_mode
			. = TRUE

/datum/module_picker/proc/purchase_module(mob/living/silicon/ai/AI, datum/AI_Module/AM)
	if(!istype(AM))
		return
	if(!AI || AI.stat == DEAD)
		return
	if(AM.cost > processing_time)
		return

	var/datum/action/innate/ai/action = locate(AM.power_type) in AI.actions
	// Give the power and take away the money.
	if(AM.upgrade) //upgrade and upgrade() are separate, be careful!
		AM.upgrade(AI)
		possible_modules[AM.category] -= AM
		if(AM.unlock_text)
			to_chat(AI, AM.unlock_text)
		if(AM.unlock_sound)
			AI.playsound_local(AI, AM.unlock_sound, 50, 0)
		update_static_data(AI)
	else
		if(AM.power_type)
			if(!action) //Unlocking for the first time
				var/datum/action/AC = new AM.power_type
				AC.Grant(AI)
				AI.current_modules += new AM.type
				if(AM.one_purchase)
					possible_modules[AM.category] -= AM
					update_static_data(AI)
				if(AM.unlock_text)
					to_chat(AI, AM.unlock_text)
				if(AM.unlock_sound)
					AI.playsound_local(AI, AM.unlock_sound, 50, 0)
			else //Adding uses to an existing module
				action.uses += initial(action.uses)
				action.desc = "[initial(action.desc)] It has [action.uses] use\s remaining."
				action.UpdateButtonIcon()
	processing_time -= AM.cost
