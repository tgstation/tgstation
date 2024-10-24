///Incremets an an value assosiated by an key in the list creating that value if nessassary
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
	register_context()

	materials = AddComponent( \
		/datum/component/material_container, \
		SSmaterials.materials_by_category[MAT_CATEGORY_SILO], \
		0, \
		MATCONTAINER_EXAMINE, \
		container_signals = list(COMSIG_MATCONTAINER_ITEM_CONSUMED = TYPE_PROC_REF(/obj/machinery/flatpacker, AfterMaterialInsert)) \
	)

	return ..()

/obj/machinery/flatpacker/Destroy()
	materials = null
	QDEL_NULL(inserted_board)
	. = ..()

/obj/machinery/flatpacker/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(!QDELETED(inserted_board))
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Eject board"
		. = CONTEXTUAL_SCREENTIP_SET

	if(!isnull(held_item))
		if(istype(held_item, /obj/item/circuitboard/machine))
			context[SCREENTIP_CONTEXT_LMB] = "Insert board"
			return CONTEXTUAL_SCREENTIP_SET
		else if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] panel"
			return CONTEXTUAL_SCREENTIP_SET
		else if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
			context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
			return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/flatpacker/examine(mob/user)
	. += ..()
	if(!in_range(user, src) && !isobserver(user))
		return

	. += span_notice("The status display reads:")
	. += span_notice("Capable of packing up to <b>Tier [max_part_tier]</b>.")
	. += span_notice("Storing up to <b>[materials.max_amount]</b> material units.")
	. += span_notice("Material consumption at <b>[creation_efficiency * 100]%</b>")

	. += span_notice("Its maintainence panel can be [EXAMINE_HINT("screwed")] [panel_open ? "close" : "open"]")
	if(panel_open)
		. += span_notice("It can be [EXAMINE_HINT("pried")] apart")
	if(!QDELETED(inserted_board))
		. += span_notice("The board can be ejected via [EXAMINE_HINT("Ctrl Click")]")

/obj/machinery/flatpacker/update_overlays()
	. = ..()

	if(!QDELETED(inserted_board))
		. += mutable_appearance(icon, "[base_icon_state]_c")

/obj/machinery/flatpacker/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == inserted_board)
		inserted_board = null
		needed_mats.Cut()
		print_tier = 1
		update_appearance(UPDATE_OVERLAYS)

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

/obj/machinery/flatpacker/proc/AfterMaterialInsert(container, obj/item/item_inserted, last_inserted_id, mats_consumed, amount_inserted, atom/context)
	SIGNAL_HANDLER

	//we use initial(active_power_usage) because higher tier parts will have higher active usage but we have no benefit from it
	if(directly_use_energy(ROUND_UP((amount_inserted / (MAX_STACK_SIZE * SHEET_MATERIAL_AMOUNT)) * 0.4 * initial(active_power_usage))))
		flick_overlay_view(mutable_appearance('icons/obj/machines/lathes.dmi', "flatpacker_bar"), 1 SECONDS)

		var/datum/material/highest_mat_ref
		var/highest_mat = 0
		for(var/datum/material/mat as anything in mats_consumed)
			var/present_mat = mats_consumed[mat]
			if(present_mat > highest_mat)
				highest_mat = present_mat
				highest_mat_ref = mat

		flick_overlay_view(material_insertion_animation(highest_mat_ref), 1 SECONDS)

/**
 * Attempts to find the total material cost of a typepath (including our creation efficiency), modifying a list
 * The list is modified as an assoc list: Material datum typepath = Cost
 * If the type is found on a techweb, uses material costs from there
 * Otherwise, the typepath is created in nullspace and fetches materials from the initialized one, then deleted.
 *
 * Args:
 * part_type - Typepath of the item we are trying to find the costs of
 * costs - Assoc list we modify and return
 */
/obj/machinery/flatpacker/proc/analyze_cost(part_type, costs)
	PRIVATE_PROC(TRUE)

	var/comp_type = part_type
	if(ispath(part_type, /datum/stock_part))
		var/datum/stock_part/as_part = part_type
		comp_type = initial(as_part.physical_object_type)
		if(as_part.tier > print_tier)
			print_tier = as_part.tier

	var/list/mat_list
	var/obj/item/null_comp
	if(!isnull(SSresearch.item_to_design[comp_type]))
		mat_list = SSresearch.item_to_design[comp_type][1].materials
	else
		var/datum/stock_part/part = GLOB.stock_part_datums_per_object[comp_type]
		if(part)
			mat_list = part.physical_object_reference.custom_materials
		else
			null_comp = new comp_type
			mat_list = null_comp.custom_materials

	for(var/atom/mat as anything in mat_list)
		CREATE_AND_INCREMENT(costs, mat.type, mat_list[mat] * inserted_board.req_components[part_type])

	if(null_comp)
		qdel(null_comp)
	return costs

/obj/machinery/flatpacker/item_interaction(mob/living/user, obj/item/attacking_item, params)
	. = NONE
	if(user.combat_mode || attacking_item.flags_1 & HOLOGRAM_1 || attacking_item.item_flags & ABSTRACT)
		return ITEM_INTERACT_SKIP_TO_ATTACK

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

		//compute the needed mats from its stock parts
		for(var/type as anything in inserted_board.req_components)
			needed_mats = analyze_cost(type, needed_mats)

		// 5 sheets of iron and 5 of cable coil
		CREATE_AND_INCREMENT(needed_mats, /datum/material/iron, (SHEET_MATERIAL_AMOUNT * 5 + (SHEET_MATERIAL_AMOUNT / 20)))
		CREATE_AND_INCREMENT(needed_mats, /datum/material/glass, (SHEET_MATERIAL_AMOUNT / 20))

		update_appearance(UPDATE_OVERLAYS)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/flatpacker/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_o", base_icon_state, tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/flatpacker/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/flatpacker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Flatpacker")
		ui.open()

/obj/machinery/flatpacker/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/sheetmaterials),
		get_asset_datum(/datum/asset/spritesheet/research_designs),
	)

/obj/machinery/flatpacker/ui_static_data(mob/user)
	return materials.ui_static_data()

/obj/machinery/flatpacker/ui_data(mob/user)
	. = list()

	.["materials"] = materials.ui_data()
	.["busy"] = busy

	var/list/design
	if(!QDELETED(inserted_board))
		var/list/cost_mats = list()
		for(var/datum/material/mat_type as anything in needed_mats)
			var/list/new_entry = list()
			new_entry["name"] = initial(mat_type.name)
			new_entry["amount"] = OPTIMAL_COST(needed_mats[mat_type] * creation_efficiency)
			cost_mats += list(new_entry)

		var/atom/build = initial(inserted_board.build_path)

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
	.["design"] = design

/obj/machinery/flatpacker/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("build")
			if(busy)
				return

			if(QDELETED(inserted_board))
				return
			if(print_tier > max_part_tier)
				say("Design too complex.")
				return
			if(!materials.has_materials(needed_mats, creation_efficiency))
				say("Not enough materials to begin production.")
				return
			playsound(src, 'sound/items/tools/rped.ogg', 50, TRUE)

			busy = TRUE
			flick_overlay_view(mutable_appearance('icons/obj/machines/lathes.dmi', "flatpacker_bar"), flatpack_time)
			addtimer(CALLBACK(src, PROC_REF(finish_build), inserted_board), flatpack_time)
			return TRUE

		if("ejectBoard")
			try_put_in_hand(inserted_board, ui.user)
			return TRUE

		if("eject")
			var/datum/material/material = locate(params["ref"])
			if(!istype(material))
				return

			var/amount = params["amount"]
			if(isnull(amount))
				return

			amount = text2num(amount)
			if(isnull(amount))
				return

			//we use initial(active_power_usage) because higher tier parts will have higher active usage but we have no benefit from it
			if(!directly_use_energy(ROUND_UP((amount / MAX_STACK_SIZE) * 0.4 * initial(active_power_usage))))
				say("No power to dispense sheets")
				return

			materials.retrieve_sheets(amount, material)
			return TRUE

/**
 * Turns the supplied board into a flatpack, and sets the machine as not busy
 * Arguments
 *
 * * board - the board to put inside the flatpack
 */
/obj/machinery/flatpacker/proc/finish_build(board)
	PRIVATE_PROC(TRUE)

	busy = FALSE

	materials.use_materials(needed_mats, creation_efficiency)
	new /obj/item/flatpack(drop_location(), board)

	SStgui.update_uis(src)

/obj/machinery/flatpacker/click_ctrl(mob/user)
	if(QDELETED(inserted_board) || busy)
		return CLICK_ACTION_BLOCKING

	try_put_in_hand(inserted_board, user)

	return CLICK_ACTION_SUCCESS

#undef CREATE_AND_INCREMENT

/obj/item/flatpack
	name = "flatpack"
	desc = "A box containing a compactly packed machine. Use multitool to deploy."
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "flatpack"
	density = TRUE
	w_class = WEIGHT_CLASS_HUGE //cart time
	throw_range = 2
	item_flags = SLOWS_WHILE_IN_HAND | IMMUTABLE_SLOW
	slowdown = 2.5
	drag_slowdown = 3.5 //use the cart stupid

	/// The board we deploy
	var/obj/item/circuitboard/machine/board

/obj/item/flatpack/Initialize(mapload, obj/item/circuitboard/machine/new_board)
	if(isnull(board) && isnull(new_board))
		return INITIALIZE_HINT_QDEL //how

	. = ..()

	var/static/list/tool_behaviors = list(
			TOOL_MULTITOOL = list(
				SCREENTIP_CONTEXT_LMB = "Deploy",
			),
		)
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)

	board = !isnull(new_board) ? new_board : new board(src) // i got board
	if(board.loc != src)
		board.forceMove(src)
	var/obj/machinery/build = initial(board.build_path)
	name += " ([initial(build.name)])"

/obj/item/flatpack/Destroy()
	QDEL_NULL(board)
	. = ..()

/obj/item/flatpack/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return

	if(loc == user)
		. += span_warning("You can't deploy while holding it in your hand.")
	else if(isturf(loc))
		var/turf/location = loc
		if(!isopenturf(location))
			. += span_warning("Can't deploy in this location")
		else if(location.is_blocked_turf(source_atom = src))
			. += span_warning("No space for deployment")

/obj/item/flatpack/multitool_act(mob/living/user, obj/item/tool)
	. = NONE

	if(isnull(board))
		return ITEM_INTERACT_BLOCKING
	if(loc == user)
		balloon_alert(user, "can't deploy in hand")
		return ITEM_INTERACT_BLOCKING
	else if(isturf(loc))
		var/turf/location = loc
		if(!isopenturf(location))
			balloon_alert(user, "can't deploy here")
			return ITEM_INTERACT_BLOCKING
		else if(location.is_blocked_turf(source_atom = src))
			balloon_alert(user, "no space for deployment")
			return ITEM_INTERACT_BLOCKING
	balloon_alert_to_viewers("deploying!")
	if(!do_after(user, 1 SECONDS, target = src))
		return ITEM_INTERACT_BLOCKING

	new /obj/effect/temp_visual/mook_dust(loc)
	var/obj/machinery/new_machine = new board.build_path(loc)
	loc.visible_message(span_warning("[src] deploys!"))
	playsound(src, 'sound/machines/terminal/terminal_eject.ogg', 70, TRUE)
	new_machine.on_construction(user)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

///Maximum number of flatpacks in a cart
#define MAX_FLAT_PACKS 3

/obj/structure/flatpack_cart
	name = "flatpack cart"
	desc = "A cart specifically made to hold flatpacks from a flatpacker, evenly distributing weight. Convenient!"
	icon = 'icons/obj/structures.dmi'
	icon_state = "flatcart"
	density = TRUE
	opacity = FALSE

/obj/structure/flatpack_cart/Initialize(mapload)
	. = ..()

	register_context()

	AddElement(/datum/element/noisy_movement, volume = 45) // i hate noise

/obj/structure/flatpack_cart/atom_deconstruct(disassembled)
	for(var/atom/movable/content as anything in contents)
		content.forceMove(drop_location())

/obj/structure/flatpack_cart/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item))
		return

	if(istype(held_item, /obj/item/flatpack))
		context[SCREENTIP_CONTEXT_LMB] = "Load pack"
		return CONTEXTUAL_SCREENTIP_SET

/obj/structure/flatpack_cart/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return

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
	if(!istype(attacking_item, /obj/item/flatpack) || user.combat_mode || attacking_item.flags_1 & HOLOGRAM_1 || attacking_item.item_flags & ABSTRACT)
		return ITEM_INTERACT_SKIP_TO_ATTACK

	if (length(contents) >= MAX_FLAT_PACKS)
		balloon_alert(user, "full!")
		return ITEM_INTERACT_BLOCKING
	if (!user.transferItemToLoc(attacking_item, src))
		return ITEM_INTERACT_BLOCKING
	update_appearance(UPDATE_OVERLAYS)
	return ITEM_INTERACT_SUCCESS

#undef MAX_FLAT_PACKS
