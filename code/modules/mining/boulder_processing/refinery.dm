/**
 * Your new favorite industrial waste magnet!
 * Accepts boulders and produces sheets of non-metalic materials.
 * Can be upgraded with stock parts or through chemical inputs.
 * When upgraded, it can hold more boulders and process more at once.
 *
 * Chemical inputs can be used to boost the refinery's efficiency, but produces industrial waste, which eats through the station and is generally difficult to store.
 */

/obj/machinery/bouldertech/refinery
	name = "boulder refinery"
	desc = "BR for short. Accepts boulders and refines non-metallic ores into sheets. Can be upgraded with stock parts or through chemical inputs."
	icon_state = "stacker"
	holds_minerals = TRUE
	processable_materials = list(
		/datum/material/glass,
		/datum/material/plasma,
		/datum/material/diamond,
		/datum/material/bluespace,
		/datum/material/bananium,
		/datum/material/plastic,
	)
	circuit = /obj/item/circuitboard/machine/refinery
	usage_sound = 'sound/machines/mining/refinery.ogg'

	/// Reagents that we can use to wash the boulders
	var/list/allowed_reagents = list(
		/datum/reagent/toxin/acid/industrial_waste = 0.1,
		/datum/reagent/lube = 1.2,
		/datum/reagent/sorium = 1.5,
		/datum/reagent/toxin/acid/nitracid = 2.0,
	)
	/// Internal beaker for storing washing fluid
	var/obj/item/reagent_containers/cup/beaker/large/washing_input
	/// Reagent produced by boosting mineral output.
	var/datum/reagent/waste_chem = /datum/reagent/toxin/acid/industrial_waste
/// okay so var that holds mining points to claim
/// add total of pts from minerals mined in parent proc
/// then, little mini UI showing points to collect?

/obj/machinery/bouldertech/refinery/Initialize(mapload)
	. = ..()

	washing_input = new()
	create_reagents(100, TRANSPARENT)
	AddComponent(/datum/component/plumbing/selective, anchored, custom_receiver = washing_input.reagents, allowed_reagents = src.allowed_reagents)

/obj/machinery/bouldertech/refinery/RefreshParts()
	. = ..()
	var/manipulator_stack = 0
	var/matter_bin_stack = 0
	for(var/datum/stock_part/servo/servo in component_parts)
		manipulator_stack += ((servo.tier - 1))
	boulders_processing_max = clamp(manipulator_stack, 1, 6)
	for(var/datum/stock_part/matter_bin/bin in component_parts)
		matter_bin_stack += ((bin.tier))
	boulders_held_max = matter_bin_stack

/obj/machinery/bouldertech/refinery/check_for_boosts()
	. = ..()
	process_reagents()

/obj/machinery/bouldertech/refinery/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(istype(held_item, /obj/item/boulder))
		context[SCREENTIP_CONTEXT_LMB] = "Insert boulder"
	context[SCREENTIP_CONTEXT_RMB] = "Remove boulder"
	return CONTEXTUAL_SCREENTIP_SET

/**
 * Try and draw reagents and produce waste. Utilized when we have boosting chemicals to use.
 * Calls generate_waste() when successful.
 * @param volume: How much reagent to draw from the washing input.
 */
/obj/machinery/bouldertech/refinery/proc/process_reagents(volume = MACHINE_REAGENT_TRANSFER)
	say("Processing reagents!")
	if(volume > washing_input.reagents.total_volume) //not enough washing fluid
		return null

	if(reagents.maximum_volume < reagents.total_volume + volume) //we dont have enough space for waste!
		return null

	. = list() //keep track of which reagents we use and how much. list(type = volume)

	// Pull washing fluids from the washing input and remove it, but record they've been used
	for(var/datum/reagent/reagent as anything in washing_input.reagents.reagent_list)
		var/volume_to_draw = min(reagent.volume, volume)

		volume -= volume_to_draw
		.[reagent.type] = volume_to_draw
		washing_input.reagents.remove_reagent(reagent.type, volume_to_draw)
		refining_efficiency = max(allowed_reagents[reagent.type], refining_efficiency) //Set refining efficiency to the highest efficiency of the reagents used within the input reagents.
	say("efficiency is now [refining_efficiency]")
	generate_waste(.)

/**
 * Generate waste reagents, depending on boulders and washing fluid
 * @param used_reagents: list of reagents used to wash the boulders
 */
/obj/machinery/bouldertech/refinery/proc/generate_waste(list/used_reagents)
	var/total_waste = 0
	for(var/reagent_type as anything in used_reagents)
		switch(reagent_type)

			if(/datum/reagent/toxin/acid/fluacid)
				total_waste += used_reagents[reagent_type] * 4
				continue
			if(/datum/reagent/sorium)
				total_waste += used_reagents[reagent_type] * 2
				continue
			if(/datum/reagent/lube)
				total_waste += used_reagents[reagent_type]
				continue
	reagents.add_reagent(waste_chem, clamp(total_waste, 0, 100))

/**
 * Your other new favorite industrial waste magnet!
 * Accepts boulders and produces sheets of metalic materials.
 * Can be upgraded with stock parts or through chemical inputs.
 * When upgraded, it can hold more boulders and process more at once.
 *
 * Chemical inputs can be used to boost the refinery's efficiency, but produces industrial waste, which eats through the station and is generally difficult to store.
 */
/obj/machinery/bouldertech/refinery/smelter
	name = "boulder smeltery"
	desc = "BS for short. Accept boulders and refines metallic ores into sheets. Can be upgraded with stock parts or through gas inputs."
	icon_state = "furnace"
	holds_minerals = TRUE
	processable_materials = list(
		/datum/material/iron,
		/datum/material/titanium,
		/datum/material/silver,
		/datum/material/gold,
		/datum/material/uranium,
		/datum/material/mythril,
		/datum/material/adamantine,
		/datum/material/runite,
	)
	circuit = /obj/item/circuitboard/machine/smelter
	usage_sound = 'sound/machines/mining/smelter.ogg'

	/// Reagents that we can use to wash the boulders
	allowed_reagents = list(
		/datum/reagent/toxin/acid/industrial_waste = 0.1,
		/datum/reagent/pyrosium = 1.2,
		/datum/reagent/gunpowder = 1.5,
		/datum/reagent/medicine/c2/penthrite = 2.0,
	)
