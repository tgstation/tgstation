/// The datum and interface for the malf unlock menu, which lets them choose actions to unlock.
/datum/module_picker
	var/name = "Malfunction Modules Menu"
	var/processing_time = 50
	var/list/possible_modules

/datum/module_picker/New()
	possible_modules = get_malf_modules()

/proc/get_malf_modules()
	var/list/modules = list()
	for(var/path in GLOB.malf_modules)
		var/datum/ai_module/AM = new path
		if((AM.power_type == /datum/action/innate/ai) && !AM.upgrade)
			continue
		modules += AM
	return modules

/datum/module_picker/ui_state(mob/user)
	return GLOB.always_state

/datum/module_picker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MalfunctionModulePicker", name)
		ui.open()

/datum/module_picker/ui_data(mob/user)
	var/list/data = list()
	data["processingTime"] = processing_time
	if(isAI(user))
		var/mob/living/silicon/ai/ai_user = user
		data["hackedAPCs"] = ai_user.hacked_apcs.len
	return data

/datum/module_picker/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = list()
	data["modules"] = list()

	for(var/datum/ai_module/module as anything in possible_modules)
		var/icon_state = module.icon_state
		var/icon = module.icon
		if (!module.icon_state && !module.upgrade && module.power_type)
			var/datum/action/innate/ai/active_ability = module.power_type
			icon = active_ability.button_icon
			icon_state = active_ability.button_icon_state

		data["modules"] += list(list(
			"name" = module.name,
			"icon" = icon,
			"icon_state" = icon_state,
			"cost" = module.cost,
			"desc" = module.description,
			"category" = module.category,
			"minimumApcs" = module.minimum_apcs,
		))
		if (!(module.category in data["categories"]))
			data["categories"] += module.category

	return data

/datum/module_picker/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!isAI(usr))
		return
	switch(action)
		if("buy")
			var/item_name = params["name"]
			for(var/datum/ai_module/module as anything in possible_modules)
				if(module.name == item_name)
					purchase_module(usr, module)
					return TRUE

/datum/module_picker/proc/purchase_module(mob/living/silicon/ai/AI, datum/ai_module/AM)
	if(!istype(AM))
		return
	if(!AI || AI.stat == DEAD)
		return
	if(AM.cost > processing_time)
		return
	if(AM.minimum_apcs > AI.hacked_apcs.len)
		return
	// Give the power and take away the money.
	if(AM.upgrade) //upgrade and upgrade() are separate, be careful!
		AM.upgrade(AI)
		possible_modules -= AM
		if(AM.unlock_text)
			to_chat(AI, AM.unlock_text)
		if(AM.unlock_sound)
			AI.playsound_local(AI, AM.unlock_sound, 50, 0)
		update_static_data(AI)
	else
		if(AM.power_type)
			var/datum/action/innate/ai/action = locate(AM.power_type) in AI.actions
			if(!action) //Unlocking for the first time
				var/datum/action/AC = new AM.power_type
				AC.Grant(AI)
				AI.current_modules += new AM.type
				if(AM.one_purchase)
					possible_modules -= AM
					update_static_data(AI)
				if(AM.unlock_text)
					to_chat(AI, AM.unlock_text)
				if(AM.unlock_sound)
					AI.playsound_local(AI, AM.unlock_sound, 50, 0)
			else //Adding uses to an existing module
				action.uses += initial(action.uses)
				action.desc = "[initial(action.desc)] It has [action.uses] use\s remaining."
				action.build_all_button_icons()
	processing_time -= AM.cost
	log_malf_upgrades("[key_name(AI)] purchased [AM.name]")
	SSblackbox.record_feedback("nested tally", "malfunction_modules_bought", 1, list("[initial(AM.name)]", "[AM.cost]"))
