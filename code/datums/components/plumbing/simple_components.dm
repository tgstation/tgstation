
///has one pipe input that only takes, example is manual output pipe
/datum/component/plumbing/simple_demand
	demand_connects = SOUTH

/datum/component/plumbing/simple_demand/Initialize(ducting_layer, distinct_reagent_cap = INFINITY)
	src.distinct_reagent_cap = distinct_reagent_cap
	return ..()

///Component for adding an extended overlay on wall mounts
/datum/component/plumbing/simple_demand/extended/create_overlays(atom/movable/parent_movable, list/overlays)
	. = ..()

	// This is a little wiggley extension to make wallmounts like sinks and showers visually link to the pipe
	if(overlays.len)
		var/image/edge_overlay = image('icons/obj/pipes_n_cables/hydrochem/connects.dmi', "edge-extension", layer = PLUMBING_PIPE_VISIBILE_LAYER + ducting_layer * 0.0003)
		edge_overlay.dir = parent_movable.dir
		edge_overlay.color = demand_color
		edge_overlay.pixel_w = -parent_movable.pixel_x - parent_movable.pixel_w
		edge_overlay.pixel_z = -parent_movable.pixel_y - parent_movable.pixel_z
		overlays += edge_overlay

///has one pipe output that only supplies. example is liquid pump and manual input pipe
/datum/component/plumbing/simple_supply
	supply_connects = SOUTH

///input and output, like a holding tank
/datum/component/plumbing/tank
	demand_connects = WEST
	supply_connects = EAST

///Lazily demand from any direction.
/datum/component/plumbing/aquarium
	demand_connects = SOUTH|NORTH|EAST|WEST

/datum/component/plumbing/aquarium/create_overlays(atom/movable/parent_movable, list/overlays)
	//Overlays won't look good, and the aquarium sprite occupies about the entire 32x32 area anyway.
	return

///Connects different layer of ducts
/datum/component/plumbing/manifold
	demand_connects = NORTH
	supply_connects = SOUTH

/datum/component/plumbing/manifold/change_ducting_layer(obj/source, obj/changer, new_layer)
	return
