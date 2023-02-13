
#define BEAKER1 1
#define BEAKER2 2

/obj/machinery/chem_mass_spec
	name = "High-performance liquid chromatography machine"
	desc = {"This machine can separate reagents based on charge, meaning it can clean reagents of some of their impurities, unlike the Chem Master 3000.
By selecting a range in the mass spectrograph certain reagents will be transferred from one beaker to another, which will clean it of any impurities up to a certain amount.
This will not clean any inverted reagents. Inverted reagents will still be correctly detected and displayed on the scanner, however.
\nLeft click with a beaker to add it to the input slot, Right click with a beaker to add it to the output slot. Alt + left/right click can let you quickly remove the corresponding beaker."}
	density = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "HPLC"
	base_icon_state = "HPLC"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.2
	resistance_flags = FIRE_PROOF | ACID_PROOF
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

	AddElement( \
		/datum/element/contextual_screentip_bare_hands, \
		lmb_text = "Add input beaker", \
		rmb_text = "Add output beaker", \
	)

/obj/machinery/chem_mass_spec/Destroy()
	QDEL_NULL(beaker1)
	QDEL_NULL(beaker2)
	return ..()

/obj/machinery/chem_mass_spec/RefreshParts()
	. = ..()
	cms_coefficient = 1
	for(var/datum/stock_part/micro_laser/laser in component_parts)
		cms_coefficient /= laser.tier

/obj/machinery/chem_mass_spec/deconstruct(disassembled)
	if(beaker1)
		beaker1.forceMove(drop_location())
		beaker1 = null
	if(beaker2)
		beaker2.forceMove(drop_location())
		beaker2 = null
	. = ..()

/obj/machinery/chem_mass_spec/update_overlays()
	. = ..()
	if(panel_open)
		. += mutable_appearance(icon, "[base_icon_state]_panel-o")

/obj/machinery/chem_mass_spec/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/*			beaker swapping/attack code			*/
/obj/machinery/chem_mass_spec/attackby(obj/item/item, mob/user, params)
	if(processing_reagents)
		to_chat(user, "<span class='notice'> The [src] is currently processing a batch!")
		return ..()

	if(default_deconstruction_screwdriver(user, icon_state, icon_state, item))
		update_appearance()
		return

	if(is_reagent_container(item) && !(item.item_flags & ABSTRACT) && item.is_open_container())
		var/obj/item/reagent_containers/beaker = item
		. = TRUE //no afterattack
		if(!user.transferItemToLoc(beaker, src))
			return
		replace_beaker(user, BEAKER1, beaker)
		to_chat(user, span_notice("You add [beaker] to [src]."))
		update_appearance()
		ui_interact(user)
		return
	..()

/obj/machinery/chem_mass_spec/attackby_secondary(obj/item/item, mob/user, params)
	. = ..()

	if(processing_reagents)
		to_chat(user, "<span class='notice'> The [src] is currently processing a batch!")
		return

	if(default_deconstruction_crowbar(item))
		return

	if(is_reagent_container(item) && !(item.item_flags & ABSTRACT) && item.is_open_container())
		var/obj/item/reagent_containers/beaker = item
		if(!user.transferItemToLoc(beaker, src))
			return
		replace_beaker(user, BEAKER2, beaker)
		to_chat(user, span_notice("You add [beaker] to [src]."))
		ui_interact(user)
		. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	update_appearance()

/obj/machinery/chem_mass_spec/AltClick(mob/living/user)
	. = ..()
	if(processing_reagents)
		to_chat(user, "<span class='notice'> The [src] is currently processing a batch!")
		return
	if(!can_interact(user) || !user.canUseTopic(src, be_close = TRUE, no_dexterity = FALSE, no_tk = TRUE))
		return ..()
	replace_beaker(user, BEAKER1)

/obj/machinery/chem_mass_spec/alt_click_secondary(mob/living/user)
	. = ..()
	if(processing_reagents)
		to_chat(user, "<span class='notice'> The [src] is currently processing a batch!")
		return
	if(!can_interact(user) || !user.canUseTopic(src, be_close = TRUE, no_dexterity = FALSE, no_tk = TRUE))
		return
	replace_beaker(user, BEAKER2)

///Gee how come you get two beakers?
/*
 * Similar to other replace beaker procs, except now there are two of them!
 * When passed a beaker along with a position define it will swap a beaker in that slot (if there is one) with the beaker the machine is bonked with
 *
 * arguments:
 * * user - The one bonking the machine
 * * target beaker - the define (BEAKER1/BEAKER2) of what position to replace
 * * new beaker - the new beaker to add/replace the slot with
 */
/obj/machinery/chem_mass_spec/proc/replace_beaker(mob/living/user, target_beaker, obj/item/reagent_containers/new_beaker)
	if(!user)
		return FALSE
	switch(target_beaker)
		if(BEAKER1)
			if(beaker1)
				try_put_in_hand(beaker1, user)
				beaker1 = null
			beaker1 = new_beaker
			lower_mass_range = calculate_smallest_mass()
			upper_mass_range = calculate_largest_mass()
		if(BEAKER2)
			if(beaker2)
				try_put_in_hand(beaker2, user)
				beaker2 = null
			beaker2 = new_beaker
	update_appearance()
	return TRUE

/*			Icon code			*/

/obj/machinery/chem_mass_spec/update_icon_state()
	if(powered())
		icon_state = "HPLC_on"
	else
		icon_state = "HPLC"
	return ..()

/obj/machinery/chem_mass_spec/update_overlays()
	. = ..()
	if(beaker1)
		. += "HPLC_beaker1"
	if(beaker2)
		. += "HPLC_beaker2"
	if(powered())
		if(processing_reagents)
			. += "HPLC_graph_active"
		else if (length(beaker1?.reagents.reagent_list))
			. += "HPLC_graph_idle"

/*			UI Code				*/

/obj/machinery/chem_mass_spec/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MassSpec", name)
		ui.open()

/obj/machinery/chem_mass_spec/ui_data(mob/user)
	var/data = list()
	data["graphLowerRange"] = 0
	data["lowerRange"] = lower_mass_range
	data["upperRange"] = upper_mass_range
	data["processing"] = processing_reagents
	data["log"] = log
	data["beaker1"] = beaker1 ? TRUE : FALSE
	data["beaker2"] = beaker2 ? TRUE : FALSE
	if(processing_reagents)
		data["eta"] = delay_time - progress_time
	else
		data["eta"] = estimate_time()

	var/beakerContents[0]
	if(beaker1 && beaker1.reagents)
		for(var/datum/reagent/reagent as anything in beaker1.reagents.reagent_list)
			var/in_range = TRUE
			if(reagent.inverse_chem_val > reagent.purity && reagent.inverse_chem)
				var/datum/reagent/inverse_reagent = GLOB.chemical_reagents_list[reagent.inverse_chem]
				if(inverse_reagent.mass < lower_mass_range || inverse_reagent.mass > upper_mass_range)
					in_range = FALSE
				beakerContents.Add(list(list("name" = inverse_reagent.name, "volume" = round(reagent.volume, 0.01), "mass" = inverse_reagent.mass, "purity" = round(reagent.get_inverse_purity(), 0.000001)*100, "selected" = in_range, "color" = "#b60046", "type" = "Inverted")))
				data["peakHeight"] = max(data["peakHeight"], reagent.volume)
				continue
			if(reagent.mass < lower_mass_range || reagent.mass > upper_mass_range)
				in_range = FALSE
			///We want to be sure that the impure chem appears after the parent chem in the list so that it always overshadows pure reagents
			beakerContents.Add(list(list("name" = reagent.name, "volume" = round(reagent.volume, 0.01), "mass" = reagent.mass, "purity" = round(reagent.purity, 0.000001)*100, "selected" = in_range, "color" = "#3cf096", "type" = "Clean")))
			data["peakHeight"] = max(data["peakHeight"], reagent.volume)

		data["beaker1CurrentVolume"] = beaker1.reagents.total_volume
		data["beaker1MaxVolume"] = beaker1.reagents.maximum_volume
	data["beaker1Contents"] = beakerContents
	data["graphUpperRange"] = calculate_largest_mass()  //+10 because of the range on the peak

	beakerContents = list()
	if(beaker2 && beaker2.reagents)
		for(var/datum/reagent/reagent in beaker2.reagents.reagent_list)
			///Normal stuff
			beakerContents.Add(list(list("name" = reagent.name, "volume" = round(reagent.volume, 0.01), "mass" = reagent.mass, "purity" = round(reagent.purity, 0.000001)*100, "color" = "#3cf096", "type" = "Clean", log = log[reagent.type])))
		data["beaker2CurrentVolume"] = beaker2.reagents.total_volume
		data["beaker2MaxVolume"] = beaker2.reagents.maximum_volume
	data["beaker2Contents"] = beakerContents

	return data

/obj/machinery/chem_mass_spec/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("activate")
			if(!beaker1 || !beaker2 || !is_operational)
				say("This [src] is missing an output beaker!")
				return
			if(processing_reagents)
				say("You shouldn't be seeing this message! Please report this bug to https://github.com/tgstation/tgstation/issues . Thank you!")
				stack_trace("Someone managed to break the HPLC and tried to get it to activate when it's already activated!")
				return
			processing_reagents = TRUE
			estimate_time()
			progress_time = 0
			update_appearance()
			begin_processing()
			. = TRUE
		if("leftSlider")
			if(!is_operational || processing_reagents)
				return
			var/current_center = (lower_mass_range + upper_mass_range)/2
			lower_mass_range = clamp(params["value"], calculate_smallest_mass(), current_center)
			. = TRUE
		if("rightSlider")
			if(!is_operational || processing_reagents)
				return
			var/current_center = (lower_mass_range + upper_mass_range)/2
			upper_mass_range = clamp(params["value"], current_center, calculate_largest_mass())
			. = TRUE
		if("centerSlider")
			if(!is_operational || processing_reagents)
				return
			var/current_center = (lower_mass_range + upper_mass_range)/2
			var/delta_center = current_center - params["value"]
			var/lowest = calculate_smallest_mass()
			var/highest = calculate_largest_mass()
			lower_mass_range = clamp(lower_mass_range - delta_center, lowest, highest)
			upper_mass_range = clamp(upper_mass_range - delta_center, lowest, highest)
			. = TRUE
		if("eject1")
			if(processing_reagents)
				return
			replace_beaker(usr, BEAKER1)
			. = TRUE
		if("eject2")
			if(processing_reagents)
				return
			replace_beaker(usr, BEAKER2)
			. = TRUE

/*				processing procs				*/

///Increments time if it's progressing - if it's past time then it purifies and stops processing
/obj/machinery/chem_mass_spec/process(delta_time)
	. = ..()
	if(!is_operational)
		return FALSE
	if(!processing_reagents)
		return TRUE
	use_power(active_power_usage)
	if(progress_time >= delay_time)
		processing_reagents = FALSE
		progress_time = 0
		purify_reagents()
		end_processing()
		update_appearance()
		return TRUE
	progress_time += delta_time
	return FALSE

/*
 * Processing through the reagents in beaker 1
 * For all the reagents within the selected range - we will then purify them up to their initial purity (usually 75%). It will take away the relative reagent volume from the sum volume of the reagent however.
 * If there are any inverted reagents - then it will instead just create a new reagent of the inverted type. This doesn't really do anything other than change the name of it,
 * As it processes through the reagents, it saves what changes were applied to each reagent in a log var to show the results at the end
 */
/obj/machinery/chem_mass_spec/proc/purify_reagents()
	log = list()
	for(var/datum/reagent/reagent as anything in beaker1.reagents.reagent_list)
		//Inverse first
		var/volume = reagent.volume
		if(reagent.inverse_chem_val > reagent.purity && reagent.inverse_chem)
			var/datum/reagent/inverse_reagent = GLOB.chemical_reagents_list[reagent.inverse_chem]
			if(inverse_reagent.mass < lower_mass_range || inverse_reagent.mass > upper_mass_range)
				continue
			log += list(inverse_reagent.type = "Cannot purify inverted") //Might as well make it do something - just updates the reagent's name
			beaker2.reagents.add_reagent(reagent.inverse_chem, volume, reagtemp = beaker1.reagents.chem_temp, added_purity = reagent.get_inverse_purity())
			beaker1.reagents.remove_reagent(reagent.type, volume)
			continue

		if(reagent.mass < lower_mass_range || reagent.mass > upper_mass_range)
			continue

		var/delta_purity = initial(reagent.purity) - reagent.purity
		if(delta_purity <= 0)//As pure as we can be - so lets not add more than we need
			log += list(reagent.type = "Can't purify over [initial(reagent.purity)*100]%")
			beaker2.reagents.add_reagent(reagent.type, volume, reagtemp = beaker1.reagents.chem_temp, added_purity = reagent.purity, added_ph = reagent.ph)
			beaker1.reagents.remove_reagent(reagent.type, volume)
			continue

		var/product_vol = reagent.volume * (1-delta_purity)
		beaker2.reagents.add_reagent(reagent.type, product_vol, reagtemp = beaker1.reagents.chem_temp, added_purity = initial(reagent.purity), added_ph = reagent.ph)
		beaker1.reagents.remove_reagent(reagent.type, reagent.volume)
		log += list(reagent.type = "Purified to [initial(reagent.purity)*100]%")

/*				Mass spec graph calcs		 	 */

///Returns the largest mass to the nearest 50 (rounded up)
/obj/machinery/chem_mass_spec/proc/calculate_largest_mass()
	if(!beaker1?.reagents)
		return 0
	var/max_mass = 0
	for(var/datum/reagent/reagent as anything in beaker1.reagents.reagent_list)
		if(reagent.inverse_chem_val > reagent.purity && reagent.inverse_chem)
			var/datum/reagent/inverse_reagent = GLOB.chemical_reagents_list[reagent.inverse_chem]
			max_mass = max(max_mass, inverse_reagent.mass)
			continue
		max_mass = max(max_mass, reagent.mass)
	return CEILING(max_mass, 50)

///Returns the smallest mass to the nearest 50 (rounded down)
/obj/machinery/chem_mass_spec/proc/calculate_smallest_mass()
	if(!beaker1?.reagents)
		return 0
	var/min_mass = 0
	for(var/datum/reagent/reagent as anything in beaker1.reagents.reagent_list)
		if(reagent.inverse_chem_val > reagent.purity && reagent.inverse_chem)
			var/datum/reagent/inverse_reagent = GLOB.chemical_reagents_list[reagent.inverse_chem]
			min_mass = min(min_mass, inverse_reagent.mass)
			continue
		min_mass = min(min_mass, reagent.mass)
	return FLOOR(min_mass, 50)

/*
 * Estimates how long the highlighted range will take to process
 * The time will increase based off the reagent's volume, mass and purity.
 * In most cases this is between 10 to 30s for a single reagent.
 * This is why having a higher mass for a reagent is a balancing tool.
 */
/obj/machinery/chem_mass_spec/proc/estimate_time()
	if(!beaker1?.reagents)
		return 0
	var/time = 0
	for(var/datum/reagent/reagent as anything in beaker1.reagents.reagent_list)
		if(reagent.inverse_chem_val > reagent.purity && reagent.inverse_chem)
			var/datum/reagent/inverse_reagent = GLOB.chemical_reagents_list[reagent.inverse_chem]
			if(inverse_reagent.mass < lower_mass_range || inverse_reagent.mass > upper_mass_range)
				continue
			time += (((inverse_reagent.mass * reagent.volume) + (inverse_reagent.mass * reagent.purity * 0.1)) * 0.003) + 10 ///Roughly 10 - 30s?
			continue
		if(reagent.mass < lower_mass_range || reagent.mass > upper_mass_range)
			continue
		time += (((reagent.mass * reagent.volume) + (reagent.mass * reagent.get_inverse_purity() * 0.1)) * 0.0035) + 10 ///Roughly 10 - 30s?
	delay_time = (time * cms_coefficient)
	return delay_time
