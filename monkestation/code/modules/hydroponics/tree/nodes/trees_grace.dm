/datum/tree_node/major/trees_grace
	name = "Tree's Grace"
	desc = "Nearby plants are basked in the glow of the tree, the need for water and pest control has vanished, it still consumes nutriments though."

	on_pulse = TRUE

	visual_change = "Trunk"
	visual_numerical_change = 1
	color_change_leaf = "#00a841"
	color_change_trunk = "#744b1d"

/datum/tree_node/major/trees_grace/on_pulse(list/affected_plants, pulse_range)
	. = ..()
	for(var/obj/machinery/hydroponics/viewed_hydroponics in affected_plants)
		viewed_hydroponics.self_sustaining = TRUE
		viewed_hydroponics.visible_message("<span class='boldnotice'>[src] begins to glow with a beautiful light!</span>")
		viewed_hydroponics.update_icon()
