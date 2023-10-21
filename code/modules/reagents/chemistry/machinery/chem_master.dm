#define TRANSFER_MODE_DESTROY 0
#define TRANSFER_MODE_MOVE 1
#define TARGET_BEAKER "beaker"
#define TARGET_BUFFER "buffer"

/obj/machinery/chem_master
	name = "ChemMaster 3000"
	desc = "Used to separate chemicals and distribute them in a variety of forms."
	density = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "chemmaster"
	base_icon_state = "chemmaster"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.2
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_master
	/// Icons for different percentages of buffer reagents
	var/fill_icon = 'icons/obj/medical/reagent_fillings.dmi'
	var/fill_icon_state = "chemmaster"
	var/static/list/fill_icon_thresholds = list(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
	/// Inserted reagent container
	var/obj/item/reagent_containers/beaker
	/// Whether separated reagents should be moved back to container or destroyed.
	var/transfer_mode = TRANSFER_MODE_MOVE
	/// Whether reagent analysis screen is active
	var/reagent_analysis_mode = FALSE
	/// Reagent being analyzed
	var/datum/reagent/analyzed_reagent
	/// List of printable container types
	var/list/printable_containers = list()
	/// Container used by default to reset to (REF)
	var/default_container
	/// Selected printable container type (REF)
	var/selected_container
	/// Whether the machine has an option to suggest container
	var/has_container_suggestion = FALSE
	/// Whether to suggest container or not
	var/do_suggest_container = FALSE
	/// The container suggested by main reagent in the buffer
	var/suggested_container
	/// Whether the machine is busy with printing containers
	var/is_printing = FALSE
	/// Number of printed containers in the current printing cycle for UI progress bar
	var/printing_progress
	var/printing_total
	/// Default duration of printing cycle
	var/printing_speed = 0.75 SECONDS // Duration of animation
	/// The amount of containers printed in one cycle
	var/printing_amount = 1

/obj/machinery/chem_master/Initialize(mapload)
	create_reagents(100)
	load_printable_containers()
	default_container = REF(printable_containers[printable_containers[1]][1])
	selected_container = default_container
	return ..()

/obj/machinery/chem_master/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/chem_master/on_deconstruction()
	replace_beaker()
	return ..()

/obj/machinery/chem_master/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == beaker)
		beaker = null
		update_appearance(UPDATE_ICON)

/obj/machinery/chem_master/RefreshParts()
	. = ..()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/cup/beaker/beaker in component_parts)
		reagents.maximum_volume += beaker.reagents.maximum_volume
	printing_amount = 0
	for(var/datum/stock_part/servo/servo in component_parts)
		printing_amount += servo.tier

/obj/machinery/chem_master/update_appearance(updates=ALL)
	. = ..()
	if(panel_open || (machine_stat & (NOPOWER|BROKEN)))
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
	if(!panel_open && !(machine_stat & (NOPOWER | BROKEN)))
		var/screen_overlay = base_icon_state + "_overlay_screen"
		if(reagent_analysis_mode)
			screen_overlay += "_analysis"
		else if(is_printing)
			screen_overlay += "_active"
		else if(reagents.total_volume > 0)
			screen_overlay += "_main"
		. += mutable_appearance(icon, screen_overlay)
		. += emissive_appearance(icon, base_icon_state + "_overlay_lightmask", src, alpha = src.alpha)

	// Buffer reagents overlay
	if(reagents.total_volume)
		var/threshold = null
		for(var/i in 1 to fill_icon_thresholds.len)
			if(ROUND_UP(100 * reagents.total_volume / reagents.maximum_volume) >= fill_icon_thresholds[i])
				threshold = i
		if(threshold)
			var/fill_name = "[fill_icon_state][fill_icon_thresholds[threshold]]"
			var/mutable_appearance/filling = mutable_appearance(fill_icon, fill_name)
			filling.color = mix_color_from_reagents(reagents.reagent_list)
			. += filling

/obj/machinery/chem_master/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/chem_master/attackby(obj/item/item, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, item))
		update_appearance(UPDATE_ICON)
		return
	if(default_deconstruction_crowbar(item))
		return
	if(is_reagent_container(item) && !(item.item_flags & ABSTRACT) && item.is_open_container())
		. = TRUE // No afterattack
		var/obj/item/reagent_containers/beaker = item
		replace_beaker(user, beaker)
		if(!panel_open)
			ui_interact(user)
	return ..()

/obj/machinery/chem_master/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!can_interact(user) || !user.can_perform_action(src, ALLOW_SILICON_REACH|FORBID_TELEKINESIS_REACH))
		return
	replace_beaker(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/chem_master/attack_robot_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/chem_master/attack_ai_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/// Insert new beaker and/or eject the inserted one
/obj/machinery/chem_master/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(new_beaker && user && !user.transferItemToLoc(new_beaker, src))
		return FALSE
	if(beaker)
		try_put_in_hand(beaker, user)
		beaker = null
	if(new_beaker)
		beaker = new_beaker
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/machinery/chem_master/proc/load_printable_containers()
	printable_containers = list(
		CAT_TUBES = GLOB.reagent_containers[CAT_TUBES],
		CAT_PILLS = GLOB.reagent_containers[CAT_PILLS],
		CAT_PATCHES = GLOB.reagent_containers[CAT_PATCHES],
	)

/obj/machinery/chem_master/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/chemmaster)
	)

/obj/machinery/chem_master/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemMaster", name)
		ui.open()

/obj/machinery/chem_master/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = list()
	for(var/category in printable_containers)
		var/container_data = list()
		for(var/obj/item/reagent_containers/container as anything in printable_containers[category])
			container_data += list(list(
				"icon" = sanitize_css_class_name("[container]"),
				"ref" = REF(container),
				"name" = initial(container.name),
				"volume" = initial(container.volume),
			))
		data["categories"]+= list(list(
			"name" = category,
			"containers" = container_data,
		))

	return data

/obj/machinery/chem_master/ui_data(mob/user)
	var/list/data = list()

	data["reagentAnalysisMode"] = reagent_analysis_mode
	if(reagent_analysis_mode && analyzed_reagent)
		var/state
		switch(analyzed_reagent.reagent_state)
			if(SOLID)
				state = "Solid"
			if(LIQUID)
				state = "Liquid"
			if(GAS)
				state = "Gas"
			else
				state = "Unknown"
		data["analysisData"] = list(
			"name" = analyzed_reagent.name,
			"state" = state,
			"pH" = analyzed_reagent.ph,
			"color" = analyzed_reagent.color,
			"description" = analyzed_reagent.description,
			"purity" = analyzed_reagent.purity,
			"metaRate" = analyzed_reagent.metabolization_rate,
			"overdose" = analyzed_reagent.overdose_threshold,
			"addictionTypes" = reagents.parse_addictions(analyzed_reagent),
		)
	else
		data["isPrinting"] = is_printing
		data["printingProgress"] = printing_progress
		data["printingTotal"] = printing_total
		data["hasBeaker"] = beaker ? TRUE : FALSE
		data["beakerCurrentVolume"] = beaker ? round(beaker.reagents.total_volume, 0.01) : null
		data["beakerMaxVolume"] = beaker ? beaker.volume : null
		var/list/beaker_contents = list()
		if(beaker)
			for(var/datum/reagent/reagent in beaker.reagents.reagent_list)
				beaker_contents.Add(list(list("name" = reagent.name, "ref" = REF(reagent), "volume" = round(reagent.volume, 0.01))))
		data["beakerContents"] = beaker_contents

		var/list/buffer_contents = list()
		if(reagents.total_volume)
			for(var/datum/reagent/reagent in reagents.reagent_list)
				buffer_contents.Add(list(list("name" = reagent.name, "ref" = REF(reagent), "volume" = round(reagent.volume, 0.01))))
		data["bufferContents"] = buffer_contents
		data["bufferCurrentVolume"] = round(reagents.total_volume, 0.01)
		data["bufferMaxVolume"] = reagents.maximum_volume

		data["transferMode"] = transfer_mode

		data["hasContainerSuggestion"] = !!has_container_suggestion
		if(has_container_suggestion)
			data["doSuggestContainer"] = !!do_suggest_container
			if(do_suggest_container)
				if(reagents.total_volume > 0)
					var/master_reagent = reagents.get_master_reagent()
					suggested_container = get_suggested_container(master_reagent)
				else
					suggested_container = default_container
				data["suggestedContainer"] = suggested_container
				selected_container = suggested_container
			else if (isnull(selected_container))
				selected_container = default_container

		data["selectedContainerRef"] = selected_container
		var/obj/item/reagent_containers/container = locate(selected_container)
		data["selectedContainerVolume"] = initial(container.volume)

	return data

/obj/machinery/chem_master/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(action == "eject")
		replace_beaker(usr)
		return TRUE

	if(action == "transfer")
		var/reagent_ref = params["reagentRef"]
		var/amount = text2num(params["amount"])
		var/target = params["target"]
		return transfer_reagent(reagent_ref, amount, target)

	if(action == "toggleTransferMode")
		transfer_mode = !transfer_mode
		return TRUE

	if(action == "analyze")
		analyzed_reagent = locate(params["reagentRef"])
		if(analyzed_reagent)
			reagent_analysis_mode = TRUE
			update_appearance(UPDATE_ICON)
			return TRUE

	if(action == "stopAnalysis")
		reagent_analysis_mode = FALSE
		analyzed_reagent = null
		update_appearance(UPDATE_ICON)
		return TRUE

	if(action == "stopPrinting")
		is_printing = FALSE
		return TRUE

	if(action == "toggleContainerSuggestion")
		do_suggest_container = !do_suggest_container
		return TRUE

	if(action == "selectContainer")
		selected_container = params["ref"]
		return TRUE

	if(action == "create")
		if(reagents.total_volume == 0)
			return FALSE
		var/item_count = text2num(params["itemCount"])
		if(item_count <= 0)
			return FALSE
		create_containers(item_count)
		return TRUE

/// Create N selected containers with reagents from buffer split between them
/obj/machinery/chem_master/proc/create_containers(item_count = 1)
	var/obj/item/reagent_containers/container_style = locate(selected_container)
	var/is_pill_subtype = ispath(container_style, /obj/item/reagent_containers/pill)
	var/volume_in_each = reagents.total_volume / item_count
	var/printing_amount_current = is_pill_subtype ? printing_amount * 2 : printing_amount

	// Generate item name
	var/item_name_default = initial(container_style.name)
	if(selected_container == default_container) // Tubes and bottles gain reagent name
		item_name_default = "[reagents.get_master_reagent_name()] [item_name_default]"
	if(!(initial(container_style.reagent_flags) & OPENCONTAINER)) // Closed containers get both reagent name and units in the name
		item_name_default = "[reagents.get_master_reagent_name()] [item_name_default] ([volume_in_each]u)"
	var/item_name = tgui_input_text(usr,
		"Container name",
		"Name",
		item_name_default,
		MAX_NAME_LEN)

	if(!item_name || !reagents.total_volume || QDELETED(src) || !usr.can_perform_action(src, ALLOW_SILICON_REACH))
		return FALSE

	// Print and fill containers
	is_printing = TRUE
	update_appearance(UPDATE_ICON)
	printing_progress = 0
	printing_total = item_count
	while(item_count > 0)
		if(!is_printing)
			break
		use_power(active_power_usage)
		stoplag(printing_speed)
		for(var/i in 1 to printing_amount_current)
			if(!item_count)
				continue
			var/obj/item/reagent_containers/item = new container_style(drop_location())
			adjust_item_drop_location(item)
			item.name = item_name
			item.reagents.clear_reagents()
			reagents.trans_to(item, volume_in_each, transferred_by = src)
			printing_progress++
			item_count--
		update_appearance(UPDATE_ICON)
	is_printing = FALSE
	update_appearance(UPDATE_ICON)
	return TRUE

/// Transfer reagents to specified target from the opposite source
/obj/machinery/chem_master/proc/transfer_reagent(reagent_ref, amount, target)
	if (amount == -1)
		amount = text2num(input("Enter the amount you want to transfer:", name, ""))
	if (amount == null || amount <= 0)
		return FALSE
	if (!beaker && target == TARGET_BEAKER && transfer_mode == TRANSFER_MODE_MOVE)
		return FALSE
	var/datum/reagent/reagent = locate(reagent_ref)
	if (!reagent)
		return FALSE

	use_power(active_power_usage)

	if (target == TARGET_BUFFER)
		if(!check_reactions(reagent, beaker.reagents))
			return FALSE
		beaker.reagents.trans_id_to(src, reagent.type, amount)
		update_appearance(UPDATE_ICON)
		return TRUE

	if (target == TARGET_BEAKER && transfer_mode == TRANSFER_MODE_DESTROY)
		reagents.remove_reagent(reagent.type, amount)
		update_appearance(UPDATE_ICON)
		return TRUE
	if (target == TARGET_BEAKER && transfer_mode == TRANSFER_MODE_MOVE)
		if(!check_reactions(reagent, reagents))
			return FALSE
		reagents.trans_id_to(beaker, reagent.type, amount)
		update_appearance(UPDATE_ICON)
		return TRUE

	return FALSE

/// Checks to see if the target reagent is being created (reacting) and if so prevents transfer
/// Only prevents reactant from being moved so that people can still manlipulate input reagents
/obj/machinery/chem_master/proc/check_reactions(datum/reagent/reagent, datum/reagents/holder)
	if(!reagent)
		return FALSE
	var/canMove = TRUE
	for(var/datum/equilibrium/equilibrium as anything in holder.reaction_list)
		if(equilibrium.reaction.reaction_flags & REACTION_COMPETITIVE)
			continue
		for(var/datum/reagent/result as anything in equilibrium.reaction.required_reagents)
			if(result == reagent.type)
				canMove = FALSE
	if(!canMove)
		say("Cannot move reagent during reaction!")
	return canMove

/// Retrieve REF to the best container for provided reagent
/obj/machinery/chem_master/proc/get_suggested_container(datum/reagent/reagent)
	var/preferred_container = reagent.default_container
	for(var/category in printable_containers)
		for(var/container in printable_containers[category])
			if(container == preferred_container)
				return REF(container)
	return default_container

/obj/machinery/chem_master/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads:<br>Reagent buffer capacity: <b>[reagents.maximum_volume]</b> units.<br>Number of containers printed at once increased by <b>[100 * (printing_amount / initial(printing_amount)) - 100]%</b>.")

/obj/machinery/chem_master/condimaster
	name = "CondiMaster 3000"
	desc = "Used to create condiments and other cooking supplies."
	icon_state = "condimaster"
	has_container_suggestion = TRUE

/obj/machinery/chem_master/condimaster/load_printable_containers()
	printable_containers = list(
		CAT_CONDIMENTS = GLOB.reagent_containers[CAT_CONDIMENTS],
	)

#undef TRANSFER_MODE_DESTROY
#undef TRANSFER_MODE_MOVE
#undef TARGET_BEAKER
#undef TARGET_BUFFER
