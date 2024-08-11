/datum/map_template/shuttle/cargo/nova
	name = "Supply Shuttle (Cargo)"
	prefix = "_maps/shuttles/nova/"
	port_id = "cargo"
	suffix = "nova"

/datum/map_template/shuttle/ferry/nova
	name = "NAV Monarch (Ferry)"
	prefix = "_maps/shuttles/nova/"
	port_id = "ferry"
	suffix = "nova"
	who_can_purchase = null

/datum/map_template/shuttle/emergency/nova
	name = "Standard Emergency Shuttle"
	description = "Nanotrasen's standard issue emergency shuttle."
	prefix = "_maps/shuttles/nova/"
	suffix = "nova"
	occupancy_limit = "65"

/datum/map_template/shuttle/arrival/nova
	name = "Blueshift Arrival"
	description = "Nanotrasen's standard issue arrival shuttle."
	prefix = "_maps/shuttles/nova/"
	suffix = "nova"

/datum/map_template/shuttle/labour/nova
	name = "NMC Drudge (Labour)"
	prefix = "_maps/shuttles/nova/"
	suffix = "nova"

/datum/map_template/shuttle/mining_common/nova
	name = "NMC Chimera (Mining)"
	prefix = "_maps/shuttles/nova/"
	suffix = "nova"

/datum/map_template/shuttle/mining/nova/large
	name = "NMC Manticore (Mining)"
	prefix = "_maps/shuttles/nova/"
	suffix = "nova_large"

/datum/map_template/shuttle/cargo/nova/delta
	name = "Supply Shuttle (Delta)"
	prefix = "_maps/shuttles/nova/"
	suffix = "nova_delta"	//I hate this. Delta station is one tile different docking-wise, which fucks it ALL up unless we either a) change the map (this would be nonmodular and also press the engine against disposals) or b) this (actually easy, just dumb)

/datum/map_template/shuttle/cargo/nova/ouroboros
	name = "Supply Shuttle (Ouroboros)"
	suffix = "ouroboros"

/datum/map_template/shuttle/whiteship/ouroboros
	name = "JN Chasse-Galerie"
	description = "A small Jim Nortons shuttle meant to be a mobile cafe. No hostiles onboard, but multiple corpses of Jim Nortons employees."
	prefix = "_maps/shuttles/nova/"
	port_id = "whiteship"
	suffix = "ouroboros"
