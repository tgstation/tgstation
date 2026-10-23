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
	var/locked = FALSE
	/// The static data key we last sent each viewer, by REF(), so we know to resend it when the catalogue or experiments change
	var/list/sent_static_keys
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
			to_chat(user, span_warning("A technology disk is already loaded!"))
			return ITEM_INTERACT_BLOCKING

		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("[tool] is stuck to your hand!"))
			return ITEM_INTERACT_BLOCKING

		t_disk = tool
		to_chat(user, span_notice("You insert [tool] into \the [src]!"))
		return ITEM_INTERACT_SUCCESS

	if (!istype(tool, /obj/item/disk/design_disk))
		to_chat(user, span_warning("Machine cannot accept disks in that format."))
		return ITEM_INTERACT_BLOCKING

	if(d_disk)
		to_chat(user, span_warning("A design disk is already loaded!"))
		return ITEM_INTERACT_BLOCKING

	if(!user.transferItemToLoc(tool, src))
		to_chat(user, span_warning("[tool] is stuck to your hand!"))
		return ITEM_INTERACT_BLOCKING

	d_disk = tool
	to_chat(user, span_notice("You insert [tool] into \the [src]!"))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/computer/rdconsole/multitool_act(mob/living/user, obj/item/multitool/tool)
	. = ..()
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		stored_research = tool.buffer
	return TRUE

/obj/machinery/computer/rdconsole/proc/enqueue_node(id, mob/user)
	if(!stored_research || !stored_research.available_nodes[id] || stored_research.researched_nodes[id])
		say("Node enqueue failed: Either no techweb is found, node is already researched or is not available!")
		return FALSE
	stored_research.enqueue_node(id, user)
	return TRUE

/obj/machinery/computer/rdconsole/proc/dequeue_node(id, mob/user)
	if(!stored_research || !stored_research.available_nodes[id] || stored_research.researched_nodes[id])
		say("Node dequeue failed: Either no techweb is found, node is already researched or is not available!")
		return FALSE
	stored_research.dequeue_node(id, user)
	return TRUE

/obj/machinery/computer/rdconsole/proc/research_node(node_path, mob/user)
	if(!stored_research)
		say("Node unlock failed: No techweb found!")
		return FALSE
	if(!stored_research.available_nodes[node_path])
		say("Node unlock failed: Node is not available!")
		return FALSE
	if(stored_research.researched_nodes[node_path])
		say("Node unlock failed: Node is already researched!")
		return FALSE

	var/datum/techweb_node/unlocked_node = SSresearch.techweb_nodes[node_path]
	if(!istype(unlocked_node))
		say("Node unlock failed: Unknown error.")
		return FALSE

	var/list/price = unlocked_node.get_price(stored_research)
	if(!stored_research.can_afford(price))
		say("Not enough research points...")
		return FALSE

	if(!stored_research.research_node(unlocked_node, research_source = src))
		say("Failed to research node: Internal database error!")
		return FALSE

	user.investigate_log("researched [unlocked_node.display_name]([json_encode(price)]) on techweb id [stored_research.id].", INVESTIGATE_RESEARCH)
	if(istype(stored_research, /datum/techweb/science))
		SSblackbox.record_feedback("associative", "science_techweb_unlock", 1, list("path" = "[node_path]", "name" = unlocked_node.display_name, "price" = "[json_encode(price)]", "time" = ISOtime()))

	say("Successfully researched [unlocked_node.display_name].")

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
	balloon_alert(user, "security protocols disabled")
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
	var/obj/item/circuitboard/computer/rdconsole/board = circuit
	var/list/data = list(
		"stored_research" = !!stored_research,
		"locked" = board.locked,
	)
	if(!stored_research) //lack of a research node is all we care about.
		update_static_data_if_outdated(user)
		return data

	var/datum/asset/json/techweb_catalogue/catalogue = get_asset_datum(/datum/asset/json/techweb_catalogue)
	data += stored_research.get_ui_data(user, catalogue)
	update_static_data_if_outdated(user) // after get_ui_data(), which notices the experiment stage texts in our static data changing
	data["sec_protocols"] = !(obj_flags & EMAGGED)
	data["t_disk"] = null
	data["d_disk"] = null
	if (t_disk)
		var/list/stored_ids = list()
		for(var/node_path in t_disk.stored_nodes)
			var/id = catalogue.ids[node_path]
			if(id)
				stored_ids += id
		data["t_disk"] = stored_ids
	if (d_disk)
		var/list/blueprint_ids = list()
		for(var/design_path in d_disk.blueprints)
			blueprint_ids += list(isnull(design_path) ? null : catalogue.ids[design_path]) // empty slots stay null
		data["d_disk"] = blueprint_ids
	return data

/obj/machinery/computer/rdconsole/ui_static_data(mob/user)
	LAZYSET(sent_static_keys, REF(user), get_static_key())
	if(!stored_research)
		return list()
	var/datum/asset/json/techweb_catalogue/catalogue = get_asset_datum(/datum/asset/json/techweb_catalogue)
	return list(
		"techweb_catalogue" = catalogue.get_window_data(user),
		"experiment_metadata" = stored_research.get_ui_static_data(catalogue),
	)

/obj/machinery/computer/rdconsole/ui_close(mob/user)
	. = ..()
	LAZYREMOVE(sent_static_keys, REF(user))

/// Returns everything this console's static data depends on, see [/datum/techweb/proc/get_ui_static_key]
/obj/machinery/computer/rdconsole/proc/get_static_key()
	return "[stored_research?.get_ui_static_key()]"

/// Sends the user a full update first if their static data is out of date (older catalogue build, other techweb or new experiments)
/obj/machinery/computer/rdconsole/proc/update_static_data_if_outdated(mob/user)
	var/user_ref = REF(user)
	var/sent_key = sent_static_keys?[user_ref]
	if(isnull(sent_key))
		return
	var/static_key = get_static_key()
	if(sent_key != static_key)
		sent_static_keys[user_ref] = static_key // set this first or the full update's ui_data() sends another one
		var/datum/tgui/ui = SStgui.get_open_ui(user, src)
		ui?.send_full_update(always_instant = TRUE)

/obj/machinery/computer/rdconsole/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	add_fingerprint(usr)

	var/obj/item/circuitboard/computer/rdconsole/board = circuit

	// Check if the console is locked to block any actions occuring
	if (board.locked && action != "toggleLock")
		say("Console is locked, cannot perform further actions.")
		return TRUE

	switch (action)
		if ("toggleLock")
			if(obj_flags & EMAGGED)
				to_chat(usr, span_boldwarning("Security protocol error: Unable to access locking protocols."))
				return TRUE
			if(allowed(usr))
				board.locked = !board.locked
			else
				to_chat(usr, span_boldwarning("Unauthorized Access."))
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
					say("No design disk inserted!")
					return TRUE
				for(var/design_path in d_disk.blueprints)
					stored_research.add_design(design_path, TRUE)
				say("Uploading blueprints from disk.")
				d_disk.on_upload(stored_research, src)
				return TRUE
			if (params["type"] == RND_TECH_DISK)
				if(!COOLDOWN_FINISHED(src, cooldowncopy)) // prevents MC hang
					say("Servers busy!")
					return
				if (QDELETED(t_disk))
					say("No tech disk inserted!")
					return TRUE
				COOLDOWN_START(src, cooldowncopy, 5 SECONDS)
				say("Uploading technology disk.")
				stored_research.absorb_techdisk(t_disk)
			return TRUE

		//Tech disk-only action.
		if ("loadTech")
			if(!COOLDOWN_FINISHED(src, cooldowncopy)) // prevents MC hang
				say("Servers busy!")
				return
			if(QDELETED(t_disk))
				say("No tech disk inserted!")
				return
			COOLDOWN_START(src, cooldowncopy, 5 SECONDS)
			say("Downloading to technology disk.")
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
