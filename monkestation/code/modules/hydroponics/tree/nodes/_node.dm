/datum/tree_node
	var/name = "Base Tree Node"
	var/desc = "Baseline tree node you shouldn't see this"
	var/ui_icon = "soap"

	///is it a major node?
	var/is_major = FALSE
	///what level does the tree need to be to appear.
	var/min_level = 1

	var/on_pulse = FALSE
	var/on_final_growth = FALSE
	var/on_levelup = FALSE

	var/visual_change
	var/visual_numerical_change

	var/color_change_leaf
	var/color_change_trunk

	var/obj/machinery/mother_tree/connected_tree

/datum/tree_node/proc/on_choice_generation()
	return

/datum/tree_node/proc/on_tree_add(obj/machinery/mother_tree/added_tree)
	connected_tree = added_tree

/datum/tree_node/proc/on_pulse(list/affected_plants, pulse_range)
	return

/datum/tree_node/proc/final_growth(obj/machinery/hydroponics/grown_location)
	return

/datum/tree_node/proc/on_levelup()
	return

/datum/tree_node/proc/get_ui_data()
	return list(
		"name" = name,
		"desc" = desc,
		"ref" = REF(src),
		"icon" = ui_icon
	)


/datum/tree_node/minor
	name = "Minor Node"
	desc = "Holder minor node you shouldn't be seeing this!"

/datum/tree_node/major
	name = "Major Node"
	desc = "Holder major node you shouldn't be seeing this!"

/datum/tree_node/major/fruit
	var/pulses_per_fruit = 3
	var/pulses = 0
	var/obj/item/created_fruit
	var/generated_fruits
	on_pulse = TRUE

/datum/tree_node/major/fruit/on_pulse(list/affected_plants, pulse_range)
	. = ..()
	if(pulses >= pulses_per_fruit)
		if(connected_tree.stored_fruits.len <= 4)
			connected_tree.stored_fruits += new created_fruit
		pulses = 0
	else
		pulses++

/obj/item/fruit
	icon = 'monkestation/icons/obj/mother_tree.dmi'


/obj/item/fruit/proc/on_hydrotray_add(obj/item/seeds/stored_seed)
	return
