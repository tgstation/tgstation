/obj/machinery/autolathe
	name = "autolathe"
	desc = "It produces items using iron, glass, plastic and maybe some more."
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

/obj/machinery/autolathe/Initialize(mapload)
	AddComponent(/datum/component/material_container, SSmaterials.materials_by_category[MAT_CATEGORY_ITEM_MATERIAL], 0, MATCONTAINER_EXAMINE, _after_insert = CALLBACK(src, PROC_REF(AfterMaterialInsert)))
	. = ..()
	wires = new /datum/wires/autolathe(src)
	if(!GLOB.autounlock_techwebs[/datum/techweb/autounlocking/autolathe])
		GLOB.autounlock_techwebs[/datum/techweb/autounlocking/autolathe] = new /datum/techweb/autounlocking/autolathe
	stored_research = GLOB.autounlock_techwebs[/datum/techweb/autounlocking/autolathe]

/obj/machinery/autolathe/Destroy()
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
	var/list/data = list()

	data["designs"] = handle_designs(stored_research.researched_designs)
	if(imported_designs.len)
		data["designs"] += handle_designs(imported_designs)
	if(hacked)
		data["designs"] += handle_designs(stored_research.hacked_designs)

	return data

/obj/machinery/autolathe/ui_data(mob/user)
	var/list/data = list()

	data["materials"] = list()

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

	data["materialtotal"] = materials.total_amount
	data["materialsmax"] = materials.max_amount
	data["active"] = busy
	data["materials"] = materials.ui_data()

	return data

/obj/machinery/autolathe/proc/handle_designs(list/designs)
	var/list/output = list()

	var/datum/asset/spritesheet/research_designs/spritesheet = get_asset_datum(/datum/asset/spritesheet/research_designs)
	var/size32x32 = "[spritesheet.name]32x32"

	for(var/design_id in designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(design_id)

		var/unbuildable = FALSE // we can't build the design currently
		var/m10 = FALSE // 10x mult
		var/m25 = FALSE // 25x mult
		var/m50 = FALSE // 50x mult
		var/m5 = FALSE // 5x mult
		var/sheets = FALSE // sheets or no?

		if(disabled || !can_build(design))
			unbuildable = TRUE

		var/max_multiplier = unbuildable ? 0 : 1

		if(ispath(design.build_path, /obj/item/stack))
			sheets = TRUE

			if(!unbuildable)
				var/datum/component/material_container/mats = GetComponent(/datum/component/material_container)

				for(var/datum/material/mat in design.materials)
					max_multiplier = min(design.maxstack, round(mats.get_material_amount(mat) / design.materials[mat]))
				if (max_multiplier >= 10 && !disabled)
					m10 = TRUE
				if (max_multiplier >= 25 && !disabled)
					m25 = TRUE
		else
			if(!unbuildable)
				if(!disabled && can_build(design, 5))
					m5 = TRUE
				if(!disabled && can_build(design, 10))
					m10 = TRUE

				var/datum/component/material_container/mats = GetComponent(/datum/component/material_container)

				for(var/datum/material/mat in design.materials)
					max_multiplier = min(50, round(mats.get_material_amount(mat) / (design.materials[mat] * creation_efficiency)))

		var/icon_size = spritesheet.icon_size_id(design.id)

		var/list/design_data = list(
			"name" = design.name,
			"desc" = design.get_description(),
			"cost" = get_design_cost(design),
			"id" = design.id,
			"categories" = design.category,
			"icon" = "[icon_size == size32x32 ? "" : "[icon_size] "][design.id]",
			"constructionTime" = -1,

			"buildable" = unbuildable,
			"mult5" = m5,
			"mult10" = m10,
			"mult25" = m25,
			"mult50" = m50,
			"sheet" = sheets,
			"maxmult" = max_multiplier,
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
		var/design_id = params["id"]
		if(!istext(design_id))
			return

		if(!stored_research.researched_designs.Find(design_id) && !stored_research.hacked_designs.Find(design_id) && !imported_designs.Find(design_id))
			return

		var/datum/design/design = SSresearch.techweb_design_by_id(design_id)

		if(!(design.build_type & AUTOLATHE) || design.id != design_id)
			return

		if (busy)
			to_chat(usr, span_alert("The autolathe is busy. Please wait for completion of previous operation."))
			return

		being_built = design

		var/multiplier = round(text2num(params["multiplier"]))

		if(!multiplier || !IS_FINITE(multiplier))
			return

		var/is_stack = ispath(being_built.build_path, /obj/item/stack)
		multiplier = clamp(multiplier, 1, 50)

		var/coeff = (is_stack ? 1 : creation_efficiency) // Stacks are unaffected by production coefficient
		var/total_amount = 0

		for(var/material in being_built.materials)
			total_amount += being_built.materials[material]

		var/power = max(active_power_usage, (total_amount)*multiplier/5) // Change this to use all materials

		var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

		var/list/materials_used = list()
		var/list/custom_materials = list() // These will apply their material effect, should usually only be one.

		for(var/mat in being_built.materials)
			var/datum/material/used_material = mat
			var/amount_needed = being_built.materials[mat] * coeff * multiplier

			if(istext(used_material)) // This means its a category
				var/list/list_to_show = list()

				for(var/i in SSmaterials.materials_by_category[used_material])
					if(materials.materials[i] > 0)
						list_to_show += i

				used_material = tgui_input_list(
					usr,
					"Choose [used_material]",
					"Custom Material",
					sort_list(list_to_show, GLOBAL_PROC_REF(cmp_typepaths_asc))
				)

				if(isnull(used_material))
					// Didn't pick any material, so you can't build shit either.
					return

				custom_materials[used_material] += amount_needed

			materials_used[used_material] = amount_needed

		if(materials.has_materials(materials_used))
			busy = TRUE
			to_chat(usr, span_notice("You print [multiplier] item(s) from the [src]"))
			use_power(power)
			icon_state = "autolathe_n"
			var/time = is_stack ? 32 : (32 * coeff * multiplier) ** 0.8
			addtimer(CALLBACK(src, PROC_REF(make_item), power, materials_used, custom_materials, multiplier, coeff, is_stack, usr), time)
			. = TRUE
		else
			to_chat(usr, span_alert("Not enough materials for this operation."))

/obj/machinery/autolathe/on_deconstruction()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()

/obj/machinery/autolathe/attackby(obj/item/attacking_item, mob/living/user, params)
	if(busy)
		balloon_alert(user, "it's busy!")
		return TRUE

	if(default_deconstruction_crowbar(attacking_item))
		return TRUE

	if(panel_open && is_wire_tool(attacking_item))
		wires.interact(user)
		return TRUE

	if(user.combat_mode) //so we can hit the machine
		return ..()

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

	if(istype(attacking_item, /obj/item/storage/bag/trash))
		for(var/obj/item/content_item in attacking_item.contents)
			if(!do_after(user, 0.5 SECONDS, src))
				return FALSE
			attackby(content_item, user)
		return TRUE

	return ..()

/obj/machinery/autolathe/attackby_secondary(obj/item/weapon, mob/living/user, params)
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(busy)
		balloon_alert(user, "it's busy!")
		return

	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", weapon))
		return

	if(machine_stat)
		return SECONDARY_ATTACK_CALL_NORMAL

	if(panel_open)
		balloon_alert(user, "close the panel first!")
		return

	return SECONDARY_ATTACK_CALL_NORMAL

/obj/machinery/autolathe/proc/AfterMaterialInsert(obj/item/item_inserted, id_inserted, amount_inserted)
	if(istype(item_inserted, /obj/item/stack/ore/bluespace_crystal))
		use_power(MINERAL_MATERIAL_AMOUNT / 10)
	else if(item_inserted.has_material_type(/datum/material/glass))
		flick("autolathe_r", src)//plays glass insertion animation by default otherwise
	else
		flick("autolathe_o", src)//plays metal insertion animation

		use_power(min(active_power_usage * 0.25, amount_inserted / 100))

/obj/machinery/autolathe/proc/make_item(power, list/materials_used, list/picked_materials, multiplier, coeff, is_stack, mob/user)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/atom/A = drop_location()
	use_power(power)

	materials.use_materials(materials_used)

	if(is_stack)
		var/obj/item/stack/N = new being_built.build_path(A, multiplier, FALSE)
		N.update_appearance()
	else
		for(var/i in 1 to multiplier)
			var/obj/item/new_item = new being_built.build_path(A)

			if(length(picked_materials))
				new_item.set_custom_materials(picked_materials, 1 / multiplier) //Ensure we get the non multiplied amount
				for(var/x in picked_materials)
					var/datum/material/M = x
					if(!istype(M, /datum/material/glass) && !istype(M, /datum/material/iron))
						user.client.give_award(/datum/award/achievement/misc/getting_an_upgrade, user)


	icon_state = "autolathe"
	busy = FALSE

/obj/machinery/autolathe/RefreshParts()
	. = ..()
	var/mat_capacity = 0
	for(var/datum/stock_part/matter_bin/new_matter_bin in component_parts)
		mat_capacity += new_matter_bin.tier * 75000
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.max_amount = mat_capacity

	var/efficiency=1.8
	for(var/datum/stock_part/manipulator/new_manipulator in component_parts)
		efficiency -= new_manipulator.tier * 0.2
	creation_efficiency = max(1,efficiency) // creation_efficiency goes 1.6 -> 1.4 -> 1.2 -> 1 per level of manipulator efficiency

/obj/machinery/autolathe/examine(mob/user)
	. += ..()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Storing up to <b>[materials.max_amount]</b> material units.<br>Material consumption at <b>[creation_efficiency*100]%</b>.")

/obj/machinery/autolathe/proc/can_build(datum/design/D, amount = 1)
	if(D.make_reagent)
		return FALSE

	var/coeff = (ispath(D.build_path, /obj/item/stack) ? 1 : creation_efficiency)

	var/list/required_materials = list()

	for(var/i in D.materials)
		required_materials[i] = D.materials[i] * coeff * amount

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

	return materials.has_materials(required_materials)


/obj/machinery/autolathe/proc/get_design_cost(datum/design/design)
	var/coeff = (ispath(design.build_path, /obj/item/stack) ? 1 : creation_efficiency)
	var/list/cost = list()

	for(var/material in design.materials)
		if (istext(material))
			// Wildcard materials
			cost[material] = design.materials[material] * coeff
		else
			var/datum/material/cast = material
			cost[cast.name] = design.materials[cast] * coeff

	return cost

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
