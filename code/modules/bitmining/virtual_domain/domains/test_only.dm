/// Used for unit tests only. Skipped in UI.
/datum/map_template/virtual_domain/test_only
	filename = "test_only.dmm"
	id = "test_only"
	test_only = TRUE

/datum/map_template/virtual_domain/test_only/expensive
	id = "test_only_expensive"
	cost = 3

/datum/map_template/virtual_domain/test_only/mobs
	id = "test_only_mobs"
	filename = "test_only_mobs.dmm"

// Giant map of delete turfs, used to erase what's on the map.
/datum/map_template/virtual_domain/test_only/delete
	id = "test_only_delete"
	filename = "test_only_delete.dmm"
