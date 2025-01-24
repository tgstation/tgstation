/datum/map_template/shuttle/personal_buyable/mining
	personal_shuttle_type = PERSONAL_SHIP_TYPE_MINING
	port_id = "mining"

// One of the transport ships, but retrofit for carrying cargo in a central bay

/datum/map_template/shuttle/personal_buyable/mining/small_cargo
	name = "CAS Tawsil"
	description = "A light cargo carrier retrofit from a common \
		personnel transport shuttle design. Comes with a single central \
		cargo hold, with quarters for crew as well as a unique bridge design."
	credit_cost = CARGO_CRATE_VALUE * 12
	suffix = "tawsil"
	width = 23
	height = 11
	personal_shuttle_size = PERSONAL_SHIP_MEDIUM

/area/shuttle/personally_bought/small_cargo
	name = "CAS Tawsil"

// Mining ship, meant to be a hub for deep space mech mining

/datum/map_template/shuttle/personal_buyable/mining/mech_hub
	name = "CAS Cigale"
	description = "A heavy mining vessel meant to be a hub for \
		deep space powered mining activities. Features several launch \
		and maintenance bays, as well as crew quarters."
	credit_cost = CARGO_CRATE_VALUE * 22
	suffix = "cigale"
	width = 28
	height = 16
	personal_shuttle_size = PERSONAL_SHIP_LARGE

/area/shuttle/personally_bought/mining_hub
	name = "CAS Cigale"
