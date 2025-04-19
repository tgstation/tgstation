ADMIN_VERB(animation_panel, R_DEBUG|R_ADMIN|R_VAREDIT, "Animation Debug Panel", "Open a panel to test out various animation setups.", ADMIN_CATEGORY_FUN)
	GLOB.animate_panel.ui_interact(user.mob)

/datum/animate_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new /datum/tgui(user, src, "AnimationDebugPanel")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/animate_panel/ui_state(mob/user)
	return ADMIN_STATE(NONE)

/datum/animate_panel/ui_static_data(mob/user)
	. = list()

	var/list/animate_flags = list()
	for(var/datum/animate_flag/flag as anything in flags)
		flag = flags[flag]
		animate_flags[flag.name] = list(
			"description" = flag.description,
			"value" = flag.value,
		)
	.["animate_flags"] = animate_flags

	var/list/animate_easings = list()
	for(var/datum/animate_easing/easing as anything in easings)
		easing = easings[easing]
		animate_easings[easing.name] = list(
			"description" = easing.description,
			"value" = easing.value,
		)
	.["animate_easings"] = animate_easings

	var/list/animate_easing_flags = list()
	for(var/datum/animate_easing_flag/easing_flag as anything in easing_flags)
		easing_flag = easing_flags[easing_flag]
		animate_easing_flags[easing_flag.name] = list(
			"description" = easing_flag.description,
			"value" = easing_flag.value,
		)
	.["animate_easing_flags"] = animate_easing_flags

	var/list/animate_arguments = list()
	for(var/datum/animate_argument/argument as anything in arguments)
		argument = arguments[argument]
		animate_arguments[argument.name] = list(
			"description" = argument.description,
			"allowed_types" = list(),
		)
		for(var/arg in argument.arg_types)
			animate_arguments[argument.name]["allowed_types"] += list("[arg]")
	.["animate_arguments"] = animate_arguments

	return .

/datum/animate_panel/ui_data(mob/user)
	. = list()
	.["target"] = target_string_by_user[ref(user)]
	.["chain"] = animate_chains_by_user[ref(user)]?.serialize_json(list())
	return .

/datum/animate_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	var/mob/user = ui.user
	switch(action)
		if("export_dm")
#warn todo

		if("export_json")
			var/datum/animate_chain/front = get_chain_by_index(user, 1)
			if(!front)
				return
			var/json = front.serialize_json(list())

			var/json_directory = "data/animation_panel_exports"
			var/json_file = "[ckey(user)].json"
			if(!text2file(json, "[json_directory]/[json_file]"))
				return

			DIRECT_OUTPUT(user, ftp(file(json_file), json_file))
			return TRUE

		if("import_json")
			var/json_text = tgui_input_text(user, "Enter the json as text.", "Animation JSON Import", max_length = 4096, encode = FALSE)
			if(!json_text)
				return

			var/datum/animate_chain/imported = /datum/animate_chain::deserialize_json(json_text, list())
			if(isnull(imported))
				to_chat(user, span_warning("Failed to import JSON."))
				return

			if(imported.chain_index != 1)
				to_chat(user, span_warning("Malformed animation chain data."))
				return

			var/expected_index = 2
			for(var/datum/animate_chain/chain as anything in imported.get_all_next())
				if(chain.chain_index != expected_index)
					to_chat(user, span_warning("Malformed animation chain data."))
					return
				expected_index += 1

			animate_chains_by_user[ref(user)] = imported
			return TRUE

		if("wipe")
			animate_chains_by_user -= ref(user)
			return TRUE

		if("apply")
			var/target_text = target_string_by_user[ref(user)]
			var/target = (findtext(target_text, "ckey_") == 1) ? GLOB.directory[copytext(target_text, 6)] : locate(target_text)
			if(!target)
				return

			get_chain_by_index(user, 1)?.apply(target)
			return TRUE

		if("revert")
			var/target = locate(target_string_by_user[ref(user)])
			if(!target)
				return
			animate(target, flags = ANIMATION_END_NOW)
			return TRUE

		if("insert_chain")
			var/after = params["insert_after"]
			if(!isnum(after))
				return

			if(after == 0)
				var/datum/animate_chain/old_front = get_chain_by_index(user, 1)
				old_front.chain_index += 1

				var/datum/animate_chain/new_front = new
				new_front.chain_index = 1
				animate_chains_by_user[ref(user)] = new_front

				for(var/datum/animate_chain/chain as anything in old_front.get_all_next())
					chain.chain_index += 1
				new_front.next = old_front
				return TRUE

			var/datum/animate_chain/insert_after = get_chain_by_index(user, after)
			if(isnull(insert_after))
				return

			var/datum/animate_chain/inserted = new
			inserted.chain_index = after + 1

			for(var/datum/animate_chain/chain as anything in insert_after.get_all_next())
				chain.chain_index += 1
			inserted.next = insert_after.next
			insert_after.next = inserted

			return TRUE

		if("drop_chain")
			var/index = params["drop_index"]
			if(!isnum(index))
				return

			if(index == 1)
				var/datum/animate_chain/front = get_chain_by_index(user, 1)
				if(!front)
					return
				for(var/datum/animate_chain/chain as anything in front.get_all_next())
					chain.chain_index -= 1
				animate_chains_by_user[ref(user)] = front.next
				front.next = null
				return TRUE

			var/datum/animate_chain/before_dropped = get_chain_by_index(user, index - 1)
			var/datum/animate_chain/dropped = before_dropped.next
			for(var/datum/animate_chain/chain as anything in before_dropped.get_all_next())
				chain.chain_index -= 1
			before_dropped.next = dropped.next
			dropped.next = null
			return TRUE

		if("drop_argument")
			var/datum/animate_chain/chain = get_chain_by_index(user, params["drop_param_index"])
			if(isnull(chain))
				return

			var/param_name = params["drop_param_name"]
			if(!istext(param_name) || !(param_name in arguments))
				return
			chain.vars[param_name] = null

			return TRUE

		if("set_argument")
			var/datum/animate_chain/chain = get_chain_by_index(user, params["set_param_index"])
			if(isnull(chain))
				return

			var/param_name = params["set_param_name"]
			if(!istext(param_name) || !(param_name in arguments))
				return

			var/datum/animate_argument/argument_definition = arguments[param_name]
			var/list/valid_types = list()
			for(var/valid_type in argument_definition.arg_types)
				valid_types["[valid_type]"] = TRUE

			var/param_type = params["set_param_type"]
			if(!(param_type in valid_types))
				return
			if(!argument_definition.handle_set(user, chain, param_type, params["set_param_value"]))
				to_chat(user, span_warning("Failed to set argument!"))
				return

			return TRUE
