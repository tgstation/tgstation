/datum/tree_node/minor/random_reagent_chance
	name = "Random Chemical Creation Chance"
	desc = "Has the chance to add a random reagent to a plant."

	on_pulse = TRUE

	var/static/add_chance = 0
	var/static/first = TRUE

/datum/tree_node/minor/random_reagent_chance/on_tree_add(obj/machinery/mother_tree/added_tree)
	. = ..()
	add_chance = min(add_chance + 5, 100)
	if(!first)
		on_pulse = FALSE
	else
		first = FALSE

/datum/tree_node/minor/random_reagent_chance/on_pulse(list/affected_plants, pulse_range)
	for(var/obj/item/seeds/affected_seed in affected_plants)
		if(prob(add_chance))
			affected_seed.add_random_reagents(1,1)
