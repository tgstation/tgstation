/obj/machinery/mecha_part_fabricator
	icon = 'icons/obj/machines/robotics.dmi'
	icon_state = "fab-idle"
	name = "exosuit fabricator"
	desc = "Nothing is being built."
	density = TRUE
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/machine/mechfab
	processing_flags = START_PROCESSING_MANUALLY

	subsystem_type = /datum/controller/subsystem/processing/fastprocess

	interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_MOUSEDROP_IGNORE_CHECKS
	/// Current items in the build queue.
	var/list/datum/design/queue = list()

	/// Whether or not the machine is building the entire queue automagically.
	var/process_queue = FALSE

	/// The current design datum that the machine is building.
	var/datum/design/being_built

	/// World time when the build will finish.
	var/build_finish = 0

	/// World time when the build started.
	var/build_start = 0

	/// The job ID of the part currently being processed. This is used for ordering list items for the client UI.
	var/top_job_id = 0

	/// Part currently stored in the Exofab.
	var/obj/item/stored_part

	/// Coefficient for the speed of item building. Based on the installed parts.
	var/time_coeff = 1

	/// Coefficient for the efficiency of material usage in item building. Based on the installed parts.
	var/component_coeff = 1

	/// Reference to the techweb.
	var/datum/techweb/stored_research

	/// Whether the Exofab links to the ore silo on init. Special derelict or maintanance variants should set this to FALSE.
	var/link_on_init = TRUE

	/// Reference to a remote material inventory, such as an ore silo.
	var/datum/component/remote_materials/rmat

	/// All designs in the techweb that can be fabricated by this machine, since the last update.
	var/list/datum/design/cached_designs

	/// Looping sound for printing items
	var/datum/looping_sound/lathe_print/print_sound

	/// Direction the produced items will drop (0 means on top of us)
	var/drop_direction = SOUTH

/obj/machinery/mecha_part_fabricator/Initialize(mapload)
	print_sound = new(src,  FALSE)
	rmat = AddComponent(/datum/component/remote_materials, mapload && link_on_init)
	cached_designs = list()
	return ..()

/obj/machinery/mecha_part_fabricator/Destroy()
	QDEL_NULL(print_sound)
	return ..()

/obj/machinery/mecha_part_fabricator/post_machine_initialize()
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !stored_research)
		CONNECT_TO_RND_SERVER_ROUNDSTART(stored_research, src)
	if(stored_research)
		on_connected_techweb()

/obj/machinery/mecha_part_fabricator/proc/connect_techweb(datum/techweb/new_techweb)
	if(stored_research)
		UnregisterSignal(stored_research, list(COMSIG_TECHWEB_ADD_DESIGN, COMSIG_TECHWEB_REMOVE_DESIGN))
	stored_research = new_techweb
	if(!isnull(stored_research))
		on_connected_techweb()

/obj/machinery/mecha_part_fabricator/proc/on_connected_techweb()
	RegisterSignals(
		stored_research,
		list(COMSIG_TECHWEB_ADD_DESIGN, COMSIG_TECHWEB_REMOVE_DESIGN),
		PROC_REF(on_techweb_update)
	)
	update_menu_tech()

/obj/machinery/mecha_part_fabricator/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		connect_techweb(tool.buffer)
	return TRUE

/obj/machinery/mecha_part_fabricator/proc/on_techweb_update()
	SIGNAL_HANDLER

	// We're probably going to get more than one update (design) at a time, so batch
	// them together.
	addtimer(CALLBACK(src, PROC_REF(update_menu_tech)), 2 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/machinery/mecha_part_fabricator/RefreshParts()
	. = ..()
	var/T = 0

	//maximum stocking amount (default 300000, 600000 at T4)
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		T += matter_bin.tier
	rmat.set_local_size(((100 * SHEET_MATERIAL_AMOUNT) + (T * (25 * SHEET_MATERIAL_AMOUNT))))

	//resources adjustment coefficient (1 -> 0.85 -> 0.7 -> 0.55)
	T = 1.15
	for(var/datum/stock_part/micro_laser/micro_laser in component_parts)
		T -= micro_laser.tier * 0.15
	component_coeff = T

	//building time adjustment coefficient (1 -> 0.8 -> 0.6)
	T = -1
	for(var/datum/stock_part/servo/servo in component_parts)
		T += servo.tier
	time_coeff = round(initial(time_coeff) - (initial(time_coeff)*(T))/5,0.01)

	// Adjust the build time of any item currently being built.
	if(being_built)
		var/last_const_time = build_finish - build_start
		var/new_const_time = get_construction_time_w_coeff(initial(being_built.construction_time))
		var/const_time_left = build_finish - world.time
		var/new_build_time = (new_const_time / last_const_time) * const_time_left
		build_finish = world.time + new_build_time

	update_static_data_for_all_viewers()

/obj/machinery/mecha_part_fabricator/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Storing up to <b>[rmat.local_size]</b> material units.<br>Material consumption at <b>[component_coeff*100]%</b>.<br>Build time reduced by <b>[100-time_coeff*100]%</b>.")
		. += span_notice("Currently configured to drop printed objects <b>[dir2text(drop_direction)]</b>.")

/obj/machinery/mecha_part_fabricator/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	if(!can_interact(user) || (!HAS_SILICON_ACCESS(user) && !isAdminGhostAI(user)) && !Adjacent(user))
		return
	if(being_built)
		balloon_alert(user, "printing started!")
		return
	var/direction = get_dir(src, over_location)
	if(!direction)
		return
	drop_direction = direction
	balloon_alert(user, "dropping [dir2text(drop_direction)]")

/**
 * Updates the `final_sets` and `buildable_parts` for the current mecha fabricator.
 */
/obj/machinery/mecha_part_fabricator/proc/update_menu_tech()
	var/previous_design_count = cached_designs.len

	cached_designs.Cut()
	for(var/v in stored_research.researched_designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(v)

		if(design.build_type & MECHFAB)
			cached_designs |= design

	var/design_delta = cached_designs.len - previous_design_count

	if(design_delta > 0)
		say("Received [design_delta] new design[design_delta == 1 ? "" : "s"].")
		playsound(src, 'sound/machines/beep/twobeep_high.ogg', 50, TRUE)

	update_static_data_for_all_viewers()

/**
 * Intended to be called when an item starts printing.
 *
 * Adds the overlay to show the fab working and sets active power usage settings.
 */
/obj/machinery/mecha_part_fabricator/proc/on_start_printing()
	add_overlay("fab-active")
	update_use_power(ACTIVE_POWER_USE)
	print_sound.start()
/**
 * Intended to be called when the exofab has stopped working and is no longer printing items.
 *
 * Removes the overlay to show the fab working and sets idle power usage settings. Additionally resets the description and turns off queue processing.
 */
/obj/machinery/mecha_part_fabricator/proc/on_finish_printing()
	cut_overlay("fab-active")
	update_use_power(IDLE_POWER_USE)
	desc = initial(desc)
	process_queue = FALSE
	print_sound.stop()

/**
 * Attempts to build the next item in the build queue.
 *
 * Returns FALSE if either there are no more parts to build or the next part is not buildable.
 * Returns TRUE if the next part has started building.
 * * verbose - Whether the machine should use say() procs. Set to FALSE to disable the machine saying reasons for failure to build.
 */
/obj/machinery/mecha_part_fabricator/proc/build_next_in_queue(verbose = TRUE)
	if(!length(queue))
		return FALSE

	var/alist/queue_record = queue[1]
	var/datum/design/D = queue_record["design"]
	var/alist/user_data = queue_record["user"]
	if(build_part(D, verbose, user_data))
		remove_from_queue(1)
		return TRUE

	return FALSE

/**
 * Starts the build process for a given design datum.
 *
 * Returns FALSE if the procedure fails. Returns TRUE when being_built is set.
 * Uses materials.
 * * D - Design datum to attempt to print.
 * * verbose - Whether the machine should use say() procs. Set to FALSE to disable the machine saying reasons for failure to build.
 * * user_data - ID_DATA(user), see the proc on SSid_access
 */
/obj/machinery/mecha_part_fabricator/proc/build_part(datum/design/D, verbose = TRUE, alist/user_data)
	if(!D || length(D.reagents_list))
		return FALSE

	var/datum/component/material_container/materials = rmat.mat_container
	if (!materials)
		if(verbose)
			say("No access to material storage, please contact the quartermaster.")
		return FALSE
	if (!rmat.can_use_resource(user_data = user_data))
		return FALSE
	if(!materials.has_materials(D.materials, component_coeff))
		if(verbose)
			say("Not enough resources. Processing stopped.")
		return FALSE

	rmat.use_materials(D.materials, component_coeff, 1, "processed", "[D.name]", user_data)
	being_built = D
	build_finish = world.time + get_construction_time_w_coeff(initial(D.construction_time))
	build_start = world.time
	desc = "It's building \a [D.name]."

	return TRUE

/obj/machinery/mecha_part_fabricator/process()
	// If there's a stored part to dispense due to an obstruction, try to dispense it.
	if(stored_part)
		var/turf/exit = get_step(src, drop_direction)
		if(exit.density)
			return TRUE

		say("Obstruction cleared. The fabrication of [stored_part] is now complete.")
		stored_part.forceMove(exit)
		stored_part = null

	// If there's nothing being built, try to build something
	if(!being_built)
		// If we're not processing the queue anymore or there's nothing to build, end processing.
		if(!process_queue || !build_next_in_queue())
			on_finish_printing()
			end_processing()
			return TRUE
		on_start_printing()

	// If there's an item being built, check if it is complete.
	if(being_built && (build_finish < world.time))
		// Then attempt to dispense it and if appropriate build the next item.
		dispense_built_part(being_built)
		if(process_queue)
			build_next_in_queue(FALSE)
		return TRUE

/**
 * Dispenses a part to the tile infront of the Exosuit Fab.
 *
 * Returns FALSE is the machine cannot dispense the part on the appropriate turf.
 * Return TRUE if the part was successfully dispensed.
 * * dispensed_design - Design datum to attempt to dispense.
 */
/obj/machinery/mecha_part_fabricator/proc/dispense_built_part(datum/design/dispensed_design)
	var/obj/item/built_part = new dispensed_design.build_path(src)
	SSblackbox.record_feedback("nested tally", "lathe_printed_items", 1, list("[type]", "[built_part.type]"))

	being_built = null

	var/turf/exit = get_step(src, drop_direction)
	if(exit.density)
		say("Error! The part outlet is obstructed.")
		desc = "It's trying to dispense the fabricated [dispensed_design.name], but the part outlet is obstructed."
		stored_part = built_part
		return FALSE

	say("The fabrication of [built_part] is now complete.")
	built_part.forceMove(exit)

	top_job_id += 1

	return TRUE

/**
 * Adds a datum design to the build queue.
 *
 * Returns TRUE if successful and FALSE if the design was not added to the queue.
 * * D - Datum design to add to the queue.
 * user_data - user data in the form rendered by ID_DATA(user), see the proc on SSidaccess
 */
/obj/machinery/mecha_part_fabricator/proc/add_to_queue(datum/design/D, alist/user_data)
	if(!istype(queue))
		queue = list()

	if(D)
		queue[++queue.len] = alist("design" = D, "user" = user_data)
		return TRUE

	return FALSE

/**
 * Removes datum design from the build queue based on index.
 *
 * Returns TRUE if successful and FALSE if a design was not removed from the queue.
 * * index - Index in the build queue of the element to remove.
 */
/obj/machinery/mecha_part_fabricator/proc/remove_from_queue(index)
	if(!isnum(index) || !ISINTEGER(index) || !istype(queue) || (index<1 || index>length(queue)))
		return FALSE
	queue.Cut(index,++index)
	return TRUE

/**
 * Calculates the coefficient-modified build time of a design.
 *
 * Returns coefficient-modified build time of a given design.
 * * D - Design datum to calculate the modified build time of.
 * * roundto - Rounding value for round() proc
 */
/obj/machinery/mecha_part_fabricator/proc/get_construction_time_w_coeff(construction_time, roundto = 1) //aran
	return round(construction_time*time_coeff, roundto)

/obj/machinery/mecha_part_fabricator/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/sheetmaterials),
		get_asset_datum(/datum/asset/spritesheet_batched/research_designs)
	)

/obj/machinery/mecha_part_fabricator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ExosuitFabricator")
		ui.open()

/obj/machinery/mecha_part_fabricator/ui_static_data(mob/user)
	var/list/data = rmat.mat_container.ui_static_data()

	var/list/designs = list()

	var/datum/asset/spritesheet_batched/research_designs/spritesheet = get_asset_datum(/datum/asset/spritesheet_batched/research_designs)
	var/size32x32 = "[spritesheet.name]32x32"

	for(var/datum/design/design in cached_designs)
		var/cost = list()
		var/list/materials = design.materials
		for(var/datum/material/mat in materials)
			cost[mat.name] = OPTIMAL_COST(materials[mat] * component_coeff)

		var/icon_size = spritesheet.icon_size_id(design.id)
		designs[design.id] = list(
			"name" = design.name,
			"desc" = design.get_description(),
			"cost" = cost,
			"id" = design.id,
			"categories" = design.category,
			"icon" = "[icon_size == size32x32 ? "" : "[icon_size] "][design.id]",
			"constructionTime" = get_construction_time_w_coeff(design.construction_time)
		)

	data["designs"] = designs

	return data

/obj/machinery/mecha_part_fabricator/ui_data(mob/user)
	var/list/data = list()

	data["materials"] = rmat.mat_container.ui_data()
	data["queue"] = list()
	data["processing"] = process_queue

	if(being_built)
		data["queue"] += list(list(
			"jobId" = top_job_id,
			"designId" = being_built.id,
			"processing" = TRUE,
			"timeLeft" = (build_finish - world.time)
		))

	var/offset = 0

	for(var/alist/queue_item in queue)
		offset += 1
		var/datum/design/design = queue_item["design"]

		data["queue"] += list(list(
			"jobId" = top_job_id + offset,
			"designId" = design.id,
			"processing" = FALSE,
			"timeLeft" = get_construction_time_w_coeff(design.construction_time) / 10
		))

	return data

/obj/machinery/mecha_part_fabricator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(.)
		return

	. = TRUE

	switch(action)
		if("build")
			if(!rmat.can_use_resource(user_data = ID_DATA(usr)))
				return
			var/designs = params["designs"]

			if(!islist(designs))
				return

			for(var/design_id in designs)
				if(!istext(design_id))
					continue

				if(!stored_research.researched_designs.Find(design_id))
					continue

				var/datum/design/design = SSresearch.techweb_design_by_id(design_id)

				if(!(design.build_type & MECHFAB) || design.id != design_id)
					continue

				add_to_queue(design, ID_DATA(usr))

			if(params["now"])
				if(process_queue)
					return

				process_queue = TRUE

				if(!being_built)
					begin_processing()

			return

		if("del_queue_part")
			// Delete a specific from the queue
			var/index = text2num(params["index"])
			remove_from_queue(index)

			return

		if("clear_queue")
			// Delete everything from queue
			queue.Cut()

			return

		if("build_queue")
			// Build everything in queue
			if(process_queue)
				return

			process_queue = TRUE

			if(!being_built)
				begin_processing()

			return

		if("stop_queue")
			// Pause queue building. Also known as stop.
			process_queue = FALSE

			return

		if("remove_mat")
			var/datum/material/material = locate(params["ref"])
			var/amount = text2num(params["amount"])
			// SAFETY: eject_sheets checks for valid mats
			rmat.eject_sheets(material, amount)
			return

	return FALSE

/obj/machinery/mecha_part_fabricator/proc/AfterMaterialInsert(item_inserted, id_inserted, amount_inserted)
	var/datum/material/M = id_inserted
	add_overlay("fab-load-[M.name]")
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, cut_overlay), "fab-load-[M.name]"), 1 SECONDS)

/obj/machinery/mecha_part_fabricator/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(being_built)
		to_chat(user, span_warning("\The [src] is currently processing! Please wait until completion."))
		return FALSE
	return default_deconstruction_screwdriver(user, "fab-o", "fab-idle", I)

/obj/machinery/mecha_part_fabricator/crowbar_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(being_built)
		to_chat(user, span_warning("\The [src] is currently processing! Please wait until completion."))
		return FALSE
	return default_deconstruction_crowbar(I)

/obj/machinery/mecha_part_fabricator/maint
	link_on_init = FALSE
