/**
 * Your new favorite industrial waste magnet!
 * Accepts boulders and produces sheets of non-metallic materials.
 * When upgraded, it can hold more boulders and process more at once.
 */
/obj/machinery/bouldertech/refinery
	name = "boulder refinery"
	desc = "BR for short. Accepts boulders and refines non-metallic ores into sheets using internal chemicals."
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

/obj/machinery/bouldertech/refinery/RefreshParts()
	. = ..()

	boulders_held_max = 0
	for(var/datum/stock_part/matter_bin/bin in component_parts)
		boulders_held_max += bin.tier

	boulders_processing_count = 0
	for(var/datum/stock_part/servo/servo in component_parts)
		boulders_processing_count += servo.tier
	boulders_processing_count = ROUND_UP((boulders_processing_count / 8) * boulders_held_max)

/**
 * Your other new favorite industrial waste magnet!
 * Accepts boulders and produces sheets of metallic materials.
 * When upgraded, it can hold more boulders and process more at once.
 */
/obj/machinery/bouldertech/refinery/smelter
	name = "boulder smelter"
	desc = "BS for short. Accept boulders and refines metallic ores into sheets."
	icon_state = "smelter"
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 3
	light_color = "#ffaf55"
	circuit = /obj/item/circuitboard/machine/smelter
	usage_sound = 'sound/machines/mining/smelter.ogg'
	action = "smelting"

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

/obj/machinery/bouldertech/refinery/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	. = ..()
	set_light_on(TRUE)

/obj/machinery/bouldertech/refinery/default_unfasten_wrench(mob/user, obj/item/wrench, time)
	. = ..()
	set_light_on(TRUE)

/obj/machinery/bouldertech/refinery/smelter/on_set_is_operational(old_value)
	set_light_on(TRUE)

/obj/machinery/bouldertech/refinery/smelter/maim_golem(mob/living/carbon/human/rockman)
	rockman.visible_message(span_warning("[rockman] is processed by [src]!"), span_userdanger("You get melted into rock by [src]!"))
	rockman.investigate_log("was melted by [src] for being a golem", INVESTIGATE_DEATHS)
	rockman.dust()
