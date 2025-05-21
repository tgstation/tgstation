ADMIN_VERB(dynamic_panel, R_ADMIN, "Dynamic Panel", "Mess with dynamic.", ADMIN_CATEGORY_GAME)
	dynamic_panel(user.mob)

/proc/dynamic_panel(mob/user)
	if(!check_rights(R_ADMIN))
		return
	BLACKBOX_LOG_ADMIN_VERB("Dynamic Panel")
	var/datum/dynamic_panel/tgui = new()
	tgui.ui_interact(user)

/datum/dynamic_panel

/datum/dynamic_panel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/dynamic_panel/ui_close()
	qdel(src)

/datum/dynamic_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DynamicAdmin")
		ui.open()

/datum/dynamic_panel/ui_data(mob/user)
	var/list/data = list()

	if(SSdynamic.current_tier)
		data["current_tier"] = list(
			"number" = SSdynamic.current_tier.tier,
			"name" = SSdynamic.current_tier.name,
		)

	data["ruleset_count"] = list()
	for(var/category in SSdynamic.rulesets_to_spawn)
		data["ruleset_count"][category] = "[max(SSdynamic.rulesets_to_spawn[category], 0)] / [SSdynamic.base_rulesets_to_spawn[category]]"

	data["full_config"] = SSdynamic.get_config()
	data["config_even_enabled"] = CONFIG_GET(flag/dynamic_config_enabled)

	data["queued_rulesets"] = list()
	for(var/i in 1 to length(SSdynamic.queued_rulesets))
		data["queued_rulesets"] += list(ruleset_to_data(SSdynamic.queued_rulesets[i]) + list("index" = i))

	data["active_rulesets"] = list()
	for(var/i in 1 to length(SSdynamic.executed_rulesets))
		data["active_rulesets"] += list(ruleset_to_data(SSdynamic.executed_rulesets[i]) + list("index" = i))

	data["all_rulesets"] = list()
	for(var/ruleset_type in subtypesof(/datum/dynamic_ruleset/roundstart))
		data["all_rulesets"][ROUNDSTART] += list(ruleset_to_data(ruleset_type))
	for(var/ruleset_type in subtypesof(/datum/dynamic_ruleset/midround))
		var/datum/dynamic_ruleset/midround/midround = ruleset_type
		switch(initial(midround.midround_type))
			if(MIDROUND_RULESET_STYLE_HEAVY)
				data["all_rulesets"][HEAVY_MIDROUND] += list(ruleset_to_data(ruleset_type))
			if(MIDROUND_RULESET_STYLE_LIGHT)
				data["all_rulesets"][LIGHT_MIDROUND] += list(ruleset_to_data(ruleset_type))
	for(var/ruleset_type in subtypesof(/datum/dynamic_ruleset/latejoin))
		data["all_rulesets"][LATEJOIN] += list(ruleset_to_data(ruleset_type))

	data["time_until_lights"] = COOLDOWN_TIMELEFT(SSdynamic, light_ruleset_start)
	data["time_until_heavies"] = COOLDOWN_TIMELEFT(SSdynamic, heavy_ruleset_start)
	data["time_until_latejoins"] = COOLDOWN_TIMELEFT(SSdynamic, latejoin_ruleset_start)

	data["time_until_next_midround"] = COOLDOWN_TIMELEFT(SSdynamic, midround_cooldown)
	data["time_until_next_latejoin"] = COOLDOWN_TIMELEFT(SSdynamic, latejoin_cooldown)
	data["failed_latejoins"] = SSdynamic.failed_latejoins

	data["light_midround_chance"] = SSdynamic.get_midround_chance(LIGHT_MIDROUND)
	data["heavy_midround_chance"] = SSdynamic.get_midround_chance(HEAVY_MIDROUND)
	data["latejoin_chance"] = SSdynamic.get_latejoin_chance()

	data["roundstarted"] = SSticker.HasRoundStarted()

	data["light_chance_maxxed"] = SSdynamic.admin_forcing_next_light
	data["heavy_chance_maxxed"] = SSdynamic.admin_forcing_next_heavy
	data["latejoin_chance_maxxed"] = SSdynamic.admin_forcing_next_latejoin

	data["next_dynamic_tick"] = SSdynamic.next_fire - world.time

	return data

/// Pass a ruleset typepath or a ruleset instance
/datum/dynamic_panel/proc/ruleset_to_data(datum/dynamic_ruleset/ruleset)
	var/list/data = list()
	var/ruleset_path = isdatum(ruleset) ? ruleset.type : ruleset
	data["name"] = initial(ruleset.name)
	data["id"] = initial(ruleset.config_tag)
	data["typepath"] = ruleset_path
	data["selected_players"] = list()
	data["admin_disabled"] = (ruleset_path in SSdynamic.admin_disabled_rulesets)
	if(isdatum(ruleset))
		for(var/datum/mind/player as anything in ruleset.selected_minds)
			data["selected_players"] += list(list(
				"key" = player.key,
			))
	return data

/datum/dynamic_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("remove_queued_ruleset")
			var/index = params["ruleset_index"]
			if(length(SSdynamic.queued_rulesets) < index)
				return
			var/datum/dynamic_ruleset/ruleset = SSdynamic.queued_rulesets[index]
			if(!ruleset)
				return
			SSdynamic.queued_rulesets -= ruleset
			message_admins("[key_name_admin(ui.user)] removed [ruleset.config_tag] from the dynamic ruleset queue.")
			log_admin("[key_name_admin(ui.user)] removed [ruleset.config_tag] from the dynamic ruleset queue.")
			qdel(ruleset)
			return TRUE
		if("add_queued_ruleset")
			var/datum/dynamic_ruleset/ruleset_path = text2path(params["ruleset_type"])
			if(!ruleset_path)
				return
			SSdynamic.queue_ruleset(ruleset_path)
			message_admins("[key_name_admin(ui.user)] added [initial(ruleset_path.config_tag)] to the dynamic ruleset queue.")
			log_admin("[key_name_admin(ui.user)] added [initial(ruleset_path.config_tag)] to the dynamic ruleset queue.")
			return TRUE
		if("dynamic_vv")
			ui.user?.client?.debug_variables(SSdynamic)
			return TRUE
		if("add_ruleset_category_count")
			var/category = params["ruleset_category"]
			if(!category)
				return
			SSdynamic.rulesets_to_spawn[category] += 1
			message_admins("[key_name_admin(ui.user)] added 1 to the [category] ruleset category.")
			log_admin("[key_name_admin(ui.user)] added 1 to the [category] ruleset category.")
			return TRUE
		if("set_ruleset_category_count")
			var/category = params["ruleset_category"]
			var/count = params["ruleset_count"]
			if(!category || !isnum(count))
				return
			SSdynamic.rulesets_to_spawn[category] = count
			message_admins("[key_name_admin(ui.user)] set the [category] ruleset category to [count].")
			log_admin("[key_name_admin(ui.user)] set the [category] ruleset category to [count].")
			return TRUE
		if("execute_ruleset")
			var/ruleset_path = text2path(params["ruleset_type"])
			if(!ruleset_path)
				return
			ASYNC
				SSdynamic.force_run_midround(ruleset_path, alert_admins_on_fail = TRUE)
			return TRUE
		if("disable_ruleset")
			var/ruleset_path = text2path(params["ruleset_type"])
			if(!ruleset_path)
				return
			if(ruleset_path in SSdynamic.admin_disabled_rulesets)
				SSdynamic.admin_disabled_rulesets -= ruleset_path
				message_admins("[key_name_admin(ui.user)] enabled [ruleset_path] to be selected.")
				log_admin("[key_name_admin(ui.user)] enabled [ruleset_path] to be selected.")
			else
				SSdynamic.admin_disabled_rulesets += ruleset_path
				message_admins("[key_name_admin(ui.user)] disabled [ruleset_path] from being selected.")
				log_admin("[key_name_admin(ui.user)] disabled [ruleset_path] from being selected.")
			return TRUE
		if("disable_all")
			SSdynamic.admin_disabled_rulesets |= subtypesof(/datum/dynamic_ruleset)
			message_admins("[key_name_admin(ui.user)] disabled all rulesets from being selected.")
			log_admin("[key_name_admin(ui.user)] disabled all rulesets from being selected.")
		if("enable_all")
			SSdynamic.admin_disabled_rulesets.Cut()
			message_admins("[key_name_admin(ui.user)] re-enabled all rulesets.")
			log_admin("[key_name_admin(ui.user)] re_enabled all rulesets.")
		if("set_tier")
			if(SSdynamic.current_tier)
				return TRUE
			var/list/tiers = list()
			for(var/datum/dynamic_tier/tier as anything in subtypesof(/datum/dynamic_tier))
				tiers[initial(tier.name)] = tier
			var/picked = tgui_input_list(ui.user, "Pick a dynamic tier before the game starts", "Pick tier", tiers, ui_state = ADMIN_STATE(R_ADMIN))
			if(picked && !SSdynamic.current_tier)
				SSdynamic.set_tier(tiers[picked])
			return TRUE
		if("max_light_chance")
			SSdynamic.admin_forcing_next_light = !SSdynamic.admin_forcing_next_light
			return TRUE
		if("max_heavy_chance")
			SSdynamic.admin_forcing_next_heavy = !SSdynamic.admin_forcing_next_heavy
			return TRUE
		if("max_latejoin_chance")
			SSdynamic.admin_forcing_next_latejoin = !SSdynamic.admin_forcing_next_latejoin
			return TRUE
		if("light_start_now")
			COOLDOWN_RESET(SSdynamic, light_ruleset_start)
			return TRUE
		if("heavy_start_now")
			COOLDOWN_RESET(SSdynamic, heavy_ruleset_start)
			return TRUE
		if("latejoin_start_now")
			COOLDOWN_RESET(SSdynamic, latejoin_ruleset_start)
			return TRUE
		if("reset_midround_cooldown")
			COOLDOWN_RESET(SSdynamic, midround_cooldown)
			return TRUE
		if("reset_latejoin_cooldown")
			COOLDOWN_RESET(SSdynamic, latejoin_cooldown)
			return TRUE
