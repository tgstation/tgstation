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

/obj/machinery/autolathe/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if(action == "make")
		if(disabled)
			say("The autolathe wires are disabled.")
			return
		if(busy)
			say("The autolathe is busy. Please wait for completion of previous operation.")
			return

		if(isclosedturf(get_step(src, drop_direction)))
			say("Output is obstructed.")
			return

		var/design_id = params["id"]
		if(!istext(design_id))
			return
		if(!stored_research.researched_designs.Find(design_id) && !stored_research.hacked_designs.Find(design_id) && !imported_designs.Find(design_id))
			return
		var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
		if(!(design.build_type & AUTOLATHE) || design.id != design_id)
			return

		being_built = design
		var/is_stack = ispath(being_built.build_path, /obj/item/stack)
		var/coeff = (is_stack ? 1 : creation_efficiency) // Stacks are unaffected by production coefficient

		var/multiplier = round(text2num(params["multiplier"]))
		if(!multiplier || !IS_FINITE(multiplier))
			return
		multiplier = clamp(multiplier, 1, 50)

		//check for materials
		var/list/materials_used = list()
		var/list/custom_materials = list() // These will apply their material effect, should usually only be one.
		for(var/mat in being_built.materials)
			var/datum/material/used_material = mat

			var/amount_needed = being_built.materials[mat]
			if(istext(used_material)) // This means its a category
				var/list/list_to_show = list()
				//list all materials in said category
				for(var/i in SSmaterials.materials_by_category[used_material])
					if(materials.materials[i] > 0)
						list_to_show += i
				//ask user to pick specific material from list
				used_material = tgui_input_list(
					usr,
					"Choose [used_material]",
					"Custom Material",
					sort_list(list_to_show, GLOBAL_PROC_REF(cmp_typepaths_asc))
				)
				if(isnull(used_material))
					return
				//the item composition will be made of these materials
				custom_materials[used_material] += amount_needed
			materials_used[used_material] = amount_needed

		if(!materials.has_materials(materials_used, coeff, multiplier))
			say("Not enough materials for this operation!.")
			return

		//use power
		var/total_amount = 0
		for(var/material in being_built.materials)
			total_amount += being_built.materials[material]
		use_power(max(active_power_usage, (total_amount) * multiplier / 5))

		//use materials
		materials.use_materials(materials_used, coeff, multiplier)
		to_chat(usr, span_notice("You print [multiplier] item(s) from the [src]"))
		update_static_data_for_all_viewers()

		//print item
		icon_state = "autolathe_n"
		var/time_per_item = is_stack ? 32 : ((32 * coeff * multiplier) ** 0.8) / multiplier
		make_items(custom_materials, multiplier, is_stack, usr, time_per_item)

		return TRUE

/obj/machinery/autolathe/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/autolathe/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", tool))
		return TOOL_ACT_TOOLTYPE_SUCCESS

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
					imported_designs += blueprint.id
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

	use_power(min(active_power_usage * 0.25, amount_inserted / 100))

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

/obj/machinery/autolathe/proc/make_items(list/picked_materials, multiplier, is_stack, mob/user, time_per_item)
	var/atom/our_loc = drop_location()
	var/atom/drop_loc = get_step(src, drop_direction)

	busy = TRUE
	SStgui.update_uis(src) //so ui immediatly knows its busy
	while(multiplier > 0)
		if(!busy)
			break
		stoplag(time_per_item)
		var/obj/item/new_item
		if(is_stack)
			new_item = new being_built.build_path(our_loc, multiplier)
		else
			new_item = new being_built.build_path(our_loc)

			//custom materials for toolboxes
			if(length(picked_materials))
				new_item.set_custom_materials(picked_materials) //Ensure we get the non multiplied amount
				for(var/datum/material/mat in picked_materials)
					if(!istype(mat, /datum/material/glass) && !istype(mat, /datum/material/iron))
						user.client.give_award(/datum/award/achievement/misc/getting_an_upgrade, user)

		//no need to call if ontop of us
		if(drop_direction)
			new_item.Move(drop_loc)
		//multiplier already applied in stack initialization. work done
		if(is_stack)
			break

		multiplier--

	icon_state = "autolathe"
	busy = FALSE

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
	if (electrocute_mob(user, get_area(src), src, 0.7, TRUE))
		return TRUE
	else
		return FALSE

/obj/machinery/autolathe/proc/adjust_hacked(state)
	hacked = state
	update_static_data_for_all_viewers()

/obj/machinery/autolathe/hacked/Initialize(mapload)
	. = ..()
	adjust_hacked(TRUE)
