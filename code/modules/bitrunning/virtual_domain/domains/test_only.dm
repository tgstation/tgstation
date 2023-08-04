/// Used for unit tests only. Skipped in UI.
/datum/lazy_template/virtual_domain/test_only
	name = "Test Only"
	key = "test_only"
	map_name = "test_only"
	map_height = 5
	map_width = 5
	test_only = TRUE
	safehouse_path = /datum/map_template/safehouse/test_only

/datum/lazy_template/virtual_domain/test_only/expensive
	key = "test_only_expensive"
	cost = 3
