/datum/computer_file/program/science
	filename = "experi_track"
	filedesc = "Nanotrasen Science Hub"
	downloader_category = PROGRAM_CATEGORY_SCIENCE
	program_open_overlay = "research"
	extended_desc = "Connect to the internal science server in order to assist in station research efforts."
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
	/// The static data key we last sent each viewer, by REF(), so we know to resend it when the catalogue or experiments change
	var/list/sent_static_keys

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
	computer.balloon_alert(user, "buffer linked!")
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
		update_static_data_if_outdated(user)
		return data
	data += stored_research.get_ui_data(user, get_asset_datum(/datum/asset/json/techweb_catalogue))
	update_static_data_if_outdated(user) // after get_ui_data(), which notices the experiment stage texts in our static data changing
	data += list(
		"sec_protocols" = !(computer.obj_flags & EMAGGED),
		"t_disk" = null, //Not doing disk operations on the app, use the console for that.
		"d_disk" = null, //See above.
		"locked" = locked,
	)
	return data

/datum/computer_file/program/science/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	// Check if the console is locked to block any actions occuring
	if (locked && action != "toggleLock")
		computer.say("Console is locked, cannot perform further actions.")
		return TRUE

	switch (action)
		if ("toggleLock")
			if(computer.obj_flags & EMAGGED)
				to_chat(usr, span_boldwarning("Security protocol error: Unable to access locking protocols."))
				return TRUE
			if(lock_access in computer?.stored_id?.access)
				locked = !locked
			else
				to_chat(usr, span_boldwarning("Unauthorized Access. Please insert research ID card."))
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
	LAZYSET(sent_static_keys, REF(user), get_static_key())
	if(!stored_research)
		return list()
	var/datum/asset/json/techweb_catalogue/catalogue = get_asset_datum(/datum/asset/json/techweb_catalogue)
	return list(
		"techweb_catalogue" = catalogue.get_window_data(user),
		"experiment_metadata" = stored_research.get_ui_static_data(catalogue),
	)

/datum/computer_file/program/science/on_made_active_program(mob/user)
	. = ..()
	sent_static_keys = null

/datum/computer_file/program/science/ui_close(mob/user)
	. = ..()
	LAZYREMOVE(sent_static_keys, REF(user))

/// Returns everything this program's static data depends on, see [/datum/techweb/proc/get_ui_static_key]
/datum/computer_file/program/science/proc/get_static_key()
	return "[stored_research?.get_ui_static_key()]"

/// Sends the user a full update first if their static data is out of date (older catalogue build, other techweb or new experiments)
/datum/computer_file/program/science/proc/update_static_data_if_outdated(mob/user)
	var/user_ref = REF(user)
	var/sent_key = sent_static_keys?[user_ref]
	if(isnull(sent_key))
		return
	var/static_key = get_static_key()
	if(sent_key != static_key)
		sent_static_keys[user_ref] = static_key // set this first or the full update's ui_data() sends another one
		var/datum/tgui/ui = SStgui.get_open_ui(user, computer)
		ui?.send_full_update(always_instant = TRUE)

/datum/computer_file/program/science/proc/enqueue_node(node_path, mob/user)
	if(!stored_research || !stored_research.available_nodes[node_path] || stored_research.researched_nodes[node_path])
		computer.say("Node enqueue failed: Either no techweb is found, node is already researched or is not available!")
		return FALSE
	stored_research.enqueue_node(node_path, user)
	return TRUE

/datum/computer_file/program/science/proc/dequeue_node(node_path, mob/user)
	if(!stored_research || !stored_research.available_nodes[node_path] || stored_research.researched_nodes[node_path])
		computer.say("Node dequeue failed: Either no techweb is found, node is already researched or is not available!")
		return FALSE
	stored_research.dequeue_node(node_path, user)
	return TRUE

/datum/computer_file/program/science/proc/research_node(node_path, mob/user)
	if(!stored_research)
		computer.say("Node unlock failed: No techweb found!")
		return FALSE
	if(!stored_research.available_nodes[node_path])
		computer.say("Node unlock failed: Node is not available!")
		return FALSE
	if(stored_research.researched_nodes[node_path])
		computer.say("Node unlock failed: Node is already researched!")
		return FALSE

	var/datum/techweb_node/unlocked_node = SSresearch.techweb_nodes[node_path]
	if(!istype(unlocked_node))
		computer.say("Node unlock failed: Unknown error.")
		return FALSE

	var/list/price = unlocked_node.get_price(stored_research)
	if(!stored_research.can_afford(price))
		computer.say("Not enough research points...")
		return FALSE

	if(!stored_research.research_node(unlocked_node, research_source = computer))
		computer.say("Failed to research node: Internal database error!")
		return FALSE

	user.investigate_log("researched [unlocked_node.display_name]([json_encode(price)]) on techweb id [stored_research.id].", INVESTIGATE_RESEARCH)
	if(istype(stored_research, /datum/techweb/science))
		SSblackbox.record_feedback("associative", "science_techweb_unlock", 1, list("path" = "[node_path]", "name" = unlocked_node.display_name, "price" = "[json_encode(price)]", "time" = ISOtime()))

	computer.say("Successfully researched [unlocked_node.display_name].")

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
