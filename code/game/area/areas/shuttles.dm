
//These are shuttle areas; all subtypes are only used as teleportation markers, they have no actual function beyond that.
//Multi area shuttles are a thing now, use subtypes! ~ninjanomnom

/area/shuttle
	name = "Shuttle"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	has_gravity = TRUE
	always_unpowered = FALSE
	valid_territory = FALSE
	icon_state = "shuttle"
	canSmoothWithAreas = /area/shuttle

////////////////////////////Multi-area shuttles////////////////////////////

////////////////////////////Syndicate infiltrator////////////////////////////

/area/shuttle/syndicate
	name = "Syndicate Infiltrator"
	blob_allowed = FALSE
	ambientsounds = HIGHSEC
	canSmoothWithAreas = /area/shuttle/syndicate

/area/shuttle/syndicate/bridge
	name = "Syndicate Infiltrator Control"

/area/shuttle/syndicate/medical
	name = "Syndicate Infiltrator Medbay"

/area/shuttle/syndicate/armory
	name = "Syndicate Infiltrator Armory"

/area/shuttle/syndicate/eva
	name = "Syndicate Infiltrator EVA"

/area/shuttle/syndicate/hallway

/area/shuttle/syndicate/airlock
	name = "Syndicate Infiltrator Airlock"

////////////////////////////Single-area shuttles////////////////////////////

/area/shuttle/transit
	name = "Hyperspace"
	desc = "Weeeeee"
	canSmoothWithAreas = null

/area/shuttle/custom
	name = "Custom player shuttle"
	canSmoothWithAreas = /area/shuttle/custom

/area/shuttle/arrival
	name = "Arrival Shuttle"
	canSmoothWithAreas = /area/shuttle/arrival

/area/shuttle/pod_1
	name = "Escape Pod One"
	canSmoothWithAreas = /area/shuttle/pod_1

/area/shuttle/pod_2
	name = "Escape Pod Two"
	canSmoothWithAreas = /area/shuttle/pod_2

/area/shuttle/pod_3
	name = "Escape Pod Three"
	canSmoothWithAreas = /area/shuttle/pod_3

/area/shuttle/pod_4
	name = "Escape Pod Four"
	canSmoothWithAreas = /area/shuttle/pod_4

/area/shuttle/mining
	name = "Mining Shuttle"
	blob_allowed = FALSE
	canSmoothWithAreas = /area/shuttle/mining

/area/shuttle/labor
	name = "Labor Camp Shuttle"
	blob_allowed = FALSE
	canSmoothWithAreas = /area/shuttle/labor

/area/shuttle/supply
	name = "Supply Shuttle"
	blob_allowed = FALSE
	canSmoothWithAreas = /area/shuttle/supply

/area/shuttle/escape
	name = "Emergency Shuttle"
	canSmoothWithAreas = /area/shuttle/escape

/area/shuttle/escape/luxury
	name = "Luxurious Emergency Shuttle"
	noteleport = TRUE

/area/shuttle/transport
	name = "Transport Shuttle"
	blob_allowed = FALSE
	canSmoothWithAreas = /area/shuttle/transport

/area/shuttle/assault_pod
	name = "Steel Rain"
	blob_allowed = FALSE
	canSmoothWithAreas = /area/shuttle/assault_pod

/area/shuttle/abandoned
	name = "Abandoned Ship"
	blob_allowed = FALSE
	canSmoothWithAreas = /area/shuttle/abandoned

/area/shuttle/sbc_starfury
	name = "SBC Starfury"
	blob_allowed = FALSE
	canSmoothWithAreas = /area/shuttle/sbc_starfury

/area/shuttle/sbc_fighter1
	name = "SBC Fighter 1"
	blob_allowed = FALSE
	canSmoothWithAreas = /area/shuttle/sbc_fighter1

/area/shuttle/sbc_fighter2
	name = "SBC Fighter 2"
	blob_allowed = FALSE
	canSmoothWithAreas = /area/shuttle/sbc_fighter2

/area/shuttle/sbc_corvette
	name = "SBC corvette"
	blob_allowed = FALSE
	canSmoothWithAreas = /area/shuttle/sbc_corvette

/area/shuttle/syndicate_scout
	name = "Syndicate Scout"
	blob_allowed = FALSE
	canSmoothWithAreas = /area/shuttle/syndicate_scout

/area/shuttle/pirate
	name = "Pirate Shuttle"
	blob_allowed = FALSE
	requires_power = TRUE
	canSmoothWithAreas = /area/shuttle/pirate

/area/shuttle/pirate/vault
	name = "Pirate Shuttle Vault"
	requires_power = FALSE