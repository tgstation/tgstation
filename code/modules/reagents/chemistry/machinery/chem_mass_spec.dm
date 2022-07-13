
#define BEAKER1 1
#define BEAKER2 2

/obj/machinery/chem_mass_spec
	name = "High-performance liquid chromatography machine"
	desc = "This machine will accurately read out detected reagents and their masses in a batch. It can also detect if a reagent is inverted."	
	density = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'icons/obj/chemical.dmi'
	icon_state = "HPLC"
	base_icon_state = "HPLC"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.2
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_mass_spec
	///Lower mass range - for mass selection of what will be processed
	var/lower_mass_range = 0
	///Upper_mass_range - for mass selection of what will be processed
	var/upper_mass_range = INFINITY
	///The log output to clarify how the thing works
	var/list/log = list()
	///Input reagents container
	var/obj/item/reagent_containers/beaker1

/obj/machinery/chem_mass_spec/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, DO_NOT_SPLASH, src.type)

/obj/machinery/chem_mass_spec/examine()
	. += span_notice("Left-Click on the machine with a beaker to insert. Alt-Left-Click to remove.")

/obj/machinery/chem_mass_spec/Destroy()
	QDEL_NULL(beaker1)
	return ..()

/obj/machinery/chem_mass_spec/deconstruct(disassembled)
	if(beaker1)
		beaker1.forceMove(drop_location())
		beaker1 = null
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
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, item))
		update_appearance()
		return

	if(istype(item, /obj/item/reagent_containers) && !(item.item_flags & ABSTRACT) && item.is_open_container())
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

	if(default_deconstruction_crowbar(item))
		return

	if(istype(item, /obj/item/reagent_containers) && !(item.item_flags & ABSTRACT) && item.is_open_container())
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
	if(!can_interact(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return ..()
	replace_beaker(user, BEAKER1)

/obj/machinery/chem_mass_spec/alt_click_secondary(mob/living/user)
	. = ..()
	if(!can_interact(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
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
	if(powered() && length(beaker1?.reagents.reagent_list))
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
	data["log"] = log
	data["beaker1"] = beaker1 ? TRUE : FALSE

	var/beakerContents[0]
	if(beaker1 && beaker1.reagents)
		for(var/datum/reagent/reagent as anything in beaker1.reagents.reagent_list)
			var/in_range = TRUE
			if(reagent.inverse_chem_val > reagent.purity && reagent.inverse_chem)
				var/datum/reagent/inverse_reagent = GLOB.chemical_reagents_list[reagent.inverse_chem]
				if(inverse_reagent.mass < lower_mass_range || inverse_reagent.mass > upper_mass_range)
					in_range = FALSE
				beakerContents.Add(list(list("name" = inverse_reagent.name, "volume" = round(reagent.volume, 0.01), "mass" = inverse_reagent.mass, "purity" = 1-reagent.purity, "selected" = in_range, "color" = "#b60046", "type" = "Inverted")))
				data["peakHeight"] = max(data["peakHeight"], reagent.volume)
				continue
			if(reagent.mass < lower_mass_range || reagent.mass > upper_mass_range)
				in_range = FALSE
			///We want to be sure that the impure chem appears after the parent chem in the list so that it always overshadows pure reagents
			beakerContents.Add(list(list("name" = reagent.name, "volume" = round(reagent.volume, 0.01), "mass" = reagent.mass, "purity" = reagent.purity, "selected" = in_range, "color" = "#3cf096", "type" = "Clean")))
			data["peakHeight"] = max(data["peakHeight"], reagent.volume)

		data["beaker1CurrentVolume"] = beaker1.reagents.total_volume
		data["beaker1MaxVolume"] = beaker1.reagents.maximum_volume
	data["beaker1Contents"] = beakerContents
	data["graphUpperRange"] = calculate_largest_mass()  //+10 because of the range on the peak

	return data

/obj/machinery/chem_mass_spec/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("leftSlider")
			if(!is_operational)
				return
			var/current_center = (lower_mass_range + upper_mass_range)/2
			lower_mass_range = clamp(params["value"], calculate_smallest_mass(), current_center)
			. = TRUE
		if("rightSlider")
			if(!is_operational)
				return
			var/current_center = (lower_mass_range + upper_mass_range)/2
			upper_mass_range = clamp(params["value"], current_center, calculate_largest_mass())
			. = TRUE
		if("centerSlider")
			if(!is_operational)
				return
			var/current_center = (lower_mass_range + upper_mass_range)/2
			var/delta_center = current_center - params["value"]
			var/lowest = calculate_smallest_mass()
			var/highest = calculate_largest_mass()
			lower_mass_range = clamp(lower_mass_range - delta_center, lowest, highest)
			upper_mass_range = clamp(upper_mass_range - delta_center, lowest, highest)
			. = TRUE
		if("eject1")
			replace_beaker(usr, BEAKER1)
			. = TRUE

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
