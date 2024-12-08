// General
/datum/lazy_template/nukie_base
	map_dir = "_maps/templates/lazy_templates/ss220"
	map_name = "syndie_cc"
	key = LAZY_TEMPLATE_KEY_NUKIEBASE

// Shuttles
/datum/map_template/shuttle/sit
	port_id = "sit"
	who_can_purchase = null
	prefix = "_maps/shuttles/ss220/"

/datum/map_template/shuttle/sit/basic
	suffix = "basic"
	name = "basic syndicate sit shuttle"
	description = "Base SIT shuttle, spawned by default for syndicate infiltration team to use."

/datum/map_template/shuttle/sst
	port_id = "sst"
	who_can_purchase = null
	prefix = "_maps/shuttles/ss220/"

/datum/map_template/shuttle/sst/basic
	suffix = "basic"
	name = "basic syndicate sst shuttle"
	description = "Base SST shuttle, spawned by default for syndicate strike team to use."

// Shuttles Overrides
/datum/map_template/shuttle/infiltrator/basic
	prefix = "_maps/shuttles/ss220/"

// Deathmatch
/datum/lazy_template/deathmatch/underground_thunderdome
	name = "Underground Thunderdome"
	map_dir = "_maps/deathmatch/ss220"
	map_name = "underground_arena_big"
	key = "underground_arena_big"
