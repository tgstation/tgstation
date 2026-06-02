/**
 * Your new favorite industrial waste magnet!
 * Accepts boulders and produces sheets of non-metallic materials.
 * When upgraded, it can hold more boulders and process more at once.
 */
/obj/machinery/bouldertech/refinery
	name = "boulder refinery"
	desc = "Accepts boulders and refines non-metallic ores into sheets using internal chemicals."
	icon_state = "stacker"
	base_icon_state = "stacker"
	circuit = /obj/item/circuitboard/machine/refinery
	usage_sound = 'sound/machines/mining/refinery.ogg'
	action = "crushing"
	waste_chemical = /datum/reagent/toxin/acid/industrial_waste
	pixel_y = 1

/obj/machinery/bouldertech/refinery/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/plumbing/boulder_reactions)
	AddElement(/datum/element/simple_rotation)
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/bouldertech/refinery/update_icon_state()
	. = ..()
	set_light_on(anchored && is_operational && !panel_open)

/obj/machinery/bouldertech/refinery/create_reagents(max_vol, flags)
	QDEL_NULL(reagents)
	reagents = new /datum/reagents/plumbing(max_vol, flags)
	reagents.my_atom = src

/obj/machinery/bouldertech/refinery/get_booster_reagents()
	var/static/list/booster_reagents
	if(!length(booster_reagents))
		booster_reagents = list(
			/datum/reagent/toxin/acid = 1,
			/datum/reagent/toxin/acid/fluacid = 2,
			/datum/reagent/toxin/acid/nitracid = 3,
			/datum/reagent/teslium = 5,
		)
	return booster_reagents

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
		create_reagents(new_volume, OPENCONTAINER)
	reagents.maximum_volume = new_volume


/obj/machinery/bouldertech/refinery/check_for_boosts()
	. = ..() //resets to 1.00 efficiency in the parent

	var/highest_boost = 0
	var/datum/reagent/biggest_booster
	var/list/datum/reagents/booster_list = get_booster_reagents()
	for(var/datum/reagent/booster as anything in booster_list)
		var/booster_volume = booster_list[booster]
		if(!reagents.has_reagent(booster, booster_volume)) //check that we have the associated quantity of the chem in order to perform the boost.
			continue
		if(booster_list[booster] > highest_boost)
			highest_boost = booster_volume
			biggest_booster = booster

	if(!biggest_booster)
		return

	reagents.remove_reagent(biggest_booster, highest_boost) //remove the associated amount from the reagents
	refining_efficiency = 1 + (highest_boost / 10) //Results in a boost from 10-30%
	reagents.add_reagent(waste_chemical, highest_boost)

/obj/machinery/bouldertech/refinery/plunger_act(obj/item/plunger/attacking_plunger, mob/living/user, reinforced)
	. = ..()
	balloon_alert(user, "emptying...")
	if(do_after(user, 2 SECONDS, src))
		reagents.expose(drop_location())
		reagents.clear_reagents()


/**
 * Your other new favorite industrial waste magnet!
 * Accepts boulders and produces sheets of metallic materials.
 * When upgraded, it can hold more boulders and process more at once.
 */
/obj/machinery/bouldertech/refinery/smelter
	name = "boulder smelter"
	desc = "Accept boulders and refines metallic ores into sheets."
	icon_state = "smelter"
	base_icon_state = "smelter"
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 3
	light_color = "#ffaf55"
	circuit = /obj/item/circuitboard/machine/smelter
	usage_sound = 'sound/machines/mining/smelter.ogg'
	action = "smelting"
	pixel_x = -1

/obj/machinery/bouldertech/refinery/smelter/Initialize(mapload)
	. = ..()
	update_light_value()


/obj/machinery/bouldertech/refinery/smelter/get_booster_reagents()
	var/static/list/booster_reagents
	if(!length(booster_reagents))
		booster_reagents = list(
			/datum/reagent/fuel = 1,
			/datum/reagent/thermite = 2,
			/datum/reagent/gunpowder = 3,
			/datum/reagent/liquid_dark_matter = 5,
		)
	return booster_reagents

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

/obj/machinery/bouldertech/refinery/smelter/proc/update_light_value()
	set_light_on(!panel_open && anchored && is_operational)

/obj/machinery/bouldertech/refinery/smelter/on_set_anchored(atom/movable/source, anchorvalue)
	update_light_value()

/obj/machinery/bouldertech/refinery/smelter/on_set_is_operational(old_value)
	update_light_value()

/obj/machinery/bouldertech/refinery/smelter/on_set_panel_open(old_value)
	update_light_value()

/obj/machinery/bouldertech/refinery/smelter/maim_golem(mob/living/carbon/human/rockman)
	rockman.visible_message(span_warning("[rockman] is processed by [src]!"), span_userdanger("You get melted into rock by [src]!"))
	rockman.investigate_log("was melted by [src] for being a golem", INVESTIGATE_DEATHS)
	rockman.dust()
