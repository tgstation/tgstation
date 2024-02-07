/obj/machinery/autolathe
	name = "autolathe"
	desc = "It produces items using iron, glass, plastic and maybe some more."
	icon = 'icons/obj/machines/lathes.dmi'
	icon_state = "autolathe"
	density = TRUE
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.5
	circuit = /obj/item/circuitboard/machine/autolathe
	layer = BELOW_OBJ_LAYER

	var/hacked = FALSE
	var/disabled = FALSE
	var/shocked = FALSE
	var/busy = FALSE

	/// Coefficient applied to consumed materials. Lower values result in lower material consumption.
	var/creation_efficiency = 1.6

	var/datum/design/being_built
	var/datum/techweb/autounlocking/stored_research

	///Designs imported from technology disks that we can print.
	var/list/imported_designs = list()

	///The container to hold materials
	var/datum/component/material_container/materials

	///direction we output onto (if 0, on top of us)
	var/drop_direction = 0

/obj/machinery/autolathe/Initialize(mapload)
	materials = AddComponent( \
		/datum/component/material_container, \
		SSmaterials.materials_by_category[MAT_CATEGORY_ITEM_MATERIAL], \
		0, \
		MATCONTAINER_EXAMINE, \
		container_signals = list(COMSIG_MATCONTAINER_ITEM_CONSUMED = TYPE_PROC_REF(/obj/machinery/autolathe, AfterMaterialInsert)) \
	)
	. = ..()

	set_wires(new /datum/wires/autolathe(src))
	if(!GLOB.autounlock_techwebs[/datum/techweb/autounlocking/autolathe])
		GLOB.autounlock_techwebs[/datum/techweb/autounlocking/autolathe] = new /datum/techweb/autounlocking/autolathe
	stored_research = GLOB.autounlock_techwebs[/datum/techweb/autounlocking/autolathe]

/obj/machinery/autolathe/Destroy()
	materials = null
	QDEL_NULL(wires)
	return ..()

/obj/machinery/autolathe/ui_interact(mob/user, datum/tgui/ui)
	if(!is_operational)
		return

	if(shocked && !(machine_stat & NOPOWER))
		shock(user, 50)

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Autolathe")
		ui.open()

/obj/machinery/autolathe/ui_static_data(mob/user)
	var/list/data = materials.ui_static_data()

	var/max_available = materials.total_amount()
	for(var/datum/material/container_mat as anything in materials.materials)
		var/available = materials.materials[container_mat]
		if(available)
			max_available = max(max_available, available)

	data["designs"] = handle_designs(stored_research.researched_designs, max_available)
	if(imported_designs.len)
		data["designs"] += handle_designs(imported_designs, max_available)
	if(hacked)
		data["designs"] += handle_designs(stored_research.hacked_designs, max_available)

	return data

/obj/machinery/autolathe/ui_data(mob/user)
	var/list/data = list()

	data["materials"] = list()
	data["materialtotal"] = materials.total_amount()
	data["materialsmax"] = materials.max_amount
	data["active"] = busy
	data["materials"] = materials.ui_data()

	return data

/obj/machinery/autolathe/proc/handle_designs(list/designs, max_available)
	var/list/output = list()

	var/datum/asset/spritesheet/research_designs/spritesheet = get_asset_datum(/datum/asset/spritesheet/research_designs)
	var/size32x32 = "[spritesheet.name]32x32"

	var/max_multiplier = INFINITY
	for(var/design_id in designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
		if(design.make_reagent)
			continue

		//compute cost & maximum number of printable items
		max_multiplier = INFINITY
		var/coeff = (ispath(design.build_path, /obj/item/stack) ? 1 : creation_efficiency)
		var/list/cost = list()
		for(var/i in design.materials)
			var/datum/material/mat = i

			var/design_cost = OPTIMAL_COST(design.materials[i] * coeff)
			if(istype(mat))
				cost[mat.name] = design_cost
			else
				cost[i] = design_cost

			var/mat_available
			if(istype(mat)) //regular mat
				mat_available = materials.get_material_amount(mat)
			else //category mat means we can make it from any mat, use largest available mat
				mat_available = max_available

			max_multiplier = min(max_multiplier, 50, round(mat_available / design_cost))

		//create & send ui data
		var/icon_size = spritesheet.icon_size_id(design.id)
		var/list/design_data = list(
			"name" = design.name,
			"desc" = design.get_description(),
			"cost" = cost,
			"id" = design.id,
			"categories" = design.category,
			"icon" = "[icon_size == size32x32 ? "" : "[icon_size] "][design.id]",
			"constructionTime" = -1,
			"maxmult" = max_multiplier
		)

		output += list(design_data)

	return output

/obj/machinery/autolathe/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/sheetmaterials),
		get_asset_datum(/datum/asset/spritesheet/research_designs),
	)

/obj/machinery/autolathe/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	if(action != "make")
		stack_trace("unknown autolathe ui_act: [action]")
		return

	if(disabled)
		say("Unable to print, voltage mismatch in internal wiring.")
		return

	if(busy)
		balloon_alert(ui.user, "busy!")
		return

	var/turf/target_location = get_step(src, drop_direction)
	if(isclosedturf(target_location))
		say("Output path is obstructed by a large object.")
		return

	var/design_id = params["id"]

	var/valid_design = stored_research.researched_designs[design_id]
	valid_design ||= stored_research.hacked_designs[design_id]
	valid_design ||= imported_designs[design_id]
	if(!valid_design)
		return

	var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
	if(isnull(design))
		stack_trace("got passed an invalid design id: [design_id] and somehow made it past all checks")
		return

	if(!(design.build_type & AUTOLATHE))
		return

	var/build_count = text2num(params["multiplier"])
	if(!build_count)
		return
	build_count = clamp(build_count, 1, 50)

	var/list/materials_needed = list()
	for(var/datum/material/material as anything in design.materials)
		var/amount_needed = design.materials[material]
		if(istext(material)) // category
			var/list/choices = list()
			for(var/datum/material/valid_candidate as anything in SSmaterials.materials_by_category[material])
				if(materials.get_material_amount(valid_candidate) < amount_needed)
					continue
				choices[valid_candidate.name] = valid_candidate
			if(!length(choices))
				say("No valid materials with applicable amounts detected for design.")
				return
			var/chosen = tgui_input_list(
				ui.user,
				"Select the material to use",
				"Material Selection",
				sort_list(choices),
			)
			if(isnull(chosen))
				return // user cancelled
			material = choices[chosen]

		if(isnull(material))
			stack_trace("got passed an invalid material id: [material]")
			return
		materials_needed[material] = amount_needed

	var/material_cost_coefficient = ispath(design.build_path, /obj/item/stack) ? 1 : creation_efficiency
	if(!materials.has_materials(materials_needed, material_cost_coefficient, build_count))
		say("Not enough materials to begin production.")
		return

	//use power
	var/total_charge = 0
	for(var/material in design.materials)
		total_charge += round(design.materials[material] * material_cost_coefficient * build_count)
	var/charge_per_item = total_charge / build_count

	var/total_time = (design.construction_time * design.lathe_time_factor * build_count) ** 0.8
	var/time_per_item = total_time / build_count
	start_making(design, build_count, time_per_item, material_cost_coefficient, charge_per_item)
	return TRUE

/// Begins the act of making the given design the given number of items
/// Does not check or use materials/power/etc
/obj/machinery/autolathe/proc/start_making(datum/design/design, build_count, build_time_per_item, material_cost_coefficient, charge_per_item)
	PROTECTED_PROC(TRUE)

	busy = TRUE
	icon_state = "autolathe_n"
	update_static_data_for_all_viewers()

	addtimer(CALLBACK(src, PROC_REF(do_make_item), design, material_cost_coefficient, build_time_per_item, charge_per_item, build_count), build_time_per_item)

/// Callback for start_making, actually makes the item
/// Called using timers started by start_making
/obj/machinery/autolathe/proc/do_make_item(datum/design/design, material_cost_coefficient, time_per_item, charge_per_item, items_remaining)
	PROTECTED_PROC(TRUE)

	if(!items_remaining) // how
		finalize_build()
		return

	if(!directly_use_power(charge_per_item))
		say("Unable to continue production, power failure.")
		finalize_build()
		return

	var/list/design_materials = design.materials
	var/is_stack = ispath(design.build_path, /obj/item/stack)
	if(!materials.has_materials(design_materials, material_cost_coefficient, is_stack ? items_remaining : 1))
		say("Unable to continue production, missing materials.")
		return
	materials.use_materials(design_materials, material_cost_coefficient, is_stack ? items_remaining : 1)

	var/turf/target = get_step(src, drop_direction)
	if(isclosedturf(target))
		target = get_turf(src)

	var/atom/movable/created
	if(is_stack)
		created = new design.build_path(target, items_remaining)
	else
		created = new design.build_path(target)
		split_materials_uniformly(design_materials, material_cost_coefficient, created)

	created.pixel_x = created.base_pixel_x + rand(-6, 6)
	created.pixel_y = created.base_pixel_y + rand(-6, 6)
	created.forceMove(target)

	if(is_stack)
		items_remaining = 0
	else
		items_remaining -= 1

	if(!items_remaining)
		finalize_build()
		return
	addtimer(CALLBACK(src, PROC_REF(do_make_item), design, material_cost_coefficient, time_per_item, items_remaining), time_per_item)

/// Resets the icon state and busy flag
/// Called at the end of do_make_item's timer loop
/obj/machinery/autolathe/proc/finalize_build()
	PROTECTED_PROC(TRUE)
	icon_state = initial(icon_state)
	busy = FALSE
	update_static_data_for_all_viewers()

/obj/machinery/autolathe/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/autolathe/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/autolathe/attackby(obj/item/attacking_item, mob/living/user, params)
	if(user.combat_mode) //so we can hit the machine
		return ..()

	if(busy)
		balloon_alert(user, "it's busy!")
		return TRUE

	if(panel_open && is_wire_tool(attacking_item))
		wires.interact(user)
		return TRUE

	if(machine_stat)
		return TRUE

	if(istype(attacking_item, /obj/item/disk/design_disk))
		user.visible_message(span_notice("[user] begins to load \the [attacking_item] in \the [src]..."),
			balloon_alert(user, "uploading design..."),
			span_hear("You hear the chatter of a floppy drive."))
		busy = TRUE
		if(do_after(user, 14.4, target = src))
			var/obj/item/disk/design_disk/disky = attacking_item
			var/list/not_imported
			for(var/datum/design/blueprint as anything in disky.blueprints)
				if(!blueprint)
					continue
				if(blueprint.build_type & AUTOLATHE)
					imported_designs[blueprint.id] = TRUE
				else
					LAZYADD(not_imported, blueprint.name)
			if(not_imported)
				to_chat(user, span_warning("The following design[length(not_imported) > 1 ? "s" : ""] couldn't be imported: [english_list(not_imported)]"))
		busy = FALSE
		update_static_data_for_all_viewers()
		return TRUE

	if(panel_open)
		balloon_alert(user, "close the panel first!")
		return FALSE

	return ..()

/obj/machinery/autolathe/proc/AfterMaterialInsert(container, obj/item/item_inserted, last_inserted_id, mats_consumed, amount_inserted, atom/context)
	SIGNAL_HANDLER

	flick("autolathe_[item_inserted.has_material_type(/datum/material/glass) ? "r" : "o"]", src)

	use_power(min(active_power_usage * 0.25, amount_inserted / SHEET_MATERIAL_AMOUNT))

	update_static_data_for_all_viewers()

/obj/machinery/autolathe/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if((!issilicon(usr) && !isAdminGhostAI(usr)) && !Adjacent(usr))
		return
	var/direction = get_dir(src, over_location)
	if(!direction)
		return
	drop_direction = direction
	balloon_alert(usr, "dropping [dir2text(drop_direction)]")

/obj/machinery/autolathe/RefreshParts()
	. = ..()
	var/mat_capacity = 0
	for(var/datum/stock_part/matter_bin/new_matter_bin in component_parts)
		mat_capacity += new_matter_bin.tier * (37.5*SHEET_MATERIAL_AMOUNT)
	materials.max_amount = mat_capacity

	var/efficiency=1.8
	for(var/datum/stock_part/servo/new_servo in component_parts)
		efficiency -= new_servo.tier * 0.2
	creation_efficiency = max(1,efficiency) // creation_efficiency goes 1.6 -> 1.4 -> 1.2 -> 1 per level of servo efficiency

/obj/machinery/autolathe/examine(mob/user)
	. += ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Storing up to <b>[materials.max_amount]</b> material units.<br>Material consumption at <b>[creation_efficiency*100]%</b>.")
		if(drop_direction)
			. += span_notice("Currently configured to drop printed objects <b>[dir2text(drop_direction)]</b>.")
			. += span_notice("<b>Alt-click</b> to reset.")
		else
			. += span_notice("<b>Drag towards a direction</b> (while next to it) to change drop direction.")

/obj/machinery/autolathe/AltClick(mob/user)
	. = ..()
	if(!can_interact(user))
		return
	if(drop_direction)
		balloon_alert(user, "drop direction reset")
		drop_direction = 0

/obj/machinery/autolathe/proc/reset(wire)
	switch(wire)
		if(WIRE_HACK)
			if(!wires.is_cut(wire))
				adjust_hacked(FALSE)
		if(WIRE_SHOCK)
			if(!wires.is_cut(wire))
				shocked = FALSE
		if(WIRE_DISABLE)
			if(!wires.is_cut(wire))
				disabled = FALSE

/obj/machinery/autolathe/proc/shock(mob/user, prb)
	if(machine_stat & (BROKEN|NOPOWER)) // unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	return electrocute_mob(user, get_area(src), src, 0.7, TRUE)

/obj/machinery/autolathe/proc/adjust_hacked(state)
	hacked = state
	update_static_data_for_all_viewers()

/obj/machinery/autolathe/hacked/Initialize(mapload)
	. = ..()
	adjust_hacked(TRUE)
