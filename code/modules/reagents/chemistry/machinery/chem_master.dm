#define MAX_CONTAINER_PRINT_AMOUNT 50

/obj/machinery/chem_master
	name = "ChemMaster 3000"
	desc = "Used to separate chemicals and distribute them in a variety of forms."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "chemmaster"
	base_icon_state = "chemmaster"
	density = TRUE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.2
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.2
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_master

	/// Inserted reagent container
	var/obj/item/reagent_containers/beaker
	/// Whether separated reagents should be moved back to container or destroyed.
	var/is_transfering = TRUE
	/// List of printable container types
	var/list/printable_containers
	/// Container used by default to reset to
	var/obj/item/reagent_containers/default_container
	/// Selected printable container type
	var/obj/item/reagent_containers/selected_container
	/// Whether the machine is busy with printing containers
	var/is_printing = FALSE
	/// Number of containers printed so far
	var/printing_progress
	/// Number of containers to be printed
	var/printing_total
	/// The time it takes to print a container
	var/printing_speed = 0.75 SECONDS
	/// Amount of layers which printed pills will be coated in
	var/pill_layers = 3

/obj/machinery/chem_master/Initialize(mapload)
	create_reagents(100)

	printable_containers = load_printable_containers()
	default_container = printable_containers[printable_containers[1]][1]
	selected_container = default_container
	pill_layers = /obj/item/reagent_containers/applicator/pill::layers_remaining

	register_context()

	. = ..()

	var/obj/item/circuitboard/machine/chem_master/board = circuit
	board.build_path = type
	board.name = name

/obj/machinery/chem_master/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/chem_master/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item) || (held_item.item_flags & ABSTRACT) || (held_item.flags_1 & HOLOGRAM_1))
		if(isnull(held_item))
			context[SCREENTIP_CONTEXT_RMB] = "Remove beaker"
			. = CONTEXTUAL_SCREENTIP_SET
		return .

	if(is_reagent_container(held_item) && held_item.is_open_container())
		if(!QDELETED(beaker))
			context[SCREENTIP_CONTEXT_LMB] = "Replace beaker"
		else
			context[SCREENTIP_CONTEXT_LMB] = "Insert beaker"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] panel"
		return CONTEXTUAL_SCREENTIP_SET
	else if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Un" : ""] anchor"
		return CONTEXTUAL_SCREENTIP_SET
	else if(panel_open && held_item.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/chem_master/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads:<br>Reagent buffer capacity: <b>[reagents.maximum_volume]</b> units.<br>Printing speed: <b>[0.75 SECONDS / printing_speed * 100]%</b>.")
		if(!QDELETED(beaker))
			. += span_notice("[beaker] of <b>[beaker.reagents.maximum_volume]u</b> capacity inserted")
			. += span_notice("Right click with empty hand to remove beaker")
		else
			. += span_warning("Missing input beaker")

		. += span_notice("It can be [EXAMINE_HINT("wrenched")] [anchored ? "loose" : "in place"]")
		. += span_notice("Its maintainence panel can be [EXAMINE_HINT("screwed")] [panel_open ? "close" : "open"]")
		if(panel_open)
			. += span_notice("The machine can be [EXAMINE_HINT("pried")] apart.")

/obj/machinery/chem_master/update_appearance(updates)
	. = ..()
	if(panel_open || !is_operational)
		set_light(0)
	else
		set_light(1, 1, "#fffb00")

/obj/machinery/chem_master/update_overlays()
	. = ..()
	if(!isnull(beaker))
		. += mutable_appearance(icon, base_icon_state + "_overlay_container")
	if(machine_stat & BROKEN)
		. += mutable_appearance(icon, base_icon_state + "_overlay_broken")
	if(panel_open)
		. += mutable_appearance(icon, base_icon_state + "_overlay_panel")

	if(is_printing)
		. += mutable_appearance(icon, base_icon_state + "_overlay_extruder_active")
	else
		. += mutable_appearance(icon, base_icon_state + "_overlay_extruder")

	// Screen overlay
	if(!panel_open && is_operational)
		var/screen_overlay = base_icon_state + "_overlay_screen"
		if(is_printing)
			screen_overlay += "_active"
		else if(reagents.total_volume > 0)
			screen_overlay += "_main"
		. += mutable_appearance(icon, screen_overlay)
		. += emissive_appearance(icon, base_icon_state + "_overlay_lightmask", src, alpha = src.alpha)

	// Buffer reagents overlay
	if(reagents.total_volume)
		var/static/list/fill_icon_thresholds = list(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
		var/mutable_appearance/filling = reagent_threshold_overlay(reagents, 'icons/obj/medical/reagent_fillings.dmi', "chemmaster", fill_icon_thresholds)
		if(!isnull(filling))
			. += filling

/obj/machinery/chem_master/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == beaker)
		beaker = null
		update_appearance(UPDATE_OVERLAYS)

/obj/machinery/chem_master/on_set_is_operational(old_value)
	if(!is_operational)
		is_printing = FALSE
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/chem_master/RefreshParts()
	. = ..()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/cup/beaker/beaker in component_parts)
		reagents.maximum_volume += beaker.reagents.maximum_volume

	//Servo tier determines printing speed
	printing_speed = 1 SECONDS
	for(var/datum/stock_part/servo/servo in component_parts)
		printing_speed -= servo.tier * 0.25 SECONDS
	printing_speed = max(printing_speed, 0.25 SECONDS)

///Return a map of category->list of containers this machine can print
/obj/machinery/chem_master/proc/load_printable_containers()
	PROTECTED_PROC(TRUE)
	SHOULD_BE_PURE(TRUE)

	var/static/list/containers
	if(!length(containers))
		containers = list(
			CAT_TUBES = GLOB.reagent_containers[CAT_TUBES],
			CAT_PILLS = GLOB.reagent_containers[CAT_PILLS],
			CAT_PATCHES = GLOB.reagent_containers[CAT_PATCHES],
			CAT_HYPOS = GLOB.reagent_containers[CAT_HYPOS], /// DOPPLER SHIFT ADDITION
		)
	return containers

/obj/machinery/chem_master/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode || (tool.item_flags & ABSTRACT) || (tool.flags_1 & HOLOGRAM_1) || !can_interact(user) || !user.can_perform_action(src, ALLOW_SILICON_REACH | FORBID_TELEKINESIS_REACH))
		return NONE

	if(is_reagent_container(tool) && tool.is_open_container())
		replace_beaker(user, tool)
		if(!panel_open)
			ui_interact(user)
			return ITEM_INTERACT_SUCCESS
		else
			return ITEM_INTERACT_BLOCKING

	return NONE

/obj/machinery/chem_master/wrench_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	. = ITEM_INTERACT_BLOCKING
	if(is_printing)
		balloon_alert(user, "still printing!")
		return .

	if(default_unfasten_wrench(user, tool) == SUCCESSFUL_UNFASTEN)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/chem_master/screwdriver_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	. = ITEM_INTERACT_BLOCKING
	if(is_printing)
		balloon_alert(user, "still printing!")
		return .

	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		update_appearance(UPDATE_OVERLAYS)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/chem_master/crowbar_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	. = ITEM_INTERACT_BLOCKING
	if(is_printing)
		balloon_alert(user, "still printing!")
		return .

	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/**
 * Insert, remove, replace the existig beaker
 * Arguments
 *
 * * mob/living/user - the player trying to replace the beaker
 * * obj/item/reagent_containers/new_beaker - the beaker we are trying to insert, swap with existing or remove if null
 */
/obj/machinery/chem_master/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	PRIVATE_PROC(TRUE)

	if(!QDELETED(beaker))
		try_put_in_hand(beaker, user)
	if(!QDELETED(new_beaker) && user.transferItemToLoc(new_beaker, src))
		beaker = new_beaker
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/chem_master/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return .
	if(!can_interact(user) || !user.can_perform_action(src, ALLOW_SILICON_REACH | FORBID_TELEKINESIS_REACH))
		return .
	replace_beaker(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/chem_master/attack_robot_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/chem_master/attack_ai_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/chem_master/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemMaster", name)
		ui.open()

/obj/machinery/chem_master/ui_static_data(mob/user)
	var/list/data = list()

	data["maxPrintable"] = MAX_CONTAINER_PRINT_AMOUNT
	data["maxPillDuration"] = PILL_MAX_PRINTABLE_LAYERS
	data["categories"] = list()
	for(var/category in printable_containers)
		//make the category
		var/list/category_list = list(
			"name" = category,
			"containers" = list(),
		)

		//add containers to this category
		for(var/obj/item/reagent_containers/container as anything in printable_containers[category])
			category_list["containers"] += list(list(
				"ref" = REF(container),
				"name" = initial(container.name),
				"icon" = initial(container.icon),
				"icon_state" = initial(container.icon_state),
				"volume" = initial(container.volume),
			))

		//add the category
		data["categories"] += list(category_list)

	return data

/obj/machinery/chem_master/ui_data(mob/user)
	. = list()

	//printing statictics
	.["isPrinting"] = is_printing
	.["printingProgress"] = printing_progress
	.["printingTotal"] = printing_total
	.["selectedPillDuration"] = pill_layers

	//contents of source beaker
	var/list/beaker_data = null
	if(!QDELETED(beaker))
		beaker_data = list()
		beaker_data["maxVolume"] = beaker.volume
		beaker_data["currentVolume"] = beaker.reagents.total_volume
		var/list/beakerContents = list()
		if(length(beaker.reagents.reagent_list))
			for(var/datum/reagent/reagent as anything in beaker.reagents.reagent_list)
				beakerContents += list(list(
					"ref" = "[reagent.type]",
					"name" = reagent.name,
					"volume" = round(reagent.volume, CHEMICAL_VOLUME_ROUNDING),
					"pH" = reagent.ph,
					"color" = reagent.color,
					"description" = reagent.description,
					"purity" = reagent.purity,
					"metaRate" = reagent.metabolization_rate,
					"overdose" = reagent.overdose_threshold,
					"addictionTypes" = reagents.parse_addictions(reagent),
				))
		beaker_data["contents"] = beakerContents
	.["beaker"] = beaker_data

	//contents of buffer
	beaker_data = list()
	beaker_data["maxVolume"] = reagents.maximum_volume
	beaker_data["currentVolume"] = reagents.total_volume
	var/list/beakerContents = list()
	if(length(reagents.reagent_list))
		for(var/datum/reagent/reagent as anything in reagents.reagent_list)
			beakerContents += list(list(
				"ref" = "[reagent.type]",
				"name" = reagent.name,
				"volume" = round(reagent.volume, CHEMICAL_VOLUME_ROUNDING),
				"pH" = reagent.ph,
				"color" = reagent.color,
				"description" = reagent.description,
				"purity" = reagent.purity,
				"metaRate" = reagent.metabolization_rate,
				"overdose" = reagent.overdose_threshold,
				"addictionTypes" = reagents.parse_addictions(reagent),
			))
	beaker_data["contents"] = beakerContents
	.["buffer"] = beaker_data

	//is transfering or destroying reagents. applied only for buffer
	.["isTransfering"] = is_transfering

	//container along with the suggested type
	var/obj/item/reagent_containers/suggested_container = default_container
	if(reagents.total_volume > 0)
		var/datum/reagent/master_reagent = reagents.get_master_reagent()
		var/container_found = FALSE
		suggested_container = master_reagent.default_container
		for(var/category in printable_containers)
			for(var/obj/item/reagent_containers/container as anything in printable_containers[category])
				if(container == suggested_container)
					suggested_container = REF(container)
					container_found = TRUE
					break
		if(!container_found)
			suggested_container = REF(default_container)
	.["suggestedContainerRef"] = suggested_container

	//selected container
	.["selectedContainerRef"] = REF(selected_container)
	.["selectedContainerVolume"] = initial(selected_container.volume)

	for (var/category in printable_containers)
		if (selected_container in printable_containers[category])
			.["selectedContainerCategory"] = category
			break

/**
 * Transfers a single reagent between buffer & beaker
 * Arguments
 *
 * * datum/reagents/source - the holder we are transferring from
 * * datum/reagents/target - the holder we are transferring to
 * * datum/reagent/path - the reagent typepath we are transfering
 * * amount - volume to transfer
 * * do_transfer - transfer the reagents else destroy them
 */
/obj/machinery/chem_master/proc/transfer_reagent(datum/reagents/source, datum/reagents/target, datum/reagent/path, amount, do_transfer)
	PRIVATE_PROC(TRUE)

	//sanity checks for transfer amount
	if(isnull(amount) || amount <= 0)
		return FALSE
	//sanity checks for reagent path
	var/datum/reagent/reagent = text2path(path)
	if (!reagent)
		return FALSE

	//use energy
	if(!use_energy(active_power_usage, force = FALSE))
		return FALSE

	//do the operation
	. = FALSE
	if(do_transfer)
		if(target.is_reacting)
			return FALSE
		if(source.trans_to(target, amount, target_id = reagent))
			. = TRUE
	else if(source.remove_reagent(reagent, amount))
		. = TRUE
	if(. && !QDELETED(src)) //transferring volatile reagents can cause a explosion & destory us
		update_appearance(UPDATE_OVERLAYS)

/obj/machinery/chem_master/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("eject")
			if(is_printing)
				say("The buffer is locked while printing.")
				return

			replace_beaker(ui.user)
			return TRUE

		if("transfer")
			if(is_printing)
				say("The buffer is locked while printing.")
				return

			var/reagent_ref = params["reagentRef"]
			var/amount = params["amount"]
			var/target = params["target"]

			if(amount == -1) // Set custom amount
				var/mob/user = ui.user //Hold a reference of the user if the UI is closed
				amount = round(tgui_input_number(user, "Enter amount to transfer", "Transfer amount", round_value = FALSE), CHEMICAL_VOLUME_ROUNDING)
				if(!amount || !user.can_perform_action(src))
					return FALSE

			var/should_transfer = is_transfering || (target == "buffer") // we should always transfer if target is the buffer
			if(should_transfer && isnull(beaker)) // if there's no beaker, we cannot transfer
				say("No reagent container is inserted.")
				return FALSE

			var/reagents_from
			var/reagents_to = null
			if(target == "buffer")
				reagents_from = beaker.reagents
				reagents_to = reagents // buffer
			else if(target == "beaker")
				reagents_from = reagents // buffer
				if(should_transfer)
					reagents_to = beaker.reagents
			return transfer_reagent(reagents_from, reagents_to, reagent_ref, amount, should_transfer)

		if("toggleTransferMode")
			is_transfering = !is_transfering
			return TRUE

		if("stopPrinting")
			is_printing = FALSE
			update_appearance(UPDATE_OVERLAYS)
			return TRUE

		if ("setPillDuration")
			pill_layers = clamp(params["duration"], 0, PILL_MAX_PRINTABLE_LAYERS)
			return TRUE

		if("selectContainer")
			var/obj/item/reagent_containers/target = locate(params["ref"])

			//is this even a valid type path
			if(!ispath(target))
				return FALSE

			//are we printing a valid container
			var/container_found = FALSE
			for(var/category in printable_containers)
				//container found in previous iteration
				if(container_found)
					break

				//find for matching typepath
				for(var/obj/item/reagent_containers/container as anything in printable_containers[category])
					if(target == container)
						container_found = TRUE
						break
			if(!container_found)
				return FALSE

			//set the container
			selected_container = target
			return TRUE

		if("create")
			if(!reagents.total_volume || is_printing)
				return FALSE

			//validate print count
			var/item_count = params["itemCount"]
			if(isnull(item_count))
				return FALSE
			item_count = text2num(item_count)
			if(isnull(item_count) || item_count <= 0)
				return FALSE
			item_count = min(item_count, MAX_CONTAINER_PRINT_AMOUNT)
			var/volume_in_each = min(round(reagents.total_volume / item_count, CHEMICAL_VOLUME_ROUNDING), initial(selected_container.volume))

			// Generate item name
			var/item_name_default = initial(selected_container.name)
			var/datum/reagent/master_reagent = reagents.get_master_reagent()
			if(selected_container == default_container) // Tubes and bottles gain reagent name
				item_name_default = "[master_reagent.name] [item_name_default]"
			if(!(initial(selected_container.reagent_flags) & OPENCONTAINER)) // Closed containers get both reagent name and units in the name
				item_name_default = "[master_reagent.name] [item_name_default] ([volume_in_each]u)"
			var/item_name = tgui_input_text(
				usr,
				"Container name",
				"Name",
				item_name_default,
				max_length = MAX_NAME_LEN,
			)

			if(!item_name || is_printing)
				return FALSE

			//start printing
			is_printing = TRUE
			printing_progress = 0
			printing_total = item_count
			update_appearance(UPDATE_OVERLAYS)
			create_containers(ui.user, item_count, item_name, volume_in_each, selected_container)
			return TRUE

/**
 * Create N selected containers with reagents from buffer split between them
 * Arguments
 *
 * * mob/user - the player printing these containers
 * * item_count - number of containers to print
 * * item_name - the name for each container printed
 * * volume_in_each - volume in each container created
 * * chosen_container - type of the container we're going to print
 */
/obj/machinery/chem_master/proc/create_containers(mob/user, item_count, item_name, volume_in_each, chosen_container)
	PRIVATE_PROC(TRUE)

	//lost power or manually stopped
	if(!is_printing)
		return

	//use power
	if(!use_energy(active_power_usage, force = FALSE))
		is_printing = FALSE
		update_appearance(UPDATE_OVERLAYS)
		return

	//print the stuff
	var/obj/item/reagent_containers/item = new chosen_container(drop_location())
	adjust_item_drop_location(item)
	item.name = item_name
	item.reagents.clear_reagents()
	reagents.trans_to(item, volume_in_each, transferred_by = user)
	if (istype(item, /obj/item/reagent_containers/applicator/pill))
		var/obj/item/reagent_containers/applicator/pill/pill = item
		pill.layers_remaining = pill_layers
	printing_progress++
	update_appearance(UPDATE_OVERLAYS)

	//print more items
	item_count --
	if(item_count > 0)
		addtimer(CALLBACK(src, PROC_REF(create_containers), user, item_count, item_name, volume_in_each, chosen_container), printing_speed)
	else
		is_printing = FALSE
		update_appearance(UPDATE_OVERLAYS)

/obj/machinery/chem_master/condimaster
	name = "CondiMaster 3000"
	desc = "Used to create condiments and other cooking supplies."
	icon_state = "condimaster"

/obj/machinery/chem_master/condimaster/load_printable_containers()
	var/static/list/containers
	if(!length(containers))
		containers = list(CAT_CONDIMENTS = GLOB.reagent_containers[CAT_CONDIMENTS])
	return containers

#undef MAX_CONTAINER_PRINT_AMOUNT
