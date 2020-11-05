#define NO_CATEGORY_SET "none"


/obj/machinery/rnd/production
	name = "technology fabricator"
	desc = "Makes researched and prototype items with materials and energy."
	layer = BELOW_OBJ_LAYER
	idle_power_usage = 20
	active_power_usage = 5000
	processing_flags = START_PROCESSING_MANUALLY
	subsystem_type = /datum/controller/subsystem/processing/fastprocess

	// List of catagories this machine supports and displays.  Order of this
	// list is the order that is displayed
	var/list/categories = list()

	// Associated list of catagories that have sub catagories.  The order of
	// the sub catagories are displayed in the listed ordered
	var/list/sub_category_order = list(
		CATEGORY_STOCK_PARTS = list(
			CATEGORY_TIER_MATERIALS,
			CATEGORY_TIER_BLUESPACE,
			CATEGORY_TIER_SUPER,
			CATEGORY_TIER_ADVANCED,
			CATEGORY_TIER_BASIC,
			CATEGORY_TIER_TELECOMS
		),
	)

	var/allowed_department_flags = ALL
	var/production_animation				//What's flick()'d on print.
	var/allowed_buildtypes = NONE

	var/department_tag = "Unidentified"			//used for material distribution among other things.

	/// Current items in the build queue.
	var/list/queue = list()
	/// Whether or not the machine is building the entire queue automagically.
	var/process_queue = FALSE

	/// The current design datum that the machine is building.
	var/datum/design/being_built
	/// World time when the build will finish.
	var/build_finish = 0
	/// World time when the build started.
	var/build_start = 0
	/// Reference to all materials used in the creation of the item being_built.
	var/list/build_materials
	/// Part currently stored in the Exofab.
	var/obj/item/stored_part

	/// Coefficient for the speed of item building AND material usage  Based on the installed parts.
	var/efficiency_coeff = 1.2

	/// Whether the Exofab links to the ore silo on init. Special derelict or maintanance variants should set this to FALSE.
	var/link_on_init = TRUE

	/// Reference to a remote material inventory, such as an ore silo.
	var/datum/component/remote_materials/rmat
	/// Parts set...generate_or_wait_for_human_dummy(slotkey)
	var/list/part_sets = list()
	/// Dispensing direction.
	var/dispense_direction 	// Default on top
	/// type list of things that ignore the coeff
	var/list/ignore_coeff = list(
		/obj/item/stack/sheet,
		/obj/item/stack/ore/bluespace_crystal
	)

/obj/machinery/rnd/production/Initialize(mapload)
	rmat = AddComponent(/datum/component/remote_materials, "lathe", mapload && link_on_init, breakdown_flags=BREAKDOWN_FLAGS_LATHE) // _after_insert = CALLBACK(.proc/AfterMaterialInsert))
	// To make life easier for ui, we insert BASE_OF_CATEGORY at the front so
	// items without a sub category get displayed first
	create_reagents(0, OPENCONTAINER)
	// converts to assoc list for quicker finds
	ignore_coeff = make_associative(ignore_coeff)
	#if 0
	var/list/category_order
	for(var/category_name in categories)
		category_order = categories[category_name]
		category_order.Insert(1,BASE_OF_CATEGORY)
		#endif
	RefreshParts() //Recalculating local material sizes if the fab isn't linked
	return ..

//we eject the materials upon deconstruction.
/obj/machinery/rnd/production/on_deconstruction()
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)
	return ..()

/obj/machinery/rnd/production/RefreshParts()
	var/T = 0

	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.maximum_volume += G.volume
		G.reagents.trans_to(src, G.reagents.total_volume)

	T = 0
	//maximum stocking amount (default 300000, 600000 at T4)
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	rmat.set_local_size((200000 + (T*50000)))


	// Unlike the mechfab we don't got lasers so the manipulators control
	// both the speed and consumption of materials
	efficiency_coeff = inital(efficiency_coeff)
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		efficiency_coeff = clamp(efficiency_coeff - (M.rating * 0.1), 0, 1)
	if(total_rating == 0)
		efficiency_coeff = INFINITY
	else
		efficiency_coeff = 1/efficiency_coeff

	// Adjust the build time of any item currently being built.
	if(being_built)
		var/last_const_time = build_finish - build_start
		var/new_const_time = get_construction_time_w_coeff(initial(being_built.construction_time))
		var/const_time_left = build_finish - world.time
		var/new_build_time = (new_const_time / last_const_time) * const_time_left
		build_finish = world.time + new_build_time

	testing("/obj/machinery/rnd/production/RefreshParts: reagents.maximum_volume=[reagents.maximum_volume] time_coeff=[time_coeff] component_coeff=[component_coeff] ")
	update_static_data(usr)

/obj/machinery/rnd/production/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Storing up to <b>[rmat.local_size]</b> material units.<br>Material consumption at <b>[component_coeff*100]%</b>.<br>Build time reduced by <b>[100-time_coeff*100]%</b>.</span>"

/**
  * Generates an info list for a given part.
  *
  * Returns a list of part information.
  * * D - Design datum to get information on.
  * * parse_categories - tex,t name of the category to find if its a sub category we want to use
  */
/obj/machinery/rnd/production/proc/output_part_info(datum/design/D, parse_categories = null)
	var/cost = list()
	for(var/c in D.materials)
		var/datum/material/M = c
		cost[M.name] = get_resource_cost_w_coeff(D, M)

	var/obj/built_item = D.build_path
	var/list/sub_category = null

	if(parse_categories)
		// Unlike mechfab that needs hard coded sub_catagories, we are using the sub
		// category var off the design

		if(D.sub_category)
			sub_category = list(D.sub_category)


	var/list/part = list(
		"name" = D.name,
		"desc" = initial(built_item.desc),
		"printTime" = get_construction_time_w_coeff(initial(D.construction_time))/10,
		"cost" = cost,
		"id" = D.id,
		"subCategory" = sub_category,
		"categoryOverride" = null,
		"searchMeta" = D.search_metadata
	)

	return part

/**
  * Generates a list of resources / materials available to this Exosuit Fab
  *
  * Returns null if there is no material container available.
  * List format is list(material_name = list(amount = ..., ref = ..., etc.))
  */
/obj/machinery/rnd/production/proc/output_available_resources()
	var/datum/component/material_container/materials = rmat.mat_container

	var/list/material_data = list()

	if(materials)
		for(var/mat_id in materials.materials)
			var/datum/material/M = mat_id
			var/list/material_info = list()
			var/amount = materials.materials[mat_id]

			material_info = list(
				"name" = M.name,
				"ref" = REF(M),
				"amount" = amount,
				"sheets" = round(amount / MINERAL_MATERIAL_AMOUNT),
				"removable" = amount >= MINERAL_MATERIAL_AMOUNT
			)

			material_data += list(material_info)

		return material_data

	return null

/**
  * Intended to be called when an item starts printing.
  *
  * Adds the overlay to show the fab working and sets active power usage settings.
  */
/obj/machinery/rnd/production/proc/on_start_printing()
	if(production_animation)
		add_overlay(production_animation)
	use_power = ACTIVE_POWER_USE

/**
  * Intended to be called when the exofab has stopped working and is no longer printing items.
  *
  * Removes the overlay to show the fab working and sets idle power usage settings. Additionally resets the description and turns off queue processing.
  */
/obj/machinery/rnd/production/proc/on_finish_printing()
	if(production_animation)
		cut_overlay(production_animation)
	use_power = IDLE_POWER_USE
	desc = initial(desc)
	process_queue = FALSE

/**
  * Calculates resource/material costs for printing an item based on the machine's resource coefficient.
  *
  * Returns a list of k,v resources with their amounts.
  * * D - Design datum to calculate the modified resource cost of.
  */
/obj/machinery/rnd/production/proc/get_resources_w_coeff(datum/design/D)
	var/list/resources = list()
	for(var/R in D.materials)
		var/datum/material/M = R
		resources[M] = get_resource_cost_w_coeff(D, M)
	return resources

/**
  * Checks if the Exofab has enough resources to print a given item.
  *
  * Returns FALSE if the design has no reagents used in its construction (?) or if there are insufficient resources.
  * Returns TRUE if there are sufficient resources to print the item.
  * * D - Design datum to calculate the modified resource cost of.
  */
/obj/machinery/rnd/production/proc/check_resources(datum/design/D)
	if(length(D.reagents_list)) // No reagents storage - no reagent designs.
		return FALSE
	var/datum/component/material_container/materials = rmat.mat_container
	if(materials.has_materials(get_resources_w_coeff(D)))
		return TRUE
	return FALSE

/**
  * Attempts to build the next item in the build queue.
  *
  * Returns FALSE if either there are no more parts to build or the next part is not buildable.
  * Returns TRUE if the next part has started building.
  */
/obj/machinery/rnd/production/proc/build_next_in_queue()
	if(!length(queue))
		return FALSE

	var/datum/design/D = queue[1]
	testing("build_next_in_queue: [D.name]")
	if(build_part(D))
		remove_from_queue(1)
		return TRUE

	return FALSE

/**
  * Starts the build process for a given design datum.
  *
  * Returns FALSE if the procedure fails. Returns TRUE when being_built is set.
  * Uses materials.
  * * D - Design datum to attempt to print.
  */
/obj/machinery/rnd/production/proc/build_part(datum/design/D)
	if(!D)
		testing("/obj/machinery/rnd/production/proc/build_part: design is null")
		return FALSE

	var/datum/component/material_container/materials = rmat.mat_container
	if (!materials)
		say("No access to material storage, please contact the quartermaster.")
		return FALSE
	if (rmat.on_hold())
		say("Mineral access is on hold, please contact the quartermaster.")
		return FALSE
	if(!check_resources(D))
		say("Not enough resources. Processing stopped.")
		return FALSE

	build_materials = get_resources_w_coeff(D)

	materials.use_materials(build_materials)
	being_built = D
	build_finish = world.time + get_construction_time_w_coeff(initial(D.construction_time))
	build_start = world.time

	desc = "It's building \a [D.name]."
	rmat.silo_log(src, "built", -1, "[D.name]", build_materials)

	testing("build_part: [desc] [build_start]->[build_finish]")
	return TRUE

/obj/machinery/rnd/production/process()
	if(stored_part)
		var/turf/exit = dispense_direction ? get_step(src, dispense_direction) : get_turf(src)
		if(dispense_direction && exit.density)
			testing("/obj/machinery/rnd/process: Obstruction in machine")
			on_finish_printing()
			return PROCESS_KILL
		testing("/obj/machinery/rnd/process: Obstruction cleared")
		say("Obstruction cleared. \The [stored_part] is complete.")
		stored_part.forceMove(exit)
		stored_part = null

	// If there's nothing being built, try to build something
	if(!being_built)
		// If we're not processing the queue anymore or there's nothing to build, end processing.
		if(!process_queue || !build_next_in_queue())
			on_finish_printing()
			return PROCESS_KILL
		on_start_printing()

	// If there's an item being built, check if it is complete.
	if(being_built && (build_finish < world.time))
		// Then attempt to dispense it and if appropriate build the next item.
		dispense_built_part()
		if(process_queue)
			build_next_in_queue(FALSE)
		return

/**
  * Dispenses a part to the tile infront of the Exosuit Fab.
  *
  * Returns FALSE is the machine cannot dispense the part on the appropriate turf.
  * Return TRUE if the part was successfully dispensed.
  */
/obj/machinery/rnd/production/proc/dispense_built_part()
	var/obj/I = new being_built.build_path(src)
	var/backup_material_flags = I.material_flags
	I.material_flags |= MATERIAL_NO_EFFECTS		// prevents discoloration
	I.set_custom_materials(build_materials)
	I.material_flags = backup_material_flags

	being_built = null
	build_materials.Cut()

	var/turf/exit = dispense_direction ? get_step(src, dispense_direction) : get_turf(src)
	if(dispense_direction && exit.density)
		say("Error! Part outlet is obstructed.")
		desc = "It's trying to dispense \a [I.name], but the part outlet is obstructed."
		stored_part = I
		return FALSE

	say("\The [I] is complete.")
	I.forceMove(exit)
	return TRUE

/**
  * Adds a list of datum designs to the build queue.
  *
  * Will only add designs that are in this machine's stored techweb.
  * Does final checks for datum IDs and makes sure this machine can build the designs.
  * * part_list - List of datum design ids for designs to add to the queue.
  */
/obj/machinery/rnd/production/proc/add_part_set_to_queue(list/part_list)
	for(var/id in part_list)
		if(!stored_research.researched_designs[id])
			continue
		var/datum/design/D = SSresearch.techweb_design_by_id(id)
		if(D.build_type && !(D.build_type & allowed_buildtypes))
			continue
		add_to_queue(D)

/**
  * Adds a datum design to the build queue.
  *
  * Returns TRUE if successful and FALSE if the design was not added to the queue.
  * * D - Datum design to add to the queue.
  */
/obj/machinery/rnd/production/proc/add_to_queue(datum/design/D)
	if(D)
		queue[++queue.len] = D
		return TRUE
	return FALSE

/**
  * Removes datum design from the build queue based on index.
  *
  * Returns TRUE if successful and FALSE if a design was not removed from the queue.
  * * index - Index in the build queue of the element to remove.
  */
/obj/machinery/rnd/production/proc/remove_from_queue(index)
	if(!isnum(index) || !ISINTEGER(index) || !istype(queue) || (index<1 || index>length(queue)))
		return FALSE
	queue.Cut(index,++index)
	return TRUE

/**
  * Generates a list of parts formatted for tgui based on the current build queue.
  *
  * Returns a formatted list of lists containing formatted part information for every part in the build queue.
  */
/obj/machinery/rnd/production/proc/list_queue()
	if(!istype(queue) || !length(queue))
		return null

	var/list/queued_parts = list()
	for(var/datum/design/D in queue)
		var/list/part = output_part_info(D)
		queued_parts += list(part)
	return queued_parts

/**
  * Calculates the coefficient-modified resource cost of a single material component of a design's recipe.
  *
  * Returns coefficient-modified resource cost for the given material component.
  * * D - Design datum to pull the resource cost from.
  * * resource - Material datum reference to the resource to calculate the cost of.
  * * roundto - Rounding value for round() proc
  */
/obj/machinery/rnd/production/proc/get_resource_cost_w_coeff(datum/design/D, datum/material/resource, roundto = 1)
	return ignore_coeff[d.build_path] ? 1 : round(D.materials[resource]/efficiency_coeff, roundto)

/**
  * Calculates the coefficient-modified build time of a design.
  *
  * Returns coefficient-modified build time of a given design.
  * * D - Design datum to calculate the modified build time of.
  * * roundto - Rounding value for round() proc
  */
/obj/machinery/rnd/production/proc/get_construction_time_w_coeff(construction_time, roundto = 1) //aran
	return round(construction_time/efficiency_coeff, roundto)

/obj/machinery/rnd/production/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/sheetmaterials)
	)

/obj/machinery/rnd/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ProLathe")
		ui.open()

/obj/machinery/rnd/production/ui_static_data(mob/user)
	var/list/data = list()

	var/list/final_sets = list()
	var/list/buildable_parts = list()

	// changed to stop going though the catagories on EACH freaking design
	for(var/cat in categories)
		final_sets += cat
		for(var/datum/design/D in stored_research.researched_designs_by_category[cat])
			if(D.build_type && !(D.build_type & allowed_buildtypes))
				continue	// machine cannot build this thing
			if(!(isnull(allowed_department_flags) || (D.departmental_flags & allowed_department_flags)))
				continue 	// Not the right department

			// This is for us.
			var/list/part = output_part_info(D, TRUE)

			if(part["category_override"])
				for(var/cat in part["category_override"])
					buildable_parts[cat] += list(part)
					if(!(cat in part_sets))
						final_sets += cat
				continue

			buildable_parts[cat] += list(part)

	data["partSets"] = final_sets
	data["buildableParts"] = buildable_parts
	data["department_tag"] = department_tag
	data["parts_mode"] = FALSE
	return data

/obj/machinery/rnd/production/ui_data(mob/user)
	var/list/data = list()

	data["materials"] = output_available_resources()

	if(being_built)
		var/list/part = list(
			"name" = being_built.name,
			"duration" = build_finish - world.time,
			"printTime" = get_construction_time_w_coeff(initial(being_built.construction_time))
		)
		data["buildingPart"] = part
	else
		data["buildingPart"] = null

	data["queue"] = list_queue()

	if(stored_part)
		data["storedPart"] = stored_part.name
	else
		data["storedPart"] = null

	data["isProcessingQueue"] = process_queue

	return data

/obj/machinery/rnd/production/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	. = TRUE
	// aren't these done in ..()?
	// add_fingerprint(usr) Done in ..()
	// usr.set_machine(src) Done in ui_interact?

	switch(action)
		if("sync_rnd")
			// Syncronises designs on interface with R&D techweb.
			update_static_data(usr)
			say("Successfully synchronized with R&D server.")
			return
		if("add_queue_set")
			// Add all parts of a set to queue
			var/part_list = params["part_list"]
			add_part_set_to_queue(part_list)
			return
		if("add_queue_part")
			// Add a specific part to queue
			var/id = params["id"]
			if(!stored_research.researched_designs[id])
				return
			var/datum/design/D = SSresearch.techweb_design_by_id(id)
			if(!D.build_type || (D.build_type & allowed_buildtypes))
				add_to_queue(D)

			return
		if("del_queue_part")
			// Delete a specific from from the queue
			var/index = text2num(params["index"])
			remove_from_queue(index)
			return
		if("clear_queue")
			// Delete everything from queue
			queue.Cut()

		if("build_queue")
			// Build everything in queue
			if(!process_queue)
				process_queue = TRUE
				if(!being_built)
					begin_processing()

		if("stop_queue")
			// Pause queue building. Also known as stop.
			process_queue = FALSE

		if("build_part")
			// Build a single part
			if(being_built || process_queue)
				return

			var/id = params["id"]
			if(stored_research.researched_designs[id])
				var/datum/design/D = SSresearch.techweb_design_by_id(id)
				if((!D.build_type || (D.build_type & allowed_buildtypes)) && build_part(D))
					on_start_printing()
					begin_processing()

		if("move_queue_part")
			// Moves a part up or down in the queue.
			var/index = text2num(params["index"])
			var/new_index = index + text2num(params["newindex"])
			if(isnum(index) && isnum(new_index) && ISINTEGER(index) && ISINTEGER(new_index))
				if(ISINRANGE(new_index,1,length(queue)))
					queue.Swap(index,new_index)

		if("remove_mat")
			// Remove a material from the fab
			var/mat_ref = params["ref"]
			var/amount = text2num(params["amount"])
			var/datum/material/mat = locate(mat_ref)
			eject_sheets(mat, amount)

		else
			return FALSE

/**
  * Eject material sheets.
  *
  * Returns the number of sheets successfully ejected.
  * eject_sheet - Byond REF of the material to eject.
  *	eject_amt - Number of sheets to attempt to eject.
  */
/obj/machinery/rnd/production/proc/eject_sheets(eject_sheet, eject_amt)
	var/datum/component/material_container/mat_container = rmat.mat_container
	if (!mat_container)
		say("No access to material storage, please contact the quartermaster.")
		return 0
	if (rmat.on_hold())
		say("Mineral access is on hold, please contact the quartermaster.")
		return 0
	var/count = mat_container.retrieve_sheets(text2num(eject_amt), eject_sheet, drop_location())
	var/list/matlist = list()
	matlist[eject_sheet] = text2num(eject_amt)
	rmat.silo_log(src, "ejected", -count, "sheets", matlist)
	return count

/obj/machinery/rnd/production/proc/AfterMaterialInsert(item_inserted, id_inserted, amount_inserted)
	var/stack_name
	if(istype(item_inserted, /obj/item/stack/ore/bluespace_crystal))
		stack_name = "bluespace"
		use_power(MINERAL_MATERIAL_AMOUNT / 10)
	else
		var/obj/item/stack/S = item_inserted
		stack_name = S.name
		use_power(min(1000, (amount_inserted / 100)))
	add_overlay("protolathe_[stack_name]")
	addtimer(CALLBACK(src, /atom/proc/cut_overlay, "protolathe_[stack_name]"), 10)


/obj/machinery/rnd/production/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(being_built)
		to_chat(user, "<span class='warning'>\The [src] is currently processing! Please wait until completion.</span>")
		return FALSE
	return default_deconstruction_screwdriver(user, "[initial(icon_state)]_t", initial(icon_state), I)

/obj/machinery/rnd/production/crowbar_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(being_built)
		to_chat(user, "<span class='warning'>\The [src] is currently processing! Please wait until completion.</span>")
		return FALSE
	return default_deconstruction_crowbar(I)

/obj/machinery/rnd/production/is_insertion_ready(mob/user)
	if(being_built)
		to_chat(user, "<span class='warning'>\The [src] is currently processing! Please wait until completion.</span>")
		return FALSE
	return ..()





#undef NO_CATEGORY_SET
