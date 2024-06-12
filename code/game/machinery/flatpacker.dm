#define CREATE_AND_INCREMENT(L, I, increment) if(!(I in L)) { L[I] = 0; } L[I] += increment;
/obj/machinery/flatpacker
	name = "flatpacker"
	desc = "It produces items using iron, glass, plastic and maybe some more."
	icon = 'icons/obj/machines/lathes.dmi'
	base_icon_state = "flatpacker"
	icon_state = "flatpacker"
	density = TRUE
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION
	circuit = /obj/item/circuitboard/machine/flatpacker

	/// Are we busy printing?
	var/busy = FALSE
	/// Coefficient applied to consumed materials. Lower values result in lower material consumption.
	var/creation_efficiency = 2
	///The container to hold materials
	var/datum/component/material_container/materials
	/// The inserted board
	var/obj/item/circuitboard/machine/inserted_board
	/// Materials needed to print this board
	var/list/needed_mats = list()
	/// The highest tier of this board
	var/print_tier = 1
	/// Our max print tier
	var/max_part_tier = 1
	/// time needed to produce a flatpacked machine
	var/flatpack_time = 4.5 SECONDS

/obj/machinery/flatpacker/Initialize(mapload)
	materials = AddComponent( \
		/datum/component/material_container, \
		SSmaterials.materials_by_category[MAT_CATEGORY_SILO], \
		0, \
		MATCONTAINER_EXAMINE, \
		container_signals = list(COMSIG_MATCONTAINER_ITEM_CONSUMED = TYPE_PROC_REF(/obj/machinery/flatpacker, AfterMaterialInsert)) \
	)
	return ..()

/obj/machinery/flatpacker/RefreshParts()
	. = ..()
	var/mat_capacity = 0
	for(var/datum/stock_part/matter_bin/new_matter_bin in component_parts)
		mat_capacity += new_matter_bin.tier * 25 * SHEET_MATERIAL_AMOUNT
	materials.max_amount = mat_capacity

	var/datum/stock_part/servo/servo = locate() in component_parts
	max_part_tier = servo.tier
	flatpack_time = initial(flatpack_time) - servo.tier / 2 // T4 = 2 seconds off
	var/efficiency = initial(creation_efficiency)
	for(var/datum/stock_part/micro_laser/laser in component_parts)
		efficiency -= laser.tier * 0.2
	creation_efficiency = max(1.2, efficiency)

/obj/machinery/flatpacker/examine(mob/user)
	. += ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads:")
		. += span_notice("Capable of packing up to <b>Tier [max_part_tier]</b>.")
		. += span_notice("Storing up to <b>[materials.max_amount]</b> material units.")
		. += span_notice("Material consumption at <b>[creation_efficiency*100]%</b>")

/obj/machinery/flatpacker/proc/AfterMaterialInsert(container, obj/item/item_inserted, last_inserted_id, mats_consumed, amount_inserted, atom/context)
	SIGNAL_HANDLER

	flick_overlay_view("[base_icon_state]_[item_inserted.has_material_type(/datum/material/glass) ? "glass" : "metal"]", 1.4 SECONDS)

	directly_use_energy(min(active_power_usage * 0.25, amount_inserted / 100))

/obj/machinery/flatpacker/update_overlays()
	. = ..()

	if(!isnull(inserted_board))
		. += mutable_appearance(icon, "[base_icon_state]_c")

/obj/machinery/flatpacker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Flatpacker")
		ui.open()

/obj/machinery/flatpacker/ui_static_data(mob/user)
	return materials.ui_static_data()

/obj/machinery/flatpacker/ui_data(mob/user)
	var/list/data = list()

	var/atom/build = initial(inserted_board.build_path)
	data["materials"] = materials.ui_data()
	data["boardInserted"] = !isnull(inserted_board)
	data["busy"] = busy
	var/list/cost_mats = list()
	for(var/datum/material/mat_type as anything in needed_mats)
		var/list/new_entry = list()
		new_entry["name"] = initial(mat_type.name)
		new_entry["amount"] = needed_mats[mat_type]
		cost_mats += list(new_entry)

	var/list/design
	if(data["boardInserted"])
		var/disableReason = ""
		var/has_materials = materials.has_materials(needed_mats, creation_efficiency)
		if(!has_materials)
			disableReason += "Not enough materials. "
		if(print_tier > max_part_tier)
			disableReason += "This design is too advanced for this machine. "
		design = list(
			"name" = initial(build.name),
			"requiredMaterials" = cost_mats,
			"icon" = icon2base64(icon(initial(build.icon), initial(build.icon_state), frame = 1)),
			"canPrint" = has_materials && print_tier <= max_part_tier,
			"disableReason" = disableReason
		)
	data["design"] = design
	return data

/obj/machinery/flatpacker/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/sheetmaterials),
		get_asset_datum(/datum/asset/spritesheet/research_designs),
	)

/obj/machinery/flatpacker/item_interaction(mob/living/user, obj/item/attacking_item, params)
	if(istype(attacking_item, /obj/item/circuitboard/machine))
		if(busy)
			balloon_alert(user, "busy!")
			return ITEM_INTERACT_BLOCKING
		if (!user.transferItemToLoc(attacking_item, src))
			return ITEM_INTERACT_BLOCKING
		// If insertion was successful and there's already a diskette in the console, eject the old one.
		if(inserted_board)
			inserted_board.forceMove(drop_location())

		inserted_board = attacking_item
		// 5 sheets of iron and 5 of cable coil
		needed_mats = list()
		for(var/type as anything in inserted_board.req_components)
			needed_mats = analyze_cost(type, needed_mats)

		CREATE_AND_INCREMENT(needed_mats, /datum/material/iron, (SHEET_MATERIAL_AMOUNT * 5 + (SHEET_MATERIAL_AMOUNT / 20)))
		CREATE_AND_INCREMENT(needed_mats, /datum/material/glass, (SHEET_MATERIAL_AMOUNT / 20))

		update_appearance()
		return ITEM_INTERACT_SUCCESS

	return NONE

/**
 * Attempts to find the total material cost of a typepath (including our creation efficiency), modifying a list
 * The list is modified as an assoc list: Material datum typepath = Cost
 * If the type is found on a techweb, uses material costs from there
 * Otherwise, the typepath is created in nullspace and fetches materials from the initialized one, then deleted.
 *
 * Args:
 * type - Typepath of the item we are trying to find the costs of
 * costs - Assoc list we modify and return
 */
/obj/machinery/flatpacker/proc/analyze_cost(type, costs)
	var/comp_type = type
	if(ispath(type, /datum/stock_part))
		var/datum/stock_part/as_part = type
		comp_type = initial(as_part.physical_object_type)
		if(as_part.tier > print_tier)
			print_tier = as_part.tier

	var/by_techweb = !isnull(SSresearch.item_to_design[comp_type])
	var/obj/item/null_comp = by_techweb ? null : new comp_type
	var/list/mat_list = by_techweb ? SSresearch.item_to_design[comp_type][1].materials : null_comp.custom_materials
	for(var/atom/mat as anything in mat_list)
		var/mat_type = mat.type

		CREATE_AND_INCREMENT(costs, mat_type, mat_list[mat] * inserted_board.req_components[type])

	qdel(null_comp)
	return costs

/// Start building the currently inserted board, if possible
/obj/machinery/flatpacker/proc/start_build()
	. = FALSE
	if(!inserted_board)
		return
	if(!materials.has_materials(needed_mats, creation_efficiency))
		say("Not enough materials to begin production.")
		return
	if(print_tier > max_part_tier)
		say("Design too complex.")
		return
	materials.use_materials(needed_mats, creation_efficiency)
	playsound(src, 'sound/items/rped.ogg', 50, TRUE)
	busy = TRUE

	addtimer(CALLBACK(src, PROC_REF(finish_build), inserted_board), flatpack_time)
	return TRUE

/// turns the supplied board into a flatpack, and sets the machine as not busy
/obj/machinery/flatpacker/proc/finish_build(board)
	busy = FALSE
	new /obj/item/flatpack(drop_location(), board)

/obj/machinery/flatpacker/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == inserted_board)
		inserted_board = null
		needed_mats = null
		print_tier = 1
		update_appearance()

/obj/machinery/flatpacker/ui_act(action, list/params)
	. = ..()

	if(.)
		return


	switch(action)
		if("build")
			if(busy)
				return FALSE
			start_build()
			return TRUE

		if("ejectBoard")
			inserted_board.forceMove(drop_location())
			return TRUE

		if("eject")
			var/datum/material/ejecting = locate(params["ref"])
			var/amount = text2num(params["amount"])
			if(!isnum(amount) || !istype(ejecting))
				return FALSE

			materials.retrieve_sheets(amount, ejecting, drop_location())
			return TRUE


/obj/machinery/flatpacker/Destroy()
	QDEL_NULL(inserted_board)
	. = ..()

/obj/item/flatpack
	name = "flatpack"
	desc = "A box containing a compacted packed machine. Use multitool to deploy."
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "flatpack"
	w_class = WEIGHT_CLASS_HUGE //cart time
	throw_range = 2
	item_flags = SLOWS_WHILE_IN_HAND | IMMUTABLE_SLOW
	slowdown = 2.5
	drag_slowdown = 3.5 //use the cart stupid
	/// The board we deploy
	var/obj/item/circuitboard/machine/board

/obj/item/flatpack/Initialize(mapload, obj/item/circuitboard/machine/board)
	. = ..()
	if(!isnull(board))
		src.board = board // i got board
		board.forceMove(src)
		var/obj/machinery/build = initial(board.build_path)
		name += " ([initial(build.name)])"

/obj/item/flatpack/Destroy()
	QDEL_NULL(board)
	. = ..()

/obj/item/flatpack/multitool_act(mob/living/user, obj/item/tool)
	. = NONE
	if(isnull(board))
		return ITEM_INTERACT_BLOCKING
	if(!isopenturf(loc))
		user.balloon_alert(user, "cant deploy here!")
		return ITEM_INTERACT_BLOCKING
	balloon_alert_to_viewers("deploying!")
	if(!do_after(user, 1 SECONDS, target = src))
		return ITEM_INTERACT_BLOCKING
	new /obj/effect/temp_visual/mook_dust(loc)
	var/obj/machinery/new_machine = new board.build_path(loc)
	loc.visible_message(span_warning("[src] deploys!"))
	playsound(src, 'sound/machines/terminal_eject.ogg', 70, TRUE)
	new_machine.RefreshParts()
	new_machine.on_construction(user)

	for(var/mob/living/victim in loc)
		step(victim, pick(GLOB.cardinals))

	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/flatpack_cart
	name = "flatpack cart"
	desc = "A cart specifically made to hold flatpacks from a flatpacker, evenly distributing weight. Convenient!"
	icon = 'icons/obj/structures.dmi'
	icon_state = "flatcart"
	density = TRUE
	opacity = FALSE
	/// max flatpacks
	var/max_flatpacks = 3

/obj/structure/flatpack_cart/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noisy_movement, volume = 45) // i hate noise

/obj/structure/flatpack_cart/atom_destruction(damage_flag)
	for(var/atom/movable/content as anything in contents)
		content.forceMove(drop_location())
	return ..()

/obj/structure/flatpack_cart/examine(mob/user)
	. = ..()
	. += "From bottom to top, this cart contains:"
	for(var/obj/item/flatpack as anything in contents)
		. += flatpack.name

/obj/structure/flatpack_cart/update_overlays()
	. = ..()

	var/offset = 0
	for(var/item in contents)
		var/mutable_appearance/flatpack_overlay = mutable_appearance(icon, "flatcart_flat", layer = layer + (offset * 0.01))
		flatpack_overlay.pixel_y = offset
		offset += 4
		. += flatpack_overlay

/obj/structure/flatpack_cart/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.put_in_hands(contents[length(contents)]) //topmost box
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/flatpack_cart/item_interaction(mob/living/user, obj/item/attacking_item, params)
	if(!istype(attacking_item, /obj/item/flatpack))
		return NONE
	if (length(contents) >= max_flatpacks)
		balloon_alert(user, "full!")
		return ITEM_INTERACT_BLOCKING
	if (!user.transferItemToLoc(attacking_item, src))
		return ITEM_INTERACT_BLOCKING
	update_appearance(UPDATE_OVERLAYS)
	return ITEM_INTERACT_SUCCESS

#undef CREATE_AND_INCREMENT
