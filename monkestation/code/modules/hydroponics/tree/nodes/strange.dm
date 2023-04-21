/datum/tree_node/major/strange
	name = "Even Stranger Tree"
	desc = "The tree seems to produce fruits that have odd effects on plants."

	on_pulse = TRUE

	visual_change = "Trunk"
	visual_numerical_change = 2
	color_change_leaf = "#FFC0CB"
	color_change_trunk = "#00FFFF"


/datum/tree_node/major/strange/on_pulse(list/affected_plants, pulse_range)
	for(var/obj/item/seeds/listed_seed as anything in affected_plants)
		if(prob(50))
			listed_seed.add_random_reagents(1,1)
			listed_seed.visible_message("The light pulse from the tree seems to have mutated the [listed_seed]!", vision_distance = 5)
