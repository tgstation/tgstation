
//These are shuttle areas; all subtypes are only used as teleportation markers, they have no actual function beyond that.

/area/shuttle
	name = "Shuttle"
	requires_power = 0
	luminosity = 1
	lighting_use_dynamic = DYNAMIC_LIGHTING_ENABLED
	has_gravity = 1
	always_unpowered = 0
	valid_territory = 0
	icon_state = "shuttle"

/area/shuttle/transit
	name = "Hyperspace"
	desc = "Weeeeee"

/area/shuttle/arrival
	name = "Arrival Shuttle"

/area/shuttle/pod_1
	name = "Escape Pod One"

/area/shuttle/pod_2
	name = "Escape Pod Two"

/area/shuttle/pod_3
	name = "Escape Pod Three"

/area/shuttle/pod_4
	name = "Escape Pod Four"

/area/shuttle/mining
	name = "Mining Shuttle"
	blob_allowed = FALSE

/area/shuttle/labor
	name = "Labor Camp Shuttle"
	blob_allowed = FALSE

/area/shuttle/supply
	name = "Supply Shuttle"
	blob_allowed = FALSE

/area/shuttle/escape
	name = "Emergency Shuttle"

/area/shuttle/transport
	name = "Transport Shuttle"
	blob_allowed = FALSE

/area/shuttle/syndicate
	name = "Syndicate Infiltrator"
	blob_allowed = FALSE

/area/shuttle/assault_pod
	name = "Steel Rain"
	blob_allowed = FALSE

/area/shuttle/abandoned
	name = "Abandoned Ship"
	blob_allowed = FALSE
