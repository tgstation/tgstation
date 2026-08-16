#define RND_TECH_DISK	"tech"
#define RND_DESIGN_DISK	"design"

/*
Research and Development (R&D) Console

This is the main work horse of the R&D system. It contains the menus/controls for the Destructive Analyzer, Protolathe, and Circuit
imprinter.

Basic use: When it first is created, it will attempt to link up to related devices within 3 squares. It'll only link up if they
aren't already linked to another console. Any consoles it cannot link up with (either because all of a certain type are already
linked or there aren't any in range), you'll just not have access to that menu. In the settings menu, there are menu options that
allow a player to attempt to re-sync with nearby consoles. You can also force it to disconnect from a specific console.

The only thing that requires ordnance access is locking and unlocking the console on the settings menu.
Nothing else in the console has ID requirements.

*/
/obj/machinery/computer/rdconsole
	name = "R&D Console"
	desc = "A console used to interface with R&D tools."
	icon_state = MAP_SWITCH("computer", "/obj/machinery/computer/rdconsole")
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/rdconsole
	req_access = list(ACCESS_RESEARCH) // Locking and unlocking the console requires research access
	/// Reference to global science techweb
	var/datum/techweb/stored_research
	/// The stored technology disk, if present
	var/obj/item/disk/tech_disk/t_disk
	/// The stored design disk, if present
	var/obj/item/disk/design_disk/d_disk
	/// Determines if the console is locked, and consequently if actions can be performed with it
	var/locked = TRUE // BANDASTATION EDIT = var/locked = FALSE
	/// Used for compressing data sent to the UI via static_data as payload size is of concern
	var/id_cache = list()
	/// Sequence var for the id cache
	var/id_cache_seq = 1
	/// Cooldown that prevents hanging the MC when tech disks are copied
	STATIC_COOLDOWN_DECLARE(cooldowncopy)

// An unlocked subtype of the console for mapping.
/obj/machinery/computer/rdconsole/unlocked
	circuit = /obj/item/circuitboard/computer/rdconsole/unlocked

/proc/CallMaterialName(ID)
	if (istype(ID, /datum/material))
		var/datum/material/material = ID
		return material.name
	else if(GLOB.chemical_reagents_list[ID])
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[ID]
		return reagent.name
	return ID

/obj/machinery/computer/rdconsole/post_machine_initialize()
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !stored_research)
		CONNECT_TO_RND_SERVER_ROUNDSTART(stored_research, src)
	if(stored_research)
		stored_research.consoles_accessing += src

/obj/machinery/computer/rdconsole/Destroy()
	if(stored_research)
		stored_research.consoles_accessing -= src
		stored_research = null
	if(t_disk)
		t_disk.forceMove(get_turf(src))
		t_disk = null
	if(d_disk)
		d_disk.forceMove(get_turf(src))
		d_disk = null
	return ..()

/obj/machinery/computer/rdconsole/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/disk))
		return NONE

	if(istype(tool, /obj/item/disk/tech_disk))
		if(t_disk)
			to_chat(user, span_warning("Диск с технологией уже загружен!"))
			return ITEM_INTERACT_BLOCKING

		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("[tool] застрял в вашей руке!"))
			return ITEM_INTERACT_BLOCKING

		t_disk = tool
		to_chat(user, span_notice("Вы вставляете [tool] в [src]!"))
		return ITEM_INTERACT_SUCCESS

	if (!istype(tool, /obj/item/disk/design_disk))
		to_chat(user, span_warning("Консоль не принимает диски такого формата."))
		return ITEM_INTERACT_BLOCKING

	if(d_disk)
		to_chat(user, span_warning("Диск с технологией уже загружен!"))
		return ITEM_INTERACT_BLOCKING

	if(!user.transferItemToLoc(tool, src))
		to_chat(user, span_warning("[tool] застрял в вашей руке!"))
		return ITEM_INTERACT_BLOCKING

	d_disk = tool
	to_chat(user, span_notice("Вы вставляете [tool] в [src]!"))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/computer/rdconsole/multitool_act(mob/living/user, obj/item/multitool/tool)
	. = ..()
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		stored_research = tool.buffer
	return TRUE

/obj/machinery/computer/rdconsole/proc/enqueue_node(id, mob/user)
	if(!stored_research || !stored_research.available_nodes[id] || stored_research.researched_nodes[id])
		say("Не удалось поставить узел в очередь: технология не найдена, либо узел уже исследован или он недоступен!")
		return FALSE
	stored_research.enqueue_node(id, user)
	return TRUE

/obj/machinery/computer/rdconsole/proc/dequeue_node(id, mob/user)
	if(!stored_research || !stored_research.available_nodes[id] || stored_research.researched_nodes[id])
		say("Не удалось убрать узел из очереди: технология не найдена, либо узел уже исследован или он недоступен!")
		return FALSE
	stored_research.dequeue_node(id, user)
	return TRUE

/obj/machinery/computer/rdconsole/proc/research_node(node_path, mob/user)
	if(!stored_research)
		say("Не удалось разблокировать узел: технология не найдена!")
		return FALSE
	if(!stored_research.available_nodes[node_path])
		say("Не удалось разблокировать узел: технология недоступна!")
		return FALSE
	if(stored_research.researched_nodes[node_path])
		say("Не удалось разблокировать узел: технология уже изучена!")
		return FALSE

	var/datum/techweb_node/unlocked_node = SSresearch.techweb_nodes[node_path]
	if(!istype(unlocked_node))
		say("Не удалось разблокировать узел: неизвестная ошибка.")
		return FALSE

	var/list/price = unlocked_node.get_price(stored_research)
	if(!stored_research.can_afford(price))
		say("Недостаточно очков для исследования...")
		return FALSE

	if(!stored_research.research_node(unlocked_node, research_source = src))
		say("Не удалось исследовать узел: внутренняя ошибка базы данных!")
		return FALSE

	user.investigate_log("researched [unlocked_node.display_name]([json_encode(price)]) on techweb id [stored_research.id].", INVESTIGATE_RESEARCH)
	if(istype(stored_research, /datum/techweb/science))
		SSblackbox.record_feedback("associative", "science_techweb_unlock", 1, list("path" = "[node_path]", "name" = unlocked_node.display_name, "price" = "[json_encode(price)]", "time" = ISOtime()))

	say("Успешно исследовано [unlocked_node.display_name].")

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
		"node_research_location" = "[get_area(src)] ([src.x],[src.y],[src.z])",
	))
	return TRUE

/obj/machinery/computer/rdconsole/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if (obj_flags & EMAGGED)
		return
	balloon_alert(user, "протоколы безопасности отключены")
	playsound(src, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	obj_flags |= EMAGGED
	var/obj/item/circuitboard/computer/rdconsole/board = circuit
	if(!(board.obj_flags & EMAGGED))
		board.silence_announcements = TRUE
	board.locked = FALSE
	return TRUE

/obj/machinery/computer/rdconsole/ui_interact(mob/user, datum/tgui/ui = null)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Techweb", name)
		ui.open()

/obj/machinery/computer/rdconsole/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/sheetmaterials),
		get_asset_datum(/datum/asset/spritesheet_batched/research_designs),
	)

// heavy data from this proc should be moved to static data when possible
/obj/machinery/computer/rdconsole/ui_data(mob/user)
	var/list/data = list()

	var/obj/item/circuitboard/computer/rdconsole/board = circuit

	data["stored_research"] = !!stored_research
	data["locked"] = board.locked
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
		"sec_protocols" = !(obj_flags & EMAGGED),
		"t_disk" = null,
		"d_disk" = null,
	)

	if (t_disk)
		data["t_disk"] = list(
			"stored_research" = t_disk.stored_nodes,
		)
	if (d_disk)
		data["d_disk"] = list(
			"blueprints" = d_disk.blueprints,
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
	for (var/datum/experiment/experiment as anything in exp_to_process)
		data["experiments"][experiment.type] = experiment.to_ui_data()
	return data

/**
 * Compresses an ID to an integer representation using the id_cache, used for deduplication
 * in sent JSON payloads
 *
 * Arguments:
 * * id - the ID to compress
 */
/obj/machinery/computer/rdconsole/proc/compress_id(id)
	if (!id_cache[id])
		id_cache[id] = id_cache_seq
		id_cache_seq += 1
	return id_cache[id]

/obj/machinery/computer/rdconsole/ui_static_data(mob/user)
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

/obj/machinery/computer/rdconsole/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	add_fingerprint(usr)

	var/obj/item/circuitboard/computer/rdconsole/board = circuit

	// Check if the console is locked to block any actions occuring
	if (board.locked && action != "toggleLock")
		say("Консоль заблокирована. Дальнейшие действия невозможны.")
		return TRUE

	switch (action)
		if ("toggleLock")
			if(obj_flags & EMAGGED)
				to_chat(usr, span_boldwarning("Ошибка протокола безопасности: не удается получить доступ к протоколам блокировки."))
				return TRUE
			if(allowed(usr))
				board.locked = !board.locked
			else
				to_chat(usr, span_boldwarning("Несанкционированный доступ."))
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

		if ("ejectDisk")
			eject_disk(params["type"])
			return TRUE

		if ("uploadDisk")
			if (params["type"] == RND_DESIGN_DISK)
				if(QDELETED(d_disk))
					say("Диск с дизайном не вставлен!")
					return TRUE
				for(var/design_path in d_disk.blueprints)
					stored_research.add_design(design_path, TRUE)
				say("Загрузка чертежей с диска.")
				d_disk.on_upload(stored_research, src)
				return TRUE
			if (params["type"] == RND_TECH_DISK)
				if(!COOLDOWN_FINISHED(src, cooldowncopy)) // prevents MC hang
					say("Серверы заняты!")
					return
				if (QDELETED(t_disk))
					say("Технологический диск не вставлен!")
					return TRUE
				COOLDOWN_START(src, cooldowncopy, 5 SECONDS)
				say("Загрузка технологии на диск.")
				stored_research.absorb_techdisk(t_disk)
			return TRUE

		//Tech disk-only action.
		if ("loadTech")
			if(!COOLDOWN_FINISHED(src, cooldowncopy)) // prevents MC hang
				say("Серверы заняты!")
				return
			if(QDELETED(t_disk))
				say("ехнологический диск не вставлен!")
				return
			COOLDOWN_START(src, cooldowncopy, 5 SECONDS)
			say("Загрузка на технологический диск.")
			t_disk.stored_nodes |= stored_research.researched_nodes
			return TRUE

/obj/machinery/computer/rdconsole/proc/eject_disk(type)
	if(type == RND_DESIGN_DISK && d_disk)
		d_disk.forceMove(get_turf(src))
		d_disk = null
	if(type == RND_TECH_DISK && t_disk)
		t_disk.forceMove(get_turf(src))
		t_disk = null

#undef RND_TECH_DISK
#undef RND_DESIGN_DISK
