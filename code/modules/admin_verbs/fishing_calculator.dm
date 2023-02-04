ADMIN_VERB(debug, fishing_calculator, "Fishing Calculator", "Helper tool to see fishing probabilities with different setups", R_DEBUG)
	var/datum/fishing_calculator/ui = new(usr)
	ui.ui_interact(usr)

/datum/fishing_calculator
	var/list/current_table

/datum/fishing_calculator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FishingCalculator")
		ui.open()

/datum/fishing_calculator/ui_state(mob/user)
	return GLOB.admin_state

/datum/fishing_calculator/ui_close(mob/user)
	qdel(src)

/datum/fishing_calculator/ui_static_data(mob/user)
	. = ..()
	.["rod_types"] = typesof(/obj/item/fishing_rod)
	.["hook_types"] = typesof(/obj/item/fishing_hook)
	.["line_types"] = typesof(/obj/item/fishing_line)
	var/list/spot_keys = list()
	for(var/key in GLOB.preset_fish_sources)
		spot_keys += key
	.["spot_types"] = subtypesof(/datum/fish_source) + spot_keys

/datum/fishing_calculator/ui_data(mob/user)
	return list("info" = current_table)

/datum/fishing_calculator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = usr
	switch(action)
		if("recalc")
			var/rod_type = text2path(params["rod"])
			var/bait_type = text2path(params["bait"])
			var/hook_type = text2path(params["hook"])
			var/line_type = text2path(params["line"])
			var/spot_type = text2path(params["spot"]) || params["spot"] //can be also key from presets

			//validate here against nonsense values
			var/datum/fish_source/spot
			if(ispath(spot_type))
				spot = new spot_type
			else
				spot = GLOB.preset_fish_sources[spot_type]

			var/obj/item/fishing_rod/temporary_rod = new rod_type
			if(bait_type)
				temporary_rod.bait = new bait_type
			if(hook_type)
				temporary_rod.hook = new hook_type
			if(line_type)
				temporary_rod.line = new line_type
			var/result_table = list()
			var/modified_table = spot.get_modified_fish_table(temporary_rod,user)
			for(var/result_type in spot.fish_table) // through this not modified to display 0 chance ones too
				var/list/info = list()
				info["result"] = result_type
				info["weight"] = modified_table[result_type] || 0
				info["difficulty"] = spot.calculate_difficulty(result_type,temporary_rod, user)
				info["count"] = spot.fish_counts[result_type] || "Infinite"
				result_table += list(info)
			current_table = result_table
			qdel(temporary_rod)
			return TRUE
