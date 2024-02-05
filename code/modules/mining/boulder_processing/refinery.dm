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
	desc = "BR for short. Accepts boulders and refines non-metallic ores into sheets using internal chemicals. Can be upgraded with stock parts or through chemical inputs."
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
	holds_mining_points = TRUE

/// okay so var that holds mining points to claim
/// add total of pts from minerals mined in parent proc
/// then, little mini UI showing points to collect?

/obj/machinery/bouldertech/refinery/RefreshParts()
	. = ..()
	var/manipulator_stack = 0
	var/matter_bin_stack = 0
	for(var/datum/stock_part/servo/servo in component_parts)
		manipulator_stack += servo.tier - 1
	boulders_processing_max = clamp(manipulator_stack, 1, 6)
	for(var/datum/stock_part/matter_bin/bin in component_parts)
		matter_bin_stack += bin.tier
	boulders_held_max = matter_bin_stack


/obj/machinery/bouldertech/refinery/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(istype(held_item, /obj/item/boulder))
		context[SCREENTIP_CONTEXT_LMB] = "Insert boulder"
	if(istype(held_item, /obj/item/card/id) && points_held > 0)
		context[SCREENTIP_CONTEXT_LMB] = "Claim mining points"
	context[SCREENTIP_CONTEXT_RMB] = "Remove boulder"
	return CONTEXTUAL_SCREENTIP_SET


/**
 * Your other new favorite industrial waste magnet!
 * Accepts boulders and produces sheets of metalic materials.
 * Can be upgraded with stock parts or through chemical inputs.
 * When upgraded, it can hold more boulders and process more at once.
 *
 * Chemical inputs can be used to boost the refinery's efficiency, but produces industrial waste, which eats through the station and is generally difficult to store.
 */
/obj/machinery/bouldertech/refinery/smelter
	name = "boulder smelter"
	desc = "BS for short. Accept boulders and refines metallic ores into sheets. Can be upgraded with stock parts or through gas inputs."
	icon_state = "smelter"
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
	light_system = MOVABLE_LIGHT
	light_range = 1
	light_power = 2
	light_color = "#ffaf55"
	light_on = FALSE
	circuit = /obj/item/circuitboard/machine/smelter
	usage_sound = 'sound/machines/mining/smelter.ogg'

/obj/machinery/bouldertech/refinery/smelter/RefreshParts()
	. = ..()
	light_power = boulders_processing_max

/obj/machinery/bouldertech/refinery/smelter/accept_boulder(obj/item/boulder/new_boulder)
	. = ..()
	if(.)
		set_light_on(TRUE)
		return TRUE


/obj/machinery/bouldertech/refinery/smelter/process()
	. = ..()
	if(. == PROCESS_KILL)
		set_light_on(FALSE)

