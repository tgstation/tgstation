/datum/tree_node/minor/pulse_speed_increase
	name = "Pulse Speed Increase"
	desc = "Increases the pulse speed of the tree"


/datum/tree_node/minor/pulse_speed_increase/on_tree_add(obj/machinery/mother_tree/added_tree)
	. = ..()
	added_tree.attached_component.pulse_time -= 1 SECONDS
