/**
 * Your new favorite industrial waste magnet!
 * Accepts boulders and produces sheets of non-metallic materials.
 * When upgraded, it can hold more boulders and process more at once.
 */
/obj/machinery/bouldertech/refinery
	name = "boulder refinery"
	desc = "Accepts boulders and refines non-metallic ores into sheets using internal chemicals."
	icon_state = "stacker"
	circuit = /obj/item/circuitboard/machine/refinery
	usage_sound = 'sound/machines/mining/refinery.ogg'
	action = "crushing"
	waste_chemical = /datum/reagent/toxin/acid/industrial_waste

	/// What list of reagents should we look at when we boost the effectiveness of this machinery?
	booster_list = list(
		/datum/reagent/toxin/acid = 1,
		/datum/reagent/toxin/acid/nitracid = 2,
		/datum/reagent/teslium = 5,
	)

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

/obj/machinery/bouldertech/refinery/RefreshParts()
	. = ..()

	boulders_held_max = 0
	for(var/datum/stock_part/matter_bin/bin in component_parts)
		boulders_held_max += bin.tier

	boulders_processing_count = 0
	for(var/datum/stock_part/servo/servo in component_parts)
		boulders_processing_count += servo.tier
	boulders_processing_count = ROUND_UP((boulders_processing_count / 8) * boulders_held_max)

	var/new_volume = 0
	for(var/obj/item/reagent_containers/beaker in component_parts)
		new_volume += beaker.volume
	if(!reagents)
		create_reagents(new_volume, TRANSPARENT)
	reagents.maximum_volume = new_volume


/obj/machinery/bouldertech/refinery/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/plumbing/boulder_reactions)
	AddElement(/datum/element/simple_rotation)

/obj/machinery/bouldertech/refinery/check_for_boosts()
	. = ..() //resets to 1.00 efficiency in the parent
	var/highest_boost = 0
	var/datum/reagent/biggest_booster
	for(var/datum/reagent/chem in reagents.reagent_list)
		if(booster_list[chem.type])
			if(!reagents.has_reagent(chem.type, booster_list[chem.type])) //check that we have the associated quantity of the chem in order to perform the boost.
				continue
			if(booster_list[chem.type] > highest_boost)
				highest_boost = booster_list[chem.type]
				biggest_booster = chem.type

	if(!biggest_booster)
		return

	reagents.remove_reagent(biggest_booster, highest_boost) //remove the associated amount from the reagents
	refining_efficiency = 1 + (highest_boost / 10) //Results in a boost from 10-30%
	reagents.add_reagent(waste_chemical, highest_boost)

/obj/machinery/bouldertech/refinery/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	. = ..()
	set_light_on(TRUE)

/obj/machinery/bouldertech/refinery/default_unfasten_wrench(mob/user, obj/item/wrench, time)
	. = ..()
	set_light_on(TRUE)


/**
 * Your other new favorite industrial waste magnet!
 * Accepts boulders and produces sheets of metallic materials.
 * When upgraded, it can hold more boulders and process more at once.
 */
/obj/machinery/bouldertech/refinery/smelter
	name = "boulder smelter"
	desc = "Accept boulders and refines metallic ores into sheets."
	icon_state = "smelter"
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 3
	light_color = "#ffaf55"
	circuit = /obj/item/circuitboard/machine/smelter
	usage_sound = 'sound/machines/mining/smelter.ogg'
	action = "smelting"
	booster_list = list(
		/datum/reagent/fuel = 1,
		/datum/reagent/thermite = 2,
		/datum/reagent/liquid_dark_matter = 5,
	)

/obj/machinery/bouldertech/refinery/smelter/Initialize(mapload)
	. = ..()
	set_light_on(TRUE)

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

/obj/machinery/bouldertech/refinery/smelter/set_light_on(new_value)
	if(panel_open || !anchored || !is_operational || machine_stat & (BROKEN | NOPOWER))
		new_value = FALSE
	return ..()

/obj/machinery/bouldertech/refinery/smelter/on_set_is_operational(old_value)
	set_light_on(TRUE)

/obj/machinery/bouldertech/refinery/smelter/maim_golem(mob/living/carbon/human/rockman)
	rockman.visible_message(span_warning("[rockman] is processed by [src]!"), span_userdanger("You get melted into rock by [src]!"))
	rockman.investigate_log("was melted by [src] for being a golem", INVESTIGATE_DEATHS)
	rockman.dust()
