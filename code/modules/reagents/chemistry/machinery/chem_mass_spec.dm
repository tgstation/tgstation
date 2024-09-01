/obj/machinery/chem_mass_spec
	name = "High-performance liquid chromatography machine"
	desc = "Allows you to purify reagents & seperate out inverse reagents"
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "HPLC"
	base_icon_state = "HPLC"
	density = TRUE
	interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_REQUIRES_ANCHORED
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.2
	resistance_flags = FIRE_PROOF | ACID_PROOF
	processing_flags = START_PROCESSING_MANUALLY
	circuit = /obj/item/circuitboard/machine/chem_mass_spec

	///If we're processing reagents or not
	var/processing_reagents = FALSE
	///Time we started processing + the delay
	var/delay_time = 0
	///How much time we've done so far
	var/progress_time = 0
	///Lower mass range - for mass selection of what will be processed
	var/lower_mass_range = 0
	///Upper_mass_range - for mass selection of what will be processed
	var/upper_mass_range = INFINITY
	///The log output to clarify how the thing works
	var/list/log = list()
	///Input reagents container
	var/obj/item/reagent_containers/beaker1
	///Output reagents container
	var/obj/item/reagent_containers/beaker2
	///multiplies the final time needed to process the chems depending on the laser stock part
	var/cms_coefficient = 1

/obj/machinery/chem_mass_spec/Initialize(mapload)
	. = ..()

	ADD_TRAIT(src, TRAIT_DO_NOT_SPLASH, INNATE_TRAIT)

	if(mapload)
		beaker2 = new /obj/item/reagent_containers/cup/beaker/large(src)

	register_context()

/obj/machinery/chem_mass_spec/Destroy()
	QDEL_NULL(beaker1)
	QDEL_NULL(beaker2)
	return ..()

/obj/machinery/chem_mass_spec/on_deconstruction(disassembled)
	var/location = drop_location()
	beaker1?.forceMove(location)
	beaker2?.forceMove(location)

/obj/machinery/chem_mass_spec/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE

	if(!QDELETED(beaker1))
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Eject input beaker"
		. = CONTEXTUAL_SCREENTIP_SET
	if(!QDELETED(beaker2))
		context[SCREENTIP_CONTEXT_ALT_RMB] = "Eject output beaker"
		. = CONTEXTUAL_SCREENTIP_SET

	if(isnull(held_item) || (held_item.item_flags & ABSTRACT) || (held_item.flags_1 & HOLOGRAM_1))
		return

	if(is_reagent_container(held_item))
		if(QDELETED(beaker1))
			context[SCREENTIP_CONTEXT_LMB] = "Insert input beaker"
		else
			context[SCREENTIP_CONTEXT_LMB] = "Replace input beaker"

		if(QDELETED(beaker2))
			context[SCREENTIP_CONTEXT_RMB] = "Insert output beaker"
		else
			context[SCREENTIP_CONTEXT_RMB] = "Replace output beaker"

		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Un" : ""]anchor"
		return CONTEXTUAL_SCREENTIP_SET
	else if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] panel"
		return CONTEXTUAL_SCREENTIP_SET
	else if(panel_open && held_item.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/chem_mass_spec/examine(mob/user)
	. = ..()

	if(!QDELETED(beaker1))
		. += span_notice("Input beaker of [beaker1.reagents.maximum_volume]u capacity is inserted.")
		. += span_notice("Its Input beaker Can be ejected with [EXAMINE_HINT("LMB Alt")] click.")
	else
		. += span_warning("Its missing an input beaker. insert with [EXAMINE_HINT("Left Click")].")
	if(!QDELETED(beaker2))
		. += span_notice("Output beaker of [beaker2.reagents.maximum_volume]u capacity is inserted.")
		. += span_notice("Its Output beaker can be ejected with [EXAMINE_HINT("RMB Alt")] click.")
	else
		. += span_warning("Its missing an output beaker, insert with [EXAMINE_HINT("Right Click")].")

	if(anchored)
		. += span_notice("Its [EXAMINE_HINT("anchored")] in place.")
	else
		. += span_warning("Needs to be [EXAMINE_HINT("wrenched")] to use.")
	. += span_notice("Its maintainence panel can be [EXAMINE_HINT("screwed")] [panel_open ? "closed" : "open"].")
	if(panel_open)
		. += span_notice("It can be [EXAMINE_HINT("pried")] apart.")

/obj/machinery/chem_mass_spec/update_overlays()
	. = ..()

	if(panel_open)
		. += mutable_appearance(icon, "[base_icon_state]_panel-o")
		return

	if(!QDELETED(beaker1))
		. += "HPLC_beaker1"
	if(!QDELETED(beaker2))
		. += "HPLC_beaker2"

	if(is_operational && !panel_open && anchored && !(machine_stat & (BROKEN | NOPOWER)))
		if(processing_reagents)
			. += "HPLC_graph_active"
		else if (length(beaker1?.reagents.reagent_list))
			. += "HPLC_graph_idle"

/obj/machinery/chem_mass_spec/update_icon_state()
	if(is_operational && !panel_open && anchored && !(machine_stat & (BROKEN | NOPOWER)))
		icon_state = "HPLC_on"
	else
		icon_state = "HPLC"
	return ..()

/obj/machinery/chem_mass_spec/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == beaker1)
		beaker1 = null
	if(gone == beaker2)
		beaker2 = null

/obj/machinery/chem_mass_spec/RefreshParts()
	. = ..()

	cms_coefficient = 1
	for(var/datum/stock_part/micro_laser/laser in component_parts)
		cms_coefficient /= laser.tier

/obj/machinery/chem_mass_spec/item_interaction(mob/living/user, obj/item/item, list/modifiers)
	if((item.item_flags & ABSTRACT) || (item.flags_1 & HOLOGRAM_1) || !can_interact(user) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return NONE

	if(is_reagent_container(item) && item.is_open_container())
		if(processing_reagents)
			balloon_alert(user, "still processing!")
			return ITEM_INTERACT_BLOCKING

		var/obj/item/reagent_containers/beaker = item
		if(!user.transferItemToLoc(beaker, src))
			return ITEM_INTERACT_BLOCKING

		var/is_right_clicking = LAZYACCESS(modifiers, RIGHT_CLICK)
		replace_beaker(user, !is_right_clicking, beaker)
		to_chat(user, span_notice("You add [beaker] to [is_right_clicking ? "output" : "input"] slot."))
		update_appearance()
		ui_interact(user)
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/machinery/chem_mass_spec/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(processing_reagents)
		balloon_alert(user, "still processing!")
		return .

	if(default_unfasten_wrench(user, tool) == SUCCESSFUL_UNFASTEN)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/chem_mass_spec/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(processing_reagents)
		balloon_alert(user, "still processing!")
		return .

	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		update_appearance()
		return ITEM_INTERACT_SUCCESS

/obj/machinery/chem_mass_spec/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(processing_reagents)
		balloon_alert(user, "still processing!")
		return .

	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS


/**
 * Computes either the lightest or heaviest reagent in the input beaker
 * Arguments
 *
 * * smallest - TRUE to find lightest reagent, FALSE to find heaviest reagent
 */
/obj/machinery/chem_mass_spec/proc/calculate_mass(smallest = TRUE)
	PRIVATE_PROC(TRUE)
	SHOULD_BE_PURE(TRUE)

	if(QDELETED(beaker1))
		return 0

	var/result = 0
	for(var/datum/reagent/reagent as anything in beaker1?.reagents.reagent_list)
		var/datum/reagent/target = reagent
		if(!istype(reagent, /datum/reagent/inverse) && (reagent.inverse_chem_val > reagent.purity && reagent.inverse_chem))
			target = GLOB.chemical_reagents_list[reagent.inverse_chem]

		if(!result)
			result = target.mass
		else
			result = smallest ? min(result, reagent.mass) : max(result, reagent.mass)
	return smallest ? FLOOR(result, 50) : CEILING(result, 50)

/*
 * Replaces a beaker in the machine, either input or output
 * Arguments
 *
 * * user - The one bonking the machine
 * * target beaker - the target beaker we are trying to replace
 * * new beaker - the new beaker to add/replace the slot with
 */
/obj/machinery/chem_mass_spec/proc/replace_beaker(mob/living/user, is_input, obj/item/reagent_containers/new_beaker)
	PRIVATE_PROC(TRUE)

	if(is_input) //replace input beaker
		if(!QDELETED(beaker1))
			try_put_in_hand(beaker1, user)
		beaker1 = new_beaker
		lower_mass_range = calculate_mass(smallest = TRUE)
		upper_mass_range = calculate_mass(smallest = FALSE)
		estimate_time()
	else //replace output beaker
		if(!QDELETED(beaker2))
			try_put_in_hand(beaker2, user)
		beaker2 = new_beaker
		log.Cut()

	update_appearance()

///Computes time to purity reagents
/obj/machinery/chem_mass_spec/proc/estimate_time()
	PRIVATE_PROC(TRUE)

	delay_time = 0
	if(QDELETED(beaker1))
		return

	for(var/datum/reagent/reagent as anything in beaker1.reagents.reagent_list)
		//we don't deal chems that are so impure that they are about to become inverted
		if(reagent.inverse_chem_val > reagent.purity && reagent.inverse_chem)
			continue
		//out of our selected range
		if(reagent.mass < lower_mass_range || reagent.mass > upper_mass_range)
			continue
		//already at max purity
		if((initial(reagent.purity) - reagent.purity) <= 0)
			continue
		///Roughly 10 - 30s?
		delay_time += (((reagent.mass * reagent.volume) + (reagent.mass * reagent.get_inverse_purity() * 0.1)) * 0.0035) + 10

	delay_time *= cms_coefficient

/obj/machinery/chem_mass_spec/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MassSpec", name)
		ui.open()

/obj/machinery/chem_mass_spec/ui_data(mob/user)
	. = list()
	.["lowerRange"] = lower_mass_range
	.["upperRange"] = upper_mass_range
	.["processing"] = processing_reagents
	.["eta"] = delay_time - progress_time
	.["peakHeight"] = 0

	//input reagents
	var/list/beaker1Data = null
	if(!QDELETED(beaker1))
		beaker1Data = list()
		var/datum/reagents/beaker_1_reagents = beaker1.reagents
		beaker1Data["currentVolume"] = beaker_1_reagents.total_volume
		beaker1Data["maxVolume"] = beaker_1_reagents.maximum_volume
		var/list/beakerContents = list()
		for(var/datum/reagent/reagent as anything in beaker_1_reagents.reagent_list)
			var/log = ""
			var/datum/reagent/target = reagent
			var/purity = target.purity
			var/is_inverse = FALSE

			if(reagent.inverse_chem_val > reagent.purity && reagent.inverse_chem)
				purity = target.get_inverse_purity()
				target = GLOB.chemical_reagents_list[reagent.inverse_chem]
				log = "Too impure to use" //we don't bother about impure chems
				is_inverse = TRUE
			else
				var/initial_purity = initial(reagent.purity)
				if((initial_purity - reagent.purity) <= 0) //already at max purity
					log = "Cannot purify above [round(initial_purity * 100)]%"
				else
					log = "Ready"

			beakerContents += list(list(
				"name" = target.name,
				"volume" = round(reagent.volume, CHEMICAL_VOLUME_ROUNDING),
				"mass" = target.mass,
				"purity" = round(purity * 100),
				"type" = is_inverse ? "Inverted" : "Clean",
				"log" = log
			))
			.["peakHeight"] = max(.["peakHeight"], reagent.volume)
		beaker1Data["contents"] = beakerContents
	.["beaker1"] = beaker1Data

	//+10 because of the range on the peak
	.["graphUpperRange"] = calculate_mass(smallest = FALSE)

	//output reagents
	var/list/beaker2Data = null
	if(!QDELETED(beaker2))
		beaker2Data = list()
		var/datum/reagents/beaker_2_reagents = beaker2.reagents
		beaker2Data["currentVolume"] = beaker_2_reagents.total_volume
		beaker2Data["maxVolume"] = beaker_2_reagents.maximum_volume
		var/list/beakerContents = list()
		for(var/datum/reagent/reagent as anything in beaker_2_reagents.reagent_list)
			beakerContents += list(list(
				"name" = reagent.name,
				"volume" = round(reagent.volume, CHEMICAL_VOLUME_ROUNDING),
				"mass" = reagent.mass,
				"purity" = round(reagent.purity * 100),
				"type" = "Clean",
				"log" = log[reagent.type]
			))
		beaker2Data["contents"] = beakerContents
	.["beaker2"] = beaker2Data

/obj/machinery/chem_mass_spec/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || processing_reagents)
		return

	switch(action)
		if("activate")
			if(QDELETED(beaker1))
				say("Missing input beaker!")
				return
			if(QDELETED(beaker2))
				say("Missing output beaker!")
				return

			//adjust timer for purification
			progress_time = 0
			estimate_time()
			if(delay_time <= 0)
				say("No work to be done!")
				return

			//start the purification process
			processing_reagents = TRUE
			begin_processing()
			update_appearance()

			return TRUE

		if("leftSlider")
			var/value = params["value"]
			if(isnull(value))
				return

			value = text2num(value)
			if(isnull(value))
				return

			lower_mass_range = clamp(value, calculate_mass(smallest = TRUE), (lower_mass_range + upper_mass_range) / 2)
			estimate_time()
			return TRUE

		if("rightSlider")
			var/value = params["value"]
			if(isnull(value))
				return

			value = text2num(value)
			if(isnull(value))
				return

			upper_mass_range = clamp(value, (lower_mass_range + upper_mass_range) / 2, calculate_mass(smallest = FALSE))
			estimate_time()
			return TRUE

		if("centerSlider")
			var/value = params["value"]
			if(isnull(value))
				return

			value = text2num(value)
			if(isnull(value))
				return

			var/delta_center = ((lower_mass_range + upper_mass_range) / 2) - params["value"]
			var/lowest = calculate_mass(smallest = TRUE)
			var/highest = calculate_mass(smallest = FALSE)
			lower_mass_range = clamp(lower_mass_range - delta_center, lowest, highest)
			upper_mass_range = clamp(upper_mass_range - delta_center, lowest, highest)
			estimate_time()

			return TRUE

		if("eject1")
			replace_beaker(ui.user, TRUE)
			return TRUE

		if("eject2")
			replace_beaker(ui.user, FALSE)
			return TRUE

/obj/machinery/chem_mass_spec/click_alt(mob/living/user)
	if(processing_reagents)
		balloon_alert(user, "still processing!")
		return CLICK_ACTION_BLOCKING
	replace_beaker(user, TRUE)
	return CLICK_ACTION_SUCCESS

/obj/machinery/chem_mass_spec/click_alt_secondary(mob/living/user)
	if(processing_reagents)
		balloon_alert(user, "still processing!")
		return
	replace_beaker(user, FALSE)

/obj/machinery/chem_mass_spec/process(seconds_per_tick)
	if(!processing_reagents)
		return PROCESS_KILL

	if(!is_operational || panel_open || !anchored)
		return

	progress_time += seconds_per_tick
	if(progress_time >= delay_time)
		processing_reagents = FALSE
		progress_time = 0

		log.Cut()
		for(var/datum/reagent/reagent as anything in beaker1.reagents.reagent_list)
			//we don't deal chems that are so impure that they are about to become inverted
			if(reagent.inverse_chem_val > reagent.purity && reagent.inverse_chem)
				continue
			//out of our selected range
			if(reagent.mass < lower_mass_range || reagent.mass > upper_mass_range)
				continue
			//already at max purity
			var/delta_purity = initial(reagent.purity) - reagent.purity
			if(delta_purity <= 0)
				continue
			//add the purified reagent. More impure reagents will yield smaller amounts
			var/product_vol = reagent.volume
			beaker1.reagents.remove_reagent(reagent.type, product_vol)
			beaker2.reagents.add_reagent(reagent.type, product_vol * (1 - delta_purity), reagtemp = beaker1.reagents.chem_temp, added_purity = initial(reagent.purity), added_ph = reagent.ph)
			log[reagent.type] = "Purified to [initial(reagent.purity) * 100]%"

		//recompute everything
		lower_mass_range = calculate_mass(smallest = TRUE)
		upper_mass_range = calculate_mass(smallest = FALSE)
		estimate_time()
		update_appearance()
		return PROCESS_KILL

	use_energy(active_power_usage * seconds_per_tick)
