/datum/tree_node/minor/pulse_range_increase
	name = "Pulse Range Increase"
	desc = "Increases the pulse range of the tree"


/datum/tree_node/minor/pulse_speed_increase/on_tree_add(obj/machinery/mother_tree/added_tree)
	. = ..()
	added_tree.attached_component.pulse_range++
