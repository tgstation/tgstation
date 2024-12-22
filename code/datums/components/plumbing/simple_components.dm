
///has one pipe input that only takes, example is manual output pipe
/datum/component/plumbing/simple_demand
	demand_connects = SOUTH

///has one pipe output that only supplies. example is liquid pump and manual input pipe
/datum/component/plumbing/simple_supply
	supply_connects = SOUTH

///input and output, like a holding tank
/datum/component/plumbing/tank
	demand_connects = WEST
	supply_connects = EAST

///Lazily demand from any direction. Overlays won't look good, and the aquarium sprite occupies about the entire 32x32 area anyway.
/datum/component/plumbing/aquarium
	demand_connects = SOUTH|NORTH|EAST|WEST
	use_overlays = FALSE

///Connects different layer of ducts
/datum/component/plumbing/manifold
	demand_connects = NORTH
	supply_connects = SOUTH

/datum/component/plumbing/manifold/change_ducting_layer(obj/source, obj/changer, new_layer)
	return
