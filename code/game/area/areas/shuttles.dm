
//These are shuttle areas; all subtypes are only used as teleportation markers, they have no actual function beyond that.
//Multi area shuttles are a thing now, use subtypes! ~ninjanomnom

/area/shuttle
	name = "Shuttle"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	has_gravity = STANDARD_GRAVITY
	always_unpowered = FALSE
	valid_territory = FALSE
	icon_state = "shuttle"

/area/shuttle/Initialize()
	if(!canSmoothWithAreas)
		canSmoothWithAreas = type
	. = ..()

/area/shuttle/PlaceOnTopReact(list/new_baseturfs, turf/fake_turf_type, flags)
	. = ..()
	if(length(new_baseturfs) > 1 || fake_turf_type)
		return // More complicated larger changes indicate this isn't a player
	if(ispath(new_baseturfs[1], /turf/open/floor/plating))
		new_baseturfs.Insert(1, /turf/baseturf_skipover/shuttle)

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

////////////////////////////Pirate Shuttle////////////////////////////

/area/shuttle/pirate
	name = "Pirate Shuttle"
	blob_allowed = FALSE
	requires_power = TRUE
	canSmoothWithAreas = /area/shuttle/pirate

/area/shuttle/pirate/vault
	name = "Pirate Shuttle Vault"
	requires_power = FALSE

////////////////////////////White Ship////////////////////////////

/area/shuttle/abandoned
	name = "Abandoned Ship"
	blob_allowed = FALSE
	canSmoothWithAreas = /area/shuttle/abandoned

/area/shuttle/abandoned/bridge
	name = "Abandoned Ship Bridge"
	requires_power = TRUE

/area/shuttle/abandoned/engine
	name = "Abandoned Ship Engine"
	requires_power = TRUE

/area/shuttle/abandoned/bar
	name = "Abandoned Ship Bar"
	requires_power = TRUE

/area/shuttle/abandoned/crew
	name = "Abandoned Ship Crew Quarters"
	requires_power = TRUE

/area/shuttle/abandoned/cargo
	name = "Abandoned Ship Cargo Bay"
	requires_power = TRUE

/area/shuttle/abandoned/medbay
	name = "Abandoned Ship Medbay"
	requires_power = TRUE

////////////////////////////Single-area shuttles////////////////////////////

/area/shuttle/transit
	name = "Hyperspace"
	desc = "Weeeeee"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/shuttle/custom
	name = "Custom player shuttle"

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

/area/shuttle/escape/backup
	name = "Backup Emergency Shuttle"

/area/shuttle/escape/luxury
	name = "Luxurious Emergency Shuttle"
	noteleport = TRUE

/area/shuttle/escape/arena
	name = "The Arena"
	noteleport = TRUE

/area/shuttle/escape/meteor
	name = "\proper a meteor with engines strapped to it"
	luminosity = NONE

/area/shuttle/transport
	name = "Transport Shuttle"
	blob_allowed = FALSE

/area/shuttle/assault_pod
	name = "Steel Rain"
	blob_allowed = FALSE

/area/shuttle/sbc_starfury
	name = "SBC Starfury"
	blob_allowed = FALSE

/area/shuttle/sbc_fighter1
	name = "SBC Fighter 1"
	blob_allowed = FALSE

/area/shuttle/sbc_fighter2
	name = "SBC Fighter 2"
	blob_allowed = FALSE

/area/shuttle/sbc_corvette
	name = "SBC corvette"
	blob_allowed = FALSE

/area/shuttle/syndicate_scout
	name = "Syndicate Scout"
	blob_allowed = FALSE

/area/shuttle/caravan
	blob_allowed = FALSE
	requires_power = TRUE

/area/shuttle/caravan/syndicate1
	name = "Syndicate Fighter"

/area/shuttle/caravan/syndicate2
	name = "Syndicate Fighter"

/area/shuttle/caravan/syndicate3
	name = "Syndicate Drop Ship"

/area/shuttle/caravan/pirate
	name = "Pirate Cutter"

/area/shuttle/caravan/freighter1
	name = "Small Freighter"

/area/shuttle/caravan/freighter2
	name = "Tiny Freighter"

/area/shuttle/caravan/freighter3
	name = "Tiny Freighter"