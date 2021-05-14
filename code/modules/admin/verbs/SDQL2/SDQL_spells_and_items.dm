/obj/effect/proc_holder/spell/aimed/sdql
	name = "Aimed SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."
	var/query = "CALL visible_message(\"<span class='warning'>The spell fizzles!</span>\") ON * IN TARGETS"
	var/list/scratchpad = list() //Use this to store vars in between queries and casts.
	projectile_type = /obj/projectile/sdql

/obj/effect/proc_holder/spell/aimed/sdql/ready_projectile(obj/projectile/P, atom/target, mob/user, iteration)
	var/obj/projectile/sdql/S = P
	S.linked_spell = src
	S.query = query

/obj/projectile/sdql
	name = "\improper SDQL projectile"
	damage_type = STAMINA
	nodamage = TRUE
	damage = 0
	var/query
	var/obj/effect/proc_holder/spell/linked_spell

/obj/projectile/sdql/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	var/mob/firer_mob = firer
	process_spell_query(query, list(target), firer_mob, linked_spell)

/obj/effect/proc_holder/spell/aoe_turf/sdql
	name = "AoE SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."
	var/query = "CALL visible_message(\"<span class='warning'>The spell fizzles!</span>\") ON * IN TARGETS"
	var/list/scratchpad = list() //Use this to store vars in between queries and casts.

/obj/effect/proc_holder/spell/aoe_turf/sdql/cast(list/targets, mob/user)
	process_spell_query(query, targets, user, src)

/obj/effect/proc_holder/spell/cone/sdql
	name = "Cone SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."
	var/query = "CALL visible_message(\"<span class='warning'>The spell fizzles!</span>\") ON * IN TARGETS"
	var/list/targets = list()
	var/list/scratchpad = list() //Use this to store vars in between queries and casts.

/obj/effect/proc_holder/spell/cone/sdql/do_mob_cone_effect(mob/living/target_mob, level)
	targets |= target_mob

/obj/effect/proc_holder/spell/cone/sdql/do_obj_cone_effect(obj/target_obj, level)
	targets |= target_obj

/obj/effect/proc_holder/spell/cone/sdql/do_turf_cone_effect(turf/target_turf, level)
	targets |= target_turf

/obj/effect/proc_holder/spell/cone/sdql/cast(list/targets, mob/user)
	. = ..()
	process_spell_query(query, targets, user, src)
	targets = list()

/obj/effect/proc_holder/spell/cone/staggered/sdql
	name = "Staggered Cone SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."
	var/query = "CALL visible_message(\"<span class='warning'>The spell fizzles!</span>\") ON * IN TARGETS"
	var/list/targets = list()
	var/list/scratchpad = list() //Use this to store vars in between queries and casts.

/obj/effect/proc_holder/spell/cone/staggered/sdql/do_mob_cone_effect(mob/living/target_mob, level)
	targets |= target_mob

/obj/effect/proc_holder/spell/cone/staggered/sdql/do_obj_cone_effect(obj/target_obj, level)
	targets |= target_obj

/obj/effect/proc_holder/spell/cone/staggered/sdql/do_turf_cone_effect(turf/target_turf, level)
	targets |= target_turf

/obj/effect/proc_holder/spell/cone/staggered/sdql/do_cone_effects(list/target_turf_list, level)
	. = ..()
	process_spell_query(query, targets, usr, src)
	targets = list()

/obj/effect/proc_holder/spell/pointed/sdql
	name = "Pointed SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."
	var/query = "CALL visible_message(\"<span class='warning'>The spell fizzles!</span>\") ON * IN TARGETS"
	var/list/scratchpad = list() //Use this to store vars in between queries and casts.

/obj/effect/proc_holder/spell/pointed/sdql/cast(list/targets, mob/user)
	process_spell_query(query, targets, user, src)

/obj/effect/proc_holder/spell/self/sdql
	name = "Self SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."
	var/query = "CALL visible_message(\"<span class='warning'>The spell fizzles!</span>\") ON * IN TARGETS"
	var/list/scratchpad = list() //Use this to store vars in between queries and casts.

/obj/effect/proc_holder/spell/self/sdql/cast(list/targets, mob/user)
	process_spell_query(query, list(user), user, src)

/obj/effect/proc_holder/spell/targeted/sdql
	name = "Targeted SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."
	var/query = "CALL visible_message(\"<span class='warning'>The spell fizzles!</span>\") ON * IN TARGETS"
	var/list/scratchpad = list() //Use this to store vars in between queries and casts.

/obj/effect/proc_holder/spell/targeted/sdql/cast(list/targets, mob/user)
	process_spell_query(query, targets, user, src)

/obj/effect/proc_holder/spell/targeted/touch/sdql
	name = "Touch SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."
	hand_path = /obj/item/melee/touch_attack/sdql
	var/query = "CALL visible_message(\"<span class='warning'>The spell fizzles!</span>\") ON * IN TARGETS"
	var/list/scratchpad = list() //Use this to store vars in between queries and casts.
	var/list/hand_var_overrides = list() //The touch attack has its vars changed to the ones put in this list.

/obj/effect/proc_holder/spell/targeted/touch/sdql/ChargeHand(mob/living/carbon/user)
	if(..())
		for(var/V in hand_var_overrides)
			if(V in attached_hand.vars)
				attached_hand.vv_edit_var(V, hand_var_overrides[V])
		user.update_inv_hands()


/obj/item/melee/touch_attack/sdql
	name = "\improper SDQL touch attack"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."
	catchphrase = "ADMINS WERE LAZY!!"

/obj/item/melee/touch_attack/sdql/afterattack(atom/target, mob/user, proximity)
	var/obj/effect/proc_holder/spell/targeted/touch/sdql/spell = attached_spell
	process_spell_query(spell.query, list(target), user, spell)
	. = ..()

//Returns the address of x without the square brackets around it.
#define RAW_ADDRESS(x) copytext("\ref[x]",2,-1)

/proc/process_spell_query(query_text, list/targets, mob/user, source)
	if(!CONFIG_GET(flag/sdql_spells))
		return
	if(!length(query_text))
		return
	var/message_query = query_text
	var/list/targets_and_user_list = targets+user
	var/targets_and_user_string = ref_list(targets_and_user_list)
	var/targets_string = ref_list(targets)
	query_text = replacetextEx_char(query_text, "TARGETS_AND_USER", "[targets_and_user_string]")
	message_query = replacetext_char(message_query, "TARGETS_AND_USER", (targets_and_user_list.len > 3) ? "\[<i>[targets_and_user_list.len] items</i>]" : targets_and_user_string)
	query_text = replacetextEx_char(query_text, "USER", "{[RAW_ADDRESS(user)]}")
	message_query = replacetextEx_char(message_query, "USER", "{[RAW_ADDRESS(user)]}")
	query_text = replacetextEx_char(query_text, "TARGETS", "[targets_string]")
	message_query = replacetextEx_char(message_query, "TARGETS", (targets.len > 3) ? "\[<i>[targets.len] items</i>]" : targets_string)
	query_text = replacetextEx_char(query_text, "SOURCE", "{[RAW_ADDRESS(source)]}")
	message_query = replacetextEx_char(message_query, "SOURCE", "{[RAW_ADDRESS(source)]}")
	var/query_message = "[key_name(user)] executed SDQL query(s): \"[message_query]\" using a player query caller."
	message_admins(query_message)
	log_game(query_message)
	var/list/query_list = SDQL2_tokenize(query_text)
	if(!query_list.len)
		return
	var/list/querys = SDQL_parse(query_list)
	if(!querys.len)
		return

	var/list/datum/sdql2_query/running = list()
	var/list/datum/sdql2_query/waiting_queue = list() //Sequential queries queue.

	for(var/list/query_tree in querys)
		var/datum/sdql2_query/query = new /datum/sdql2_query(query_tree, SU = TRUE, admin_interact = FALSE)
		if(QDELETED(query))
			continue
		waiting_queue += query

	var/datum/sdql2_query/query = popleft(waiting_queue)
	running += query
	query.ARun()

	var/finished = FALSE
	do
		CHECK_TICK
		finished = TRUE
		for(var/i in running)
			query = i
			if(QDELETED(query))
				running -= query
				continue
			else if(query.state != SDQL2_STATE_IDLE)
				finished = FALSE
				if(query.state == SDQL2_STATE_ERROR)
					running -= query
			else
				if(query.finished)
					qdel(query)
					if(waiting_queue.len)
						finished = FALSE
						var/datum/sdql2_query/next_query = popleft(waiting_queue)
						running += next_query
						next_query.ARun()
				else
					running -= query
	while(!finished)

/proc/ref_list(list/L)
	if(!L.len)
		return "\[]"
	var/ret = "\["
	for(var/i in 1 to L.len-1)
		ret += "{[RAW_ADDRESS(L[i])]},"
	ret += "{[RAW_ADDRESS(L[L.len])]}]"
	return ret

#undef RAW_ADDRESS

/client/proc/cmd_give_sdql_spell(mob/target in GLOB.mob_list)
	set name = "Give SDQL spell"
	set hidden = TRUE
	if(CONFIG_GET(flag/sdql_spells))
		var/datum/give_sdql_spell/ui = new(usr, target)
		ui.ui_interact(usr)
	else
		to_chat(usr, "<span class='warning'>SDQL spells are disabled.</span>")


/datum/give_sdql_spell
	var/client/user
	var/mob/living/target_mob
	var/spell_type
	var/list/saved_vars = list()
	var/list/list_vars = list("scratchpad" = list())
	var/alert

	//This list contains all the vars that it should be okay to edit from the menu
	var/static/list/editable_spell_vars = list(
		"action_background_icon_state",
		"action_icon_state",
		"action_icon",
		"active_msg",
		"aim_assist",
		"antimagic_allowed",
		"base_icon_state",
		"centcom_cancast",
		"charge_max",
		"charge_type",
		"clothes_req",
		"cone_level",
		"cult_req",
		"deactive_msg",
		"desc",
		"drawmessage",
		"dropmessage",
		"hand_var_overrides",
		"holder_var_amount",
		"holder_var_type",
		"human_req",
		"include_user",
		"inner_radius",
		"invocation_emote_self",
		"invocation_type",
		"invocation",
		"max_targets",
		"message",
		"name",
		"nonabstract_req",
		"overlay_icon_state",
		"overlay_icon",
		"overlay_lifespan",
		"overlay",
		"phase_allowed",
		"player_lock",
		"projectile_amount",
		"projectile_var_overrides",
		"projectiles_per_fire",
		"query",
		"random_target_priority",
		"random_target",
		"range",
		"ranged_mousepointer",
		"respect_density",
		"selection_type",
		"self_castable",
		"smoke_amt",
		"smoke_spread",
		"sound",
		"sparks_amt",
		"sparks_spread",
		"stat_allowed",
		"still_recharging_message",
		"target_ignore_prev",
	)

	//If a spell creates a datum with vars it overrides, this list should contain an association with the supertype of the created datum
	var/static/list/special_list_vars = list(
		"projectile_var_overrides" = list(
			"supertype" = /obj/projectile,
			"type" = /obj/projectile/sdql,
		),
		"hand_var_overrides" = list(
			"supertype" = /obj/item/melee/touch_attack,
			"type" = /obj/item/melee/touch_attack/sdql,
		),
	)

	var/static/list/static_data

	//base64 representations of any icons that may need to be displayed
	var/action_icon_base64
	var/projectile_icon_base64
	var/hand_icon_base64
	var/overlay_icon_base64
	var/mouse_icon_base64

/datum/give_sdql_spell/New(_user, target)
	if(!CONFIG_GET(flag/sdql_spells))
		to_chat(_user, "<span class='warning'>SDQL spells are disabled.</span>")
		qdel(src)
		return
	user = CLIENT_FROM_VAR(_user)

	if(!isliving(target))
		alert("Invalid mob")
		return
	target_mob = target

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

/datum/give_sdql_spell/ui_data(mob/user, params)
	var/list/data = list()
	data["type"] = spell_type
	data["saved_vars"] = saved_vars
	data["list_vars"] = list_vars
	data["action_icon"] = action_icon_base64
	data["projectile_icon"] = projectile_icon_base64
	data["hand_icon"] = hand_icon_base64
	data["overlay_icon"] = overlay_icon_base64
	data["mouse_icon"] = mouse_icon_base64
	data["alert"] = alert
	alert = ""
	return data

/datum/give_sdql_spell/ui_static_data(mob/user)
	if(!static_data)
		static_data = list(
			"types" = list("aimed", "aoe_turf", "cone", "cone/staggered", "pointed", "self", "targeted", "targeted/touch"),
			"tooltips" = list(
				"query" = "The SDQL query that is executed. Certain keywords are specific to SDQL spell queries.\n\
					$type\n\
					USER is replaced with a reference to the user of the spell.\n\
					TARGETS_AND_USER is replaced with the combined references from TARGETS and USER.\n\
					SOURCE is replaced with a reference to this spell, allowing you to refer to and edit variables within it.\n\
					You can use the list variable \"scratchpad\" to store variables between individual queries within the same cast or between multiple casts.",
				"query_aimed" = "TARGETS is replaced with a list containing a reference to the atom hit by the fired projectile.",
				"query_aoe_turf" = "TARGETS is replaced with a list containing references to every atom in the spell's area of effect.",
				"query_cone" = "TARGETS is replaced with a list containing references to every atom in the cone produced by the spell.",
				"query_cone/staggered" = "The query will be executed once for every level of the cone produced by the spell.\n\
					TARGETS is replaced with a list containing references to every atom in the given level of the cone.",
				"query_pointed" = "TARGETS is replaced with a list containing a reference to the targeted atom.",
				"query_self" = "TARGETS is replaced with a list containing a reference to the caster.",
				"query_targeted" = "TARGETS is replaced with a list containing a reference(s) to the targeted mob(s).",
				"query_targeted_touch" = "TARGETS is replaced with a list containing a reference to the atom hit with the touch attack.",
				"charge_type" = "How the spell's charge works. This affects how charge_max is used.\n\
					When set to \"recharge\", charge_max is the time in deciseconds between casts of the spell.\n\
					When set to \"charges\", the user can only use the spell a number of times equal to charge_max.\n\
					When set to \"holder_var\", charge_max is not used. holder_var_type and holder_var_amount are used instead.\n",
				"holder_var_type" = "When charge_type is set to \"holder_var\", this is the name of the var that is modified each time the spell is cast.\n\
					If this is set to \"bruteloss\", \"fireloss\", \"toxloss\", or \"oxyloss\", the user will take the corresponding damage.\n\
					If this is set to \"stun\", \"knockdown\", \"paralyze\", \"immobilize\", or \"unconscious\", the user will suffer the corresponding status effect.\n\
					If this is set to anything else, the variable with the appropriate name will be modified.",
				"holder_var_amount" = "The amount of damage taken, the duration of status effect inflicted, or the change made to any other variable.",
				"clothes_req" = "Whether the user has to be wearing wizard robes to cast the spell.",
				"cult_req" = "Whether the user has to be wearing cult robes to cast the spell.",
				"human_req" = "Whether the user has to be a human to cast the spell. Redundant when clothes_req is true.",
				"nonabstract_req" = "If this is true, the spell cannot be cast by brains and pAIs.",
				"stat_allowed" = "Whether the spell can be cast if the user is unconscious or dead.",
				"phase_allowed" = "Whether the spell can be cast while the user is jaunting or bloodcrawling.",
				"antimagic_allowed" = "Whether the spell can be cast while the user is affected by anti-magic effects.",
				"invocation_type" = "How the spell is invoked.\n\
					When set to \"whisper\", the user whispers the invocation, as if with the whisper verb.\n\
					When set to \"shout\", the user says the invocation, as if with the say verb.\n\
					When set to \"emote\", a visible message is produced.",
				"invocation" = "What the user says, whispers, or emotes when using the spell.",
				"invocation_emote_self" = "What the user sees in their own chat when they use the spell.",
				"selection_type" = "Whether the spell can target any mob in range, or only visible mobs in range.",
				"range" = "The spell's range, in tiles.",
				"message" = "What mobs affected by the spell see in their chat.\n\
					Keep in mind, just because a mob is affected by the spell doesn't mean the query will have any effect on them.",
				"player_lock" = "If false, simple mobs can use the spell.",
				"overlay" = "Whether an overlay is drawn atop atoms affectecd by the spell.\n\
					Keep in mind, just because an atom is affected by the spell doesn't mean the query will have any effect on it.",
				"overlay_lifetime" = "The amount of time in deciseconds the overlay will persist.",
				"sparks_spread" = "Whether the spell produces sparks when cast.",
				"smoke_spread" = "The kind of smoke, if any, the spell produces when cast.",
				"centcom_cancast" = "If true, the spell can be cast on the centcom Z-level.",
				"max_targets" = "The maximum number of mobs the spell can target.",
				"target_ignore_prev" = "If false, the same mob can be targeted multiple times.",
				"include_user" = "If true, the user can target themselves with the spell.",
				"random_target" = "If true, the spell will target a random mob(s) in range.",
				"random_target_priority" = "Whether the spell will target random mobs in range or the closest mobs in range.",
				"inner_radius" = "If this is a non-negative number, the spell will not affect atoms within that many tiles of the user.",
				"ranged_mousepointer" = "The icon used for the mouse when aiming the spell.",
				"deactive_mesg" = "The message the user sees when canceling the spell.",
				"active_msg" = "The message the user sees when activating the spell.",
				"projectile_amount" = "The maximum number of projectiles the user can fire with each cast of the spell.",
				"projectiles_per_fire" = "The amount of projectiles fired with each click of the mouse.",
				"projectile_var_overrides" = "The fired projectiles will have the appropriate variables overridden by the corresponding values in this associative list.\n\
					You should probably set \"name\", \"icon\", and \"icon_state\".\n\
					Refer to code/modules/projectiles/projectile.dm to see what other vars you can override.",
				"cone_level" = "How many tiles out the cone will extend.",
				"respect_density" = "If true, the cone produced by the spell is blocked by walls.",
				"self_castable" = "If true, the user can cast the spell on themselves.",
				"aim_assist" = "If true, the spell has turf-based aim assist.",
				"drawmessage" = "The message the user sees when activating the spell.",
				"dropmessage" = "The message the user sees when canceling the spell.",
				"hand_var_overrides" = "The touch attack will have the appropriate variables overridden by the corresponding values in this associative list.\n\
					You should probably set \"name\", \"desc\", \"catchphrase\", \"on_use_sound\" \"icon\", \"icon_state\", and \"inhand_icon_state\".\n\
					Refer to code/modules/spells/spell_types/godhand.dm for see what other vars you can override.",
				"scratchpad" = "This list can be used to store variables between individual queries within the same cast or between casts.\n\
					You can declare variables from this menu for convenience. To access this list in a query, use the identifier \"SOURCE.scratchpad\".\n\
					Refer to the _list procs defined in code/modules/admin/verbs/SDQL2/SDQL_2_wrappers.dm for information on how to modify and edit list vars from within a query.",
			),
		)
	return static_data

#define LIST_VAR_FLAGS_TYPED 1
#define LIST_VAR_FLAGS_NAMED 2

/datum/give_sdql_spell/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	. = TRUE
	switch(action)
		if("type")
			spell_type = params["path"]
			var/path = text2path("/obj/effect/proc_holder/spell/[spell_type]/sdql")
			var/datum/sample = new path
			if(spell_type)
				for(var/V in sample.vars)
					if(V in editable_spell_vars)
						if(islist(sample.vars[V]))
							list_vars += list("[V]" = list())
							if(V in special_list_vars)
								var/subpath = special_list_vars[V]["type"]
								var/datum/subsample = new subpath
								if("icon" in sample.vars)
									icon_needs_updating("[V]/icon")
								qdel(subsample)
						else
							saved_vars[V] = sample.vars[V]
							icon_needs_updating(V)
			qdel(sample)
		if("variable")
			var/V = params["name"]
			if(V == "holder_var_type")
				if(!holder_var_validate(params["value"]))
					return
			saved_vars[V] = params["value"]
			icon_needs_updating(V)
		if("bool_variable")
			saved_vars[params["name"]] = !saved_vars[params["name"]]
		if("list_variable_add")
			if(params["list"] in list_vars)
				if(params["list"] in special_list_vars)
					var/superpath = special_list_vars[params["list"]]["supertype"]
					var/path = special_list_vars[params["list"]]["type"]
					var/datum/supersample = new superpath
					var/datum/sample = new path
					var/list/choosable_vars = map_var_list((sample.vars&supersample.vars)-list_vars[params["list"]], sample)
					var/chosen_var = input(user, "Select variable to add.", "Add SDQL Spell", null) as null|anything in sortList(choosable_vars)
					if(chosen_var)
						if(islist(sample.vars[choosable_vars[chosen_var]]))
							list_vars[params["list"]] += list("[choosable_vars[chosen_var]]" = list("type" = "list", "value" = null, "flags" = LIST_VAR_FLAGS_TYPED|LIST_VAR_FLAGS_NAMED))
							list_vars |= list("[params["list"]]/[choosable_vars[chosen_var]]" = list())
						else if(isnum(sample.vars[choosable_vars[chosen_var]]))
							list_vars[params["list"]][choosable_vars[chosen_var]] = list("type" = "num", "value" = sample.vars[choosable_vars[chosen_var]], "flags" = LIST_VAR_FLAGS_TYPED|LIST_VAR_FLAGS_NAMED)
						else if(ispath(sample.vars[choosable_vars[chosen_var]]))
							list_vars[params["list"]][choosable_vars[chosen_var]] = list("type" = "path", "value" = sample.vars[choosable_vars[chosen_var]], "flags" = LIST_VAR_FLAGS_TYPED|LIST_VAR_FLAGS_NAMED)
						else if(isicon(sample.vars[choosable_vars[chosen_var]]))
							list_vars[params["list"]][choosable_vars[chosen_var]] = list("type" = "icon", "value" = sample.vars[choosable_vars[chosen_var]], "flags" = LIST_VAR_FLAGS_TYPED|LIST_VAR_FLAGS_NAMED)
						else if(istext(sample.vars[choosable_vars[chosen_var]]) || isfile(sample.vars[choosable_vars[chosen_var]]))
							list_vars[params["list"]][choosable_vars[chosen_var]] = list("type" = "string", "value" = sample.vars[choosable_vars[chosen_var]], "flags" = LIST_VAR_FLAGS_TYPED|LIST_VAR_FLAGS_NAMED)
						else if(isnull(sample.vars[choosable_vars[chosen_var]]))
							list_vars[params["list"]][choosable_vars[chosen_var]] = list("type" = "num", "value" = 0, "flags" = LIST_VAR_FLAGS_NAMED)
							alert = "Could not determine the type for [params["list"]]/[choosable_vars[chosen_var]]! Be sure to set it correctly, or you may cause unnecessary runtimes!"
						else
							alert = "[params["list"]]/[choosable_vars[chosen_var]] is not of a supported type!"
						icon_needs_updating("[params["list"]]/[choosable_vars[chosen_var]]")
					qdel(sample)
					qdel(supersample)
				else
					if(!("new_var" in list_vars[params["list"]]))
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
		if("save")
			var/f = file("data/TempSpellUpload")
			fdel(f)
			WRITE_FILE(f, json_encode(list("type" = spell_type, "vars" = saved_vars, "list_vars" = list_vars)))
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
			if(load_from_json(json))
				icon_needs_updating("everything")
			else
				alert = "Malformed/Outdated file!"
				return
		if("confirm")
			give_spell()
			ui.close()

/datum/give_sdql_spell/proc/load_from_json(json)
	if(!(("type" in json) && ("vars" in json) && ("list_vars" in json)))
		return FALSE
	var/temp_type = json["type"]
	var/datum/D = text2path("/obj/effect/proc_holder/spell/[temp_type]/sdql")
	if(!ispath(D))
		return FALSE
	if(!islist(json["vars"]))
		return FALSE
	if(!islist(json["list_vars"]))
		return FALSE
	var/list/temp_vars = json["vars"]
	var/list/temp_list_vars = json["list_vars"]
	D = new D
	. = TRUE
	for(var/V in temp_vars)
		if(!istext(V))
			. = FALSE
			break
		if(!(V in editable_spell_vars))
			. = FALSE
			break
		if(!(V in D.vars))
			. = FALSE
			break
		if(islist(D.vars[V]))
			. = FALSE
			break
		if(istext(D.vars[V]) || isicon(D.vars[V]) || ispath(D.vars[V]))
			if(!istext(temp_vars[V]))
				. = FALSE
				break
		if(isnum(D.vars[V]))
			if(!isnum(temp_vars[V]))
				. = FALSE
				break
	if(.)
		for(var/V in temp_list_vars)
			if(!islist(temp_list_vars[V]))
				. = FALSE
				break
			if((V in special_list_vars) && (V in D.vars))
				var/datum/sample = special_list_vars[V]["type"]
				sample = new sample
				for(var/W in temp_list_vars[V])
					if(!istext(W))
						. = FALSE
						break
					if(!islist(temp_list_vars[V][W]))
						. = FALSE
						break
					if(!(("type" in temp_list_vars[V][W]) && ("value" in temp_list_vars[V][W]) && ("flags" in temp_list_vars[V][W])))
						. = FALSE
						break
					if(!isnum(temp_list_vars[V][W]["flags"]) || (temp_list_vars[V][W]["flags"] & LIST_VAR_FLAGS_TYPED|LIST_VAR_FLAGS_NAMED) == LIST_VAR_FLAGS_TYPED)
						. = FALSE
						break
					if(!istext(temp_list_vars[V][W]["type"]))
						. = FALSE
						break
					if(!(temp_list_vars[V][W]["flags"] & LIST_VAR_FLAGS_TYPED))
						if(!isnull(sample.vars[W]))
							. = FALSE
							break
					else
						switch(temp_list_vars[V][W]["type"])
							if("list")
								if(!islist(sample.vars[W]))
									. = FALSE
									break
								if(!("[V]/[W]" in temp_list_vars))
									. = FALSE
									break
							if("num")
								if(isnum(temp_list_vars[V][W]["value"]))
									if(!(isnum(sample.vars[W])))
										. = FALSE
										break
								else
									. = FALSE
									break
							if("string")
								if(istext(temp_list_vars[V][W]["value"]))
									if(!(istext(sample.vars[W]) || isfile(sample.vars[W])))
										. = FALSE
										break
								else
									. = FALSE
									break
							if("path")
								if(istext(temp_list_vars[V][W]["value"]))
									if(!(ispath(sample.vars[W])))
										. = FALSE
										break
								else
									. = FALSE
									break
							if("icon")
								if(istext(temp_list_vars[V][W]["value"]))
									if(!(isicon(sample.vars[W])))
										. = FALSE
										break
								else
									. = FALSE
									break
				qdel(sample)
				if(!.)
					break
	qdel(D)
	if(.)
		spell_type = temp_type
		saved_vars = temp_vars
		list_vars = temp_list_vars

#undef LIST_VAR_FLAGS_TYPED
#undef LIST_VAR_FLAGS_NAMED

/datum/give_sdql_spell/proc/map_var_list(list/L, datum/D)
	var/list/ret = list()
	for(var/V in L)
		if(V in D.vars)
			ret["[V] = [string_rep(D.vars[V])]"] = V
	return ret

/datum/give_sdql_spell/proc/string_rep(V)
	if(istext(V) || isfile(V) || isicon(V))
		return "\"[V]\""
	else if(isnull(V))
		return "null"
	else
		return "[V]"

/datum/give_sdql_spell/proc/holder_var_validate(V)
	switch(V)
		if("bruteloss", "fireloss", "toxloss", "oxyloss", "stun", "knockdown", "paralyze", "unconscious")
			return TRUE
		else
			if(V in target_mob.vars)
				if(!isnum(target_mob.vars[V]))
					alert = "[target_mob.type]/[V] is not a number!"
					return FALSE
				else
					return TRUE
			else
				alert = "[target_mob.type] has no such variable [V]!"
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

		if("projectile_var_overrides/icon", "projectile_var_overrides/icon_state")
			var/atom/A = /obj/projectile/sdql
			var/icon = initial(A.icon)
			var/icon_state = initial(A.icon_state)
			if(list_vars["projectile_var_overrides"]["icon"])
				icon = list_vars["projectile_var_overrides"]["icon"]["value"]
			if(list_vars["projectile_var_overrides"]["icon_state"])
				icon_state = list_vars["projectile_var_overrides"]["icon_state"]["value"]
			var/icon/out_icon = icon(icon, icon_state, frame = 1)
			projectile_icon_base64 = icon2base64(out_icon)

		if("hand_var_overrides/icon", "hand_var_overrides/icon_state")
			var/atom/A = /obj/item/melee/touch_attack/sdql
			var/icon = initial(A.icon)
			var/icon_state = initial(A.icon_state)
			if(list_vars["hand_var_overrides"]["icon"])
				icon = list_vars["hand_var_overrides"]["icon"]["value"]
			if(list_vars["hand_var_overrides"]["icon_state"])
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
			if(list_vars["projectile_var_overrides"])
				var/atom/A = /obj/projectile/sdql
				var/icon = initial(A.icon)
				var/icon_state = initial(A.icon_state)
				if(list_vars["projectile_var_overrides"]["icon"])
					icon = list_vars["projectile_var_overrides"]["icon"]["value"]
				if(list_vars["projectile_var_overrides"]["icon_state"])
					icon_state = list_vars["projectile_var_overrides"]["icon_state"]["value"]
				out_icon = icon(icon, icon_state, frame = 1)
				projectile_icon_base64 = icon2base64(out_icon)
			if(list_vars["hand_var_overrides"])
				var/atom/A = /obj/item/melee/touch_attack/sdql
				var/icon = initial(A.icon)
				var/icon_state = initial(A.icon_state)
				if(list_vars["hand_var_overrides"]["icon"])
					icon = list_vars["hand_var_overrides"]["icon"]["value"]
				if(list_vars["hand_var_overrides"]["icon_state"])
					icon_state = list_vars["hand_var_overrides"]["icon_state"]["value"]
				out_icon = icon(icon, icon_state, frame = 1)
				hand_icon_base64 = icon2base64(out_icon)
			out_icon = icon(saved_vars["overlay_icon"], saved_vars["overlay_icon_state"], frame = 1)
			overlay_icon_base64 = icon2base64(out_icon)
			out_icon = icon(saved_vars["ranged_mousepointer"], frame = 1)
			mouse_icon_base64 = icon2base64(out_icon)

/datum/give_sdql_spell/proc/toggle_list_var(list_name, list_var)
	if(list_name in list_vars)
		if(list_var in list_vars[list_name])
			list_vars[list_name][list_var]["value"] = !list_vars[list_name][list_var]["value"]

/datum/give_sdql_spell/proc/set_list_var(list_name, list_var, value)
	if(list_name in list_vars)
		if(list_var in list_vars[list_name])
			list_vars[list_name][list_var]["value"] = value

/datum/give_sdql_spell/proc/rename_list_var(list_name, list_var, new_name)
	if(list_var == new_name)
		return
	if(list_name in list_vars)
		var/list/L = list_vars[list_name]
		var/ind = L.Find(list_var)
		if(ind)
			if(new_name in list_vars[list_name])
				alert = "There is already a variable named [new_name] in [list_name]!"
			else
				list_vars[list_name][ind] = new_name

/datum/give_sdql_spell/proc/change_list_var_type(list_name, list_var, var_type)
	if(list_name in list_vars)
		if(list_var in list_vars[list_name])
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
	if(list_name in list_vars)
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
	if(!(list_name in list_vars))
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
	var/path = text2path("/obj/effect/proc_holder/spell/[spell_type]/sdql")
	var/obj/effect/proc_holder/spell/new_spell = new path
	for(var/V in saved_vars+list_vars)
		if(V in new_spell.vars)
			if(islist(new_spell.vars[V]))
				var/list/list_var = generate_list_var(V)
				if(list_var)
					new_spell.vv_edit_var(V, list_var)
			else if(isicon(new_spell.vars[V]))
				new_spell.vv_edit_var(V, icon(saved_vars[V]))
			else
				new_spell.vv_edit_var(V, saved_vars[V])

	//delete and recreate the action so the overriden vars are respected by the action button
	qdel(new_spell.action)
	new_spell.action = new new_spell.base_action(new_spell)
	if(target_mob.mind)
		target_mob.mind.AddSpell(new_spell)
	else
		target_mob.AddSpell(new_spell)
		to_chat(user, "<span class='danger'>Spells given to mindless mobs will not be transferred in mindswap or cloning!</span>")
