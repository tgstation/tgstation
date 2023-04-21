/datum/tree_node/minor/random_stat_increase
	name = "Plant Improvement"
	desc = "Improves nearby plants on pulse."

	min_level = 3
	on_pulse = TRUE

	var/stat_to_increase

/datum/tree_node/minor/random_stat_increase/on_choice_generation()
	stat_to_increase = pick("potency", "yield", "lifespan", "maturation rate", "production speed", "endurance")
	desc = "Improves the [stat_to_increase] of nearby plants on pulse."

/datum/tree_node/minor/random_stat_increase/on_pulse(list/affected_plants, pulse_range)
	for(var/obj/item/seeds/affected_seed in affected_plants)
		switch(stat_to_increase)
			if("potency")
				affected_seed.adjust_potency(rand(1,3))
			if("yield")
				affected_seed.adjust_yield(rand(0,2))
			if("lifespan")
				affected_seed.adjust_lifespan(rand(1,2))
			if("endurance")
				affected_seed.adjust_endurance(rand(1,2))
			if("production speed")
				affected_seed.adjust_production(rand(1,3))
			if("maturation rate")
				affected_seed.adjust_maturation(rand(1,3))
