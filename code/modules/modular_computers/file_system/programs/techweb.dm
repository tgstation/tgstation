/datum/computer_file/program/science
	filename = "experi_track"
	filedesc = "Nanotrasen Science Hub"
	program_icon_state = "research"
	extended_desc = "Connect to the internal science server in order to assist in station research efforts."
	requires_ntnet = TRUE
	size = 16
	tgui_id = "NtosTechweb"
	program_icon = "atom"
	required_access = ACCESS_RND
	transfer_access = ACCESS_RD
	/// Reference to global science techweb
	var/datum/techweb/stored_research
	/// Determines if the console is locked, and consequently if actions can be performed with it
	var/locked = FALSE
	/// Used for compressing data sent to the UI via static_data as payload size is of concern
	var/id_cache = list()
	/// Sequence var for the id cache
	var/id_cache_seq = 1

/datum/computer_file/program/science/run_program(mob/living/user)
	. = ..()
	stored_research = SSresearch.science_tech


/datum/computer_file/program/science/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/research_designs)
	)

// heavy data from this proc should be moved to static data when possible
/datum/computer_file/program/science/ui_data(mob/user)
	var/list/data = get_header_data()
	data += list(
		"nodes" = list(),
		"experiments" = list(),
		"researched_designs" = stored_research.researched_designs,
		"points" = stored_research.research_points,
		"points_last_tick" = stored_research.last_bitcoins,
		"web_org" = stored_research.organization,
		"sec_protocols" = !(computer.obj_flags & EMAGGED),
		"t_disk" = null, //Not doing disk operations on the app, use the console for that.
		"d_disk" = null, //See above.
		"locked" = locked
	)

	// Serialize all nodes to display
	for(var/v in stored_research.tiers)
		var/datum/techweb_node/n = SSresearch.techweb_node_by_id(v)

		// Ensure node is supposed to be visible
		if (stored_research.hidden_nodes[v])
			continue

		data["nodes"] += list(list(
			"id" = n.id,
			"can_unlock" = stored_research.can_unlock_node(n),
			"tier" = stored_research.tiers[n.id]
		))

	// Get experiments and serialize them
	var/list/exp_to_process = stored_research.available_experiments.Copy()
	for (var/e in stored_research.completed_experiments)
		exp_to_process += stored_research.completed_experiments[e]
	for (var/e in exp_to_process)
		var/datum/experiment/ex = e
		data["experiments"][ex.type] = list(
			"name" = ex.name,
			"description" = ex.description,
			"tag" = ex.exp_tag,
			"progress" = ex.check_progress(),
			"completed" = ex.completed,
			"performance_hint" = ex.performance_hint
		)
	return data

/datum/computer_file/program/science/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	var/obj/item/computer_hardware/card_slot/card_slot
	if(computer)
		card_slot = computer.all_components[MC_CARD]
	var/obj/item/card/id/user_id_card = card_slot.stored_card

	// Check if the console is locked to block any actions occuring
	if (locked && action != "toggleLock")
		computer.say("Console is locked, cannot perform further actions.")
		return TRUE

	switch (action)
		if ("toggleLock")
			if(computer.obj_flags & EMAGGED)
				to_chat(usr, "<span class='boldwarning'>Security protocol error: Unable to access locking protocols.</span>")
				return TRUE
			if(ACCESS_RND in user_id_card.access)
				locked = !locked
			else
				to_chat(usr, "<span class='boldwarning'>Unauthorized Access. Please insert research ID card.</span>")
			return TRUE
		if ("researchNode")
			if(!SSresearch.science_tech.available_nodes[params["node_id"]])
				return TRUE
			research_node(params["node_id"], usr)
			return TRUE

/datum/computer_file/program/science/ui_static_data(mob/user)
	. = list(
		"static_data" = list()
	)

	// Build node cache...
	// Note this looks a bit ugly but its to reduce the size of the JSON payload
	// by the greatest amount that we can, as larger JSON payloads result in
	// hanging when the user opens the UI
	var/node_cache = list()
	for (var/nid in SSresearch.techweb_nodes)
		var/datum/techweb_node/n = SSresearch.techweb_nodes[nid] || SSresearch.error_node
		var/cid = "[compress_id(n.id)]"
		node_cache[cid] = list(
			"name" = n.display_name,
			"description" = n.description
		)
		if (n.research_costs?.len)
			node_cache[cid]["costs"] = list()
			for (var/c in n.research_costs)
				node_cache[cid]["costs"]["[compress_id(c)]"] = n.research_costs[c]
		if (n.prereq_ids?.len)
			node_cache[cid]["prereq_ids"] = list()
			for (var/pn in n.prereq_ids)
				node_cache[cid]["prereq_ids"] += compress_id(pn)
		if (n.design_ids?.len)
			node_cache[cid]["design_ids"] = list()
			for (var/d in n.design_ids)
				node_cache[cid]["design_ids"] += compress_id(d)
		if (n.unlock_ids?.len)
			node_cache[cid]["unlock_ids"] = list()
			for (var/un in n.unlock_ids)
				node_cache[cid]["unlock_ids"] += compress_id(un)
		if (n.required_experiments?.len)
			node_cache[cid]["required_experiments"] = n.required_experiments
		if (n.discount_experiments?.len)
			node_cache[cid]["discount_experiments"] = n.discount_experiments

	// Build design cache
	var/design_cache = list()
	var/datum/asset/spritesheet/research_designs/ss = get_asset_datum(/datum/asset/spritesheet/research_designs)
	var/size32x32 = "[ss.name]32x32"
	for (var/did in SSresearch.techweb_designs)
		var/datum/design/d = SSresearch.techweb_designs[did] || SSresearch.error_design
		var/cid = "[compress_id(d.id)]"
		var/size = ss.icon_size_id(d.id)
		design_cache[cid] = list(
			d.name,
			"[size == size32x32 ? "" : "[size] "][d.id]"
		)

	// Ensure id cache is included for decompression
	var/flat_id_cache = list()
	for (var/id in id_cache)
		flat_id_cache += id

	.["static_data"] = list(
		"node_cache" = node_cache,
		"design_cache" = design_cache,
		"id_cache" = flat_id_cache
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
		id_cache[id] = id_cache_seq++
	return id_cache[id]

/datum/computer_file/program/science/proc/research_node(id, mob/user)
	if(!stored_research.available_nodes[id] || stored_research.researched_nodes[id])
		computer.say("Node unlock failed: Either already researched or not available!")
		return FALSE
	var/datum/techweb_node/TN = SSresearch.techweb_node_by_id(id)
	if(!istype(TN))
		computer.say("Node unlock failed: Unknown error.")
		return FALSE
	var/list/price = TN.get_price(stored_research)
	if(stored_research.can_afford(price))
		computer.investigate_log("[key_name(user)] researched [id]([json_encode(price)]) on techweb id [stored_research.id] via [computer].", INVESTIGATE_RESEARCH)
		if(stored_research == SSresearch.science_tech)
			SSblackbox.record_feedback("associative", "science_techweb_unlock", 1, list("id" = "[id]", "name" = TN.display_name, "price" = "[json_encode(price)]", "time" = SQLtime()))
		if(stored_research.research_node_id(id))
			computer.say("Successfully researched [TN.display_name].")
			var/logname = "Unknown"
			if(isAI(user))
				logname = "AI: [user.name]"
			if(iscarbon(user))
				var/obj/item/card/id/idcard = user.get_active_held_item()
				if(istype(idcard))
					logname = "User: [idcard.registered_name]"
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				var/obj/item/I = H.wear_id
				if(istype(I))
					var/obj/item/card/id/ID = I.GetID()
					if(istype(ID))
						logname = "User: [ID.registered_name]"
			var/i = stored_research.research_logs.len
			stored_research.research_logs += null
			stored_research.research_logs[++i] = list(TN.display_name, price["General Research"], logname, "[get_area(src)] ([computer.x],[computer.y],[computer.z])")
			return TRUE
		else
			computer.say("Failed to research node: Internal database error!")
			return FALSE
	computer.say("Not enough research points...")
	return FALSE
