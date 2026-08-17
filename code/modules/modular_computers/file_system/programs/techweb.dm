/datum/computer_file/program/science
	filename = "experi_track"
	filedesc = "Nanotrasen Science Hub"
	downloader_category = PROGRAM_CATEGORY_SCIENCE
	program_open_overlay = "research"
	extended_desc = "Подключитесь к внутреннему научному серверу, чтобы помочь в исследованиях на станции."
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	size = 10
	tgui_id = "NtosTechweb"
	program_icon = "atom"
	run_access = list(ACCESS_COMMAND, ACCESS_RESEARCH)
	download_access = list(ACCESS_RESEARCH)
	/// Reference to global science techweb
	var/datum/techweb/stored_research
	/// Access needed to lock/unlock the console
	var/lock_access = ACCESS_RESEARCH
	/// Determines if the console is locked, and consequently if actions can be performed with it
	var/locked = FALSE
	/// Used for compressing data sent to the UI via static_data as payload size is of concern
	var/id_cache = list()
	/// Sequence var for the id cache
	var/id_cache_seq = 1

/datum/computer_file/program/science/on_install(datum/computer_file/source, obj/item/modular_computer/computer_installing, mob/user)
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !stored_research)
		CONNECT_TO_RND_SERVER_ROUNDSTART(stored_research, computer)

/datum/computer_file/program/science/application_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/multitool))
		return multitool_act(user, tool)

/datum/computer_file/program/science/proc/multitool_act(mob/living/user, obj/item/multitool/used_multitool)
	if(QDELETED(used_multitool.buffer) || !istype(used_multitool.buffer, /datum/techweb))
		return ITEM_INTERACT_BLOCKING
	stored_research = used_multitool.buffer
	computer.balloon_alert(user, "буфер связан!")
	return ITEM_INTERACT_SUCCESS

/datum/computer_file/program/science/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/sheetmaterials),
		get_asset_datum(/datum/asset/spritesheet_batched/research_designs),
	)

// heavy data from this proc should be moved to static data when possible
/datum/computer_file/program/science/ui_data(mob/user)
	var/list/data = list()
	data["stored_research"] = !!stored_research
	if(!stored_research) //lack of a research node is all we care about.
		return data
	data += list(
		"nodes" = list(),
		"queue_nodes" = stored_research.research_queue_nodes,
		"experiments" = list(),
		"researched_designs" = stored_research.researched_designs,
		"points" = stored_research.research_points,
		"points_last_tick" = stored_research.last_bitcoins,
		"web_org" = stored_research.organization,
		"sec_protocols" = !(computer.obj_flags & EMAGGED),
		"t_disk" = null, //Not doing disk operations on the app, use the console for that.
		"d_disk" = null, //See above.
		"locked" = locked,
	)

	// Serialize all nodes to display
	for(var/node_path, node_tier in stored_research.tiers)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_path]

		// Ensure node is supposed to be visible
		if (stored_research.hidden_nodes[node_path])
			continue

		var/mob/node_queuer = stored_research.research_queue_nodes[node_path]
		var/enqueued_by_user = !isnull(node_queuer) && node_queuer == user

		data["nodes"] += list(list(
			"path" = node_path,
			"is_free" = node.is_free(stored_research),
			"can_unlock" = stored_research.can_unlock_node(node),
			"have_experiments_done" = stored_research.have_experiments_for_node(node),
			"tier" = node_tier,
			"enqueued_by_user" = enqueued_by_user,
			"discount_boosted" = !!stored_research.boosted_nodes[node_path],
		))

	// Get experiments and serialize them
	var/list/exp_to_process = stored_research.available_experiments.Copy()
	for (var/experiment_type, experiment in stored_research.completed_experiments)
		exp_to_process += experiment
	for (var/datum/experiment/unf_experi as anything in exp_to_process)
		data["experiments"][unf_experi.type] = unf_experi.to_ui_data()
	return data

/datum/computer_file/program/science/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	// Check if the console is locked to block any actions occuring
	if (locked && action != "toggleLock")
		computer.say("Консоль заблокирована. Дальнейшие действия невозможны.")
		return TRUE

	switch (action)
		if ("toggleLock")
			if(computer.obj_flags & EMAGGED)
				to_chat(usr, span_boldwarning("Ошибка протокола безопасности: не удается получить доступ к протоколам блокировки."))
				return TRUE
			if(lock_access in computer?.stored_id?.access)
				locked = !locked
			else
				to_chat(usr, span_boldwarning("Несанкционированный доступ. Пожалуйста, вставьте ID-карту научного отдела."))
			return TRUE

		if ("researchNode")
			research_node(text2path(params["node_path"]), usr)
			return TRUE
		if ("enqueueNode")
			enqueue_node(text2path(params["node_path"]), usr)
			return TRUE
		if ("dequeueNode")
			dequeue_node(text2path(params["node_path"]), usr)
			return TRUE

/datum/computer_file/program/science/ui_static_data(mob/user)
	// Build node cache...
	// Note this looks a bit ugly but its to reduce the size of the JSON payload
	// by the greatest amount that we can, as larger JSON payloads result in
	// hanging when the user opens the UI
	var/list/node_cache = list()
	for (var/node_path, _node in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = _node

		var/list/node_data = list(
			"name" = node.display_name,
			"description" = node.description
		)

		if (LAZYLEN(node.research_costs))
			node_data["costs"] = list()
			for (var/point_type, point_amount in node.research_costs)
				node_data["costs"]["[compress_id(point_type)]"] = point_amount
		if (LAZYLEN(node.prerequisite_nodes))
			node_data["prerequisite_nodes"] = list()
			for (var/prerequisite_node in node.prerequisite_nodes)
				node_data["prerequisite_nodes"] += compress_id(prerequisite_node)
		if (LAZYLEN(node.unlocked_designs))
			node_data["unlocked_designs"] = list()
			for (var/unlocked_design in node.unlocked_designs)
				node_data["unlocked_designs"] += compress_id(unlocked_design)
		if (LAZYLEN(node.unlocked_nodes))
			node_data["unlocked_nodes"] = list()
			for (var/unlocked_node in node.unlocked_nodes)
				node_data["unlocked_nodes"] += compress_id(unlocked_node)
		if (LAZYLEN(node.required_experiments))
			node_data["required_experiments"] = node.required_experiments
		if (LAZYLEN(node.discount_experiments))
			node_data["discount_experiments"] = node.discount_experiments
		if (LAZYLEN(node.discount_boosts))
			node_data["discount_boosts"] = node.discount_boosts

		var/compressed_id = "[compress_id(node_path)]"
		node_cache[compressed_id] = node_data

	// Build design cache
	var/list/design_cache = list()
	var/datum/asset/spritesheet_batched/research_designs/spritesheet = get_asset_datum(/datum/asset/spritesheet_batched/research_designs)
	var/size32x32 = "[spritesheet.name]32x32"
	for (var/design_path, _design in SSresearch.techweb_designs)
		var/datum/design/design = _design

		var/list/cost = list()
		for(var/datum/material/mat, amount in design.materials)
			cost[mat.name] = OPTIMAL_COST(amount)

		var/size = spritesheet.icon_size_id(design.asset_id)
		var/compressed_id = "[compress_id(design_path)]"
		design_cache[compressed_id] = list(
			design.name,
			cost,
			design.build_type,
			design.departmental_flags,
			"[size == size32x32 ? "" : "[size] "][design.asset_id]"
		)

	var/list/department_flags = list()
	for (var/datum/job_department/department as anything in subtypesof(/datum/job_department))
		if (department::department_bitflags)
			department_flags["[department::department_bitflags]"] = department::department_name

	// Don't pass away flags as those are irrelevant to the station
	var/list/build_types = GLOB.build_types_to_string.Copy()
	build_types -= "[AWAY_IMPRINTER]"
	build_types -= "[AWAY_LATHE]"

	return list(
		"point_types_abbreviations" = SSresearch.point_types,
		"static_data" = list(
			"node_cache" = node_cache,
			"design_cache" = design_cache,
			"id_cache" = assoc_to_keys(id_cache),
			"SHEET_MATERIAL_AMOUNT" = SHEET_MATERIAL_AMOUNT,
			"build_types" = build_types,
			"department_flags" = department_flags,
		),
	)

/**
 * Compresses an ID to an integer representation using the id_cache, used for deduplication
 * in sent JSON payloads
 *
 * Arguments:
 * * id - the ID to compress
 */
/datum/computer_file/program/science/proc/compress_id(id)
	if (!id_cache[id])
		id_cache[id] = id_cache_seq
		id_cache_seq += 1
	return id_cache[id]

/datum/computer_file/program/science/proc/enqueue_node(node_path, mob/user)
	if(!stored_research || !stored_research.available_nodes[node_path] || stored_research.researched_nodes[node_path])
		computer.say("Не удалось поставить узел в очередь: технология не найдена, либо узел уже исследован или он недоступен!")
		return FALSE
	stored_research.enqueue_node(node_path, user)
	return TRUE

/datum/computer_file/program/science/proc/dequeue_node(node_path, mob/user)
	if(!stored_research || !stored_research.available_nodes[node_path] || stored_research.researched_nodes[node_path])
		computer.say("Не удалось убрать узел из очереди: технология не найдена, либо узел уже исследован или он недоступен!")
		return FALSE
	stored_research.dequeue_node(node_path, user)
	return TRUE

/datum/computer_file/program/science/proc/research_node(node_path, mob/user)
	if(!stored_research)
		computer.say("Не удалось разблокировать узел: технология не найдена!")
		return FALSE
	if(!stored_research.available_nodes[node_path])
		computer.say("Не удалось разблокировать узел: технология недоступна!")
		return FALSE
	if(stored_research.researched_nodes[node_path])
		computer.say("Не удалось разблокировать узел: технология уже изучена!")
		return FALSE

	var/datum/techweb_node/unlocked_node = SSresearch.techweb_nodes[node_path]
	if(!istype(unlocked_node))
		computer.say("Не удалось разблокировать узел: неизвестная ошибка.")
		return FALSE

	var/list/price = unlocked_node.get_price(stored_research)
	if(!stored_research.can_afford(price))
		computer.say("Недостаточно очков для исследования...")
		return FALSE

	if(!stored_research.research_node(unlocked_node, research_source = computer))
		computer.say("Не удалось исследовать узел: внутренняя ошибка базы данных!")
		return FALSE

	user.investigate_log("researched [unlocked_node.display_name]([json_encode(price)]) on techweb id [stored_research.id].", INVESTIGATE_RESEARCH)
	if(istype(stored_research, /datum/techweb/science))
		SSblackbox.record_feedback("associative", "science_techweb_unlock", 1, list("path" = "[node_path]", "name" = unlocked_node.display_name, "price" = "[json_encode(price)]", "time" = ISOtime()))

	computer.say("Успешно изучено [unlocked_node.display_name].")

	var/logname = "Unknown"
	if(HAS_AI_ACCESS(user))
		logname = "AI [user.name]"
	if(iscyborg(user))
		logname = "CYBORG [user.name]"

	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/obj/item/card/id/id = human_user.wear_id?.GetID()
		if(istype(id))
			logname = "[id.registered_name]"
	else if(iscarbon(user))
		var/obj/item/card/id/idcard = user.get_active_held_item()
		if(istype(idcard))
			logname = "[idcard.registered_name]"

	stored_research.research_logs += list(list(
		"node_name" = unlocked_node.display_name,
		"node_cost" = price[TECHWEB_POINT_TYPE_GENERIC],
		"node_researcher" = logname,
		"node_research_location" = "[get_area(computer)] ([user.x],[user.y],[user.z])",
	))
	return TRUE
