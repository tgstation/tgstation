
#define BEAKER1 1
#define BEAKER2 2

/obj/machinery/chem_mass_spec
	name = "High-performance liquid chromatography machine"
	desc = {"This machine can separate reagents based on charge, meaning it can clean reagents of some of their impurities, unlike the Chem Master 3000.
By selecting a range in the mass spectrograph certain reagents will be transferred from one beaker to another, which will clean it of any impurities up to a certain amount.
This will not clean any inverted reagents. Inverted reagents will still be correctly detected and displayed on the scanner, however.
\nLeft click with a beaker to add it to the input slot, Right click with a beaker to add it to the output slot. Alt + left/right click can let you quickly remove the corrisponding beaker too."}
	density = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'icons/obj/chemical.dmi'
	icon_state = "HPLC"
	base_icon_state = "HPLC"
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	resistance_flags = FIRE_PROOF | ACID_PROOF
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
	var/log
	///Input reagents container
	var/obj/item/reagent_containers/beaker1
	///Output reagents container
	var/obj/item/reagent_containers/beaker2
	///Overlays for the beakers
	var/mutable_appearance/beaker1_overlay
	var/mutable_appearance/beaker2_overlay
	///Overlay for activity
	var/mutable_appearance/processing_overlay

/obj/machinery/chem_mass_spec/Initialize()
	. = ..()
	beaker1_overlay = mutable_appearance(icon, "HPLC_beaker")
	beaker2_overlay = mutable_appearance(icon, "HPLC_beaker")
	beaker2_overlay.pixel_x = 5
	processing_overlay = mutable_appearance(icon, "HPLC_graph")
	beaker2 = new /obj/item/reagent_containers/glass/beaker/large(src)


/obj/machinery/chem_mass_spec/Destroy()
	QDEL_NULL(beaker1)
	QDEL_NULL(beaker2)
	return ..()

/*			beaker swapping/attack code			*/

///Adds beaker 1
/obj/machinery/chem_mass_spec/attackby(obj/item/item, mob/user, params)
	if(processing_reagents)
		to_chat(user, "<span class='notice'> The [src] is currently processing a batch!")
		return ..()
	if(istype(item, /obj/item/reagent_containers) && !(item.item_flags & ABSTRACT) && item.is_open_container())
		var/obj/item/reagent_containers/beaker = item
		. = TRUE //no afterattack
		if(!user.transferItemToLoc(beaker, src))
			return
		replace_beaker(user, BEAKER1, beaker)
		to_chat(user, "<span class='notice'>You add [beaker] to [src].</span>")
		updateUsrDialog()
	update_icon_state()
	..()

///Adds beaker 2
/obj/machinery/chem_mass_spec/attackby_secondary(obj/item/item, mob/user, params)
	if(processing_reagents)
		to_chat(user, "<span class='notice'> The [src] is currently processing a batch!")
		return
	if(istype(item, /obj/item/reagent_containers) && !(item.item_flags & ABSTRACT) && item.is_open_container())
		var/obj/item/reagent_containers/beaker = item
		if(!user.transferItemToLoc(beaker, src))
			return
		replace_beaker(user, BEAKER2, beaker)
		to_chat(user, "<span class='notice'>You add [beaker] to [src].</span>")
		updateUsrDialog()
	update_icon_state()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	//The beaker keeps splashing itself onto the machine! aaaa

/obj/machinery/chem_mass_spec/AltClick(mob/living/user)
	. = ..()
	if(!can_interact(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return ..()
	replace_beaker(user, BEAKER1)

/obj/machinery/chem_mass_spec/AltClick_secondary(mob/living/user)
	. = ..()
	if(!can_interact(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	replace_beaker(user, BEAKER2)

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
			lower_mass_range = calculate_smallest_mass()
			upper_mass_range = calculate_largest_mass()
	update_icon_state()
	return TRUE

/*			Icon code			*/

/obj/machinery/chem_mass_spec/update_icon_state()
	. = ..()
	if(powered())
		icon_state = "HPLC_on"
	else
		icon_state = "HPLC"
	update_overlays()

/obj/machinery/chem_mass_spec/update_overlays()
	. = ..()
	if(beaker1)
		. += beaker1_overlay
	if(beaker2)
		. += beaker2_overlay
	if(processing_reagents)
		. += processing_overlay

/*			UI Code				*/

/obj/machinery/chem_mass_spec/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MassSpec", name)
		ui.open()

/obj/machinery/chem_mass_spec/ui_data(mob/user)
	var/data = list()
	data["graphUpperRange"] = calculate_largest_mass()
	data["graphLowerRange"] = calculate_smallest_mass()
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
	if(beaker1 && beaker1.reagents && beaker1.reagents.reagent_list.len)
		for(var/datum/reagent/reagent in beaker1.reagents.reagent_list)
			var/in_range = TRUE
			data["peakHeight"] = max(data["peakHeight"], reagent.volume)

			if(reagent.inverse_chem_val > reagent.purity && reagent.inverse_chem)
				var/datum/reagent/inverse_reagent = GLOB.chemical_reagents_list[reagent.impure_chem]
				if(inverse_reagent.mass < lower_mass_range || inverse_reagent.mass > upper_mass_range)
					in_range = FALSE
				beakerContents.Add(list(list("name" = inverse_reagent.name, "volume" = round(reagent.volume, 0.01), "mass" = inverse_reagent.mass, "purity" = 1-reagent.purity, "inversePurity" = reagent.inverse_chem_val, "selected" = in_range, "color" = COLOR_RED)))
				continue
			if(reagent.mass < lower_mass_range || reagent.mass > upper_mass_range)
				in_range = FALSE
			if(1 > reagent.purity && reagent.impure_chem)
				var/datum/reagent/impure_reagent = GLOB.chemical_reagents_list[reagent.impure_chem]
				beakerContents.Add(list(list("name" = impure_reagent.name, "volume" = round(reagent.volume * (1-reagent.purity), 0.01), "mass" = reagent.mass, "purity" = 1-reagent.purity, "inversePurity" = reagent.inverse_chem_val, "selected" = in_range, "color" = COLOR_YELLOW)))
			beakerContents.Add(list(list("name" = reagent.name, "volume" = round(reagent.volume * reagent.purity, 0.01), "mass" = reagent.mass, "purity" = reagent.purity, "inversePurity" = reagent.inverse_chem_val, "selected" = in_range, "color" = COLOR_GREEN)))
	data["beaker1Contents"] = beakerContents

	beakerContents = list()
	if(beaker2 && beaker2.reagents && beaker2.reagents.reagent_list.len)
		for(var/datum/reagent/reagent in beaker2.reagents.reagent_list)
			data["beaker2Vol"] = beaker2.reagents.total_volume
			data["beaker2pH"] = beaker2.reagents.ph
			beakerContents.Add(list(list("name" = reagent.name, "volume" = round(reagent.volume, 0.01), "mass" = reagent.mass, "purity" = reagent.purity)))
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
			update_icon_state()
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

/obj/machinery/chem_mass_spec/process(delta_time)
	. = ..()
	if(!is_operational)
		return FALSE
	if(!processing_reagents)
		return TRUE
	if(progress_time >= delay_time)
		processing_reagents = FALSE
		progress_time = 0
		purify_reagents()
		end_processing()
		return TRUE
	progress_time += delta_time
	return FALSE

/obj/machinery/chem_mass_spec/proc/purify_reagents()
	log = list()
	for(var/datum/reagent/reagent as anything in beaker1.reagents.reagent_list)
		if(reagent.mass < lower_mass_range || reagent.mass > upper_mass_range)
			continue

		var/delta_purity = initial(reagent.purity) - reagent.purity
		if(delta_purity =< 0)//As pure as we can be - so lets not add more than we need
			log += "Could not purify [reagent.name] past it's standard purity of [initial(reagent.purity)*100]%\n"
			beaker2.reagents.add_reagent(reagent.type, reagent.volume, reagtemp = beaker1.reagents.chem_temp, added_purity = reagent.purity, added_ph = reagent.ph)
			beaker1.reagents.remove_reagent(reagent.type, reagent.volume)
			continue

		if(reagent.purity < reagent.inverse_chem_val) //Might as well make it do something
			beaker2.reagents.add_reagent(reagent.inverse_chem, reagent.volume, reagtemp = beaker1.reagents.chem_temp, added_purity = 1-reagent.purity)
			beaker1.reagents.remove_reagent(reagent.inverse_chem, reagent.volume)
			continue

		var/product_vol = reagent.volume * (1-delta_purity)
		beaker2.reagents.add_reagent(reagent.type, product_vol, reagtemp = beaker1.reagents.chem_temp, added_purity = initial(reagent.purity), added_ph = reagent.ph)
		beaker1.reagents.remove_reagent(reagent.type, reagent.volume)
		log += "Purified [reagent.name] to [initial(reagent.purity)*100]%\n"

/*				Mass spec graph calcs		 	 */

///Returns the largest mass to the nearest 50 (rounded up)
/obj/machinery/chem_mass_spec/proc/calculate_largest_mass()
	if(!beaker1?.reagents)
		return 0
	var/max_mass = 0
	for(var/datum/reagent/reagent as anything in beaker1.reagents.reagent_list)
		max_mass = max(max_mass, reagent.mass)
	return CEILING(max_mass, 50)

///Returns the smallest mass to the nearest 50 (rounded down)
/obj/machinery/chem_mass_spec/proc/calculate_smallest_mass()
	if(!beaker1?.reagents)
		return 0
	var/min_mass = 0
	for(var/datum/reagent/reagent as anything in beaker1.reagents.reagent_list)
		min_mass = min(min_mass, reagent.mass)
	return FLOOR(min_mass, 50)

///Estimates how long something will take to process
/obj/machinery/chem_mass_spec/proc/estimate_time()
	if(!beaker1?.reagents)
		return 0
	var/time = 0
	for(var/datum/reagent/reagent as anything in beaker1.reagents.reagent_list)
		if(reagent.mass < lower_mass_range || reagent.mass > upper_mass_range)
			continue
		if(reagent.purity < reagent.inverse_chem_val)
			continue
		var/inverse_purity = 1-reagent.purity
		time += (((reagent.mass * reagent.volume) + (reagent.mass * inverse_purity * 0.1)) * 0.0025) + 10 ///Roughly 10 - 30s?
	delay_time = time
	return delay_time
