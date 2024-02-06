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
	circuit = /obj/item/circuitboard/machine/refinery
	usage_sound = 'sound/machines/mining/refinery.ogg'
	action = "crushing"

/obj/machinery/bouldertech/refinery/can_process_material(datum/material/possible_mat)
	var/static/list/processable_materials
	if(!length(processable_materials))
		processable_materials = list(
			/datum/material/glass,
			/datum/material/plasma,
			/datum/material/diamond,
			/datum/material/bluespace,
			/datum/material/bananium,
			/datum/material/plastic,
		)
	return is_type_in_list(possible_mat, processable_materials)

/// okay so var that holds mining points to claim
/// add total of pts from minerals mined in parent proc
/// then, little mini UI showing points to collect?
/obj/machinery/bouldertech/refinery/RefreshParts()
	. = ..()

	boulders_processing_power = 0
	for(var/datum/stock_part/servo/servo in component_parts)
		boulders_processing_power += servo.tier
	boulders_processing_power = ROUND_UP((boulders_processing_power / 8) * BOULDER_SIZE_MEDIUM)

	boulders_held_max = 0
	for(var/datum/stock_part/matter_bin/bin in component_parts)
		boulders_held_max += bin.tier

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
	light_system = MOVABLE_LIGHT
	light_range = 1
	light_power = 2
	light_color = "#ffaf55"
	light_on = FALSE
	circuit = /obj/item/circuitboard/machine/smelter
	usage_sound = 'sound/machines/mining/smelter.ogg'
	action = "smelting"

/obj/machinery/bouldertech/refinery/smelter/can_process_material(datum/material/possible_mat)
	var/static/list/processable_materials
	if(!length(processable_materials))
		processable_materials = list(
			/datum/material/iron,
			/datum/material/titanium,
			/datum/material/silver,
			/datum/material/gold,
			/datum/material/uranium,
		)
	return is_type_in_list(possible_mat, processable_materials)

/obj/machinery/bouldertech/refinery/smelter/on_set_is_operational(old_value)
	set_light_on(is_operational)

