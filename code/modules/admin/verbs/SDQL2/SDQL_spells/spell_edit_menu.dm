GLOBAL_LIST_INIT_TYPED(sdql_spells, /datum/action/cooldown/spell, list())

/client/proc/cmd_sdql_spell_menu(target in GLOB.mob_list)
	set name = "Give/Edit SDQL spell"
	set hidden = TRUE
	if(CONFIG_GET(flag/sdql_spells))
		var/datum/give_sdql_spell/ui = new(usr, target)
		ui.ui_interact(usr)
	else
		to_chat(usr, span_warning("SDQL spells are disabled."))

/datum/give_sdql_spell
	var/client/user
	var/mob/living/target_mob
	var/datum/action/cooldown/spell/target_spell
	var/spell_type
	var/list/saved_vars = list("query" = "", "suppress_message_admins" = FALSE)
	var/list/list_vars = list()
	var/list/parse_result = null
	var/alert

	//This list contains all the vars that it should be okay to edit from the menu
	var/static/list/editable_spell_vars = list(
		// General vars
		"name",
		"desc",
		"background_icon_state",
		"icon_icon",
		"button_icon_state",
		"sound",
		"cooldown_time",

		"invocation",
		"invocation_type",
		"invocation_self_message",

		"sparks_amt",
		"smoke_type",
		"smoke_amt",

		// Pointed
		"base_icon_state",
		"ranged_mousepointer",
		"active_msg",
		"deactive_msg",
		"aim_assist",
		"cast_range",
		// Pointed/projectile
		"projectile_type",
		"projectile_amount",
		"projectiles_per_fire",

		// Cone
		"cone_level",
		"respect_density",

		// Touch
		"draw_message",
		"drop_message",
		"hand_path",
		"hand_var_overrides",

		// AoE
		"max_targets",
		"aoe_radius",

		//"requires_human",
		//"requires_non_abstract",
		//"requires_unphased",
		//"requires_no_antimagic",
		//"can_cast_on_centcom",
		//"requires_wizard_garb",
		//"requires_conscious",

	)

	// If a spell creates a datum with vars it overrides,
	/// this list should contain an association
	/// with the variable containing the path of the created datum.
	var/static/list/special_list_vars = list(
		"hand_var_overrides" = "hand_path",
	)

	var/static/list/special_var_lists = list(
		"hand_path" = "hand_var_overrides",
	)

	var/static/list/enum_vars = list(
		"invocation_type" = list(INVOCATION_NONE, INVOCATION_WHISPER, INVOCATION_SHOUT, INVOCATION_EMOTE),
		"smoke_type" = list(NO_SMOKE, SMOKE_HARMLESS, SMOKE_HARMFUL, SMOKE_SLEEPING),
	)

	//base64 representations of any icons that may need to be displayed
	var/action_icon_base64
	var/projectile_icon_base64
	var/hand_icon_base64
	var/overlay_icon_base64
	var/mouse_icon_base64

/datum/give_sdql_spell/New(user, target)
	if(!CONFIG_GET(flag/sdql_spells))
		to_chat(user, span_warning("SDQL spells are disabled."))
		qdel(src)
		return
	src.user = CLIENT_FROM_VAR(user)

	if(istype(target, /datum/action/cooldown/spell))
		target_spell = target
		if(target_spell.owner)
			target_mob = target_spell.owner
		else
			to_chat(user, span_warning("[target_spell] does not have an owner, or its owner was qdelled. This REALLY shouldn't happen."))
			qdel(src)
			return

	else if(isliving(target))
		target_mob = target

	else
		to_chat(user, span_warning("Invalid target."))
		qdel(src)
		return

	if(target_spell)
		load_vars_from(target_spell)

/datum/give_sdql_spell/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SDQLSpellMenu", "Give SDQL Spell")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/give_sdql_spell/ui_state(mob/user)
	return GLOB.admin_state

/datum/give_sdql_spell/ui_status(mob/user, datum/ui_state/state)
	if(QDELETED(target_mob))
		return UI_CLOSE
	return ..()

/datum/give_sdql_spell/ui_close(mob/user)
	qdel(src)

#define SANITIZE_NULLIFY 0
#define SANITIZE_STRINGIFY 1

/datum/give_sdql_spell/ui_data(mob/user, params)
	var/list/data = list()
	if(target_spell)
		data["type"] = copytext("[target_spell.type]", 31, -5)
		data["fixed_type"] = TRUE
	else
		data["type"] = spell_type
		data["fixed_type"] = FALSE
	data["saved_vars"] = saved_vars
	data["list_vars"] = json_sanitize_list_vars(list_vars, SANITIZE_STRINGIFY)
	if(parse_result)
		data["parse_errors"] = parse_result["parse_errors"]
		data["parsed_type"] = parse_result["type"]
		data["parsed_vars"] = parse_result["vars"]
		data["parsed_list_vars"] = json_sanitize_list_vars(parse_result["list_vars"], SANITIZE_STRINGIFY)
	else
		data["parse_errors"] = null
		data["parsed_type"] = null
		data["parsed_vars"] = null
		data["parsed_list_vars"] = null
	data["action_icon"] = action_icon_base64
	data["projectile_icon"] = projectile_icon_base64
	data["hand_icon"] = hand_icon_base64
	data["overlay_icon"] = overlay_icon_base64
	data["mouse_icon"] = mouse_icon_base64
	data["alert"] = alert
	alert = ""
	return data

/datum/give_sdql_spell/ui_static_data(mob/user)
	return list(
		"types" = list("pointed", "pointed/projectile", "cone", "cone/staggered", "aoe", "self", "touch"),
		"tooltips" = list(
			// General tooltips
			"query" = "The SDQL query that is executed. Certain keywords are specific to SDQL spell queries.\n\
				$type\n\
				USER is replaced with a reference to the user of the spell.\n\
				TARGETS_AND_USER is replaced with the combined references from TARGETS and USER.\n\
				SOURCE is replaced with a reference to this spell, allowing you to refer to and edit variables within it.\n\
				SCRATCHPAD is a list used to store variables between individual queries within the same cast or between multiple casts.\n\
				NOTE: The SDQL keywords usr and marked do not work.",

			"query_projectile" = "TARGETS is replaced with a list with the atom hit by the fired projectile.",
			"query_aoe" = "TARGETS is replaced with a list with every atom in the spell's area of effect.",
			"query_cone" = "TARGETS is replaced with a list with every atom in the cone produced by the spell.",
			"query_cone/staggered" = "The query will be executed once for every level of the cone produced by the spell.\n\
				TARGETS is replaced with a list containing with every atom in the given level of the cone.",
			"query_pointed" = "TARGETS is replaced with a list with the targeted atom.",
			"query_self" = "TARGETS is is replaced with a list containing only the caster.",
			"query_targeted_touch" = "TARGETS is replaced with a list containing a the atom hit with the touch attack.",

			"suppress_message_admins" = "If this is true, the spell will not print out its query to admins' chat panels.\n\
				The query will still be output to the game log.",

			// Spell vars
			"invocation_type" = "How the spell is invoked.\n\
				When set to \"none\", the user will not state anything when invocating.\n\
				When set to \"whisper\", the user whispers the invocation, as if with the whisper verb.\n\
				When set to \"shout\", the user says the invocation, as if with the say verb.\n\
				When set to \"emote\", a visible message is produced.",
			"invocation" = "What the user says, whispers, or emotes when using the spell.",
			"invocation_self_message" = "What the user sees in their own chat when they use the spell. Requires emote invocation.",
			"sparks_amt" = "Whether the spell produces sparks when cast.",
			"smoke_type" = "The kind of smoke, if any, the spell produces when cast.",

			// Aoe spell vars
			"max_targets" = "The maximum number of mobs the spell can target.",
			"aoe_radius" = "The radius around the user affected by the spell.",

			// Pointed spell vars
			"ranged_mousepointer" = "The icon used for the mouse when aiming the spell.",
			"active_msg" = "The message the user sees when activating the spell.",
			"deactive_mesg" = "The message the user sees when canceling the spell.",
			"aim_assist" = "If true, the spell has turf-based aim assist.",
			// Pointed/projectile spell vars
			"projectile_amount" = "The maximum number of projectiles the user can fire with each cast of the spell.",
			"projectiles_per_fire" = "The amount of projectiles fired with each click of the mouse.",

			// Cone spell stuff
			"cone_level" = "How many tiles out the cone will extend.",
			"respect_density" = "If true, the cone produced by the spell is blocked by walls.",

			// Touch spells
			"draw_message" = "The message the user sees when activating the spell.",
			"drop_message" = "The message the user sees when canceling the spell.",
			"hand_var_overrides" = "The touch attack will have the appropriate variables overridden by the corresponding values in this associative list.\n\
				You should probably set \"name\", \"desc\", \"catchphrase\", \"on_use_sound\" \"icon\", \"icon_state\", and \"inhand_icon_state\".\n\
				Refer to code/modules/spells/spell_types/godhand.dm to see what other vars you can override.",

			// Extra
			"scratchpad" = "This list can be used to store variables between individual queries within the same cast or between casts.\n\
				You can declare variables from this menu for convenience. To access this list in a query, use the identifier \"SOURCE.scratchpad\".\n\
				Refer to the _list procs defined in code/modules/admin/verbs/SDQL2/SDQL_2_wrappers.dm for information on how to modify and edit list vars from within a query.",
		),
	)

#define LIST_VAR_FLAGS_TYPED 1
#define LIST_VAR_FLAGS_NAMED 2

/datum/give_sdql_spell/proc/load_vars_from(datum/action/cooldown/spell/sample)
	var/datum/component/sdql_spell_executor/executor = sample.GetComponent(/datum/component/sdql_spell_executor)
	if(!executor)
		CRASH("[sample]'s SDQL executor component went missing!")
	saved_vars["query"] = executor.query
	saved_vars["suppress_message_admins"] = executor.suppress_message_admins
	load_list_var(executor.scratchpad, "scratchpad")
	for(var/V in sample.vars&editable_spell_vars)
		if(islist(sample.vars[V]))
			if(special_list_vars[V])
				var/list/saved_overrides = executor.saved_overrides[V]
				if(saved_overrides)
					list_vars[V] = saved_overrides.Copy()
				icon_needs_updating("[V]/icon")
		else
			saved_vars[V] = sample.vars[V]
			icon_needs_updating(V)

/datum/give_sdql_spell/proc/load_list_var(list/L, list_name)
	list_vars[list_name] = list()
	for(var/V in L)
		if(islist(L[V]))
			list_vars[list_name][V] = list("type" = "list", "value" = null)
			list_vars |= load_list_var(L[V], "[list_name]/[V]")
		else if(isnum(L[V]))
			list_vars[list_name][V] = list("type" = "num", "value" = L[V])
		else if(ispath(L[V]))
			list_vars[list_name][V] = list("type" = "path", "value" = L[V])
		else if(isicon(L[V]))
			list_vars[list_name][V] = list("type" = "icon", "value" = L[V])
		else if(istext(L[V]) || isfile(L[V]))
			list_vars[list_name][V] = list("type" = "string", "value" = L[V])
		else if(istype(L[V], /datum))
			list_vars[list_name][V] = list("type" = "ref", "value" = L[V])
		else if(isnull(L[V]))
			list_vars[list_name][V] = list("type" = "num", "value" = 0)
			alert = "Could not determine the type for [list_name]/[V]! Be sure to set it correctly, or you may cause unnecessary runtimes!"

/datum/give_sdql_spell/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	. = TRUE
	switch(action)
		if("type")
			if(!target_spell)
				spell_type = params["path"]
				load_sample()
		if("variable")
			var/V = params["name"]
			if(V == "holder_var_type")
				if(!holder_var_validate(params["value"]))
					return
			saved_vars[V] = params["value"]
			icon_needs_updating(V)
		if("bool_variable")
			saved_vars[params["name"]] = !saved_vars[params["name"]]
		if("path_variable")
			var/new_path = tgui_input_list(user, "Select type.", "Add SDQL Spell", typesof(text2path(params["root_path"])))
			if(isnull(new_path))
				return
			saved_vars[params["name"]] = new_path
			var/datum/sample = new new_path
			var/list/overrides = list_vars[special_var_lists[params["name"]]]
			overrides = overrides&sample.vars
			qdel(sample)
			icon_needs_updating(params["name"])
		if("list_variable_add")
			if(!list_vars[params["list"]])
				list_vars[params["list"]] = list()
			if(special_list_vars[params["list"]])
				var/path = saved_vars[special_list_vars[params["list"]]]
				var/datum/sample = new path
				var/list/choosable_vars = map_var_list(sample.vars-list_vars[params["list"]], sample)
				var/chosen_var = tgui_input_list(user, "Select variable to add.", "Add SDQL Spell", sort_list(choosable_vars))
				if(chosen_var)
					if(islist(sample.vars[choosable_vars[chosen_var]]))
						list_vars[params["list"]][choosable_vars[chosen_var]] = list("type" = "list", "value" = null, "flags" = LIST_VAR_FLAGS_TYPED|LIST_VAR_FLAGS_NAMED)
						list_vars["[params["list"]]/[choosable_vars[chosen_var]]"] = list()
					else if(isnum(sample.vars[choosable_vars[chosen_var]]))
						list_vars[params["list"]][choosable_vars[chosen_var]] = list("type" = "num", "value" = sample.vars[choosable_vars[chosen_var]], "flags" = LIST_VAR_FLAGS_TYPED|LIST_VAR_FLAGS_NAMED)
					else if(ispath(sample.vars[choosable_vars[chosen_var]]))
						list_vars[params["list"]][choosable_vars[chosen_var]] = list("type" = "path", "value" = sample.vars[choosable_vars[chosen_var]], "flags" = LIST_VAR_FLAGS_TYPED|LIST_VAR_FLAGS_NAMED)
					else if(isicon(sample.vars[choosable_vars[chosen_var]]))
						list_vars[params["list"]][choosable_vars[chosen_var]] = list("type" = "icon", "value" = sample.vars[choosable_vars[chosen_var]], "flags" = LIST_VAR_FLAGS_TYPED|LIST_VAR_FLAGS_NAMED)
					else if(istext(sample.vars[choosable_vars[chosen_var]]) || isfile(sample.vars[choosable_vars[chosen_var]]))
						list_vars[params["list"]][choosable_vars[chosen_var]] = list("type" = "string", "value" = sample.vars[choosable_vars[chosen_var]], "flags" = LIST_VAR_FLAGS_TYPED|LIST_VAR_FLAGS_NAMED)
					else if(istype(sample.vars[choosable_vars[chosen_var]], /datum))
						list_vars[params["list"]][choosable_vars[chosen_var]] = list("type" = "ref", "value" = null, "flags" = LIST_VAR_FLAGS_TYPED|LIST_VAR_FLAGS_NAMED)
						alert = "[params["list"]]/[choosable_vars[chosen_var]] is a reference! Be sure to set it correctly, or you may cause unnecessary runtimes!"
					else if(isnull(sample.vars[choosable_vars[chosen_var]]))
						list_vars[params["list"]][choosable_vars[chosen_var]] = list("type" = "num", "value" = 0, "flags" = LIST_VAR_FLAGS_NAMED)
						alert = "Could not determine the type for [params["list"]]/[choosable_vars[chosen_var]]! Be sure to set it correctly, or you may cause unnecessary runtimes!"
					else
						alert = "[params["list"]]/[choosable_vars[chosen_var]] is not of a supported type!"
					icon_needs_updating("[params["list"]]/[choosable_vars[chosen_var]]")
				qdel(sample)
			else
				if(!list_vars[params["list"]]["new_var"])
					list_vars[params["list"]] += list("new_var" = list("type" = "num", "value" = 0, "flags" = 0))
				else
					alert = "Rename or remove [params["list"]]/new_var before attempting to add another variable to this list!"
		if("list_variable_remove")
			remove_list_var(params["list"], params["name"])
		if("list_variable_rename")
			rename_list_var(params["list"], params["name"], params["new_name"])
		if("list_variable_change_type")
			change_list_var_type(params["list"], params["name"], params["value"])
		if("list_variable_change_value")
			set_list_var(params["list"], params["name"], params["value"])
			icon_needs_updating("[params["list"]]/[params["name"]]")
		if("list_variable_change_bool")
			toggle_list_var(params["list"], params["name"])
		if("list_variable_set_ref")
			set_list_ref_var(params["list"], params["name"])
		if("save")
			var/f = file("data/TempSpellUpload")
			fdel(f)
			WRITE_FILE(f, json_encode(list("type" = spell_type, "vars" = saved_vars, "list_vars" = json_sanitize_list_vars(list_vars))))
			user << ftp(f,"[replacetext_char(saved_vars["name"], " ", "_")].json")
		if("load")
			var/spell_file = input("Pick spell json file:", "File") as null|file
			if(!spell_file)
				return
			var/filedata = file2text(spell_file)
			var/json = json_decode(filedata)
			if(!json)
				alert = "JSON decode error!"
				return
			parse_result = load_from_json(json)
			var/list/parse_errors = parse_result["parse_errors"]
			if(!parse_errors.len)
				finalize_load()
		if("close_error")
			parse_result = null
		if("load_despite_error")
			finalize_load()
		if("confirm")
			if(target_spell)
				reassign_vars(target_spell)
				target_spell.UpdateButtons()
				log_admin("[key_name(user)] edited the SDQL spell \"[target_spell]\" owned by [key_name(target_mob)].")
			else
				var/new_spell = give_spell()
				log_admin("[key_name(user)] gave the SDQL spell \"[new_spell]\" to [key_name(target_mob)].")
			ui.close()

/datum/give_sdql_spell/proc/load_sample()
	var/path = text2path("/datum/action/cooldown/spell/[spell_type]/sdql")
	var/datum/sample = new path
	if(spell_type)
		load_vars_from(sample)
	qdel(sample)

/datum/give_sdql_spell/proc/finalize_load()
	spell_type = parse_result["type"]
	load_sample()
	saved_vars = parse_result["vars"] | saved_vars
	list_vars = parse_result["list_vars"] | list_vars
	parse_result = null
	icon_needs_updating("everything")

//Change all references in the list vars, either to null (for saving) or to their string representation (for display)
/datum/give_sdql_spell/proc/json_sanitize_list_vars(list/list_vars, mode = SANITIZE_NULLIFY)
	var/list/temp_list_vars = deep_copy_list(list_vars)
	for(var/V in temp_list_vars)
		var/list/L = temp_list_vars[V]
		for(var/W in L)
			if(temp_list_vars[V][W]["type"] == "ref")
				switch(mode)
					if(SANITIZE_NULLIFY)
						temp_list_vars[V][W]["value"] = null
					if(SANITIZE_STRINGIFY)
						if(temp_list_vars[V][W]["value"])
							temp_list_vars[V][W]["value"] = "[temp_list_vars[V][W]["value"]]"
						else
							temp_list_vars[V][W]["value"] = "null"
	return temp_list_vars

#undef SANITIZE_NULLIFY
#undef SANITIZE_STRINGIFY

/datum/give_sdql_spell/proc/load_from_json(json)
	var/list/result_vars = list()
	var/list/result_list_vars = list()
	var/list/parse_errors = list()
	. = list("type" = "",
			"vars" = result_vars,
			"list_vars" = result_list_vars,
			"parse_errors" = parse_errors)
	if(!json["type"])
		parse_errors += "The \"type\" property is missing from the json file"
		return
	var/temp_type = json["type"]
	var/datum/D = text2path("/datum/action/cooldown/spell/[temp_type]/sdql")
	if(!ispath(D))
		parse_errors += "[temp_type] is not a valid SDQL spell type"
		return
	if(target_spell)
		if(!istype(target_spell, D))
			parse_errors += "You cannot change the type of an existing spell"
	if(!json["vars"])
		parse_errors += "The \"vars\" property is missing from the json file"
	if(!islist(json["vars"]))
		parse_errors += "The \"vars\" property must be a json object"
	if(!json["list_vars"])
		parse_errors += "The \"list_vars\" property is missing from the json file"
	if(!islist(json["list_vars"]))
		parse_errors += "The \"list_vars\" property must be a json object"
	if(parse_errors.len)
		return
	.["type"] = temp_type
	var/list/temp_vars = json["vars"]
	var/list/temp_list_vars = json["list_vars"]
	D = new D
	for(var/V in temp_vars)
		if(!istext(V))
			parse_errors += "JSON property names must be text ([V] is not text)"
			continue
		if(V == "query")
			if(!istext(temp_vars[V]))
				parse_errors += "The value of \"query\" must be text"
				continue
			result_vars[V] = temp_vars[V]
			continue
		if(V == "suppress_message_admins")
			if(!isnum(temp_vars[V]))
				parse_errors += "The value of \"suppress_message_admins\" must be a number"
				continue
			result_vars[V] = !!temp_vars[V]
			continue
		if(!(V in editable_spell_vars))
			parse_errors += "\"[V]\" is not an editable variable"
			continue
		if(!(V in D.vars)) //D.vars[V] can runtime unlike V in D.vars
			parse_errors += "Spells of type \"[temp_type]\" have no such var [V]"
			continue
		if(islist(D.vars[V]))
			parse_errors += "[D.type]/[V] is a list; vars.[V] should be in the \"list_vars\" property"
			continue
		if(istext(D.vars[V]))
			if(!istext(temp_vars[V]))
				parse_errors += "[D.type]/[V] is text; vars.[V] has been converted to text"
				temp_vars[V] = "[temp_vars[V]]"
				continue
			if(V=="holder_var_type")
				var/potential_alert = holder_var_validate(temp_vars[V], TRUE)
				if(potential_alert)
					parse_errors += potential_alert
					continue
		if(isicon(D.vars[V]))
			if(!istext(temp_vars[V]))
				parse_errors += "[D.type]/[V] is an icon; vars.[V] has been converted to text"
				temp_vars[V] = "[temp_vars[V]]"
			if(!fexists(temp_vars[V]))
				parse_errors += "[D.type]/[V] is an icon; no such file [temp_vars[V]] exists on the server"
				continue
		if(ispath(D.vars[V]))
			if(!istext(temp_vars[V]))
				parse_errors += "[D.type]/[V] is a path; vars.[V] has been converted to text"
				temp_vars[V] = "[temp_vars[V]]"
			var/path = text2path(temp_vars[V])
			if(!path)
				parse_errors += "[D.type]/[V] is a path; vars.[V] ([temp_vars[V]]) does not correspond to an existing type"
				continue
			if(!ispath(path, D.vars[V]))
				parse_errors += "[D.type]/[V] is a path; vars.[V] ([path]) is not derived from [D.vars[V]]"
				continue
		if(isnum(D.vars[V]))
			if(!isnum(temp_vars[V]))
				parse_errors += "[D.type]/[V] is a number; vars.[V] should be a number"
				continue
		if(enum_vars[V])
			var/list/enum = enum_vars[V]
			if(!enum.Find(temp_vars[V]))
				parse_errors += "[D.type]/[V] is an enumeration; vars.[V] should be one of: [english_list(enum, and_text = " or ")]"
				continue
		result_vars[V] = temp_vars[V]
	for(var/V in temp_list_vars)
		if(!istext(V))
			parse_errors += "JSON property names must be text ([V] is not text)"
			continue
		if(!islist(temp_list_vars[V]))
			parse_errors += "list_vars.[V] should be a json object"
			continue
		if(special_list_vars[V] && (V in D.vars))
			var/sample_path = D.vars[special_list_vars[V]]
			var/temp_path
			if(temp_vars[special_list_vars[V]])
				temp_path = temp_vars[special_list_vars[V]]
			temp_path = text2path(temp_path)
			if(!temp_path)
				parse_errors += "[D.type]/[special_list_vars[V]] is a path; vars.[temp_vars[special_list_vars[V]]] (temp_vars[special_list_vars[V]]) does not correspond to an existing type"
			else if(!ispath(temp_path, D.vars[special_list_vars[V]]))
				parse_errors += "[D.type]/[special_list_vars[V]] is a path; vars.[special_list_vars[V]] ([temp_path]) is not derived from [D.vars[special_list_vars[V]]]"
			else
				sample_path = temp_path
			result_list_vars[V] = list()
			var/datum/sample = new sample_path
			for(var/W in temp_list_vars[V])
				if(!istext(W))
					parse_errors += "JSON property names must be text ([W] in list_vars.[V] is not text)"
					continue
				if(!(W in sample.vars))
					parse_errors += "[sample.type] has no such var \"[W]\""
					continue
				if(!(islist(temp_list_vars[V][W]) && istext(temp_list_vars[V][W]["type"]) && (istext(temp_list_vars[V][W]["value"]) || isnum(temp_list_vars[V][W]["value"]) || isnull(temp_list_vars[V][W]["value"])) && isnum(temp_list_vars[V][W]["flags"])))
					parse_errors += "[V]/[W] is not of the form {type: string, value: num|string|null, flags: number}"
					continue
				if(!(temp_list_vars[V][W]["flags"] & LIST_VAR_FLAGS_NAMED))
					parse_errors += "[V]/[W] did not have the LIST_VAR_FLAGS_NAMED flag set; it has been set"
					temp_list_vars[V][W]["flags"] |= LIST_VAR_FLAGS_NAMED
				if(temp_list_vars[V][W]["flags"] & ~(LIST_VAR_FLAGS_NAMED | LIST_VAR_FLAGS_TYPED))
					parse_errors += "[V]/[W] has unused bit flags set; they have been unset"
					temp_list_vars[V][W]["flags"] &= LIST_VAR_FLAGS_NAMED | LIST_VAR_FLAGS_TYPED
				if(!(temp_list_vars[V][W]["flags"] & LIST_VAR_FLAGS_TYPED))
					if(isnull(sample.vars[W]))
						continue
					parse_errors += "[sample.type]/[W] is not null; it has had the LIST_VAR_FLAGS_TYPED flag set"
					temp_list_vars[V][W]["flags"] |= LIST_VAR_FLAGS_TYPED
					if(islist(sample.vars[W]))
						temp_list_vars[V][W]["type"] = "list"
					else if(isnum(sample.vars[W]))
						temp_list_vars[V][W]["type"] = "num"
					else if(istext(sample.vars[W]))
						temp_list_vars[V][W]["type"] = "string"
					else if(ispath(sample.vars[W]))
						temp_list_vars[V][W]["type"] = "path"
					else if(isicon(sample.vars[W]))
						temp_list_vars[V][W]["type"] = "icon"
					else if(istype(sample.vars[W], /datum))
						temp_list_vars[V][W]["type"] = "ref"
						temp_list_vars[V][W]["value"] = null
					else
						parse_errors += "[sample.type]/[W] is not of a supported type"
						continue
				if(islist(sample.vars[W]))
					if(temp_list_vars[V][W]["type"] != "list")
						parse_errors += "[sample.type]/[W] is a list; list_vars.[V].[W].type has been converted to \"list\""
						temp_list_vars[V][W]["type"] = "list"
					if(!istext(temp_list_vars[V][W]["value"]))
						parse_errors += "list_vars.[V].[W].type is \"list\"; list_vars.[V].[W].value ([temp_list_vars[V][W]["value"]]) has been converted to text"
						temp_list_vars[V][W]["value"] = "[temp_list_vars[V][W]["value"]]"
					if(!temp_list_vars[temp_list_vars[V][W]["value"]])
						parse_errors += "list_vars.[V].[W].type is \"list\"; there is no property of list_vars whose name is list_vars.[V].[W].value ([temp_list_vars[V][W]["value"]])"
						continue
				else if(isnum(sample.vars[W]))
					if(temp_list_vars[V][W]["type"] != "num")
						parse_errors += "[sample.type]/[W] is a number; list_vars.[V].[W].type has been converted to \"num\""
						temp_list_vars[V][W]["type"] = "num"
					if(!isnum(temp_list_vars[V][W]["value"]))
						parse_errors += "list_vars.[V].[W].type is \"num\"; list_vars.[V].[W].value ([temp_list_vars[V][W]["value"]]) should be a number"
						continue
				else if(istext(sample.vars[W]))
					if(temp_list_vars[V][W]["type"] != "string")
						parse_errors += "[sample.type]/[W] is text; list_vars.[V].[W].type has been converted to \"string\""
						temp_list_vars[V][W]["type"] = "string"
					if(!istext(temp_list_vars[V][W]["value"]))
						parse_errors += "list_vars.[V].[W].type is \"list\"; list_vars.[V].[W].value ([temp_list_vars[V][W]["value"]]) has been converted to text"
						temp_list_vars[V][W]["value"] = "[temp_list_vars[V][W]["value"]]"
				else if(ispath(sample.vars[W]))
					if(temp_list_vars[V][W]["type"] != "path")
						parse_errors += "[sample.type]/[W] is a path; list_vars.[V].[W].type has been converted to \"path\""
						temp_list_vars[V][W]["type"] = "path"
					if(!istext(temp_list_vars[V][W]["value"]))
						parse_errors += "list_vars.[V].[W].type is \"path\"; list_vars.[V].[W].value ([temp_list_vars[V][W]["value"]]) has been converted to text"
						temp_list_vars[V][W]["value"] = "[temp_list_vars[V][W]["value"]]"
					temp_path = text2path(temp_list_vars[V][W]["value"])
					if(!ispath(temp_path))
						parse_errors += "list_vars.[W].[W].type is \"path\"; list_vars.[V].[W].value ([temp_list_vars[V][W]["value"]]) does not correspond to an existing type"
						continue
					if(!ispath(temp_path, sample.vars[W]))
						parse_errors += "list_vars.[W].[W].type is \"path\"; list_vars.[V].[W].value ([temp_list_vars[V][W]["value"]]) is not derived from [sample.vars[W]]"
						continue
				else if(isicon(sample.vars[W]))
					if(temp_list_vars[V][W]["type"] != "icon")
						parse_errors += "[sample.type]/[W] is an icon; list_vars.[V].[W].type has been converted to \"icon\""
						temp_list_vars[V][W]["type"] = "icon"
					if(!istext(temp_list_vars[V][W]["value"]))
						parse_errors += "list_vars.[V].[W].type is \"icon\"; list_vars.[V].[W].value ([temp_list_vars[V][W]["value"]]) has been converted to text"
						temp_list_vars[V][W]["value"] = "[temp_list_vars[V][W]["value"]]"
					if(!fexists(temp_list_vars[V][W]["value"]))
						parse_errors += "list_vars.[V].[W].type is \"icon\"; no such file \"[temp_list_vars[V][W]["value"]]\" exists on the server"
						continue
				else if(istype(sample.vars[W], /datum))
					if(temp_list_vars[V][W]["type"] != "ref")
						parse_errors += "[sample.type]/[W] is a datum reference; list_vars.[V].[W].type has been converted to \"ref\""
						alert = "Reference vars are not assigned on load from file. Be sure to set them correctly."
						temp_list_vars[V][W]["type"] = "ref"
						temp_list_vars[V][W]["value"] = null
				result_list_vars[V][W] = temp_list_vars[V][W]
				qdel(sample)
		else
			result_list_vars[V] = list()
			for(var/W in temp_list_vars[V])
				if(temp_list_vars[V][W]["flags"])
					parse_errors += "list_vars.[V].[W] has unnecessary flags set; they have been unset"
					temp_list_vars[V][W]["flags"] = 0
				if(temp_list_vars[V][W]["type"] == "list")
					if(temp_list_vars[V][W]["value"])
						parse_errors += "list_vars.[V].[W].type is \"list\"; list_vars.[V].[W].value ([temp_list_vars[V][W]["value"]]) has been nulled, as it is not used"
						temp_list_vars[V][W]["value"] = null
					if(!temp_list_vars["[V]/[W]"])
						parse_errors += "list_vars.[V].[W].type is \"list\"; there is no property of list_vars whose name is \"[V]/[W]\""
						continue
				if(temp_list_vars[V][W]["type"] == "num")
					if(!isnum(temp_list_vars[V][W]["value"]))
						parse_errors += "list_vars.[V].[W].type is \"num\"; list_vars.[V].[W].value ([temp_list_vars[V][W]["value"]]) should be a number"
						continue
				if(temp_list_vars[V][W]["type"] == "string")
					if(!istext(temp_list_vars[V][W]["value"]))
						parse_errors += "list_vars.[V].[W].type is \"string\"; list_vars.[V].[W].value ([temp_list_vars[V][W]["value"]]) has been converted to text"
						temp_list_vars[V][W]["value"] = "[temp_list_vars[V][W]["value"]]"
				if(temp_list_vars[V][W]["type"] == "path")
					if(!istext(temp_list_vars[V][W]["value"]))
						parse_errors += "list_vars.[V].[W].type is \"path\"; list_vars.[V].[W].value ([temp_list_vars[V][W]["value"]]) has been converted to text"
						temp_list_vars[V][W]["value"] = "[temp_list_vars[V][W]["value"]]"
					var/temp_path = text2path(temp_list_vars[V][W]["value"])
					if(!ispath(temp_path))
						parse_errors += "list_vars.[W].[W].type is \"path\"; list_vars.[V].[W].value ([temp_list_vars[V][W]["value"]]) does not correspond to an existing type"
						continue
				if(temp_list_vars[V][W]["type"] == "icon")
					if(!istext(temp_list_vars[V][W]["value"]))
						parse_errors += "list_vars.[V].[W].type is \"icon\"; list_vars.[V].[W].value ([temp_list_vars[V][W]["value"]]) has been converted to text"
						temp_list_vars[V][W]["value"] = "[temp_list_vars[V][W]["value"]]"
					if(!fexists(temp_list_vars[V][W]["value"]))
						parse_errors += "list_vars.[V].[W].type is \"icon\"; no such file \"[temp_list_vars[V][W]["value"]]\" exists on the server"
						continue
				if(temp_list_vars[V][W]["type"] == "ref")
					if(!isnull(temp_list_vars[V][W]["value"]))
						parse_errors += "list_vars.[V].[W].type is \"ref\"; list_vars.[V].[W].value has been nulled out"
						temp_list_vars[V][W]["value"] = null
					else
						alert = "Reference vars are not assigned on load from file. Be sure to set them correctly."
				result_list_vars[V][W] = temp_list_vars[V][W]
	qdel(D)

#undef LIST_VAR_FLAGS_TYPED
#undef LIST_VAR_FLAGS_NAMED

/datum/give_sdql_spell/proc/map_var_list(list/L, datum/D)
	var/list/ret = list()
	for(var/V in L)
		if(D.vars[V])
			ret["[V] = [string_rep(D.vars[V])]"] = V
	return ret

/datum/give_sdql_spell/proc/string_rep(V)
	if(istext(V) || isfile(V) || isicon(V))
		return "\"[V]\""
	else if(isnull(V))
		return "null"
	else
		return "[V]"

/datum/give_sdql_spell/proc/holder_var_validate(V, return_alert = FALSE)
	switch(V)
		if("bruteloss", "fireloss", "toxloss", "oxyloss", "stun", "knockdown", "paralyze", "unconscious")
			if(return_alert)
				return ""
			return TRUE
		else
			if(target_mob.vars[V])
				if(!isnum(target_mob.vars[V]))
					var/new_alert = "[target_mob.type]/[V] is not a number!"
					if(return_alert)
						return new_alert
					alert = new_alert
					return FALSE
				else
					return return_alert ? "" : TRUE
			else
				var/new_alert = "[target_mob.type] has no such variable [V]!"
				if(return_alert)
					return new_alert
				alert = new_alert
				return FALSE

/datum/give_sdql_spell/proc/icon_needs_updating(var_name)
	switch(var_name)
		if("action_icon", "action_icon_state", "action_background_icon_state")
			var/icon/out_icon = icon('icons/effects/effects.dmi', "nothing")
			var/image/out_image = image('icons/mob/actions/backgrounds.dmi', null, saved_vars["action_background_icon_state"])
			var/overlay_icon = icon(saved_vars["action_icon"], saved_vars["action_icon_state"])
			out_image.overlays += image(overlay_icon)
			out_icon.Insert(getFlatIcon(out_image, no_anim = TRUE))
			action_icon_base64 = icon2base64(out_icon)

		if("hand_var_overrides/icon", "hand_var_overrides/icon_state")
			var/atom/A = /obj/item/melee/touch_attack
			var/icon = initial(A.icon)
			var/icon_state = initial(A.icon_state)
			if(list_vars["hand_var_overrides"]?["icon"])
				icon = list_vars["hand_var_overrides"]["icon"]["value"]
			if(list_vars["hand_var_overrides"]?["icon_state"])
				icon_state = list_vars["hand_var_overrides"]["icon_state"]["value"]
			var/icon/out_icon = icon(icon, icon_state, frame = 1)
			hand_icon_base64 = icon2base64(out_icon)

		if("overlay", "overlay_icon", "overlay_icon_state")
			var/icon/out_icon = icon(saved_vars["overlay_icon"], saved_vars["overlay_icon_state"], frame = 1)
			overlay_icon_base64 = icon2base64(out_icon)

		if("ranged_mousepointer")
			var/icon/out_icon = icon(saved_vars["ranged_mousepointer"], frame = 1)
			mouse_icon_base64 = icon2base64(out_icon)

		if("everything")
			var/icon/out_icon = icon('icons/effects/effects.dmi', "nothing")
			var/image/out_image = image('icons/mob/actions/backgrounds.dmi', null, saved_vars["action_background_icon_state"])
			var/overlay_icon = icon(saved_vars["action_icon"], saved_vars["action_icon_state"])
			out_image.overlays += image(overlay_icon)
			out_icon.Insert(getFlatIcon(out_image, no_anim = TRUE))
			action_icon_base64 = icon2base64(out_icon)
			if(list_vars["hand_var_overrides"])
				var/atom/A = saved_vars["hand_path"]
				var/icon = initial(A.icon)
				var/icon_state = initial(A.icon_state)
				if(list_vars["hand_var_overrides"]?["icon"])
					icon = list_vars["hand_var_overrides"]["icon"]["value"]
				if(list_vars["hand_var_overrides"]?["icon_state"])
					icon_state = list_vars["hand_var_overrides"]["icon_state"]["value"]
				out_icon = icon(icon, icon_state, frame = 1)
				hand_icon_base64 = icon2base64(out_icon)
			out_icon = icon(saved_vars["overlay_icon"], saved_vars["overlay_icon_state"], frame = 1)
			overlay_icon_base64 = icon2base64(out_icon)
			out_icon = icon(saved_vars["ranged_mousepointer"], frame = 1)
			mouse_icon_base64 = icon2base64(out_icon)

/datum/give_sdql_spell/proc/toggle_list_var(list_name, list_var)
	if(list_vars[list_name]?[list_var])
		list_vars[list_name][list_var]["value"] = !list_vars[list_name][list_var]["value"]

/datum/give_sdql_spell/proc/set_list_var(list_name, list_var, value)
	if(list_vars[list_name]?[list_var])
		list_vars[list_name][list_var]["value"] = value

/datum/give_sdql_spell/proc/set_list_ref_var(list_name, list_var)
	if(list_vars[list_name]?[list_var])
		list_vars[list_name][list_var]["value"] = user.holder?.marked_datum

/datum/give_sdql_spell/proc/rename_list_var(list_name, list_var, new_name)
	if(!new_name)
		alert = "You can't give a list variable an empty string for a name!"
		return
	if(list_var == new_name)
		return
	if(list_vars[list_name])
		var/list/L = list_vars[list_name]
		var/ind = L.Find(list_var)
		if(ind)
			if(list_vars[list_name][new_name])
				alert = "There is already a variable named [new_name] in [list_name]!"
			else
				var/old_val = list_vars[list_name][list_var]
				list_vars[list_name][ind] = new_name
				list_vars[list_name][new_name] = old_val

/datum/give_sdql_spell/proc/change_list_var_type(list_name, list_var, var_type)
	if(list_vars[list_name]?[list_var])
		if(list_vars[list_name][list_var]["type"] == "list" && var_type != "list")
			purge_list_var("[list_name]/[list_var]")
		list_vars[list_name][list_var]["type"] = var_type
		switch(var_type)
			if("string", "path")
				list_vars[list_name][list_var]["value"] = ""
			if("bool", "num")
				list_vars[list_name][list_var]["value"] = 0
			if("list")
				list_vars[list_name][list_var]["value"] = null
				list_vars |= list("[list_name]/[list_var]" = list())

/datum/give_sdql_spell/proc/remove_list_var(list_name, list_var)
	if(list_vars[list_name])
		var/list/L = list_vars[list_name]
		var/ind = L.Find(list_var)
		if(ind)
			if(list_vars[list_name][list_var]["type"] == "list")
				purge_list_var("[list_name]/[list_var]")
			L.Cut(ind, ind+1)
			list_vars[list_name] = L

/datum/give_sdql_spell/proc/purge_list_var(list_name)
	var/ind = list_vars.Find(list_name)
	if(ind)
		for(var/V in list_vars[list_name])
			if(list_vars[list_name][V]["type"] == "list")
				purge_list_var("[list_name]/[V]")
		list_vars.Cut(ind, ind+1)

/datum/give_sdql_spell/proc/generate_list_var(list_name)
	if(!list_vars[list_name])
		return null
	var/list/ret = list()
	for(var/V in list_vars[list_name])
		if(list_vars[list_name][V]["type"] == "list")
			ret[V] = generate_list_var("[list_name]/[V]")
		else if(list_vars[list_name][V]["type"] == "path")
			ret[V] = text2path(list_vars[list_name][V]["value"])
		else if(list_vars[list_name][V]["type"] == "icon")
			ret[V] = icon(list_vars[list_name][V]["value"])
		else
			ret[V] = list_vars[list_name][V]["value"]
	return ret

/datum/give_sdql_spell/proc/give_spell()
	var/path = text2path("/odatum/action/cooldown/spell/[spell_type]/sdql")
	var/datum/action/cooldown/spell/new_spell = new path(target_mob.mind || target_mob, user.ckey)

	GLOB.sdql_spells += new_spell
	reassign_vars(new_spell)
	new_spell.Grant(target_mob)
	if(target_mob.mind)
		to_chat(user, span_bolddanger("Spells given to mindless mobs will not be transferred in mindswap or cloning!"))

	return new_spell

/datum/give_sdql_spell/proc/reassign_vars(datum/action/cooldown/spell/target)
	if(!target)
		CRASH("edit_spell must be called with a non_null target")
	var/datum/component/sdql_spell_executor/executor = target.GetComponent(/datum/component/sdql_spell_executor)
	if(!executor)
		CRASH("[src]'s SDQL executor component went missing!")
	for(var/V in saved_vars+list_vars)
		if(V == "query")
			executor.vv_edit_var("query", saved_vars["query"])
		else if(V == "suppress_message_admins")
			executor.vv_edit_var("suppress_message_admins", saved_vars["suppress_message_admins"])
		else if(V == "scratchpad")
			var/list/new_scratchpad = generate_list_var("scratchpad")
			if(new_scratchpad)
				executor.vv_edit_var("scratchpad", new_scratchpad)
		else if(target.vars[V])
			if(islist(target.vars[V]))
				if(special_list_vars[V])
					var/list/overrides_to_save = list_vars[V]
					executor.saved_overrides[V] = overrides_to_save.Copy()
				var/list/list_var = generate_list_var(V)
				if(list_var)
					target.vv_edit_var(V, list_var)
			else if(isicon(target.vars[V]))
				target.vv_edit_var(V, icon(saved_vars[V]))
			else
				target.vv_edit_var(V, saved_vars[V])
